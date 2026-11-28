# Round 5 作業ログ（2.6.1 のあと）

Refs R-20261126-9、R-20261126-10。作業列: 1. 次の版（#74 と #96）、2. #97（CONTAINS の OR、案 B）、3. #80、4. #36 の計画。

## R1 — 棚卸し（バンドル報告、2026-11-26）

裁定 R-20261126-9 の「次の版は、#97 を待たずに出す」による。

### `git log v2.6.1..master` の分類（12 コミット）

| コミット | 中身 | 分類 |
|---|---|---|
| `d36972d`、`fa42fa1` | `docs/reports/round4-log.md` R3（2.6.1 の公開の記録） | neutral（docs） |
| `7c18ff9`、`2dba6e2` | #73: `.github/workflows/ckm-conformance.yml` と `spec/conformance/README.md` | neutral（CI と docs。gem に入らない） |
| `848de7a`、`3e97eb0` | #74: `lib/openehr/parser/opt_parser.rb` に `OPTParser.from_xml`、spec、断片 | minor |
| `ff7b2f8`、`ab5e12d` | #96: `lib/openehr/aql/engine/path_evaluator.rb` に 1 語と注釈、spec、断片 | patch |
| `e1bb96b`、`fdbaf62` | `docs/reports/97-contains-or-gate.md`（#97 のゲート報告） | neutral（docs） |
| `3c8c831`、`11f4563` | `CLAUDE.md` の「全開の進め方」（R-20261126-4） | neutral（docs） |

`lib/` の差分は 2 ファイル（20 行の追加、4 行の削除）。`openehr.gemspec`、`Gemfile`、`Gemfile.lock` は変わっていない（`git diff --stat v2.6.1..11f4563 -- lib '*.gemspec' Gemfile Gemfile.lock`、実行）。

### semver の判定: minor（2.7.0）

- #74 は公開のクラスメソッド `OPTParser.from_xml` を足す。後方互換の機能の追加なので minor
- #96 は、失敗していた query が値を返すようになる bug の修正（patch）。minor に含まれる
- 既存のシグネチャの変更、依存の追加、`required_ruby_version` の変更は無い

### リリースの PR で行うこと

- `changelog.d/74-opt-from-xml.md` と `changelog.d/96-aql-archetype-node-id.md` を `History.txt` の `=== 2.7.0` にまとめ、断片を消す（`changelog.d/README.md` は残す）
- `lib/openehr/version.rb` を 2.7.0 にする
- 版番号を変える PR なので、マージは人間。マージがタグの承認になる（R-20261126-4 の 1）。
  タグの前に、`master` の CI、依存の公開の時刻、この判定と差分の一致を確かめる

## R2 — #97 の実装とゲート（2026-11-26）

裁定 R-20261126-10（案 B、left join）による。Issue #97 に、決定と受け入れの条件、Discourse の URL を書いた。

### 実装

| Issue | PR | head |
|---|---|---|
| #97 | #104 | `3527c3e` |

- resolution shape は (a) bug。Red（実行、master `505952d` に spec だけを足した状態）: `10 examples, 8 failures`。失敗はどれも `SemanticError: unbound variable`。
  通った 2 件は regression pin（どちらも無い親は行にならない、宣言されていない名前は SemanticError）
- Green（実行、手元）: スイート全体で `4106 examples, 0 failures, 1 pending`。RuboCop は違反なし
- 1 つの枝に複数が当たるときの行の数は、EHRbase の適合性の試験と文書で確かめた（読み取り）。
  `FROM_TEST_SUIT.MD`「Simple 'AND' and 'OR'」の問い 2 では、O1 が 2 つと O2 が 1 つの節が 2 行で、null の行は無い。
  つまり、足し算ではなく掛け算。2 × 3 で 6 行になることは、試験に無いので、`AslFromCreator.java`（枝ごとの `LEFT_OUTER_JOIN`）を読んで推論した

### ゲート: 裁定に無い判断 1 つ

