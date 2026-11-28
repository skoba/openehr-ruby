# 計画書: OPT とアーキタイプの XML を STRICT で読むか(#36)

Issue #36。裁定 R-20261125-4(作業列の「STRICT の計画」)と、R-20261124-12 の「STRICT を既定にする変更は、計画のとおりゲート報告のあと」による。ゲート報告は `docs/reports/36-strict-parse-gate.md`。

これはセキュリティの議論ではない。XXE を止めているのは NOENT と DTDLOAD が無いことで(#33)、RECOVER の有無はそこに関わらない。壊れた入力をどこまで受け付けるかの判断である。

## いまの作り(読んだもの)

- `lib/openehr/parser.rb:26-30`: `SAFE_PARSE_OPTIONS` は `RECOVER | NONET | BIG_LINES`。`Nokogiri::XML::ParseOptions::DEFAULT_XML` と同じ値で、`spec/lib/openehr/parser_spec.rb:11-20` がその値と RECOVER を固定している
- `lib/openehr/parser/opt_parser.rb:77-83`(`read_document`): パスからも、`from_xml` の文字列(#74)からも、`SAFE_PARSE_OPTIONS` で読む。Nokogiri の例外を包んでいない
- `lib/openehr/parser/xml_archetype_parser.rb:31-39`(`doc`): 同じオプションで読む。`parse`(21-27 行)は、すべての `StandardError` を `ParseError` に包む
- 下流: openehr-rails master `90ffa47` の `lib/openehr_rails/opt/parser.rb:21` は、`OPTParser#parse` を上書きして、`Nokogiri::XML::Document.parse(source)` をオプション無しで呼ぶ(読み取りの越境で確かめた)。そのため、こちらの既定を変えても、openehr-rails を通る OPT(取り込み、テンプレートの登録、FHIR のプロファイル)には届かない。#74 の `from_xml` は、この上書きを要らなくするために足した入口で、openehr-rails はまだ使っていない

## 実測(2026-11-28、実行)

STRICT | NONET | BIG_LINES で、追跡しているファイルを Nokogiri で読んだ(scratch のスクリプト。リポジトリには入れていない)。

| どこ | ファイル | STRICT で読める | 読めないもの |
|---|---|---|---|
| openehr-ruby `013fa6d`(`*.opt`、`*.xml`、security_fixtures を除く) | 7 | 7 | — |
| openehr-ruby の security_fixtures(`*.xml`) | 2 | 2 | — |
| openehr-rails `90ffa47`(`*.opt`) | 10 | 8 | `spec/templates/lab_result_report_reduced.opt`、`spec/templates/problem_list.opt` |
| anlage `bae8c01`(`*.opt`) | 6 | 5 | `spec/fixtures/opt/bmi_calculation.opt` |

- 読めない 3 つは、どれも、先頭の出どころの注釈(fixture の種類を書く決まりで足したもの)に `--` があることだけが理由(libxml2: "Double hyphen within comment")。OPT の中身には誤りが無い
- この 3 つで、RECOVER で読んだ木と、注釈の `--` だけを直して STRICT で読んだ木は、要素の数も、根の要素の文字列も同じ(847・127・1407 要素)。RECOVER で失われたものは無い
- 本当に壊れた OPT を RECOVER で読むとどうなるか: `eReferral.opt` の `</children>` を 1 つ消したものを 43 か所で試すと、43 か所とも `OPTParser#parse` が `ArgumentError`(invalid archetype id form)で止まった。後ろを切ったもの(4 通り)も同じ。黙って一部だけを読んだ例は無かった。ただし、止まる理由はアーキタイプ ID の読み違いで、壊れた場所は分からない
- #33 のときの ADL のコーパス(84 件のラウンドトリップ)は、今回は回していない

## 案

### 案 A: STRICT を既定にする

- `SAFE_PARSE_OPTIONS` から RECOVER を落とす(`STRICT | NONET | BIG_LINES`)。名前はそのまま
- `OPTParser#parse` で、`Nokogiri::XML::SyntaxError` を `OpenEHR::Parser::ParseError` に包む(行と列を出す)。`XMLArchetypeParser` は、いまも包んでいる
- spec: `parser_spec.rb` の RECOVER の固定を、STRICT の固定に替える(`DEFAULT_XML` と同じ、の例は外す)。`--` の注釈の入った最小の synthetic な fixture で、`ParseError` と行の番号を Red から確かめる。リポジトリの 9 ファイルが STRICT で読めることを regression pin にする
- 先に要るもの(どれも、ほかのリポジトリのレーンの作業): openehr-rails の 2 つと anlage の 1 つの注釈の `--` を直す。openehr-rails が `from_xml` を使って上書きをやめる(そうしないと、既定を変えても届かない)
- semver: minor 以上。これまで読めた入力(注釈の `--` など)が `ParseError` になる。前例(2.6.0 の #72、仕様の外の入力を拒んだのは minor)にならうなら minor
- 得るもの: 壊れた XML が、その場所(行と列)を示す `ParseError` で止まる。いまはアーキタイプ ID の `ArgumentError` で止まることが多く、場所が分からない
- 失うもの: 中身には誤りの無いファイル(注釈の `--`)が読めなくなる。外の道具が書いた OPT に同じ癖があれば、それも読めなくなる(上の 25 ファイルでは、注釈のほかの理由で読めないものは無かった。測っていない外の OPT にも無いとは言えない)

### 案 B: STRICT を選べるようにする(既定は RECOVER のまま)

- `OPTParser.from_xml(xml, strict: true)` のような引数を足す。NOENT と DTDLOAD には決して及ばないよう、選べるのは RECOVER の有無だけにする
- #33 は「呼び出し側が安全のオプションを変えられる余地を作らない」ことを選んでいて、それと張り合う。公開 API が増える(minor)

### 案 C: 見送る(推奨)

- 実測では、RECOVER で中身を失った例も、壊れた OPT を黙って読んだ例も無い。STRICT にして読めなくなるのは、こちらで足した注釈の書き方だけ
- 代わりに、2 つのことをする(どちらも小さい):
  1. CLAUDE.md の fixture の決まりに「XML の fixture の注釈に `--` を書かない」を 1 行足す(docs のみ。ほかのリポジトリへの写しは、それぞれのレーン)
  2. 壊れた XML の場所が分かるよう、`OPTParser#parse` で、文書に `errors` があり、かつそのあとの読み取りで例外が出たときに、libxml2 のはじめの誤り(行・列・文)を `ParseError` の文に添える。RECOVER の挙動は変えない。挙動が変わるのは、例外の型と文だけで、いまも落ちる入力だけ。patch か minor かは、例外の型が `ArgumentError` から `ParseError` に変わることをどう見るかによる(ゲートで決めてほしい)
- #36 は、根拠(上の表)を書いて閉じるか、バックログに残す

## spec の見通し(どの案でも)

- 実装に進むときは、Issue を分ける(C の 2 は別の Issue。A は #36 のまま)
- 1 Issue = 1 PR。Red の出力を PR と報告に載せる
