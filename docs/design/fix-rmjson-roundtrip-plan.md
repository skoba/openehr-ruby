# Plan: RMJSONSerializer ⇔ create_from_json roundtrip (openehr-ruby upstream sprint #32)

**Status: APPROVED 2026-08-22 — 実装指示書（Codex 向け）。4論点確定:
(1) denylist + 悉皆 roundtrip spec 併設、(2) 読み側寛容化は同梱・
denylist 済みキーは無警告/未知 _type のみ warn、(3) 永続互換は寛容化を
保険として同梱（Anlage に旧永続 JSON は実在しないが一般利用者は確認不能）、
(4) semver は minor（2.4.0 仮置き、最終確定は Step 6）**

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

**裁定3（2026-08-22）**: Anlage 側には旧永続 JSON は実在しない
（`Opt::CompositionReader` は当初から `create_from_json` を使わず自前で
Hash を走査する設計 — #32 Issue 本文の「Anlage's Opt::CompositionReader
avoids CompositionFactory.create_from_json entirely」の記述どおり）。
一方、本 gem の一般利用者が既に timezone/root 付き JSON を永続化している
可能性は本 repo からは確認できない。read-side leniency は「該当データが
実在する場合の保険」として同梱する（裁定2の warn 区別と合わせて、
サイレントな互換吸収ではなく検知可能な形にする）。

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

## 採択案: **B（denylist + read-side leniency 同梱）— 確定（2026-08-22 裁定）**

根拠:
- 発見済みの病理は2箇所（DvDateTime, UID系）に限定されており、allowlist の
  89クラス分の作業量に見合う実益が今は無い（将来また増えたら、その時点で
  allowlist へ移行する判断材料が今回の denylist の保守コストから得られる）。
  代わりに Cycle 4 の悉皆 roundtrip spec を番犬として併設し、denylist の
  「保守コストが宿命」という弱点を、CI で自動検出できる形にして補う。
- read-side leniency は実装コストが小さく（`convert_hash` の1メソッド）、
  「新 writer だけでは救えない、旧 writer が既に出力した永続データ」を
  読めるようにする実利がある。タイポ隠蔽リスクは、**denylist 済み（既知）の
  型は無警告で無視・それ以外の未知 `_type` のみ warn**という区別で緩和する
  （5節・裁定2参照）。

## TDD 手順（Codex 実装指示。この順序で厳守）

### Cycle 1 — write-side: DvDateTime 系 roundtrip red → denylist で green

- **Red — 追記** `spec/lib/openehr/serializer/rm_json_serializer_spec.rb`:
  `spec/fixtures/health_summary_composition.json`（gem 既存の実アーティファクト）を
  `CompositionFactory.create_from_json` → `RMJSONSerializer#serialize` →
  `CompositionFactory.create_from_json`（再度）の roundtrip で通し、2回目の
  `create_from_json` が raise しないことを assert。現状は `start_time`
  （DvDateTime）の `timezone` で `NameError` になるため red。
- **Green — 変更** `lib/openehr/serializer/rm_json_serializer.rb`:
  `EXCLUDED_IVARS`（:13）を拡張する。2節・3節の実測（ivar 名の衝突が
  リポジトリ全体で無いことを確認済み）に基づき、**グローバル1本の配列**で
  十分と判断（クラス別 Hash にする理由が無い — 型を見ない ivar 名ベースの
  除外は DvTime の `@timezone`〔String〕も道連れにするが、非 canonical な
  スカラーが1つ余分に消えるだけで実害は無い）:
  ```ruby
  # Instance variables that value=-style setters derive and cache from a
  # single canonical attribute (e.g. `value`), but which are not part of
  # openEHR ITS-JSON canonical form and have no corresponding
  # OpenEHR::RM::Factory::<Type>Factory to reconstruct them on read - see
  # docs/design/fix-rmjson-roundtrip-plan.md for the full inventory and
  # how each was found (DvDate/DvTime/DvDateTime's value= in
  # lib/openehr/rm/data_types/quantity/date_time.rb; UIDBasedID/
  # ObjectVersionID's value= in lib/openehr/rm/support/identification.rb).
  EXCLUDED_IVARS = [
    :@parent,
    :@year, :@month, :@day,                      # DvDate, DvDateTime
    :@hour, :@minute, :@second, :@fractional_second, # DvTime, DvDateTime
    :@timezone,                                  # DvTime (String), DvDateTime (Timezone)
    :@root, :@extension,                         # UIDBasedID, HierObjectID, ObjectVersionID
    :@oid, :@creating_system_id, :@version_tree_id # ObjectVersionID
  ].freeze
  ```
