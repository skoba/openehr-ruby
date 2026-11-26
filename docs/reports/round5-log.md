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