- 2 つの枝が同じ変数名を宣言したとき（`(OBSERVATION o[bp] OR OBSERVATION o[temp])`）は、#97 の前と同じ和集合のままにした。既存の E7 の spec が、この形を使っている
- left join にすると、1 つの名前に 2 つの値を入れられない。両方の枝が当たる親では、片方の値が黙って消える
- ほかの選び方は、SemanticError で拒むか、left join にして後ろの枝の値を残すか。EHRbase の扱いは確かめていない
- 推奨は、和集合を残すこと。決まるまで PR #104 はマージしない。どのみち、`v2.7.0` のタグより前にはマージしない

### 挙動の変更（棚卸しの材料）

- 変数名が別々の OR で、どの行にも入る変数（`c` など）だけを選ぶ問いは、行の数が変わる。O1 と O2 が 1 つずつの親は 2 行から 1 行に、O1 が 2 つと O2 が 3 つの親は 5 行から 6 行になる
- semver は棚卸しで決める（裁定のとおり）。少なくとも minor として検討する

## R3 — 2.7.0 の公開（2026-11-26〜27）

- リリースの PR #102 は人間がマージ → master `432b409`（CI run 45802626011 success）。R-20261126-4 の 1 により、このマージをタグの承認とした
- タグの前の確認（実行）
  - `git diff --stat v2.6.1..432b409 -- lib '*.gemspec' Gemfile Gemfile.lock` は `path_evaluator.rb`、`opt_parser.rb`、`version.rb` だけ。R1 の判定（minor）と食い違いは無い
  - 実行時の依存 9 個は、どれも最新版の公開が CI run の開始（11/26 10:34 UTC）より前
- タグ `v2.7.0` → `432b409`。このセッションが打って push した
- Release run 45802985830 success。「Record sha256」の値は
  `f7bb253e80af7b3541a4062db1554187ed0db44c707651d46ad1393095a17cd6`
- artifact を空の `pkg/` に取り、手元の sha256 が上の値と一致（実行）
- `gem push` は人間。公開のあとの照合（実行）
  - `/api/v1/gems/openehr.json` は version 2.7.0、`sha` が上の値と一致
  - `https://index.rubygems.org/info/openehr` の 2.7.0 の `checksum:` も一致
- 照合のあと `pkg/openehr-2.7.0.gem` を消した。`pkg/` は空
- タグのあと PR #103（#59 の URL）をマージ → master `c87f54e`（CI run 45803386265 success）。PR #104（#97）は R2 のゲートの答えを待っている

## R4 — #104 のゲートへの回答（2026-11-27）

- 裁定 R-20261126-13: 2 つの枝が同じ変数名のときは、和集合のまま（推奨のとおり）。仕様にも EHRbase にも根拠を確かめていない、この実装の扱いであることを、変更履歴と spec の注釈に書く
- 訂正: R3 の最後の行の「PR #104 は R2 のゲートの答えを待っている」は、書いた時点で事実と違っていた。#104 は head `3527c3e` のまま 11/27 01:44 UTC に人間のアカウントでマージされていた（master `4a5c18d`、#97 は閉じた）。R3 を書く前に PR の状態を確かめていなかった
- そのため、注釈は別の PR で足した（`changelog.d/97-aql-contains-or-left-join.md`、`contains_resolver.rb` の注釈、spec の注釈。挙動は変えない）

## R5 — #108 と、2.8.0 の棚卸し（2026-11-27）

裁定 R-20261126-13 の「直ったら、その時点の中身で次の版に進む」による。

### #108（DvDateTime#magnitude のオフセットの向き）

- 下流の報告（openehr-rails master `5e95adc` の `docs/design/63-datetime-precision-plan.md` 4 節）は、読んだだけで、書き込みはしていない
- このリポジトリで再現した（実行、master `88fa24e`）。正のオフセットは逆向きに足される。負のオフセットは、時は正しく、分が逆になる。`-00:30` は、符号を失ったうえで、たまたま合う
- Issue #108 → PR #109（head `87d0b1f`）→ master `f2333aa`（CI run 45927209073 success）。resolution shape は (a) bug。
  Red（実行）: `10 examples, 6 failures`。通った 4 件は、もともと正しかった `-05:00`、たまたま合う `-00:30`、regression pin 2 件