- **Refactor**: 既存7 examples が green のまま保たれることを確認。

### Cycle 2 — read-side: UID 系 roundtrip red → green（新規 uid fixture）

- **新規 fixture** `spec/fixtures/health_summary_composition_with_uid.json`:
  gem 既存の `health_summary_composition.json`（実アーティファクト）を複製し、
  `Composition` トップレベルに `uid` フィールドを追加したもの
  （`{"_type":"OBJECT_VERSION_ID","value":"<既存内容から導出できる適当な UUID>::openehr-ruby::1"}`
  等、openEHR RM 標準形）。JSON 冒頭に隣接するコメントは JSON 形式では書けないため、
  同名の `.md`（または spec 内コメント）で出所を明記: 「gem 既存の実アーティファクト
  `health_summary_composition.json` を複製し、同 fixture が元来持たない `uid`
  フィールド（`ObjectVersionID`、openEHR RM 標準形）を追加したもの。UID系
  roundtrip クラッシュ（#32 調査で新規発見）の再現に使用」。既存 fixture 自体は
  変更しない（他 spec への影響を避ける）。
- **Red**: 上記 fixture を使った roundtrip spec を追加（Cycle 1 と同じ形。
  現状は `uid` の `root` で `NameError: uninitialized constant
  OpenEHR::RM::Factory::UidFactory` になるため red）。

- **訂正（2026-08-22、Codex 実装時の実測により発覚・修正）**: 当初想定
  「Cycle 1 の denylist だけで green になるはず」は誤りだった。
  `ObjectVersionID` は `UIDBasedID`（親クラス）と異なり `value=`
  （identification.rb:247-257）内で `super` を呼ばず、**`@value` ivar を
  一切保持しない**。`value`（正規属性そのもの）は `@oid`/`@creating_system_id`/
  `@version_tree_id` から都度再計算する computed getter（:259-263）としてのみ
  存在する。この3 ivar を denylist で除外すると、canonical な `value` の
  ivar 表現が跡形もなく消え、シリアライズ結果が `{"_type":"OBJECT_VERSION_ID"}`
  のみになり、読み戻し時に `ObjectVersionID#value=` が `nil` を受けて
  `ArgumentError: invalid format` になる（denylist 起因の新種のクラッシュ）。
  `HierObjectID`（`UIDBasedID` の素のサブクラス、`super` 経由で `@value` を
  保持）はこの問題を持たないため、Cycle 1 のテスト時には露見しなかった。

  **追加修正**: `lib/openehr/rm/support/identification.rb` の
  `ObjectVersionID#value=` に `@value = value` を追加し、`UIDBasedID` と
  同様に canonical `value` を ivar として保持させる（getter 側 :259-263 は
  不変— 引き続き `@oid` 等から再計算する。`@value` は RMJSONSerializer の
  reflection が拾えるようにするためだけの追加で、getter の実装は変えない）。
  これは RMJSONSerializer 側の特殊対応ではなく、`identification.rb` 自体の
  一貫性を `UIDBasedID` に揃える正当な修正 — RMJSONSerializer は
  「RM 固有ロジックを持たない汎用 walker」という自身のヘッダコメントの
  設計原則を保つ。

### Cycle 3 — read-side leniency: 未知 `_type` の warn+無視

- **Red — 追記** `spec/lib/openehr/rm/factory_spec.rb`:
  1. **denylist 済み（旧永続データ想定）の型は無警告で無視**: 手作りの
     `{_type: "TIMEZONE", value: "+02:00", hour: 2, minute: 0}` Hash を
     `Factory.params` に渡すと、raise せず、かつ **stderr に何も出力しない**
     ことを assert（`expect { ... }.not_to output.to_stderr` かつ
     `not_to raise_error`）。`UID`/`VERSION_TREE_ID` も同様に確認。
  2. **未知 `_type`（真に想定外）は warn+無視**: `{_type: "SOME_FUTURE_TYPE",
     value: "x"}` のような、denylist 対象でない未知の `_type` を渡すと、
     raise せず `output(/unknown.*SOME_FUTURE_TYPE/).to_stderr` で warn する
     ことを assert（#6a の `xml_constraint_parsing.rb` の
     `respond_to?` ガード + warn 型を踏襲）。
  現状はどちらも `NameError`（raise する）ため両方とも red。
