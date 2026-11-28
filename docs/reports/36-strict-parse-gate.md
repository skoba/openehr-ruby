# ゲート報告: OPT とアーキタイプの XML を STRICT で読むか(#36)

Issue #36。計画書: `docs/design/36-strict-parse-plan.md`。STRICT を既定にするのは挙動の変更なので、計画を出したところで止まる(R-20261124-12、R-20261125-4)。

## 決めてほしいこと

1. 案 A(STRICT を既定)、案 B(選べる)、案 C(見送る。推奨)のどれにするか
2. 案 C なら、次の 2 つを進めてよいか
   - CLAUDE.md の fixture の決まりに「XML の fixture の注釈に `--` を書かない」を足す(docs のみ)
   - `OPTParser#parse` が落ちるとき、libxml2 のはじめの誤りの場所を `ParseError` の文に添える(RECOVER の挙動は変えない)。例外の型が `ArgumentError` から `ParseError` に変わるのを、patch と見るか minor と見るか
3. 案 A なら、ほかのリポジトリの前作業(注釈の `--` を 3 つ直す。openehr-rails が `from_xml` を使う)を、どのレーンに出すか

## 実測の要点(実行、2026-11-28)

- STRICT で読めないのは、追跡している 25 ファイルのうち 3 つ(openehr-rails 2、anlage 1)。3 つとも、出どころの注釈の `--` だけが理由
- その 3 つで、RECOVER で読んだ木は、注釈を直して STRICT で読んだ木と同じ。中身は失われていない
- 壊れた OPT(閉じタグを 1 つ消す 43 か所、後ろを切る 4 通り)は、RECOVER でも全部 `ArgumentError` で止まった。黙って読んだ例は無い。ただし、壊れた場所は分からない
- openehr-rails の `Opt::Parser#parse` は、自前でオプション無しの Nokogiri を呼ぶ。こちらの既定を変えても、そこには届かない

## 読んだだけのもの

- openehr-rails `90ffa47` と anlage `bae8c01` のファイルは、読み取りの越境で読んだ(書いていない)