- **ゲート（直していない）**: `DvTime#magnitude`、`ISO8601Time#<=>`、`ISO8601DateTime#<=>` は、オフセットを見ずに地方時の欄で比べる（実行: `10:00:00+09:00 <=> 02:00:00Z` がどれも `1`）。
  DV_TIME は日付を持たないので、UTC にそろえると日をまたぐ。RM の DV_TIME.magnitude の定義もオフセットに触れていない。扱いを決めてほしい

### `git log v2.7.0..master` の分類（10 コミット）

| コミット | 中身 | 分類 |
|---|---|---|
| `252c7fd`、`c87f54e` | #59: `assumed_library_types.rb` の注釈に URL、`docs/backlog.md`、断片 | patch（注釈だけだが `lib/`） |
| `3527c3e`、`4a5c18d` | #97: `contains_resolver.rb` の OR を left join に、spec、断片 | minor（下の理由） |
| `de85d4a`、`88fa24e` | `docs/reports/round5-log.md` R3 | neutral（docs） |
| `da27b69`、`659bf0b` | #97 の注釈（同じ変数名は、この実装の扱い）、R4 | patch（注釈だけだが `lib/`） |
| `87d0b1f`、`f2333aa` | #108: `date_time.rb` の `magnitude`、spec、断片 | patch |

`lib/` の差分は 3 ファイル（68 行の追加、16 行の削除）。`openehr.gemspec`、`Gemfile`、`Gemfile.lock` は変わっていない（`git diff --stat v2.7.0..f2333aa -- lib '*.gemspec' Gemfile Gemfile.lock`、実行）。

### semver の判定: minor（2.8.0）

- #97 は、エラーになっていた OR の問いを使えるようにする。あわせて、両方の枝が当たる親で、どの行にも入る変数だけを選ぶ問い（`SELECT c` など）の行の数が変わる（1 と 1 で 2 行から 1 行、2 と 3 で 5 行から 6 行）
- 動いていた問いの結果が変わるので、patch にはしない。major にもしない。前例は 2.6.0 で、#72（受けていた入力を拒む）と #70（例外のクラスが変わる）は、挙動の変更として minor に入れた。変更履歴に「Behaviour change」として書く
- #108 と注釈 2 件は patch で、minor に含まれる
- シグネチャの変更、公開のメソッドの追加、依存の追加、`required_ruby_version` の変更は無い

### リリースの PR で行うこと

- 断片 3 つ（`59-…`、`97-…`、`108-…`）を `History.txt` の `=== 2.8.0` にまとめ、断片を消す。#97 の断片の「Semver」の行は、この判定に置き換える
- `lib/openehr/version.rb` を 2.8.0 にする
- 版番号を変える PR なので、マージは人間。マージがタグの承認になる（R-20261126-4 の 1）

## R6 — 2.8.0 の公開(2026-11-27)

Refs R-20261127-3。

- リリースの PR #111 は人間がマージ → master `d371b30`(CI run 45936303837 success)。R-20261126-4 の 1 により、このマージをタグの承認とした
- タグの前の確認(実行)
  - `git diff --stat v2.7.0..d371b30 -- lib '*.gemspec' Gemfile Gemfile.lock` は `contains_resolver.rb`、`assumed_library_types.rb`(注釈)、`date_time.rb`、`version.rb` だけ。R5 の判定(minor)と食い違いは無い
  - 実行時の依存 9 個は、どれも最新版の公開が CI run の開始(11/27 03:48 UTC)より前
- タグ `v2.8.0` → `d371b30`。このセッションが打って push した
- Release run 45936540127 success。「Record sha256」の値は
  `e7aacd8854d32be0ff1f5bbf8482a009a80ee76522c9f3910cd5a5be15ba1081`
- artifact を空の `pkg/` に取り、手元の sha256 が上の値と一致(実行)
- `gem push` は人間。公開のあとの照合(実行)
  - `/api/v1/gems/openehr.json` は version 2.8.0、`sha` が上の値と一致
  - `https://index.rubygems.org/info/openehr` の 2.8.0 の `checksum:` も一致
