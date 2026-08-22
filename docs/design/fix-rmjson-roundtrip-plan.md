# Plan: RMJSONSerializer ⇔ create_from_json roundtrip (openehr-ruby upstream sprint #32)

**Status: DRAFT — 4論点の裁定と plan 承認待ち**

## Context

`OpenEHR::Serializer::RMJSONSerializer` は対象オブジェクトの全 instance variable を
reflection で機械的にシリアライズする汎用 walker である。一部の RM クラスは
`value=` セッター内で、canonical JSON には属さない派生キャッシュ ivar を追加で
保持しており、そのうち Hash 値（`_type` 付き）のものを `create_from_json` に
そのまま読み戻すと、対応する `<Type>Factory` クラスが存在せず `NameError` で
クラッシュする。Issue の報告は `DvDateTime.timezone` の一例だが、**今回の探索で
第2の独立した発生源（`UIDBasedID`/`HierObjectID`/`ObjectVersionID` の
`root`/`oid`/`creating_system_id`/`version_tree_id`）を実測で新規に確認した** —
「timezone は氷山の一角か」という Issue の問いには **Yes** と回答できる。

Issue: [skoba/openehr-ruby#32](https://github.com/skoba/openehr-ruby/issues/32)

## Step 1 実測結果（file:line・実行結果ベース）

### 1. 影響 ivar の悉皆（DvTemporal 系列 + 新規発見の UID 系列）

`lib/openehr/rm/data_types/quantity/date_time.rb` の `value=` 系セッターを
全て直接インスタンス化して ivar を実測（`lib/openehr/assumed_library_types.rb`
の `ISO8601*Module` も併読）:

| クラス | 派生 ivar | 型 | 分類 |
|---|---|---|---|
| `DvDate`（:51-57） | `@year, @month, @day` | Integer | (b) スカラー派生キャッシュ |
| `DvTime`（:129-137） | `@hour, @minute, @second, @fractional_second` | Integer/Float | (b) スカラー派生キャッシュ |
| `DvTime`（:136） | `@timezone` | **String**（実測: `"+02:00"`） | (b) スカラー派生キャッシュ |
| `DvDateTime`（:213-224） | `@year, @month, @day, @hour, @minute, @second, @fractional_second` | Integer/Float | (b) スカラー派生キャッシュ |
| `DvDateTime`（:223） | `@timezone` | **`Timezone` オブジェクト**（実測） | **(b') Hash値派生キャッシュ = クラッシュ源** |
| `DvDuration`（:341-354） | `@years, @months, @weeks, @days, @hours, @minutes, @seconds, @negative` | Integer/Boolean | (b) スカラー派生キャッシュ |

**`@timezone` の型がクラスによって異なる理由（file:line 確認済み）**: `DvTime#value=`
（date_time.rb:136）は `@timezone = iso8601_time.timezone` と**直接 ivar 代入**しており、
右辺の `iso8601_time.timezone` は `ISO8601TimeModule#timezone`
（assumed_library_types.rb:375-377, `@timezone.to_s` を返す**文字列化ゲッター**）を
呼ぶだけ。一方 `DvDateTime#value=`（date_time.rb:223）は `self.timezone = ...` と
**セッターメソッド経由**で代入しており、`ISO8601TimeModule#timezone=`
（assumed_library_types.rb:367-373, `@timezone = Timezone.new(timezone)`）が
文字列を `Timezone` オブジェクトへラップする。同じ `ISO8601TimeModule` を
include していながら、代入経路（直接 ivar 代入 vs セッター経由）の違いだけで
型が変わる — 偶然の非対称であり、設計意図ではないと考えられる。

**新規発見: `UIDBasedID`/`ObjectVersionID`（`lib/openehr/rm/support/identification.rb`）**

- `UIDBasedID#value=`（:224-233）: `value` を `"root::extension"` 形式でパースし、
  `@root = UID.new(value: ...)`（**Hash値派生キャッシュ**）と `@extension`（String）を
  保持。`HierObjectID < UIDBasedID`（:331-333、override なし）も同じ挙動を継承。
- `ObjectVersionID#value=`（:247-257）: `"oid::system::version"` 形式をパースし、
  `@oid`（UID オブジェクト）、`@creating_system_id`（UID オブジェクト）、
  `@version_tree_id`（`VersionTreeID` オブジェクト）を保持。`@root = @oid`
  （:252、`@oid` と同一オブジェクト参照）。

**実測で再現確認**（tmp スクリプト、非コミット）:

```ruby
hier = OpenEHR::RM::Support::Identification::HierObjectID.new(value: "8849...")
json = OpenEHR::Serializer::RMJSONSerializer.new(hier).serialize
# => {"_type":"HIER_OBJECT_ID","value":"8849...","root":{"_type":"UID","value":"8849..."},"extension":""}
OpenEHR::RM::Factory.create(parsed[:_type], **OpenEHR::RM::Factory.params(parsed))
# => NameError: uninitialized constant OpenEHR::RM::Factory::UidFactory
```

`lib/openehr/rm/factory.rb` 全611行を確認したが、**`UidFactory` /
`VersionTreeIdFactory` は存在しない** — `TimezoneFactory` 不在と全く同型の欠落。
`Composition#uid` は openEHR RM 上 `UID_BASED_ID`（`ObjectVersionID` または
`HierObjectID` が典型）であり、実運用の Composition では高頻度で使われる属性 —
`spec/fixtures/health_summary_composition.json` に `uid` フィールドが**1件も
存在しない**ため、gem 自身のテストコーパスがこの経路を一度も通っていない
（`grep -c '"uid"' spec/fixtures/health_summary_composition.json` → 0）。

**副次的発見（#32 のスコープ外、要記録のみ）**: `ObjectVersionID` の `@oid` と
`@root` は同一オブジェクト参照（:252 `@root = @oid`）。`RMJSONSerializer#object_value`
の `seen` ガード（rm_json_serializer.rb:39, `return nil if seen.include?(value)`）は
`@parent` 循環参照を防ぐためのものだが、**循環ではない単なるエイリアシング**
（同一オブジェクトを指す2つの異なる ivar 名）も誤って「既出」と判定し、2回目の
出現を `nil` にしてしまう。実測: `ObjectVersionID` のシリアライズ結果は
`"oid":{...}, "root":null`（`root` が消失）。これはクラッシュではなく**サイレントな
データ損失**であり、#32（クラッシュ修正）とは別種の不具合。plan 末尾の
「関連観察」で記録し、別 Issue 化を提案する。

### 2. クラッシュ条件の一般化（悉皆版）

| 派生 ivar の型 | 例 | `Factory.create_from_json` の挙動 |
|---|---|---|
| Hash（`_type` あり）で対応 Factory **あり** | 通常の canonical 属性全般 | 正常に再構築 |
| Hash（`_type` あり）で対応 Factory **なし** | `timezone`（DvDateTime）, `root`/`oid`/`creating_system_id`（UID系）, `version_tree_id` | **`NameError: uninitialized constant ...Factory`**（factory.rb:34, `class_eval("#{type}Factory")`） |
| Hash（`_type` なし）で `NON_POLYMORPHIC_TYPE_FOR_KEY` にも無いキー | （実運用では通常発生しない。派生キャッシュは常に `_type` 付きで出力されるため） | `ArgumentError`（factory.rb:78-80、既存 spec で固定済み — factory_spec.rb:60-65「uid」の例） |
| スカラー（String/Integer/Float/Boolean） | `year`/`month`/`day`/`hour`/`minute`/`second`/`fractional_second`, `DvTime.timezone`（String）, `extension` | ターゲットクラスの `initialize(args = {})` が Hash から必要なキーだけを明示的に取り出す実装のため、**未知キーは黙って無視される**（例: `DvTemporal#initialize`, date_time.rb:16-23 は `value/magnitude_status/accuracy/normal_range/normal_status/other_reference_ranges` の6キーしか読まない） |

### 3. 修正方式の比較材料

**denylist 方式**: 既知の「派生 Hash 値 ivar」を `(クラス, ivar名)` 単位で除外リスト化。
現状で必要なのは2グループ4-5エントリのみ（`DvDateTime#timezone`,
`UIDBasedID#root`, `ObjectVersionID#oid/creating_system_id/version_tree_id`。
`root`/`extension` は `HierObjectID` にも継承されるため実質同一エントリ）。
`@root`/`@extension`/`@timezone`/`@oid`/`@creating_system_id`/`@version_tree_id`
という ivar 名は、上記2箇所以外のどの RM クラスにも出現しない（`grep` で確認済み）
ため、**ivar 名だけで denylist を組んでも誤爆リスクは無い**。保守コストは低いが、
「将来また同種のバグが増える」たびに手動追加が要る（denylist の宿命）。

**allowlist 方式**: 型ごとに canonical 属性表を持つ。典拠は openEHR ITS-JSON
スキーマ（各 RM クラスの JSON Schema）または RM 仕様書のクラス図。
`lib/openehr/rm/factory.rb` に登録されている `<Type>Factory` は **89クラス**
（`grep -c "^\s*class \w\+Factory" lib/openehr/rm/factory.rb` で確認）—
allowlist 方式はこの全クラスについて正しい属性集合を一度に定義する必要があり、
工事規模が denylist と比べて桁違いに大きい。ただし「未知の派生キャッシュが
将来また増える」ケースに対して構造的に頑健（新しい派生キャッシュも自動的に
除外される）という利点はある。

**代表クラスでの実出力比較**（denylist 適用後 vs 現状、`DvDateTime`・`HierObjectID`
の2件で実測）:

```
現状（DvDateTime, 2020-09-22T16:18:51.481+02:00 相当）:
  {"_type":"DV_DATE_TIME","value":"...","year":2020,"month":9,"day":22,
   "hour":16,"minute":18,"second":51,"fractional_second":0.481,
   "timezone":{"_type":"TIMEZONE","value":"+02:00","hour":2,"minute":0},
   "magnitude_status":"="}
denylist 適用後:
  {"_type":"DV_DATE_TIME","value":"...","magnitude_status":"="}

現状（HierObjectID）:
  {"_type":"HIER_OBJECT_ID","value":"8849...","root":{"_type":"UID","value":"8849..."},"extension":""}
denylist 適用後:
  {"_type":"HIER_OBJECT_ID","value":"8849..."}
```

denylist 後の出力は openEHR ITS-JSON の canonical 形（`_type`+`value` のみ）と
一致する。allowlist でも最終的な出力は同一になるはずだが、実装規模の差が
使う理由。

### 4. 読み側寛容化の現状確認

- 経路は2節の表の通り3分岐（Hash+Factory あり→成功、Hash+Factory なし→NameError、
  Hash+_type なし→ArgumentError、スカラー→無視）。
- 最小実装案: `Factory.convert_hash`（factory.rb:75-83）の `Factory.create(type, **value)`
  呼び出しを `NameError` のみ rescue し、該当キーを `nil`（＝実質無視）にする。
  ターゲットクラスの `initialize` は Hash 経由で明示キーのみ読むため、無関係な
  `nil` 値が紛れ込んでも実害はない（1節の型実測で確認済みの initialize 実装群と
  同型）。
- 副作用の範囲: `_type` の**タイポ**（例: `"DV_QUATNTIY"` のような誤字）も
  NameError を経由するため、寛容化すると「本当のミス」まで黙って `nil` 化されうる。
  今回発見した派生キャッシュ由来の NameError と、正規の欠陥由来の NameError を
  メッセージパターンだけで区別する手段は無い（`class_eval` の失敗はどちらも
  同じ `uninitialized constant` 形）。寛容化を入れる場合、この判別不能性を
  裁定材料として明記する。

### 5. 永続化互換の実態（4象限、うち3象限は実測・1象限は現状データが無いため分析）

| | 旧 reader（現行 Factory、strict） | 新 reader（read-side leniency 適用後、未実装） |
|---|---|---|
| **旧 writer**（現行 RMJSONSerializer、derived cache 付き） | **クラッシュ**（実測済み: `NameError`） | 動作するはず（未実装のため分析のみ。leniency 実装の要否判断そのものがこのマスに懸かる） |
| **新 writer**（denylist/allowlist 適用後、canonical のみ） | **動作する**（実測済み: `root`/`timezone` を手動で除いた JSON を現行 Factory に通し、正常に再構築できることを確認） | 動作する（自明） |

**含意**: 「新 writer」だけで「新 writer × 旧 reader」象限は解決する
（write-side の修正のみで、今後生成される JSON は現行の Factory でも問題なく
読める）。read-side leniency が必要になるのは**旧 writer が既に出力し永続化済みの
JSON を読み戻す**ケースのみ — 該当データが実運用で既に存在するか（gem 利用者が
実際に create_from_json で timezone/root 付き JSON を永続化しているか）は、
本 repo からは確認できない外部要因。裁定が必要な理由の一つ。

### 6. 関連観察: #36 調査の ADL コーパス14件失敗との異同

判定: **別問題（同根ではない）**。#33/#36 調査で確認済みの14件の失敗内訳
（`XMLSerializer cannot emit a CAttribute node` という `ArgumentError`、
意図的に不正な ADL テスト fixture の `Invalid ADL` ParseError、
`archetype id form` の ArgumentError 等）は `lib/openehr/serializer/xml_serializer.rb`
の `emit_child`（`case node; when ...; else raise ArgumentError`という
**手書きの class-based dispatch**）に起因し、`RMJSONSerializer` の**汎用
reflection walker**とは実装方式もクラス階層も異なる。#32 の「派生キャッシュに
対応 Factory が無い」という病理は reflection walker 特有のものであり、
手書き dispatch には存在しない病理（代わりに「未対応クラスの分岐が無い」という
別種のギャップを持つ）。新 Issue は起票不要と判断（既存の #33 plan 文書
「備考」で ADL 14件の内訳は既に記録済み）。

### 7. 既存テストの資産確認

- `spec/lib/openehr/serializer/rm_json_serializer_spec.rb`（62行、7 examples）:
  `serialize()` の出力形状のみ検証（`_type` 付与・再帰・配列・`@parent` 除外・
  AOM 木への転用可能性）。**roundtrip（serialize → create_from_json）を検証する
  spec は皆無**。
- `spec/lib/openehr/rm/factory_spec.rb`（697行）: `Factory.params`/個々の
  `<Type>Factory` を広くカバー。`uid` キーが「genuinely polymorphic」につき
  `NON_POLYMORPHIC_TYPE_FOR_KEY` から意図的に除外されている点を固定する spec
  （:60-65）はあるが、これは「`_type` なし Hash」経路のテストであり、
  今回発見した「`_type` あり Hash だが対応 Factory 無し」経路（`UidFactory`
  不在によるクラッシュ）は一切カバーされていない。
- 全リポジトリ横断で `roundtrip` という語を含む spec は0件
  （`grep -rn -i roundtrip spec/` で該当なし。"roundtrip" というファイル名の
  spec は AQL 領域に別途あるが、RMJSONSerializer とは無関係）。

## Step 2: 裁定用の意思決定マトリクス

| 組み合わせ | 工事規模 | canonical 準拠の保証度 | 互換リスク | 保守性 |
|---|---|---|---|---|
| A. denylist ×（read-side leniency なし） | 小（2箇所、4-5 ivar） | 中（既知のケースのみ手当て） | 旧永続 JSON は読めないまま（要 別手当て） | 低（新しい派生キャッシュが増えるたび追加要） |
| B. denylist ×（read-side leniency 同梱） | 小〜中 | 中 | **旧永続 JSON も読めるようになる** | 低〜中（ivar 追加要 + leniency のタイポ隠蔽リスクを常時抱える） |
| C. allowlist ×（read-side leniency なし） | **大**（89クラス分の canonical 属性表） | **高**（未知の将来バグにも構造的に頑健） | 旧永続 JSON は読めないまま | 高（一度整備すれば追加不要な設計） |
| D. allowlist ×（read-side leniency 同梱） | 大 | 高 | 旧永続 JSON も読める | 高 |

## 推奨案: **B（denylist + read-side leniency 同梱）**

根拠:
- 発見済みの病理は2箇所（DvDateTime, UID系）に限定されており、allowlist の
  89クラス分の作業量に見合う実益が今は無い（将来また増えたら、その時点で
  allowlist へ移行する判断材料が今回の denylist の保守コストから得られる）。
- read-side leniency は実装コストが小さく（`convert_hash` の1メソッド）、
  「新 writer だけでは救えない、旧 writer が既に出力した永続データ」を
  読めるようにする実利がある。タイポ隠蔽リスクは、leniency 発動時に
  `Kernel#warn`（本 repo の既存流儀、#33 で確立）で type 名を明示することで
  緩和できる（黙らせるのではなく、非サイレント化する）。
- ただし B は**裁定が必要な意思決定**であり、A（leniency 見送り、write-side の
  みで様子見）も正当な選択肢として残る。特に「旧永続 JSON が実運用で存在するか」
  という5節の未確認要因が、B の実利の有無を左右する。

## TDD 手順（推奨案 B ベース、裁定後に確定）

### Cycle 1 — write-side: denylist で派生キャッシュを除外

- **Red**: `spec/lib/openehr/serializer/rm_json_serializer_spec.rb` に
  roundtrip spec を追加（fixture は gem 既存の
  `spec/fixtures/health_summary_composition.json` — 実アーティファクト）:
  `CompositionFactory.create_from_json(fixture)` → `RMJSONSerializer#serialize`
  → 出力に `"timezone"` キーが**含まれない**ことを assert。現状は含まれるため red。
  併せて `HierObjectID`/`ObjectVersionID` 単体の unit spec も追加（fixture に
  `uid` が無いため、これは gem 既存 fixture 由来ではなく直接インスタンス化 —
  実アーティファクト由来ではない旨を spec コメントに明記。CLAUDE.md の
  real-artifact ルールは「臨床データ」を対象としており、RM 値オブジェクトの
  単体構築はこの対象外という整理が必要であれば裁定で確認）。
- **Green**: `RMJSONSerializer::EXCLUDED_IVARS`（rm_json_serializer.rb:13）を
  `[:@parent]` から拡張する形式は誤り（グローバル denylist だと DvTime の
  `@timezone`〔正当なスカラー、除外不要〕まで巻き込む可能性は無いが — 実際には
  ivar 名ベースの除外は「型を見ない」ため、DvTime の `@timezone`（String）も
  一緒に消えてしまう。これは実害無し〔非 canonical だから〕だが意図としては
  「クラス問わず ivar 名だけで判定」という設計になる点に注意）。具体案:
  `EXCLUDED_IVARS_BY_CLASS = { DvDateTime => [:@timezone, :@year, :@month, :@day, :@hour, :@minute, :@second, :@fractional_second], DvDate => [...], DvTime => [...], UIDBasedID => [:@root, :@extension], ObjectVersionID => [:@oid, :@root, :@creating_system_id, :@version_tree_id, :@extension] }` 形式でクラスごとに定義するか、`EXCLUDED_IVARS = [:@parent, :@timezone, :@year, :@month, ...]` とグローバル1本にするかは、2節の「名前衝突なし」実測を踏まえて **グローバル1本で十分**と考えるが、最終判断は Codex 実装時にコードレビューで確認。
- **Refactor**: 既存7 examples が green のまま保たれることを確認。

### Cycle 2 — read-side: 未知 Factory 型への寛容化（裁定で B 採用時のみ）

- **Red**: `spec/lib/openehr/rm/factory_spec.rb` に、`_type` 付き Hash だが
  対応 Factory が存在しない場合（例: 手作りの `{_type: "TIMEZONE", value: "+02:00"}`
  Hash）を渡すと、`NoMethodError`/`NameError` を raise せず、当該キーが
  `nil`（結果として無視される）になることを assert。併せて
  `output(/unknown.*TIMEZONE/).to_stderr` で warn を検証（#33 の
  `Kernel#warn` 流儀を踏襲）。
- **Green**: `Factory.convert_hash`（factory.rb:75-83）を修正。

### Cycle 3 — 旧永続データの roundtrip 固定

- **Red→Green**: Cycle 1 の denylist 適用**前**の出力形（`timezone`/`root` 付き）を
  文字列として直接 `create_from_json` に渡し、Cycle 2 の leniency で読めることを
  assert する回帰テスト（5節の「旧 writer × 新 reader」象限を固定）。

## 互換性ノート案（History.txt 草稿）

```
* RMJSONSerializer no longer emits derived-cache instance variables
  that aren't part of canonical openEHR ITS-JSON: DvDate/DvTime/
  DvDateTime's year/month/day/hour/minute/second/fractional_second/
  timezone (all recomputed from `value` on read), and UIDBasedID/
  ObjectVersionID's root/extension/oid/creating_system_id/
  version_tree_id (recomputed from `value`). Persisted JSON produced
  by prior versions may contain these keys; [B採用時: they are now
  tolerated on read, with a Kernel#warn naming any still-unrecognized
  _type / A採用時: re-serializing through this version's
  RMJSONSerializer produces canonical output, but re-reading
  already-persisted old-format JSON containing these keys still
  raises].
```

## semver 提案

577a0d7（#33）は「挙動不変でも patch」だったが、**今回は明確に挙動が変わる**
（出力から `timezone`/`root` 等のキーが消える。既存の永続化済み JSON との
文字列完全一致を仮定しているコードがあれば影響を受ける）。影響面基準で:

- 実行時挙動: **変わる**（serialize 出力が変わる。B 採用なら read 経路も変わる）
- 公開API: 変わらない（メソッドシグネチャ不変）
- インストール依存: 変わらない

出力形式の変更を伴うため **minor** を提案。ただし「壊れていた roundtrip を
直す」という bug 修正の性格が強く、患者説得力としては patch 論も成立しうる
（Issue のラベルも `bug`）。**最終判断は Step 6 棚卸しで確定**
（577a0d7 で確立した「shipped runtime code は最低 patch」規約はここでも
下限として適用され、争点は patch か minor かの2択）。

## Issue #32 増補用サマリ（英語・ペースト用）

```markdown
## Investigation update (2026-08-22): timezone is not the only instance — UID family has the identical bug

Verified against the actual source (not just the DvDateTime case in this issue's
original report): `lib/openehr/rm/support/identification.rb`'s `UIDBasedID#value=`
(:224-233, inherited by `HierObjectID`) and `ObjectVersionID#value=` (:247-257)
derive Hash-serializable `UID`/`VersionTreeID` objects (`root`, `oid`,
`creating_system_id`, `version_tree_id`) from parsing `value`, exactly like
`DvDateTime`'s `timezone`. Reproduced the crash directly:

    hier = OpenEHR::RM::Support::Identification::HierObjectID.new(value: "...")
    json = OpenEHR::Serializer::RMJSONSerializer.new(hier).serialize
    # => {"_type":"HIER_OBJECT_ID","value":"...","root":{"_type":"UID","value":"..."},"extension":""}
    OpenEHR::RM::Factory.create(parsed[:_type], **OpenEHR::RM::Factory.params(parsed))
    # => NameError: uninitialized constant OpenEHR::RM::Factory::UidFactory

No `UidFactory` or `VersionTreeIdFactory` exists anywhere in `lib/openehr/rm/factory.rb`
(confirmed by reading all 611 lines / all registered `*Factory` classes). `uid` is a
common `Composition` attribute in real openEHR data (`ObjectVersionID`/`HierObjectID`),
yet this gem's own test fixture (`spec/fixtures/health_summary_composition.json`)
contains zero `uid` fields, which is why this path has never been exercised by the
existing suite.

This confirms proposal 1 from the original report's reasoning ("the same class of bug
can recur for any future RM class that caches a derived object") was not hypothetical -
it had already recurred, just unnoticed. Strengthens the case for a general fix over a
one-off `TimezoneFactory` patch.

Also found, as a related-but-distinct bug (not part of this issue's fix, recording for
a separate issue): `ObjectVersionID`'s `@root` and `@oid` point to the *same* `UID`
object (`identification.rb:252`), and `RMJSONSerializer`'s cycle-guard (`seen` set,
`rm_json_serializer.rb:39`) misidentifies this legitimate aliasing as an already-visited
cycle, silently dropping `root` to `null` in the output - a silent-data-loss bug distinct
from this issue's crash-on-read bug.

Full investigation, decision matrix (denylist vs allowlist × read-side leniency), and
TDD plan: `docs/design/fix-rmjson-roundtrip-plan.md`.
```