- **Green — 変更** `lib/openehr/rm/factory.rb`: `Factory.convert_hash`
  （:75-83）を修正。`class_eval("#{type}Factory")` を `NameError` で rescue し、
  **`type` が Cycle 1 の `EXCLUDED_IVARS` に対応する既知の派生型名
  （`TIMEZONE`, `UID`, `VERSION_TREE_ID` — 定数として明示的に列挙。
  `EXCLUDED_IVARS` の ivar 名から機械的に導出するのではなく、対応表を明示的に
  書く方が読み手にとって追跡しやすい）なら無警告で `nil` を返し、それ以外は
  `warn "openehr factory: unknown type \"#{type}\" for attribute #{key.inspect}; ignoring"`
  してから `nil` を返す** という2分岐にする。
- **旧永続データの回帰固定（5節「旧 writer × 新 reader」象限を固定）**:
  Cycle 1 の denylist 適用**前**の出力形（`timezone`/`root` 付きの生 JSON
  文字列。ハードコードでよい）を直接 `create_from_json` に渡し、raise せず
  読めることを assert する spec も同じ Cycle 3 に含める。

### Cycle 4 — 悉皆 roundtrip spec（番犬）

- explore Step 1-1 で洗い出した**全クラス**（`DvDate`, `DvTime`, `DvDateTime`,
  `DvDuration`, `UIDBasedID`, `HierObjectID`, `ObjectVersionID`、および
  Cycle 1/2 の fixture に既に含まれる他の全 RM クラス）を対象に、
  「reflection で得られる全 ivar のうち Hash 値（`_type` 付き）になるものは、
  必ず対応する `<Type>Factory` が存在する」ことを機械的に検証する spec を
  `spec/lib/openehr/serializer/rm_json_serializer_spec.rb`
  （または新規 `spec/lib/openehr/rm/roundtrip_spec.rb`）に追加する。
  実装方針: `health_summary_composition_with_uid.json` を
  `create_from_json` → 得られた `Composition` を explore 時に使った
  reflection walker と同じロジックでオブジェクトグラフ全体を走査し、
  各オブジェクトの `_type` 付き Hash 値 ivar それぞれについて
  `OpenEHR::RM.const_defined?("#{camelized_type}Factory") ||
  <denylist 済みなら OK>` を assert する形（探索時に使った実測スクリプトを
  そのまま spec 化する形でよい）。**このテストの価値は「未知の将来の
  派生キャッシュバグを、fixture 追加なしで自動検出する」点** — 新しい
  RM クラスが同じ病理を持つようになった場合、このテストが red になることで
  検出される（denylist の追加漏れそのものは検出できないが、少なくとも
  「クラッシュする」ことは検出できる）。
- 既存の Cycle 1/2 の個別 roundtrip spec とは独立に維持する（悉皆 spec が
  1つ落ちても、どのクラスが原因か個別 spec の方が特定しやすいため）。

### Cycle 5 — 仕上げ（TDD 外）

- `lib/openehr/version.rb` → `"2.4.0"`（作業上の仮置き、Step 6 で最終確定）
- `History.txt` 追記（下記ドラフト）
- `bundle exec rspec` 全走・`bundle exec rubocop`（todo 再生成禁止）
- 循環参照ガード誤爆（`ObjectVersionID` の `root`/`oid` 同一参照 →
  `RMJSONSerializer` の `seen` ガード誤爆によるサイレント null 化）は
  **本 PR に同梱しない**。別 Issue ドラフトを英語で用意し、Claude Code の
  報告に含める（起票はユーザ。#32 と Related 相互リンク）。

## 実装後検証: `ObjectVersionID` `@value` 追加の影響（2026-08-22、Claude Code）

裁定後の Step 4 レビューで、`@value` 追加の影響を `git worktree` で
真の pre-#32 コミット（`bedb2a7`）を分離チェックアウトし、実測で検証:

- **真の元出力**（v2.3.2 相当、denylist も `@value` も無い状態）:
  `{"_type":"OBJECT_VERSION_ID","oid":{...},"creating_system_id":{...},"version_tree_id":{...},"root":null,"extension":"my.system.com::1"}`
  — `value` キーは**元々存在しない**（`ObjectVersionID` は `@value` ivar 自体を
  持たなかったため。`root` が `null` なのは既知の seen-guard 誤爆、#32 スコープ外）。
- **最終出力**（denylist + `@value` 修正後）:
  `{"_type":"OBJECT_VERSION_ID","value":"..."}`
- **消えたキー**: `oid, creating_system_id, version_tree_id, root, extension`（5件）
- **新たに現れたキー**: `value`（1件） — `HierObjectID` 等（`UIDBasedID` 経由で
  元々 `@value` を持つ）は「キーが消えるだけ」だが、`ObjectVersionID` は
  「消える＋現れる」の両方が起きる唯一のクラス。History.txt に明記済み。