- 照合のあと `pkg/openehr-2.8.0.gem` を消した。`pkg/` は空
- タグのあとの PR: #114(#112、ISO8601DateTime#<=> を UTC にそろえる)と #115(#113、DvTime・ISO8601Time は書かれた時刻のまま)。どちらも head の CI は green。セッションのマージは権限で止められたので、人間のマージを待つ

## R7 — 棚卸し(バンドル報告、2026-11-27)

裁定 R-20261127-7 の「#119 が master に入ったら、その時点の中身で棚卸しに進む」による。対象は master `76cad6f`(CI run 45950299501 success)。

### `git log v2.8.0..76cad6f` の分類(マージを除く 6 コミット)

| コミット | 中身 | 分類 |
|---|---|---|
| `cdd8a8c` | #112: `ISO8601DateTime#<=>` を UTC にそろえる。オフセットを計る処理を `ISO8601DateTimeModule` に移す | patch(順序の bug の修正) |
| `0b01754` | #113: DvTime と ISO8601Time の注釈、regression pin、`docs/backlog.md` | patch(`lib/` は注釈だけ) |
| `ded1c56` | `docs/reports/round5-log.md` R6(2.8.0 の公開の記録) | neutral(docs) |
| `5c48b60` | #117: `DvDateTime#magnitude` を 0001-01-01T00:00:00Z からの暦の秒にする | minor(下を見よ) |
| `970567a` | `docs/design/temporal-ordering-plan.md`、`docs/backlog.md` | neutral(docs) |
| `f8204fa` | #121: `ISO8601Time#as_string` がオフセットを落とさない | patch |

`lib/` の差分は 2 ファイル(41 行の追加、22 行の削除)。`openehr.gemspec`、`Gemfile`、`Gemfile.lock` は変わっていない(`git diff --stat v2.8.0..76cad6f -- lib '*.gemspec' Gemfile Gemfile.lock`、実行)。

### semver の判定: minor(2.9.0)

- #117 は、公開のメソッド `DvDateTime#magnitude` の返す数を、どの値でも変える(`2009-09-29T15:03:22.3Z` は 63423697018.3 から 63389833402.3)。
  RM の定義に合わせる bug の修正で、シグネチャは変わらない。ただ、magnitude の数をそのまま保存したり比べたりしている呼び出し側には、違う数が見える。
  そのため patch にはしない。前例は 2.8.0 の #97 と 2.6.0 の #72・#70 で、挙動を変える修正は minor にした
- major も考えた。数が変わるのは、仕様と違っていた値を仕様のとおりに直したためで、メソッドを消したり、引数を変えたりはしていない。前例にならって minor とする
- #112、#113、#121 は patch で、minor に含まれる
- 依存の追加、`required_ruby_version` の変更は無い

### 版に入らないもの

- #120(順序の計算を 1 か所に)と DvDate の起点(R-20261127-7)、#118(diff が落ちる件)は、まだ実装していない。間に合わなければ次の版(裁定のとおり)

### リリースの PR で行うこと

- 断片 4 つ(`112-…`、`113-…`、`117-…`、`121-…`)を `History.txt` の `=== 2.9.0` にまとめ、断片を消す。#117 の断片の「Semver」の行は、この判定に置き換える
- `lib/openehr/version.rb` を 2.9.0 にする
- 版番号を変える PR なので、マージは人間。マージがタグの承認になる(R-20261126-4 の 1)

## R8 — 棚卸しの補い(2026-11-27)

Refs R-20261127-7。

- 人間が #124、#127、#128、#129、#125 をマージした。master に入った順は #124 → #127 → #128 → #129 → #125(`git log --first-parent`、実行)
- リリースの PR #125 は、#127〜#129 が入る前の master から作ったので、リリースのマージのコミット `8a2da02` には、
  #120・#126・#118 のコードが入っている。一方、`History.txt` の `=== 2.9.0` にはこの 3 つが無く、`changelog.d/` に断片が 3 つ残っている
