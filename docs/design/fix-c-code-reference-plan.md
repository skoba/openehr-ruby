# Plan: C_CODE_REFERENCE でパースがクラッシュ (openehr-ruby upstream sprint #6a)

**Status: APPROVED 2026-08-22 — 実装指示書（Codex 向け）**

**Issue**: [skoba/openehr-ruby#30](https://github.com/skoba/openehr-ruby/issues/30)
（本 PR は `Fixes #30`）。関連: [#31](https://github.com/skoba/openehr-ruby/issues/31)
（term_bindings, PR 本文で関連リンクのみ・bindings 解析は別管理）。

## Context

openehr-ruby の OPT/XML 制約パーサは xsi:type を `send`+`downcase` で動的ディスパッチするが、
`C_CODE_REFERENCE` のハンドラが未定義のため、実世界の OPT（例: ProblemList.opt）を
パースすると NoMethodError でクラッシュする。Anlage プロジェクトでの利用中に発見された
バグの upstream 修正（1 Issue = 1 branch = 1 PR、bug / patch）。

本ブランチ `fix/opt-c-code-reference` は本 plan をベースに Cycle 0〜4 を t-wada TDD
（red→green→refactor）で実装する。実装完了後、diff を本 plan と突合レビューし、
`bundle exec rspec` 全走・`bundle exec rubocop`・`History.txt`/`lib/openehr/version.rb`
の確認を経て 1 PR にまとめる。

## 規範根拠: openEHR AM XML Schema (Release-1.4)

出典: openEHR/specifications-ITS-XML (master)

`components/AM/Release-1.4/Template.xsd:115-123`:

```xml
<xs:complexType name="C_CODE_REFERENCE">
  <xs:complexContent>
    <xs:extension base="C_CODE_PHRASE">
      <xs:sequence>
        <xs:element name="referenceSetUri" type="xs:anyURI"/>
      </xs:sequence>
    </xs:extension>
  </xs:complexContent>
</xs:complexType>
```

`components/AM/Release-1.4/OpenehrProfile.xsd:10-21`:

```xml
<xs:complexType name="C_CODE_PHRASE">
  <xs:complexContent>
    <xs:extension base="C_DOMAIN_TYPE">
      <xs:sequence>
        <xs:element name="assumed_value" type="CODE_PHRASE" minOccurs="0"/>
        <xs:element name="terminology_id" type="TERMINOLOGY_ID" minOccurs="0"/>
        <xs:element name="code_list" type="xs:string" minOccurs="0" maxOccurs="unbounded"/>
      </xs:sequence>
    </xs:extension>
  </xs:complexContent>
</xs:complexType>
```

含意: C_CODE_REFERENCE は C_CODE_PHRASE の**派生型**（referenceSetUri を 1 個追加、xs:anyURI）。
→ Ruby 側も `CCodeReference < CCodePhrase` が仕様に忠実で、既存の `is_a?(CCodePhrase)` 判定を
壊さない追加的変更になる。

## 補足: Issue 参照について

「#6a」は GitHub 上の issue 番号ではない（skoba/openehr-ruby の #6 は 2013 年の RMFactory issue
で既にクローズ済み）。未起票ドラフトとして扱う。本 plan が事実上の issue 本文を兼ねる
（起票する場合は anlage repo `docs/upstream-candidates.md:126-146` §6a が原典）。

## Explore 結果（file:line で検証済み）

### ディスパッチ機構（`OpenEHR::Parser::XMLConstraintParsing`）

パーサは事前に `remove_namespaces!` するため `xsi:type` は素の `type` 属性として読む
（`lib/openehr/parser/opt_parser.rb:44`）。ディスパッチは `send <type>.downcase`:

- `attributes()` — `lib/openehr/parser/xml_constraint_parsing.rb:52`:
  `send attr.attributes['type'].text.downcase, attr, child_node`
- `children()` — `lib/openehr/parser/xml_constraint_parsing.rb:68` ← **C_CODE_REFERENCE が
  ここで NoMethodError**（`send 'c_code_reference', ...` が未定義）:
  `send child.attributes['type'].text.downcase, child, child_node`
- 他に assertion/expression 系のディスパッチ: 同ファイル 194, 204, 206, 215, 222, 230 行

`respond_to?` ガード・`method_missing`・rescue は XMLConstraintParsing / XMLPrimitiveParsing /
XMLDomainTypeParsing のいずれにも**なし**。

### 登録済みハンドラ

- 制約木（`xml_constraint_parsing.rb`）: `c_archetype_root`(18), `c_complex_object`(31),
  `c_single_attribute`(72), `c_multiple_attribute`(78), `archetype_slot`(84),
  `archetype_internal_ref`(174), `constraint_ref`(181), expr 系, `c_primitive_object`(227)
- primitive（`xml_primitive_parsing.rb`）: `c_date`/`c_date_time`/`c_integer`/`c_real`/
  `c_duration`/`c_time`/`c_boolean`/`c_string`
- domain type（`xml_domain_type_parsing.rb`）: `c_code_phrase`(13), `c_dv_quantity`(44),
  `c_dv_ordinal`(75), `c_dv_scale`(97), `c_dv_state`(123, 意図的に NotImplementedError)
- `c_code_reference` は**どこにも存在しない**。リポジトリ全体で "C_CODE_REFERENCE" /
  "CCodeReference" / "referenceSetUri" / "reference_set_uri" は 0 件。

### 参照実装: c_code_phrase（xml_domain_type_parsing.rb:13-31）

```ruby
def c_code_phrase(attr_xml, node)
  terminology_id_node = attr_xml.at('terminology_id/value')
  terminology_id = terminology_id_node ? OpenEHR::RM::Support::Identification::TerminologyID.new(value: terminology_id_node.text.strip) : nil
  code_list_nodes = attr_xml.xpath('code_list')
  code_list = code_list_nodes.map { |code_node| code_node.text.strip }
  code_list = [code_list.first] if code_list.size == 1 && code_list.first.empty?
  occurrences_node = attr_xml.at('occurrences')
  occurrences_obj = occurrences_node ? occurrences(occurrences_node) : nil
  OpenEHR::AM::OpenEHRProfile::DataTypes::Text::CCodePhrase.new(
    terminology_id: terminology_id, code_list: code_list, path: node.path,
    occurrences: occurrences_obj, rm_type_name: 'CODE_PHRASE')
end
```

### 呼び出し元チェーン

- OPT: `OPTParser#parse`（opt_parser.rb:42, include XMLConstraintParsing は :9）
  → `#definition`（:115-117, `c_archetype_root`）→ `attributes`（:52 dispatch）
  → `c_single_attribute`/`c_multiple_attribute` → `children`（:68 dispatch）→ 再帰。
  **rescue なし → 生の NoMethodError が呼び出し元へ**。
- XML archetype: `XMLArchetypeParser#parse`（xml_archetype_parser.rb:21-26）は
  StandardError を `OpenEHR::Parser::ParseError` にラップ。同じ dispatch 経路
  （#definition :154-165, #invariants :167）。

### logger / 警告手段

lib/ 配下に Logger 皆無。前例は deprecation 用の `Kernel#warn`（例:
`lib/openehr/am/archetype.rb:121`, `lib/openehr/rm/data_types/text.rb:160`）。
→ フォールバック警告も `Kernel#warn` が既存流儀に一致。

### 既存テスト・fixture

- OPT パーサ spec: `spec/lib/openehr/opt_parser/` に 7 ファイル（opt_parser_spec.rb,
  minimum_template_spec.rb, opt_ontology_spec.rb, opt_parser_complex_constraints_spec.rb,
  opt_parser_edge_cases_spec.rb, opt_parser_error_cases_spec.rb,
  opt_parser_new_constraints_spec.rb）
- fixture (.opt) は spec と同居: minimum_template.opt(1491 行), eReferral.opt(12188 行),
  new_constraints_template.opt(401 行) — いずれも C_CODE_REFERENCE を含まない
- リポジトリに .xsd の同梱なし

### CCodePhrase モデル

- `lib/openehr/am/openehr_profile/data_types/text.rb:8-44`: `CCodePhrase < CDomainType`、
  `attr_accessor :terminology_id, :code_list`、initializer は `:terminology_id, :code_list,
  :assumed_value` + 継承キー（`:path, :parent, :rm_type_name`〔必須〕, `:node_id`,
  `:occurrences`〔必須〕）。nil terminology_id/code_list は `any_allowed?` を駆動（寛容設計）。
- 継承チェーン（`lib/openehr/am/archetype/constraint_model.rb`）: CDomainType(:482) <
  CDefinedObject(:235) < CObject(:95, rm_type_name/occurrences 必須で ArgumentError) <
  ArchetypeConstraint(:5)
- 「制約クラスに XML schema 属性を足す」既存パターン: `CArchetypeRoot < CComplexObject`
  （constraint_model.rb:488-506、super 後に検証付き setter）
- CCodePhrase spec: `spec/lib/openehr/am/openehr_profile/data_types/text/c_code_phrase_spec.rb`
  （旧スタイル）。新スタイルの手本は `c_archetype_root_spec.rb`（require 'spec_helper', let,
  FQCN, ArgumentError 期待）
- Template OM: `lib/openehr/am/template.rb` = `OpenEHR::AM::Template::OperationalTemplate` のみ

### fixture 出所: anlage ProblemList.opt

- `/home/skoba/src/anlage/spec/fixtures/opt/ProblemList.opt`（Archetype Designer 生成）が
  3 リポジトリ中**唯一** C_CODE_REFERENCE を含む OPT。`C_CODE_REFERENCE`:323, `referenceSetUri`:334。
- 実インスタンスの構造: ELEMENT → C_SINGLE_ATTRIBUTE `value` → DV_CODED_TEXT →
  C_SINGLE_ATTRIBUTE `defining_code` → `<children xsi:type="C_CODE_REFERENCE">` に
  rm_type_name=CODE_PHRASE / occurrences 0..1 / 空 node_id /
  `<referenceSetUri>terminology:http://id.who.int/icd/release/11/mms</referenceSetUri>`。
  **terminology_id / code_list は無し**（referenceSetUri のみ。要素順は node_id の後 =
  XSD の extension content model と一致）。
- openehr-ruby 既存 fixture（minimum_template.opt ほか）はいずれも C_CODE_REFERENCE を含まない。
- fixture 読み込み規約: spec と同居、`OPTParser.new(File.join(File.dirname(__FILE__), './x.opt'))`。
  ハンドラ単体テストは `opt_parser_new_constraints_spec.rb:6-16` の `fragment(xml)`
  （Nokogiri parse + remove_namespaces!）+ `parser.send(:c_real, node)` パターン。

### CHANGELOG / バージョン管理の実態

- CHANGELOG ファイルは `History.txt`（`=== X.Y.Z` 見出し + 散文サマリ + 箇条書きの流儀）
- バージョン定数: `lib/openehr/version.rb`（現在 "2.3.0"、gemspec が参照）
- `c_complex_object(xml, node)`（xml_constraint_parsing.rb:31）は children ディスパッチと
  同アリティ（2 引数）→ フォールバック先として呼び出し互換

## ベースライン（2026-08-22, master @ e728023）

- `bundle check`: 依存充足
- `bundle exec rspec`: **3932 examples, 0 failures**（62.7s、line coverage 97.28%）
- 既存 fail なし。deprecation 警告（DvParagraph, PartyIdentified#identifier 等）は
  既知の意図的出力で、failure ではない。

## 修正方針（確定）

### D1. モデル: `CCodeReference < CCodePhrase`（text.rb 同居）

- 配置: `lib/openehr/am/openehr_profile/data_types/text.rb` の CCodePhrase 直後（:44 の後）。
  Template.xsd 由来だが `lib/openehr/am/template.rb` は OperationalTemplate 専用で
  archetype.rb しか require しておらず、クロスパッケージ require を増やすより
  スーパークラスと同一ファイルが load 順リスクゼロ。クラスコメントで
  「Template.xsd (Template OM) 定義の C_CODE_PHRASE 拡張」と出所明記。
- `attr_reader :reference_set_uri` + 検証付き setter: **nil 許容・非 nil 空文字は
  ArgumentError**（CArchetypeRoot#slot_node_id= constraint_model.rb:497-500 と同型）。
  XSD 上は必須だが、パーサの使命は実在アーティファクトの受理であり、CCodePhrase 自体が
  寛容設計（nil → any_allowed?）のため。
- `any_allowed?`/`valid_value?` は**オーバーライドしない**: reference set を展開できる
  terminology service が無い以上厳格化は空振りし、かつ any_allowed? を false にすると
  XMLSerializer#emit_code_phrase_body（xml_serializer.rb:475-478）が nil terminology_id で
  クラッシュする。

### D2. パーサ: `c_code_reference` ハンドラ + 共通ヘルパ抽出

`lib/openehr/parser/xml_domain_type_parsing.rb` の c_code_phrase(:13-31) 直後に追加。
refactor 段階で共通読み取りを `code_phrase_constraint_args(attr_xml, node)` に抽出し
c_code_phrase を載せ替え（挙動ビット同一。:19 の `size==1 && first.empty?` quirk も保持）。

```ruby
def c_code_reference(attr_xml, node)
  args = code_phrase_constraint_args(attr_xml, node)
  args[:code_list] = nil if args[:code_list] && args[:code_list].empty?  # ①
  uri = attr_xml.at('referenceSetUri')&.text&.strip
  args[:reference_set_uri] = uri unless uri.nil? || uri.empty?           # ②
  OpenEHR::AM::OpenEHRProfile::DataTypes::Text::CCodeReference.new(args)
end
```

- ① C_CODE_REFERENCE 限定の正規化: `[]` のままだと CCodePhrase#valid_value? が
  全コード拒否になる（text.rb:18-30）。実在インスタンスは inline code_list を持たない
  （ProblemList.opt:323-335）ので `[]`=「inline 制約なし」。c_code_phrase 側は不変更。
- ② 空要素 `<referenceSetUri/>` は nil 化 → モデルの空文字 ArgumentError はパース経路から
  到達不能。
- rm_type_name は c_code_phrase 同様 `'CODE_PHRASE'` 固定（実インスタンスと一致）。

### D3. 未知 xsi:type フォールバック仕様

- **場所: children ディスパッチ（xml_constraint_parsing.rb:63-70）のみ**。
  attributes(:52)/expr 系/primitive-item はスキーマ上閉集合なのでガード対象外
  （コードコメントに理由明記）。children だけがベンダー拡張の開集合
  （C_CODE_REFERENCE がその実証）。
- 機構: `handler = type_name.downcase` を `respond_to?(handler, true)` でガード
  （ハンドラは全部 private なので第 2 引数 true 必須）。未知なら:

```ruby
warn "openehr parser: unknown constraint type \"#{type_name}\" at #{child_node.path}; treating as C_COMPLEX_OBJECT (type-specific constraints dropped)"
c_complex_object(child, child_node)   # :31 と同アリティ、呼び出し互換確認済み
```

- 警告手段: **Kernel#warn**（logger 皆無、deprecation の既存流儀と一致）。警告文は
  リリース後 stderr-grep の事実上 API になるため上記文字列をコミットとする。
- **縮退リスク（明記事項）**: c_complex_object は rm_type_name/occurrences/node_id/
  attributes しか読まないため、未知型固有の制約ペイロードは**落ち、当該ノードの
  validation はテンプレート作者の意図より寛容化**する。warn で非サイレント化。
  ガードのコードコメント・History.txt・PR 本文の 3 箇所に記載すること。
- ParseError で落とす案は棄却: 異種ツール（Ocean/Archetype Designer/Better）の実 OPT を
  読むのが本ライブラリの使命で、AOM 上どのノードも C_OBJECT コアは valid なので
  スーパークラス扱いは意味論的に健全。1 ノードのために数千行テンプレート全体を
  落とす方が全既知コンシューマ（openehr-rails, anlage）にとって悪い。
- 保持される既存挙動: `c_dv_state` はメソッドが存在するので respond_to? true →
  従来通り NotImplementedError（意図的、spec で固定する）。構造不正な未知ノード
  （occurrences 欠落）は CObject 検証（constraint_model.rb:119-124）で従来通り raise。
- 既知の許容 caveat（修正しない・記録のみ）: (a) 既存 Ruby メソッド名と衝突する型名
  （例 `OBJECT_ID`→`object_id`）はガードを素通りして ArgumentError — 今日もクラッシュする
  入力クラスで後退なし。(b) type 属性自体が無い children は nil.text で従来通り
  NoMethodError — スキーマ違反、範囲外。

### 互換性影響（重要: 純粋な追加的変更ではない）

- **唯一の既存契約変更**: `spec/lib/openehr/parser/xml_archetype_parser_spec.rb:145-206`
  「raises a ParseError for an unknown xsi:type in the definition tree」の意図が置換される。
  この spec の C_SOMETHING_UNKNOWN は occurrences も欠くため、変更後も
  「occurrences 欠落 → ArgumentError → ParseError ラップ」で*偶然*通り続けるが、
  意図が死ぬので誠実に書き換える（Cycle 3 参照）。ユーザ承認済み（2026-08-22）。
  **→ 詳細は下記「調査補遺」節を参照。この ParseError は実際には unknown xsi:type 専用の
  契約ではなく、汎用 rescue の偶発的副作用だったことが実証された。**
- OPTParser 経路は現状「素の NoMethodError」なので純粋な改善。
- serializer: CCodeReference は `when ...CCodePhrase`（xml_serializer.rb:234, `===` は
  サブクラスに match）に落ち、パース産物（terminology_id/code_list とも nil）なら
  any_allowed? true → :475 で early return → **クラッシュせず lossy**
  （referenceSetUri 消失、無制約 C_CODE_PHRASE に縮退）。ラウンドトリップ対応は
  キュー #5（RMJSONSerializer ⇔ create_from_json）とは別枠の XML serializer 課題として
  明示的に本 PR の範囲外とする。History.txt に lossy である旨を記載する。

## 調査補遺（2026-08-22）: xml_archetype_parser_spec.rb:145 が master で green である理由

Cycle 3 で書き換える既存 spec が「なぜ今 green なのか」を実ソースの読解と実行の両方で
検証した。結論: **ParseError は unknown xsi:type に対する意図的・型別の契約ではなく、
XMLArchetypeParser#parse を包む汎用 `rescue StandardError` の偶発的副作用**であり、
挙動は経路依存（OPTParser と不整合）だった。

### 1. ParseError の発生源

`lib/openehr/parser/xml_archetype_parser.rb:21-27`:

```ruby
def parse
  archetype
rescue OpenEHR::Parser::ParseError
  raise
rescue StandardError => e
  raise OpenEHR::Parser::ParseError, "invalid XML archetype (#{@filename}): #{e.class}: #{e.message}"
end
```

`rescue StandardError => e` は例外の**クラスも内容も一切検査しない**汎用ラッパー。
`XMLArchetypeParser#parse` はこの 1 箇所にしか rescue を持たない
（同ファイル内の他メソッドに rescue なし、確認済み）。

実行して確認（`bundle exec ruby` でクラス名・メッセージ・backtrace を捕捉、tmp スクリプト・
非コミット）:

```
$ parser.send(:archetype)  # parse のラップを迂回
RAW EXCEPTION CLASS: NoMethodError
RAW EXCEPTION MESSAGE: undefined method 'c_something_unknown' for an instance of OpenEHR::Parser::XMLArchetypeParser
BACKTRACE TOP:
  lib/openehr/parser/xml_constraint_parsing.rb:68:in 'block in ...#children'
  ...

$ parser.parse
parse() EXCEPTION CLASS: OpenEHR::Parser::ParseError
parse() EXCEPTION MESSAGE: invalid XML archetype (...): NoMethodError: undefined method 'c_something_unknown' for an instance of OpenEHR::Parser::XMLArchetypeParser
```

`:145` の spec が捕捉している `ParseError` は、`xml_constraint_parsing.rb:68` の
`send child.attributes['type'].text.downcase, ...` が投げる**生の NoMethodError を
そのまま文字列化してラップしたもの**。unknown xsi:type を検知する特別なロジックは
どこにも存在しない — 同じ rescue はタイポによる NoMethodError や無関係な ArgumentError
も区別なく同じ `ParseError` に変換する。

### 2. OPT parser 経路との差分（実行して確認）

`lib/openehr/parser/opt_parser.rb:42-63`（`#parse`）には rescue が**一切ない**
（構文的にも確認済み、begin/rescue 節は存在しない）。同一の unknown xsi:type 入力
（同じ `children` ディスパッチ、xml_constraint_parsing.rb:68 は共有モジュールの単一定義）
を `OPTParser` に通すと:

```
OPTParser#parse EXCEPTION CLASS: NoMethodError
OPTParser#parse EXCEPTION MESSAGE: undefined method 'c_something_unknown' for an instance of OpenEHR::Parser::OPTParser
Is it OpenEHR::Parser::ParseError? false
```

**生の NoMethodError がそのまま呼び出し元へ伝播する** — `XMLArchetypeParser` 経路とは
異なる結果になる。

### 3. 判定: 経路依存（不整合）— 全経路で堅い契約ではなかった

同一のディスパッチ機構（`XMLConstraintParsing#children`、両パーサが同一モジュールを
include）に対して同一の不正入力を与えても、結果が `ParseError`（XMLArchetypeParser）と
生の `NoMethodError`（OPTParser）に分かれる。これは「unknown xsi:type は ParseError に
なる」という**検証された契約ではなく**、`XMLArchetypeParser#parse` にたまたま存在する
汎用 rescue の副作用が、たまたまこの入力にも及んでいただけ、と判定する。
`spec/lib/openehr/parser/xml_archetype_parser_spec.rb:145` のテスト名
「raises a ParseError for an unknown xsi:type」は、実装が実際には持っていない
型別の意図性を主張しすぎていた。

### 4. History.txt / PR 本文の文言方針

上記の判定に基づき、「意図的な契約を変更する」ではなく「**汎用 rescue の偶発的副作用として
経路ごとに不統一だった挙動を、明示的かつ両経路で統一された挙動に置き換える**」という
文言を採用する。具体的には:

> Previously, an unknown constraint `xsi:type` only produced a `ParseError` on the
> `XMLArchetypeParser` path, and only as an incidental side effect of a generic
> `rescue StandardError` around the whole parse — not because of any type-specific
> handling. `OPTParser`, which shares the exact same dispatch code, had no such
> rescue and raised a raw `NoMethodError` for the identical input. The two parsers
> disagreed on the same bug. This change makes both paths behave the same way: an
> unrecognized type now warns and falls back instead of crashing (raw or wrapped)
> either way.

### 5. semver への影響

タスク指示の条件（「契約が全経路で堅牢だった場合のみ 2.4.0 の再考材料を提示」）は
**成立しない** — 調査の結果は「堅牢な契約」ではなく「経路依存の偶発的副作用」だった。
よって 2.4.0 再考の材料は無く、既定の **2.3.1 (patch) を支持する追加根拠**として
扱う。決定は引き続きユーザに委ねる。

### 6. 修正後、当該 rescue 箇所は死にコード化するか

**しない。** `XMLArchetypeParser#parse` の `rescue StandardError => e`
（xml_archetype_parser.rb:25-26）は、D3 の fix 後も以下の経路で引き続き到達可能:

- **構造不正な fallback ノード**: 未知型でも `<occurrences>` を欠く場合、fallback 先の
  `c_complex_object` は `CObject` の必須検証（constraint_model.rb:119-124）で
  `ArgumentError` を投げ、この rescue が引き続き `ParseError` にラップする
  （Cycle 3 の書き換え後 spec の第 2 例がこれを固定する）。
- **children 以外の未知型**: `attributes()` dispatch（xml_constraint_parsing.rb:52）や
  expr 系 dispatch は D3 のスコープ外（閉集合と判断、ガード対象外）なので、
  そこで発生する NoMethodError は今まで通りこの rescue に到達する。
- **その他の内部エラー全般**: archetype 構築中の無関係な StandardError
  （不正な日付、識別子など）に対する汎用セーフティネットとしての役割は変わらない。

### 7. 共有 dispatch へのガードで両パーサの挙動が揃うことの確認

`children`（xml_constraint_parsing.rb:63-70）は `XMLConstraintParsing` モジュールの
単一定義であり、`OPTParser`（opt_parser.rb:9）・`XMLArchetypeParser`
（xml_archetype_parser.rb:17）の両方が同一定義を include している。D3 のガードを
そこに追加すれば、**構造的に妥当な未知型ノードに対しては両パーサとも例外を投げず、
同一の warn を出し、同一の CComplexObject フォールバックを返す**ようになることを
確認済み（コード読解 + 3 節の実行結果より）。両パーサが唯一なお乖離するのは
「構造不正な fallback ノード」等、D3 のスコープ外にある一般的な内部エラー処理の
非対称性（OPTParser は依然無条件で raw 例外、XMLArchetypeParser は依然 ParseError
ラップ）であり、これは本 PR 以前から存在する別種の非対称性で、範囲外として記録するに
留める。

## Issue 増補用サマリ（英語・ペースト用 — Anlage 側ドラフトへ中継）

```markdown
## Investigation update (2026-08-22): the `ParseError` in the existing
unknown-`xsi:type` spec is not a real, type-specific contract

Schema authority (openEHR/specifications-ITS-XML, `components/AM/Release-1.4/Template.xsd:115-123`):

    <xs:complexType name="C_CODE_REFERENCE">
      <xs:complexContent>
        <xs:extension base="C_CODE_PHRASE">
          <xs:sequence>
            <xs:element name="referenceSetUri" type="xs:anyURI"/>
          </xs:sequence>
        </xs:extension>
      </xs:complexContent>
    </xs:complexType>

`C_CODE_REFERENCE` is a straightforward extension of `C_CODE_PHRASE` adding one
`referenceSetUri` element - confirming the planned `CCodeReference < CCodePhrase`
Ruby model is spec-faithful.

Separately, while scoping the "unknown `xsi:type` should not crash the parser"
defense that accompanies the `C_CODE_REFERENCE` fix, we traced why
`spec/lib/openehr/parser/xml_archetype_parser_spec.rb:145` ("raises a ParseError
for an unknown xsi:type in the definition tree") currently passes on `master`.

Both `OPTParser` and `XMLArchetypeParser` share one dispatch method,
`XMLConstraintParsing#children` (`lib/openehr/parser/xml_constraint_parsing.rb:68`),
which does `send child.attributes['type'].text.downcase, child, child_node` with
no guard. For an unknown type this raises a bare `NoMethodError`. We reproduced
both parsers against the same unknown-`xsi:type` input and captured the actual
exception classes:

- `XMLArchetypeParser#parse` (`lib/openehr/parser/xml_archetype_parser.rb:21-27`)
  wraps it: `rescue StandardError => e; raise ParseError, "...: #{e.class}: #{e.message}"`.
  This rescue clause does not inspect the exception type or message at all - it
  wraps *any* `StandardError` raised anywhere while building the archetype, not
  specifically unknown-`xsi:type` errors.
- `OPTParser#parse` (`lib/openehr/parser/opt_parser.rb:42-63`) has no rescue at
  all. The identical input raises a raw `NoMethodError` straight to the caller.

So the same bug, through the same shared dispatch code, currently produces two
different outcomes depending only on which of the two parser classes is used.
The existing spec's name overstates the implementation: there is no type-specific
"unknown xsi:type -> ParseError" contract, only an incidental side effect of one
parser's generic top-level rescue.

This supports (but doesn't by itself force) treating the fix as behavior
unification rather than a breaking contract change: both parsers will handle an
unrecognized constraint type the same way (a warning plus a same-shape fallback
node) instead of one silently succeeding-via-blanket-rescue and the other
crashing raw. Final call on wording/semver is the maintainer's.
```

### Cycle 0 — Acceptance red（バグの end-to-end 再現）

- **新規 fixture** `spec/lib/openehr/opt_parser/code_reference_template.opt`（~110 行）:
  minimum_template.opt の骨格（language/description/template_id/concept/definition +
  archetype_id + term_definitions〔text/description items 必須, opt_parser.rb:149-168〕）の
  category → DV_CODED_TEXT → defining_code 連鎖に、**ProblemList.opt:323-335 の
  C_CODE_REFERENCE 要素を逐語転写**。冒頭 XML コメントで出所明記:
  「referenceSetUri terminology:http://id.who.int/icd/release/11/mms を含む children 要素は
  openEHR Archetype Designer 生成の実 OPT（anlage repo spec/fixtures/opt/ProblemList.opt
  323-335 行）から逐語コピー。中間 EVALUATION/ITEM_TREE/ELEMENT 階層は縮約」。
- **新規 spec** `spec/lib/openehr/opt_parser/opt_parser_code_reference_spec.rb`
  （integration context）: `optparser.parse` が raise しない / **stderr に warn も出ない**
  （フォールバックでなく正規ハンドラ処理である証明）/
  `opt.definition.attributes[0].children[0].attributes[0].children[0]` が
  CCodeReference instance / reference_set_uri 完全一致 / rm_type_name 'CODE_PHRASE' /
  occurrences 0..1 / path `'/category/defining_code'` / terminology_id nil / code_list nil /
  any_allowed? true。
- red 確認: NameError（定数なし）。**Cycle 2 完了まで red のまま維持**（stub で潰さない）。

### Cycle 1 — モデルクラス

- **Red — 新規** `spec/lib/openehr/am/openehr_profile/data_types/text/c_code_reference_spec.rb`
  （c_archetype_root_spec.rb の新スタイル: require 'spec_helper' / let / FQCN）:
  CCodePhrase の kind_of / reference_set_uri round-trip / `''` で ArgumentError /
  nil は許容 / occurrences 欠落で ArgumentError（継承検証の確認）/
  uri のみ→ any_allowed? true・valid_value?('C92') true /
  code_list: ['C92'] 併用時 valid_value?('Z00') false（継承 enforcement 健在）。
- **Green — 変更** `lib/openehr/am/openehr_profile/data_types/text.rb`（:44 の後）:

```ruby
class CCodeReference < CCodePhrase
  attr_reader :reference_set_uri

  def initialize(args = { })
    super
    self.reference_set_uri = args[:reference_set_uri]
  end

  def reference_set_uri=(reference_set_uri)
    if !reference_set_uri.nil? && reference_set_uri.empty?
      raise ArgumentError, 'invalid reference_set_uri'
    end
    @reference_set_uri = reference_set_uri
  end
end
```

  クラスコメントに: Template.xsd 出所 / 寛容設計（nil 許容）の理由 / valid_value? を
  オーバーライドしない理由（D1 参照）を記載すること。

### Cycle 2 — パーサハンドラ

- **Red — 追記** opt_parser_code_reference_spec.rb に `describe '#c_code_reference'`
  （fragment パターン: opt_parser_new_constraints_spec.rb:11-15 の helper を複製、
  `parser.send(:c_code_reference, node, Node.new)`）:
  Fragment A = ProblemList 逐語断片 → CCodeReference / uri 一致 / code_list **nil** /
  terminology_id nil / path '/'。
  Fragment B = terminology_id + code_list 併記 → 'ICD10' / ['C92']（継承読み取り保持）。
  Fragment C = 空 `<referenceSetUri></referenceSetUri>` → uri nil, raise しない。
- **Green**: D2 のハンドラを（最初は自己完結の重複コードで）実装 → Cycle 0 も green 化。
- **Refactor**: `code_phrase_constraint_args` 抽出 + c_code_phrase 載せ替え（D2）。
  既存 C_CODE_PHRASE カバレッジ（minimum_template/eReferral fixture）がガード。全 suite green。

### Cycle 3 — 未知型フォールバック

共有 dispatch（`children`, xml_constraint_parsing.rb:63-70）を直接叩く単体テストと、
OPT/XML archetype 両経路それぞれの end-to-end テストの 3 点で、「両パーサが同一の
未知型入力に同一の挙動（warn + CComplexObject フォールバック）を返す」ことをテストで
固定する（調査補遺 7 節の結論をテストとして定着させる）。

- **Red — 追記（単体・共有 dispatch）** `spec/lib/openehr/opt_parser/opt_parser_error_cases_spec.rb`
  に `context 'unknown constraint child types'`:
  `xsi:type="C_TERMINOLOGY_CODE"`（AOM2 実在名で現実的）+ 完全 occurrences →
  `parser.send(:children, ...)` が raise せず
  `output(/unknown constraint type "C_TERMINOLOGY_CODE" at \//).to_stderr` /
  結果先頭が CComplexObject（rm_type_name/occurrences 保持）/
  `xsi:type="C_DV_STATE"` は従来通り NotImplementedError（ガードが swallow しない証明）。
- **Red — 追記（新規・OPT 経路 end-to-end）** 同じ spec ファイルに
  `context 'unknown xsi:type via OPTParser#parse (end-to-end)'`:
  完結した OPT ドキュメント（heredoc + Tempfile。xml_archetype_parser_spec.rb:145-206 の
  既存手法を踏襲、新規 .opt fixture ファイルは作らない — 防御コードのテストであり
  実アーティファクト由来の要件は適用外）で、definition の
  `attributes[xsi:type=C_SINGLE_ATTRIBUTE]/children` に上と同じ
  `xsi:type="C_TERMINOLOGY_CODE"`（occurrences 完備）を埋め込む。
  `result = nil; expect { result = OPTParser.new(path).parse }.to
  output(/unknown constraint type "C_TERMINOLOGY_CODE" at \//).to_stderr` /
  `result.definition.attributes[0].children[0]` が CComplexObject
  （rm_type_name はテスト用に埋め込んだ値と一致）。
  **これが XMLArchetypeParser 側書き換え後 spec（直下）と対をなす** — 同一の型名・同一の
  警告文言・同一のフォールバック形状を、ディスパッチを共有するもう一方の公開エントリ
  ポイントでも確認することで、「経路依存の不整合」が「経路非依存の統一挙動」に
  変わったことを実証する。
- **Red — 書き換え（XML archetype 経路 end-to-end）**
  `spec/lib/openehr/parser/xml_archetype_parser_spec.rb:145-206` を 2 例に置換
  （同一 XML テンプレート流用）:
  1. occurrences 完備の C_SOMETHING_UNKNOWN → raise せず warn、
     definition.attributes[0].children[0] が CComplexObject（rm_type_name 'DV_TEXT'）。
     spec の説明文はもはや「raises a ParseError for an unknown xsi:type」ではなく、
     実態（warn + fallback、ParseError にならない）を言い当てる名前に変更する
     （例: `'falls back to C_COMPLEX_OBJECT with a warning for an unknown xsi:type,
     matching OPTParser (see docs/design/fix-c-code-reference-plan.md investigation)'`）。
  2. 元 XML そのまま（occurrences 欠落）→ 従来通り ParseError
     （「生の NoMethodError を出さない」という元 spec の頑健性意図を新契約下で保存。
     ただし調査補遺の判定どおり、これは「unknown xsi:type 専用の契約」ではなく
     「構造不正ノードに対する汎用 StandardError→ParseError 変換」という、より正確な
     説明文にする）。
- **Green — 変更** `lib/openehr/parser/xml_constraint_parsing.rb:63-70`（D3 のコード）。
  Refactor なし（8 行のディスパッチにヘルパ抽出は過剰）。全 suite green。

### Cycle 4 — 仕上げ（TDD 外）

- `lib/openehr/version.rb` → `"2.3.1"`
- `History.txt` 先頭に追記（下記ドラフト）
- `bundle exec rspec`（3932 + 約 25 例, 0 fail 期待）+ `bundle exec rubocop`
  （**rubocop-rspec todo は再生成しない** — 7720 件は意図的除外。新規/変更ファイルは
  offense ゼロで書くこと。todo ファイルに差分が出た場合は却下）
- コミットは `Fix: ...` 流儀（`git log` 参照）。
  PR 本文に semver 判断（2.3.1 patch。「新公開クラス + エラー契約変更 = minor」という
  反対意見は調査補遺の実証により棄却済みである旨とその根拠）と縮退リスク段落を含めること。

## History.txt 記載案（=== 2.3.1 — 作業上の仮置き版数、Step 6 で最終確定）

Cycle 4 の実装時点ではこの版数（2.3.1）で `History.txt`/`lib/openehr/version.rb` を
書いてよい。ただし PR マージ後、tag 作成前の Step 6 で `git diff v2.3.0..master` の
実内容から最終版数を再判定すること（本文書「semver」節、`CLAUDE.md` の
Release convention）。矛盾があれば tag せず停止して再裁定を仰ぐ。

```
=== 2.3.1
Bug fix release: OPT parsing no longer crashes on C_CODE_REFERENCE
or other unknown constraint child types.

* OPTParser (and XMLArchetypeParser, which shares the same constraint
  readers) raised NoMethodError on templates containing
  <children xsi:type="C_CODE_REFERENCE"> - emitted by tools such as
  Archetype Designer when a DV_CODED_TEXT defining_code is bound to an
  external terminology reference set. Such children now parse into the
  new ...Text::CCodeReference (a CCodePhrase subclass, mirroring
  Template.xsd's C_CODE_REFERENCE extension) carrying referenceSetUri
  as #reference_set_uri. valid_value?/any_allowed? do not expand the
  reference set (no terminology service is wired), so an otherwise
  unconstrained C_CODE_REFERENCE validates permissively.
* Unknown <children> xsi:type values no longer abort the parse: an
  unrecognized constraint type falls back to plain C_COMPLEX_OBJECT
  reading with a Kernel#warn to stderr naming the type and node path.
  The fallback keeps the C_OBJECT core but drops the unknown type's
  specific constraint payload, so validation of that node becomes more
  permissive than the template author intended - the warning makes
  this visible. There was no prior verified, type-specific contract
  here to preserve: OPTParser and XMLArchetypeParser share the exact
  same dispatch code, but only XMLArchetypeParser wrapped the
  resulting NoMethodError into a ParseError, and only as an incidental
  side effect of a generic top-level `rescue StandardError` around
  its whole parse (confirmed by inspecting the wrapped error - the
  ParseError's message was, character for character, the stringified
  NoMethodError). OPTParser had no such rescue and raised the same
  NoMethodError raw. The two parsers already disagreed on the same
  bug; this release makes them agree. A structurally invalid unknown
  node (missing occurrences) still raises - via ParseError on the
  XMLArchetypeParser path, raw on the OPTParser path, matching each
  path's pre-existing general error-handling behavior (tracked as a
  separate backlog item, not changed by this release). C_DV_STATE
  still raises NotImplementedError as before.
* Not included: XMLSerializer does not yet emit C_CODE_REFERENCE -
  serializing a parsed CCodeReference degrades it to an unconstrained
  C_CODE_PHRASE (referenceSetUri dropped). Round-trip support is
  deferred to the serializer work item.
```

## semver: **2.3.1 (patch)** — 作業上の仮置き（2026-08-22 ユーザ裁定）

主意は「schema 準拠の実在 OPT がパースできない」バグ修復。CCodeReference は修正の
手段であり既存 API は不変（後方互換）。反対意見（新公開クラス + XMLArchetypeParser の
エラー契約変更 = 厳密には minor）は「調査補遺」5 節の実証により棄却済み — ParseError は
検証された契約ではなく偶発的副作用だったため、「契約変更」という意味での minor 論拠は
成立しない。

**ただし実装完了時点（Step 4 レビュー）ではなく、tag 作成時点（Step 6）で
`git diff <直前タグ>..master` の実内容から最終版数を再判定すること**
（`CLAUDE.md` の Release convention、openehr-rails 0.4.1 の教訓）。
実内容が本節の判定（patch）と矛盾する場合は tag せず、再裁定を仰いで停止する。
本 plan 文書の「2.3.1」表記はすべて Step 6 まで仮置きとして扱う。

## 検証（実装完了の受け入れ基準）

1. `bundle exec rspec` 全走 0 fail（ベースライン 3932 例 + 新規約 25 例）
2. `bundle exec rubocop` — 新規/変更ファイル offense ゼロ、rubocop-rspec todo ファイルに
   差分なし（再生成しない）
3. 実アーティファクト実証（tmp スクリプトで確認・コミットしない）:
   `OPTParser.new('/home/skoba/src/anlage/spec/fixtures/opt/ProblemList.opt').parse` が
   raise せず、definition 木に reference_set_uri
   'terminology:http://id.who.int/icd/release/11/mms' の CCodeReference が現れること
4. 逆検証: 既存 fixture（minimum_template/eReferral）のパース結果に差分がないこと
   （既存 spec が担保）

## 変更ファイル一覧

- 変更: `lib/openehr/parser/xml_constraint_parsing.rb`（children ガード, :63-70）
- 変更: `lib/openehr/parser/xml_domain_type_parsing.rb`（c_code_reference + ヘルパ抽出）
- 変更: `lib/openehr/am/openehr_profile/data_types/text.rb`（CCodeReference 追加）
- 変更: `lib/openehr/version.rb`, `History.txt`
- 変更: `spec/lib/openehr/parser/xml_archetype_parser_spec.rb`（:145-206 の契約書き換え）
- 変更: `spec/lib/openehr/opt_parser/opt_parser_error_cases_spec.rb`（フォールバック spec）
- 新規: `spec/lib/openehr/opt_parser/code_reference_template.opt`（出所明記 fixture）
- 新規: `spec/lib/openehr/opt_parser/opt_parser_code_reference_spec.rb`
- 新規: `spec/lib/openehr/am/openehr_profile/data_types/text/c_code_reference_spec.rb`
