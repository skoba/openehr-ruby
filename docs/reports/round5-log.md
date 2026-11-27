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
