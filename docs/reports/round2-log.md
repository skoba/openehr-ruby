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

## R2 — 実装 6 件（2026-11-22〜11-24）

裁定 R-20261120-1・R-20261122-1・R-20261124-9。1 Issue = 1 PR。Red を確認した spec の見出しは各 PR の本文にある。
マージは #62・#63・#64・#66 が人間、#67・#68 がセッション（R-20261124-8 の 3）。master の CI run は push イベントのもの。

| Issue | PR | 形 | master のコミット | master の CI run |
|---|---|---|---|---|
| #60 name 述語の値欠落 | #62 | (a) bug | `0ef5b33` | 45013196084 success |
| #31 OPT の term_bindings | #63 | (b) enhancement | `c21af74` | 45370055797 success |
| #43 埋め込みルートの path | #64 | (a) bug | `ec07936` | 45371800249 success |
| #48 EVENT.time | #66 | (a) bug | `d5e3a90` | 45372843942 success |
| #58 ルートごとの term_definitions | #67 | (b) enhancement | `d7daa00` | 45387378269 success |
| #49 defining_code / code_string | #68 | (b) enhancement（最小形） | `4eab04a` | 45388016332 success |

先に入ったもの: PR #61（Ruby 4.0.10、`978e8ed`）、PR #57（#56 の CKM コーパス、`a993531`）。

計画書からの差分（実行して確認）:

- **#58 の衝突スイープの訂正。** 計画書 3.5 節は「AM のノードが ivar 総なめの経路を通ることは無い見込み」としたが、通る。
  `OPTSerializer#context`／`#content` が制約の木を `JSONSerializer`（`rm_json_serializer.rb:97` で `RMJSONSerializer` の別名）に渡す。
  最初の実装では新 fixture の `#content` が 14250 → 16677 バイトに増えた。`CArchetypeRoot` に限った除外
  （`ARCHETYPE_ROOT_IVARS`）で 14250 バイトに戻し、regression pin の spec を足した。
  全体の `EXCLUDED_IVARS` に足さなかったのは、`ArchetypeOntology` が同名の ivar を持つため（`ontology.rb:8,11`）
- **#60 の制約。** name にアポストロフィを含むと `OpenEHR::Path::InvalidPathError`。node 述語にも元からある。#65 として起票（2.5.0 の外）
- **#43 の AC。** 実装の前に `[archetype_id]` へ書き換え、10 通り／35 通りの実測を Issue に残した

fixture の読み取り越境（書き込みなし）:

- `skoba/openehr-rails` `spec/generators/templates/bmi_calculation.opt` → `bmi_term_bindings_reduced.opt`（#31）
- `skoba/anlage` `spec/fixtures/opt/jp_referral.opt`（`a376bc4`）→ `jp_referral_repeated_roots_reduced.opt`（#58）

例外:

- 週次 workflow「CKM corpus conformance」が 11/23 の定期実行で失敗（run 45171501557、master `a041bf9`）。
  spec より前の「Assemble CKM_CORPUS_DIR」で、`cp` が同名の ADL の重複で止まっている。2.5.0 の合否には含めない。未対処

## R3 — 棚卸し（バンドル報告、2026-11-24）

基準点: 前のタグ `v2.4.3`（`1f9fba3`）、master `4eab04a`。手元の全 suite は 4019 examples、0 failures、1 pending
（Ruby 4.0.10）。pending 1 件は `CKM_CORPUS_DIR` が無いと動かない conformance spec と推定（どの spec かは未確認）。

### `git log v2.4.3..master` の分類（15 コミット）

gem に入るのは `lib/*` と `README.rdoc` だけ（`openehr.gemspec:19-20`）。

| コミット | 触ったもの | 分類 |
|---|---|---|
| `4eab04a` #49 | `lib/openehr/aql/engine/path_evaluator.rb` | minor（届く path が増える） |
| `d7daa00` #58 | `lib/`（`constraint_model.rb`、`opt_parser.rb`、`xml_constraint_parsing.rb`、`rm_json_serializer.rb`） | minor（公開リーダー／ライターの追加） |
| `d5e3a90` #48 | `lib/openehr/aql/engine/path_evaluator.rb` | patch（bug） |
| `ec07936` #43 | `lib/openehr/parser/xml_constraint_parsing.rb` | patch（bug。ただし出力値が変わる。下記） |
| `c21af74` #31 | `lib/openehr/parser/opt_parser.rb` | minor（これまで nil だった値が入る） |
| `0ef5b33` #60 | `lib/openehr/aql/`（3 ファイル） | patch（bug。CONTAINS の行数が減る場合がある） |
| `a02fa1d` | `.ruby-version`、`README.rdoc`（開発に使った Ruby の版の記述 1 行） | patch（gem に入るファイルに触る。実行時の挙動は変わらない） |
| `a993531` #56 | `.github/workflows/`、`spec/conformance/`、`docs/`、`History.txt` | neutral |
| `978e8ed` | `.ruby-version` | neutral |
| `a041bf9`・`b2e54ff`・`33b7296`・`f9509c7`・`96eb4e2`・`84714fc` | `CLAUDE.md`、`docs/` | neutral |