**reader/writer と `@value` の整合確認**: `ObjectVersionID#value`（getter,
identification.rb:260-264）は不変で、常に `@oid`/`@creating_system_id`/
`@version_tree_id` から再計算する（`@value` を読まない）。よって `@value` は
「reflection 専用の書きっぱなしキャッシュ」であり、getter の挙動には一切影響しない。

**乖離の余地（pre-existing、本修正が新規に持ち込んだものではない）**:
`objectid=`/`creating_system_id=`/`version_tree_id=`（identification.rb:270-287）は
公開セッターであり、`value=` を経由せず直接呼べば `@oid` 等だけが更新され
`@root`/`@extension`（既存）や `@value`（今回追加）が追随しない乖離が理論上
起こりうる。ただし: (a) この乖離可能性は `@root`/`@extension` について
**本修正以前から存在していた**設計であり、`@value` の追加が新たに持ち込んだ
リスクではない。(b) `grep` で確認した限り、本 repo のどこにもこれらのセッターを
`value=` 経由以外で呼ぶコードは無い（既存 spec の3箇所はいずれも `nil` を渡す
バリデーションの負例テストで、成功パスでの直接再代入は無い）。

**既存 spec への影響確認**: `spec/lib/openehr/rm/support/identification/`
全体（123 examples）を単独実行し、0 failures を確認 — `ObjectVersionID` を
含む識別子クラス群の既存挙動（`value`/`root`/`extension`/`is_branch?` 等）は
一切変わっていない。

## 互換性ノート案（History.txt 草稿、=== 2.4.0 仮置き）

```
=== 2.4.0
Bug fix release: RMJSONSerializer <-> CompositionFactory.create_from_json
roundtrips now work.

* RMJSONSerializer no longer emits derived-cache instance variables
  that aren't part of canonical openEHR ITS-JSON: DvDate/DvTime/
  DvDateTime's year/month/day/hour/minute/second/fractional_second/
  timezone (all recomputed from `value` on read), and UIDBasedID/
  HierObjectID/ObjectVersionID's root/extension/oid/
  creating_system_id/version_tree_id (also recomputed from `value`).
  Previously, serializing a DvDateTime or a Composition carrying a uid
  (ObjectVersionID/HierObjectID - a common real-world attribute) and
  feeding the result back into create_from_json raised NameError:
  uninitialized constant ...Factory::TimezoneFactory (or UidFactory) -
  no such Factory class existed for either derived cache. The gem's
  own fixture had no `uid` field, so the UID-family case had never
  been exercised until this investigation found it.
* Factory.params now tolerates an unrecognized `_type` on a Hash
  value instead of raising: a _type matching one of the
  now-excluded derived caches above (TIMEZONE, UID, VERSION_TREE_ID)
  is silently ignored - this is what makes JSON persisted by a prior
  version of this gem (which still contains those keys) readable
  again. Any other, genuinely unrecognized `_type` is also ignored,
  but with a Kernel#warn naming it, so a real authoring mistake
  (e.g. a typo'd _type) doesn't fail silently.
```

## semver: **2.4.0 (minor)** — 作業上の仮置き（2026-08-22 裁定）

577a0d7（#33）は「挙動不変でも patch」だったが、**今回は明確に挙動が変わる**
（出力から `timezone`/`root` 等のキーが消える。既存の永続化済み JSON との
文字列完全一致を仮定しているコードがあれば影響を受ける）。影響面基準で:

- 実行時挙動: **変わる**（serialize 出力が変わる。read 経路も寛容化により変わる）
- 公開API: 変わらない（メソッドシグネチャ不変）
- インストール依存: 変わらない

出力形式の変更を伴うため **minor** で確定（裁定4）。「壊れていた roundtrip を
直す」という bug 修正の性格が強く patch 論も成立しうるが（Issue のラベルも
`bug`）、観測可能な出力変更を伴う以上 minor が妥当という判断。
**ただし最終確定は Step 6 棚卸しで**（577a0d7 で確立した「shipped runtime
code は最低 patch」規約がここでも下限として適用される）。

**Step 6 棚卸し時の3成分分類（裁定・可視化条件2）**: 本 PR（1コミット）は
性質の異なる3変更を含む。棚卸しではこの3成分に分けて評価すること:

1. **denylist**（`rm_json_serializer.rb`）— write-side、出力からキーが消える
2. **read 側寛容化**（`factory.rb`）— 未知/既知除外型への warn 区別付き無視
3. **RM クラスの内部表現変更**（`identification.rb` の `ObjectVersionID`）—
   `@value` ivar の新規保持。前述「実装後検証」節の通り、`value` キーが
   ObjectVersionID の出力に**新たに現れる**という、他の2成分（キーが消える
   方向のみ）とは異なる性質の変更

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
