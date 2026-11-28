# 計画: AQL で COMPOSITION の category・language・territory・composer を引く

Issue: #156。Refs R-20261128-14(範囲は 4 つとも。composer は name と external_ref の id までを目安に)。

形: (b) enhancement。semver: minor(AQL で引けるパスが増える。公開 API に足すだけで、
いま通るクエリの結果は変わらない)。

## いまの作り(読んだもの、master `b398d56`)

- `lib/openehr/aql/engine/path_evaluator.rb:30`: `ALLOWED_TERMINAL_HOPS`(どの型でも、その名前の
  reader があれば通る名前)は `code_string defining_code magnitude name time value`。
- `path_evaluator.rb:35-40`: `TYPED_TERMINAL_HOPS`(1 つの RM の型と、その下位の型だけで通る名前)。
  いまは Locatable、Archetyped、EventContext の 3 つ。
- `path_evaluator.rb:162-178`: `navigate_terminal` は、`terminal_hop_allowed?` が偽なら
  `ExecutionError "unsupported path attribute ..."` を上げる。generic な名前は `respond_to?` で決まる
  (reader が無ければ、同じ誤り)。
- `lib/openehr/rm/composition.rb:11`: COMPOSITION の `attr_reader :language, :category, :territory, :composer`。
  `path_attribute` は `content` と `context` だけ(`:14`)。
- `lib/openehr/rm/common/generic.rb:89-90`: `PartyProxy` の `attr_accessor :external_ref`。
  `:101-102`: `PartyIdentified` の `attr_reader :name`(String)。`PartySelf`(`:97`)には name が無い。
- `lib/openehr/rm/support/identification.rb:25-26`: `ObjectRef` の `attr_reader :namespace, :type, :id`。
  `PartyRef < ObjectRef`(`:316`)。id は ObjectID で、`value` を持つ(`:8-9`)。

## 足す名前

`TYPED_TERMINAL_HOPS` に 3 つの項目を足す。

| 型 | 名前 | 引けるようになるパスの例 |
|---|---|---|
| `OpenEHR::RM::Composition::Composition` | `category composer language territory` | `c/category/value`、`c/category/defining_code/code_string`、`c/language/code_string`、`c/territory/code_string`、`c/composer/name` |
| `OpenEHR::RM::Common::Generic::PartyProxy` | `external_ref` | `c/composer/external_ref/...` |
| `OpenEHR::RM::Support::Identification::ObjectRef` | `id` | `c/composer/external_ref/id/value` |

`name`、`value`、`code_string`、`defining_code` は、すでに generic なので、足さない。
external_ref の `namespace` と `type` は、目安の外なので足さない(要るクエリが出たら足す)。

## 名前の衝突の確かめ(CLAUDE.md の決まり)

`grep -rnE "attr_(reader|accessor)[^#]*:<name>\b|def <name>\b" lib` の結果(master `b398d56`)と、扱い:

- `category`、`territory`、`composer`: COMPOSITION(`composition.rb:11`)だけ。衝突なし。
- `language`: COMPOSITION のほかに、ENTRY(`rm/composition/content/entry.rb:16`)、DV_TEXT
  (`rm/data_types/text.rb:90`)、DV_ENCAPSULATED(`rm/data_types/encapsulated.rb:13`)、
  RESOURCE_DESCRIPTION_ITEM と TRANSLATION_DETAILS(`rm/common/resource.rb:45`、`:104`)、
  `am/template.rb:93`、`parser/opt_parser.rb:105`(どちらも AQL のデータには来ない)。
  COMPOSITION に型を限って足すので、ほかでは引けないまま。spec で、OBSERVATION の
  `o/language/code_string` がいまと同じ誤りを上げることを pin する。
- `external_ref`: PARTY_PROXY(`rm/common/generic.rb:90`)だけ。PartySelf、PartyIdentified、
  PartyRelated が受け継ぐ。EHR_STATUS の `subject` や ENTRY の `subject` は hop に無いので、
  `e/ehr_status/subject/external_ref` と `o/subject/external_ref` は、いまと同じく引けない(変えない)。
- `id`: ObjectRef(`identification.rb:26`)のほかに、DV_IDENTIFIER(`rm/data_types/basic.rb:69`)、
  `parser/adl_helper.rb:60` と `parser/opt_parser.rb:247` の Node(どちらも AQL のデータには来ない)。
  ObjectRef に型を限るので、DV_IDENTIFIER の `.../id` は引けないまま。spec で pin する。
  `id` を generic にしないのは、このため。

## 決めたこと(裁定に無い点)

1. PartySelf の composer で `c/composer/name` を引くと、generic な名前の決まりのとおり
   `ExecutionError` を上げる(PartySelf には name が無い)。変えない。anlage の書く側は composer を
   PartyIdentified で作る(読み取りで確かめた: skoba/anlage `app/lib/opt/composition_builder.rb:58`)。
   null を返すように変えるのは、generic な名前すべての決まりを変えることになるので、この Issue の外。
2. `external_ref` が無い(nil)ときの `c/composer/external_ref/id/value` は null(パスの途中の nil は
   null、`path_evaluator.rb:89-91`)。
3. WHERE と ORDER BY は、SELECT と同じ道で値を引く。特別なことはしない。

## spec(Red から)

新しい spec `spec/lib/openehr/aql/engine/composition_attributes_spec.rb`。データは
`BloodPressureBuilder` の COMPOSITION(category `event`/`433`、language `en`、territory `JP`、composer
`Dr. Test`)と、spec の中で external_ref を持つ composer に差し替えたもの。

- SELECT: `c/category/value` は `event`、`c/category/defining_code/code_string` は `433`、
  `c/language/code_string` は `en`、`c/territory/code_string` は `JP`、`c/composer/name` は `Dr. Test`、
  `c/composer/external_ref/id/value` は差し替えた id、external_ref の無いものは nil。
- WHERE: `c/category/defining_code/code_string = '433'` で選ばれ、`= '431'` で選ばれない。
  `c/composer/name = 'Dr. Test'` で選ばれる。
- 衝突の pin(regression pin。いまも赤にならない): `o/language/code_string` と、DV_IDENTIFIER の
  `.../id` は、`unsupported path attribute` を上げる。

## 文書と変更履歴

- README の英語版と日本語版: AQL の節に、引けるようになった COMPOSITION の属性を 1 段落で書く。
- `changelog.d/156-aql-composition-attributes.md`: minor。
