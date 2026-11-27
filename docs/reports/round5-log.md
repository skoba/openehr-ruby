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