`lib/` の差分は 7 ファイル、108 行追加、5 行削除。`openehr.gemspec` と `Gemfile` は変わっていない（依存、`required_ruby_version`、`files` は同じ）。

### semver の判定: minor（2.5.0）

- 公開 API が増える（`CArchetypeRoot#term_definitions`／`#term_bindings`、`ArchetypeTerminology#term_bindings` に値が入る、
  AQL で届く path が 3 種増える）。削除と、シグネチャの変更は無い
- **major にしない理由。** #43 は埋め込みルートの `.path` の値を変える（`...items` → `...items[archetype_id]`）。
  これまでの値は兄弟のルートを区別できず、RM のデータ path とも AQL とも合わない誤りだったので、bug の修正として扱う
  （裁定 R-20261120-1 の D1 で、挙動の変更として History に書く条件つきで承認）。
  これまでの値に依存したコードは壊れる。History の該当項目は「Behaviour change」で始まる
- 指示された版（2.5.0）と実内容の判定は一致する

### 既知の不一致（2.5.0 では直さない）

- `README.rdoc:11` は「Developed with CRuby 4.0.7」のまま。`.ruby-version` は 4.0.10

### 下流からの問いへの回答（R-20261124-9）

1. **（anlage）同じ path に同じアーキタイプが複数回埋め込まれたとき、`CArchetypeRoot#term_definitions` はルートごとに別の値を返すか。**
   返す（実行: `opt_per_root_terminology_spec.rb` の「keeps the two roots apart even though they sit at one and the same path」）。
   値はルートのオブジェクトが持ち、path やアーキタイプ ID では引かない。2 つのルートは `.path` では区別できないので、
   取り出す側は定義の木をたどった順序に頼る。`component_terminologies[archetype_id]` は従来どおり後勝ち
2. **（openehr-rails）`OPTParser` が入れる `term_bindings` は、`parse` を上書きした経路でも入るか。** 入る。
   - 読み取り（`skoba/openehr-rails` master `3f67787`、`lib/openehr_rails/opt/parser.rb:14-39`）: 上書きした `parse` は `definition` を呼ぶ。
     `definition` → `c_archetype_root` → `component_terminologies` → `archetype_terminology` → `opt_term_bindings` はすべて親クラスのもので、
     上書きされていない
   - 実行（このリポジトリの中で、同じ形の上書きをしたサブクラスを scratch で作り、`populate_term_bindings!` を抜いて実行）:
     `bmi_term_bindings_reduced.opt` で SNOMED-CT と LOINC の束縛が入り、束縛の無いアーキタイプは `nil`
   - openehr-rails の中での実行はしていない。迂回との違いが 2 点ある（読み取りによる）。
     (a) 迂回は `terminology_id` が空のとき `term_bindings` の `terminology` 属性で補うが、上流は補わない。
     (b) 迂回は OPT 全体からアーキタイプ ID ごとに束ねるが、上流は後勝ち（最後のルートの束縛だけ）。
     同じアーキタイプのルート間で束縛が違う OPT では結果が変わりうる
3. **（openehr-rails）Issue #36 への記録。** 済み（`issuecomment-7130601375`）

## R4 — 2.5.0 の公開（2026-11-24）

裁定 R-20261124-9 の作業列 2・3。

- リリースの PR #69 → master `12d7518`（「Release 2.5.0」。人間がマージ）。master の CI run 45390579974 success
- タグ `v2.5.0`（注釈つき）→ `12d7518`。人間の指示でセッションが打って push した
- Release run 45390903643 success（RuboCop、RSpec の Ruby 3.3・3.4・4.0、gem のビルド）
- sha256 の照合（3 つとも一致）: `8eb126bfda72a16aeb608f2fba9e4259aca95800196e0b21136d9eb3ed42f10b`
  - Release run の「Record sha256」の値
  - `pkg/` にダウンロードした artifact（`gh -R skoba/openehr-ruby run download 45390903643 -n gem -D pkg`）
  - 公開後の RubyGems（`/api/v1/gems/openehr.json` の `sha` と、compact index の `checksum:`。`created_at` は 2026-11-24T12:18:23Z）
- `gem push` は人間。公開の確認のあと `pkg/openehr-2.5.0.gem` を削除し、`pkg/` は空
