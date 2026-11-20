# Round 2 log（openehr 2.5.0）

裁定 R-20261117-3 にもとづく Round 2 の作業ログ。1 ステップ 1 項目（`R` 番号）。
計画は `docs/design/round2-2.5.0-plan.md`。

## R1 — 探索と計画（2026-11-20、実装なし）

基準点: `master` `96eb4e2`、公開版 2.4.3（`gem search -r -e openehr` で確認）、Ruby 4.0.7。
open の Issue は #31 #36 #43 #48 #49 #56 #58 #59 #60、open の PR は #57 と #61（`gh -R skoba/openehr-ruby` で確認）。

実行して確認したこと（再現スクリプトはリポジトリ外の scratch。コミットしていない）:

- #48: `SELECT o/data[at0001]/events[at0006]/time/value` →
  `ExecutionError: unsupported path attribute "time" on a OpenEHR::RM::DataStructures::History::PointEvent`
- #60: 同一アーキタイプの CLUSTER 2 件（name が `First`／`Second`）の合成ツリーで、
  - RM: `items_at_path` は name なしで 2 件、name 付きで 1 件
  - SELECT・WHERE: `path segment "items[#<...ArchetypePredicate:0x..>]" matched 2 items (fan-out SELECT paths are not yet supported)`
  - CONTAINS: `CLUSTER k[<archetype_id>, 'Second']` が `[["First"], ["Second"]]` を返す（Issue に無かった 2 箇所目）
- #49 周辺: `SELECT c/archetype_details/template_id/value` → `unsupported path attribute "archetype_details"`。
  `SELECT c/name/magnitude` → `NoMethodError`（許可リストに載った名前が型に無い場合の漏れ）
- #59: `DvDateTime.new(value: '2026-09-22')` → `ArgumentError: format invalid`
- #43: eReferral.opt の埋め込み C_ARCHETYPE_ROOT は 40 件（node_id は `at0000` 35 件、`at0000.1` 5 件）。
  XML を走査して path を組むと、`[node_id]` 形は 10 通り、`[archetype_id]` 形は 35 通り
- #58: eReferral.opt で複数回埋め込まれている 7 アーキタイプは、ルート間で term の集合が同一（改名なし）。再現用 fixture にならない
- #31: 本リポジトリの OPT 4 件に `<term_bindings>` は 0 件
- PR #57: `MERGEABLE`／`CLEAN`、チェック 4 件は SUCCESS（9/20 の run）。`History.txt` に `=== Unreleased` 節を足す

他リポジトリの読み取り（書き込みなし）:

- `/home/skoba/src/anlage`（`skoba/anlage`、`main` `a376bc4`）: `docs/upstream-candidates.md` 8・18・22・24・25 項、
  `app/lib/opt/template_terms.rb`、`app/lib/opt/pathcard_extractor.rb`、`app/lib/opt/composition_builder.rb`、
  `spec/integration/jp_referral_aql_spec.rb`、`docs/demo/aql-queries.md`
- `/home/skoba/src/openehr-rails`（`skoba/openehr-rails`、作業ツリーは `dev/ruby-4.0.10` `ef6c581`、`origin/master` `97924f3`、公開版 0.8.0）:
  `lib/openehr_rails/opt/parser.rb`、`openehr-rails.gemspec`、`lib/openehr_rails/aql/executor.rb`

成果物: 計画書、`docs/backlog.md` の Round 2 magazine への「2026-11-20 見直し」追記、このログ。
`lib/`・`spec/` には触れていない（semver neutral、`History.txt` の記載なし）。ゲート承認待ち。