- このままだと、タグの前の確かめの「棚卸しの判定と、タグに入る中身が一致する」と「タグの時点で断片が残っていない」を満たさない。そのため `8a2da02` にはタグを打たない
- 追加の 3 コミットの分類

| コミット | 中身 | 分類 |
|---|---|---|
| #127(#120) | ISO8601DateTime・ISO8601Date・DvDateTime・DvDate の順序を 1 つの暦の計算に。DvDate の部分的な値が落ちない | minor(順序の結果が変わる) |
| #128(#126) | DvDate#magnitude を 0001-01-01 からの日数に(Integer) | minor(公開の数が変わる) |
| #129(#118) | DvDateTime#diff の日の借り方 | patch |

- semver は minor のまま(2.9.0)。R7 の判定と食い違わない。版番号を変える必要は無い
- この PR で、3 つの断片を `=== 2.9.0` にまとめて消し、版の冒頭の文を書き直す。この PR のマージのコミットにタグを打つ

## R9 — 2.9.0 の公開(2026-11-27)

Refs R-20261127-7。

- 人間が補いの PR #130 をマージ → master `4289afb`(CI run 45968583543 success)。R-20261126-4 の 1 により、このマージをタグの承認とした(R8 のとおり、`8a2da02` にはタグを打っていない)
- タグの前の確認(実行)
  - `changelog.d/` に断片は残っていない(`README.md` だけ)
  - `git diff --stat v2.8.0..4289afb -- lib '*.gemspec' Gemfile Gemfile.lock` は `assumed_library_types.rb`、`date_time.rb`、`version.rb` だけ。R7 と R8 の判定(minor)と食い違いは無い
  - 実行時の依存 9 個は、どれも最新版の公開が CI run の開始(11/27 08:48 UTC)より前
- タグ `v2.9.0` → `4289afb`。このセッションが打って push した
- Release run 45968836141 success。「Record sha256」の値は
  `dc0aea00c264277f6beb2b4748d5d2f1c924332f2134e3f732fe18995fe35a08`
- artifact を空の `pkg/` に取り、手元の sha256 が上の値と一致(実行)
- `gem push` は人間。公開のあとの照合(実行)
  - `/api/v1/gems/openehr.json` は version 2.9.0、`sha` が上の値と一致
  - `https://index.rubygems.org/info/openehr` の 2.9.0 の `checksum:` も一致
- 照合のあと `pkg/openehr-2.9.0.gem` を消した。`pkg/` は空

## R10 — 2.10.0 の棚卸し(やり直し。バンドル報告、2026-11-28)

R-20261128-11 による。最初の棚卸し(PR #153、master `013fa6d` で判定)は、R-20261128-10 で止め、
日時の比べ方の直し(#161、#135)と #141 が master に入ったので、閉じた(理由は PR #153 に書いた)。
対象は master `22292d2`(CI run 46114414367 success)。

### `git log v2.9.0..22292d2` の分類(マージを除く 19 コミット)

| コミット | 中身 | 分類 |
|---|---|---|
| `2f78264` | round5-log R9(2.9.0 の公開の記録) | neutral(docs) |
| `42a7a46` | #80 の計画書 | neutral(docs) |
| `85ac6a7` | #80: ISO8601Date・ISO8601DateTime がコンパクト形式を読む。`is_extended?` が与えられた形を返す | minor(受け付ける入力が増える。`is_extended?` の値が変わる) |
| `249a571` | #134 の計画書 | neutral(docs) |
| `23caef5` | #134: AQL で、日付・日時のパスを ISO 8601 のリテラルと比べる(時点で。未公開のまま #161 で直した) | minor(`NoMethodError` だった問い合わせが行を返す) |
| `08f57ba` | #136: ISO8601Time が、2 つの形を混ぜた時刻を拒む | patch(仕様の外の入力を拒む。Upgrade note あり) |
| `1b0fad9` | #137: 時だけの UTC からのずれ(`±hh`)を読む | minor(受け付ける入力が増える) |
| `d39eee9` | #138: `as_string` がオフセットを extended の形で書く | patch(出力の形が変わる。仕様に合わせる) |
| `2317dea` | #135 の計画とゲート報告(最初の版) | neutral(docs) |
| `13d9b1b` | #145: `README.ja.rdoc` と、`README.rdoc` の先頭の案内 | patch(`README.rdoc` は gem に入る) |
| `eff8f67` | #147: `README.ja.rdoc` の 2 語 | neutral(gem に入らない) |
| `ce27d71` | #148: CLAUDE.md、差分の削除を見る決まり | neutral(docs) |
| `5639372` | #151: ORDER BY … DESC で値の無い行を最後に | patch(bug の修正) |
| `39825a3` | #141: `valid_iso8601_time?` が負のオフセットを受け付ける | patch(bug の修正) |
| `17455bc` | #36 の計画とゲート報告(案 C、見送り) | neutral(docs) |
| `66ef829` | #157: CLAUDE.md の fixture の決まりと、XML の fixture が整形式である spec | neutral(docs と spec) |
| `35e4e5e` | #135 の計画の書き直し(R-20261128-11) | neutral(docs) |
| `c6b5d25` | #161: AQL の日時の比べ方を、書かれた成分に(`AQL::TemporalComparison`)。#134 の断片を最後の挙動に | minor(#134 と合わせて。未公開の挙動の直し) |
| `827951b` | #135: `…/value` も同じ比べ方と並べ方に。README(英語と日本語)に比べ方 | minor(いまの問い合わせの結果が変わる) |

`git diff --stat v2.9.0..22292d2 -- lib '*.gemspec' Gemfile Gemfile.lock README.rdoc`(実行)で変わったのは、次の 7 つ(追加 333 行、削除 26 行)。
`openehr.gemspec`、`Gemfile`、`Gemfile.lock` は変わっていない。

- `README.rdoc`
- `lib/openehr/aql/engine.rb`
- `lib/openehr/aql/engine/path_evaluator.rb`
- `lib/openehr/aql/engine/predicate_evaluator.rb`
- `lib/openehr/aql/engine/temporal_comparison.rb`(新しいファイル)
- `lib/openehr/assumed_library_types.rb`
- `lib/openehr/rm/data_types/quantity/date_time.rb`

### semver の判定: minor(2.10.0)

- 受け付ける入力と、AQL の答えが増える(#80、#137、#134/#161)。シグネチャは変わらない
- いまの問い合わせの結果が変わるもの(#135 の `…/value`)と、挙動を変える修正(#136、#138、#151、#80 の `is_extended?`)は、前例
  (2.6.0 の #72・#70、2.8.0 の #97、2.9.0 の #117)にならって minor に含めた。メソッドを消すことも、引数を変えることもしていない
- major も考えた。#135 は、`…/value` の比較の結果を黙って変える。ただ、変わるのは時刻帯か精度がそろっていない値だけで、
  そろっていれば結果は同じ(計画書の表)。変わる形は、Upgrade note と README に書いた。#136 は、仕様に無い形を拒むので、
  2.6.0 の #72 と同じ扱いにした
- 依存の追加、`required_ruby_version` と `files` の変更は無い
- 断片の semver の行で「棚卸しで決める」としていたもの(#134、#135、#136、#137、#138、#151)は、この判定で決める。
  #161 は、裁定のとおり #134 の断片に合わせて書いた(断片は 1 つ)

### 版に入らないもの

- #159(PR #160、OPTParser の誤りの場所)は、裁定に無い判断を足したのでゲートにしてある。マージされていない
- #156(AQL で `c/category` が引けない)は、Issue だけ

### リリースの PR で行うこと

- 断片 9 つを `History.txt` の `=== 2.10.0` にまとめ、断片を消す。版の冒頭の文を足す。断片の「Semver」の行は写さない
- `lib/openehr/version.rb` を 2.10.0 にする
- 版番号を変える PR なので、マージは人間。マージがタグの承認になる(R-20261126-4 の 1)
- マージの前に、`22292d2` のあとに master に入った PR が無いかを見る。入っていれば、R8 と同じく補う
