# Round 2 / openehr 2.5.0 計画（ゲート報告）

- 裁定 ID: R-20261117-3
- 対象 Issue: #60, #48, #31, #43, #58, #49（2.5.0 候補）／#36, #59（2.5.0 外の候補）／#56 = PR #57（独立軸）
- 状態: **計画のみ。実装はゲート承認のあと**（CLAUDE.md: explore → plan → approval → implementation）
- 測定の基準点: `master` = `96eb4e2`、公開版 2.4.3、2026-11-20、Ruby 4.0.7（master の `.ruby-version`。4.0.10 への bump は PR #61 で未マージ）
- 各 Issue の実装 PR は、この文書の該当節を計画として参照する（Issue ごとの補足が要る場合だけ個別の plan を足す）

「実行」と書いた事実は 2026-11-20 にこのセッションで実行して確認したもの、「推論」はその根拠を併記したもの。
他リポジトリ（`/home/skoba/src/anlage` = `skoba/anlage` `a376bc4`、`/home/skoba/src/openehr-rails` = `skoba/openehr-rails`
作業ツリー `ef6c581`〔`dev/ruby-4.0.10`〕、`origin/master` `97924f3`）は読み取りのみ。

## 1. 承認をお願いしたい判断（6 件）

| # | 判断 | 推奨 |
| --- | --- | --- |
| D1 | #43 のブラケットの中身: Issue の AC どおり `[at0000]` か、`[archetype_id]` か | **`[archetype_id]`**（3.4 節。eReferral.opt の埋め込みルート 40 件で、path が一意になるのは `[at0000]` 形で 10 通り、`[archetype_id]` 形で 35 通り）。採用なら実装前に #43 の AC を書き換える |
| D2 | #49 を 2.5.0 に入れるか | **最小形（Option A）を最後尾で入れる**。11/26 までに #58 までがマージされていなければ見送る（3.6 節） |
| D3 | #57 の扱い | **最初の実装 PR より前にマージ**（4 節） |
| D4 | #31・#58 の fixture 用に他リポジトリの実 OPT を「reduced」として取り込む越境 | #31 は openehr-rails の `bmi_calculation.opt`、#58 は anlage の `spec/fixtures/opt/jp_referral.opt` から縮約。読み取り → このリポジトリへ縮約版を書く、までを認めてほしい（本リポジトリの OPT 4 件はどちらも再現できない。3.3・3.5 節） |
| D5 | #59（日付のみの DV_DATE_TIME）の位置づけ | マガジンに載せ、**2.5.0 には入れない**（統括の希望順に無く、仕様確認が先。anlage 側に `instance_variable_set` の迂回があるので 2.5.x の先頭候補）|
| D6 | 日付案（5 節）| 11/28 棚卸し、11/30 タグ・publish |

## 2. Round 2 magazine の見直し（2026-08-25 仮置き・10/20 追記 → 現況）

`docs/backlog.md` の該当節に「2026-11-20 見直し」として追記した。要点:

1. **#31 の迂回保有者は 1 箇所に減っている。** anlage 側の生 XML 再解析は撤去済み（`skoba/anlage#19`。
   anlage `app/lib/opt/pathcard_extractor.rb:312-324` のコメントが「迂回実装は無くなった」と述べ、rails 側 `parser.rb:47-50` のコメントも同じ — 実行: 両コメントを読んだ。`:327` 以下の実装本体は読んでいない）。
   残りは openehr-rails `lib/openehr_rails/opt/parser.rb:24`（呼び出し）と `:43-`（`populate_term_bindings!` 以下）のみ。
2. **#58 と #59 がマガジンに無い**（どちらも 2026-09-25 起票）。#58 は統括の希望順で「次」。#59 は D5。
3. **#60 は直す場所が 2 箇所ある。** SELECT／WHERE の path（`path_evaluator.rb:115-119`）に加えて、CONTAINS の位置
   （`contains_resolver.rb:150-151`）も name を見ていない。実行: `CONTAINS CLUSTER k[<archetype_id>, 'Second']` が
   `First`・`Second` の 2 行を返した（期待は 1 行）。マガジンの「併せて確認」は「併せて直す」に変わる。
4. **#43 は修正形に分岐がある**（D1）。
5. **#49 に 3 件目の実需がある。** anlage 台帳 25 項（`c/archetype_details/template_id/value` に到達不能、未起票）。
   実行: `unsupported path attribute "archetype_details" on a OpenEHR::RM::Composition::Composition`。
   また Issue が指摘する `NoMethodError` の漏れも実行で確認した（`SELECT c/name/magnitude` →
   `NoMethodError: undefined method 'magnitude' for an instance of ...DvText`）。
6. **CKM 軸:** #56 は open、PR #57 は 9/20 から open のまま（4 節）。
7. **行番号:** マガジンと Issue が引く `path_evaluator.rb:23/96/115-119`、`history.rb:51/53`、
   `xml_constraint_parsing.rb:18-29`、`constraint_model.rb:488-502` は `96eb4e2` で一致。
   `opt_parser.rb` は #31 が引く `149-168` が現在 `151-170`、#58 が引く `132-163` は
   `component_terminologies` `121-125` と `archetype_terminology`／`term_definitions` `151-170` にあたる。

## 3. 2.5.0 の範囲と順序

順序案（1 Issue = 1 ブランチ = 1 PR、各 PR は直前の PR が master に入ってから切る）:

| 順 | Issue | 形 | 触る行が重なる相手 |
| --- | --- | --- | --- |
| 1 | #60 name 述語 | (a) bug | なし（`path_evaluator.rb:115-124`、`contains_resolver.rb:150-151`）|
| 2 | #48 events/time | (a) bug | #49（`path_evaluator.rb:23`）|
| 3 | #31 term_bindings | (b) enhancement | #58（`opt_parser.rb:151-159`）|
| 4 | #43 `[node_id]` | (a) bug | #58（`xml_constraint_parsing.rb:24-28`）|
| 5 | #58 ルートごとの term_definitions | (a) bug（公開 API の追加を伴う）| #31、#43 |
| 6 | #49 最小形（D2）| (b) enhancement | #48 |

並行できる組は (#60, #31) と (#48, #43)。#58 は #31 と #43 の両方のあと、#49 は #48 のあと。

**semver:** 2.5.0 は minor。根拠は #31（これまで nil だった `term_bindings` が入る）と #58（`CArchetypeRoot` に公開アクセサが増える）。
#60・#48・#43 単独なら patch 相当。最終判定はタグ前に `git diff v2.4.3..master` の実内容で行う（CLAUDE.md Release convention）。
`History.txt` は各 PR がマージ時に `=== Unreleased` 節へ書く。

### 3.1 #60 — AQL の name 述語（首位群）

- **現状（実行）:** 同一アーキタイプの CLUSTER 2 件を name で区別する合成ツリーで、
  SELECT も WHERE も `path segment "items[#<...ArchetypePredicate:0x..>]" matched 2 items` で落ちる。
  RM 側は正しい（`items_at_path` が name なし 2 件、name 付き 1 件）。CONTAINS は落ちずに 2 行返す（黙って誤答）。
- **原因:** `path_evaluator.rb:117-118` が `predicate.archetype_id` だけを返す。`contains_resolver.rb:150-151` が
  `archetype_node_id == predicate.archetype_id` だけを見る。パーサは値を保持している（`parser.rb:184`）。
- **Red から始める spec の見出し**（`spec/lib/openehr/aql/engine_spec.rb`）:
  1. `SELECT: items[archetype_id, 'name'] が同アーキタイプの兄弟から 1 件を選ぶ`
  2. `WHERE: 同じ path の比較で行を絞れる`
  3. `CONTAINS: CLUSTER k[archetype_id, 'name'] は name が一致するノードだけを束縛する`
  4. `name がパラメータのときは ExecutionError（未対応）を返す`
  5. `name なしの archetype 述語は従来どおり`（regression pin。赤にはならないと spec に明記）
- **触るファイル:** `lib/openehr/aql/engine/path_evaluator.rb`、`lib/openehr/aql/engine/contains_resolver.rb`、
  spec と fixture（`spec/lib/openehr/aql/fixtures/` に合成ビルダーを足す。種別は synthetic、アーキタイプ ID は作り物の名前）。
- **実装時の explore 項目:** name に `'` を含む場合の扱い（`path.rb:57` は `'#{@name}'` をそのまま連結する。
  NodePredicate の既存分岐 `path_evaluator.rb:133` と同じ制約なので、同じ挙動にそろえて記録する）。
  エラーメッセージに述語が `#<...>` で出る件は、同じ PR で直すかを PR 内で決める。
- **下流で撤去できる迂回:**
  - anlage `spec/integration/jp_referral_aql_spec.rb:39, :55` の `pending UPSTREAM_24`（解消すると失敗に変わるので外す）
  - anlage `spec/demo/cross_template_query_spec.rb:8`、`docs/demo/aql-queries.md:119` のデモクエリを紹介先医療機関で引く形へ
  - openehr-rails: なし（`lib/openehr_rails/aql/executor.rb:20` は例外を包み直すだけ）

### 3.2 #48 — events/time（首位群）

- **現状（実行）:** `SELECT o/data[at0001]/events[at0006]/time/value` →
  `unsupported path attribute "time" on a ...PointEvent`。
- **修正形:** `ALLOWED_TERMINAL_HOPS`（`path_evaluator.rb:23`）に `time` を足す。`path_attribute :time` を
  `Event` に宣言する代替形は取らない（`path_children`／`descendants_of` の走査対象に非 Locatable の DV_DATE_TIME が入り、影響面が広い）。
- **衝突スイープ（必須項目・実行済み）:** `lib/` で `time` を公開リーダーに持つクラスは
  `Event`（`history.rb:51`）、`Action`（`entry.rb:174`）、`Participation`（`generic.rb:171`）、
  `FeederAuditDetails`（`archetyped.rb:268`）。いずれも RM の正当な `time` 属性で、AQL から読めて困るものは無い。
  それ以外のオブジェクトに `time` を投げると `NoMethodError` が漏れる（既存 3 名と同じ失敗形。3.6 節）。
- **Red から始める spec の見出し**（同 `engine_spec.rb`、既存の血圧 fixture をそのまま使う）:
  1. `SELECT: events[...]/time/value がイベント時刻を返す`
  2. `WHERE: time/value の半開区間（>= 下限 AND < 上限）で範囲内の行だけを返す`
- **触るファイル:** `lib/openehr/aql/engine/path_evaluator.rb`（1 行とコメント）、spec。
- **注意:** 比較は ISO 8601 文字列の辞書順（既存の意味論）。オフセットが混在するデータでは時刻順と一致しない。
  spec は同一オフセットで書き、この制約を spec コメントと History に書く。
- **下流で撤去できる迂回:** anlage `docs/demo/aql-queries.md:76` の Q4 暫定形（ELEMENT 値での代替）を本来形へ。コードの迂回は無い。

### 3.3 #31 — OPT の term_bindings（首位群）

- **現状（実行）:** `opt_parser.rb:151-159` は `term_definitions` だけを渡す。本リポジトリの OPT 4 件に `<term_bindings>` は 0 件。
- **修正形:** `archetype_terminology` が OPT 固有の入れ子（`term_bindings[@terminology]/items[@code]/value/{terminology_id/value, code_string}`）を読み、
  `{ terminology => { code => [CodePhrase] } }` で `term_bindings:` に渡す。`code_string` は生のまま。無ければ nil のまま。
  `referenceSetUri`・`constraint_bindings` は対象外。
- **衝突スイープ（必須項目）:** openehr-rails の `OpenehrRails::Opt::Parser` は `OPTParser` のサブクラスで、private に
  `populate_term_bindings!`、`raw_term_bindings_by_archetype`、`nearest_archetype_id`、`binding_code_phrase` を持つ。
  上流で同名の private メソッドを足すとサブクラス側に上書きされるので、**この 4 名は使わない**。
  `component_terminologies(archetype_id, xml)` の名前と引数も変えない（サブクラスが `definition` 経由で呼ぶ）。
- **Red から始める spec の見出し**（`spec/lib/openehr/opt_parser/opt_ontology_spec.rb`）:
  1. `term_bindings が component_terminologies[archetype_id].term_bindings に正規形で入る`
  2. `1 つの at-code が複数ターミノロジー（SNOMED-CT と LOINC）に束縛されていれば両方残る`
  3. `code_string は分解せず OPT の表記のまま`
  4. `term_bindings の無いアーキタイプは nil のまま`（regression pin。rails の nil ガードとの互換）
- **fixture（D4）:** openehr-rails の `bmi_calculation.opt`（CKM 由来、at0004 に SNOMED-CT と LOINC）を縮約。種別 reduced、冒頭コメントに出所。
  SNOMED CT のコードは必要最小限にする（Issue の content firewall）。
- **触るファイル:** `lib/openehr/parser/opt_parser.rb`、spec、fixture 1 件。
- **下流で撤去できる迂回:**
  - openehr-rails `lib/openehr_rails/opt/parser.rb:24` の呼び出しと `:43-` のメソッド群（nil ガード `:60` で自動的に no-op になる）
  - 確認事項（rails 側）: rails の迂回は同一アーキタイプが複数回埋め込まれると CodePhrase を重ねて積む（`:79` 付近の `<<`）。
    上流はルートごとに作り直すので 1 件になる。rails の spec がこの差を固定していないかは 0.9.0 側で確認する（推論: コードの形から）。
  - anlage: なし（撤去済み）

### 3.4 #43 — 埋め込み C_ARCHETYPE_ROOT の `[node_id]`（次）

- **原因:** `xml_constraint_parsing.rb:24-26` はトップレベルだけを扱い、埋め込みルートの path にブラケットを足さない。
- **D1 の根拠（実行）:** eReferral.opt の埋め込みルート 40 件の node_id は `at0000` が 35、`at0000.1` が 5。
  `[node_id]` 形だと 40 件の path は 10 通りにしかならない（例: `/content[at0000]` が 5 件）。
  `[archetype_id]` 形なら 35 通りで、残る重複 5 組は同一アーキタイプの複数埋め込み（name で区別する #58・#60 の領域）。
  RM のデータ側 path と AQL も埋め込みルートは archetype_id で書く。anlage 台帳 22 項も同じ形を求めている。
- **Red から始める spec の見出し**（`spec/lib/openehr/opt_parser/opt_parser_spec.rb`、fixture は既存の eReferral.opt = real）:
  1. `埋め込み C_ARCHETYPE_ROOT の path は自身のブラケットで終わる（40 件すべて）`
  2. `子孫の path は埋め込みルートのブラケットを含む`
  3. `トップレベル definition の path は "/" のまま`（regression pin）
  4. `XMLArchetypeParser の path は変わらない`（regression pin。`xml_archetype_parser.rb:147-157` は root を自前で組む）
- **既存 spec への影響（実行）:** OPT spec で path を固定しているのは `minimum_template_spec.rb:94, :283` などで、
  埋め込みルート配下のものは無い。全 suite での確認は実装時に行う。
- **触るファイル:** `lib/openehr/parser/xml_constraint_parsing.rb`、spec。
- **下流で撤去できる迂回:** 直接は無い。anlage の抽出器と rails の `FieldExtractor` は `.path` を使わず自前で連結している
  （anlage 台帳 8 項・22 項）。`[archetype_id]` 形にすれば将来 `.path` へ寄せられるが、それは rails 側の別作業。

### 3.5 #58 — ルートごとの term_definitions（次）

- **現状:** `component_terminologies[archetype_id]` は後勝ち（`opt_parser.rb:121-125`）。`CArchetypeRoot` は
  `slot_node_id`／`archetype_id` だけを持つ（`constraint_model.rb:488-506`）。
- **本リポジトリの fixture では再現できない（実行）:** eReferral.opt は 7 アーキタイプが複数回埋め込まれているが、
  ルート間で term の集合が完全に同一（改名なし）。→ D4。
- **修正形:** `CArchetypeRoot#term_definitions`（Issue の AC どおり `{ lang => { code => ArchetypeTerm } }`）と
  `#term_bindings`（あれば）を足し、`c_archetype_root` がルートごとに渡す。`component_terminologies` の集約は互換のため残す。
  既存の集約側は `{ lang => [ArchetypeTerm] }`（`opt_parser.rb:169`）で形が違うが、既存の形は変えない（意図した不一致として History に書く）。
- **衝突スイープ（必須項目）:** `term_definitions`／`term_bindings` という ivar 名が `CArchetypeRoot` に増える。
  ivar を総なめするのは `rm_json_serializer.rb:68-69` だけ（実行: grep）。AM のノードがそこを通る経路が無いことを実装時に確認する。
  XML／ADL シリアライザは項目を明示して出すので影響しない見込み（推論: `xml_serializer.rb:157-164` の形から）。
- **Red から始める spec の見出し**（`spec/lib/openehr/opt_parser/` に新規 spec）:
  1. `同じアーキタイプを別名で 2 回埋め込んだ OPT で、各ルートが自分の at0000 の text を持つ`
  2. `ルートごとに改名された ELEMENT の term もルートごとに保持する`
  3. `component_terminologies[archetype_id] は従来どおり`（regression pin）
- **触るファイル:** `lib/openehr/am/archetype/constraint_model.rb`、`lib/openehr/parser/xml_constraint_parsing.rb`、
  `lib/openehr/parser/opt_parser.rb`、spec、fixture 1 件。
- **下流で撤去できる迂回:**
  - anlage `app/lib/opt/template_terms.rb`（クラス全体、67 行）と、それを使う `app/lib/opt/pathcard_extractor.rb:145-156`、
    対応する spec（`spec/lib/opt/pathcard_extractor_spec.rb:404, :475` の撤去条件コメント）
  - openehr-rails: #58 を参照する箇所は無い（実行: `lib`・`spec`・`docs` を grep）

### 3.6 #49 — defining_code / code_string（設計討議つき）

**2.5.0 に入れる最小形（Option A）:**

- `ALLOWED_TERMINAL_HOPS` に `defining_code` と `code_string` を足す（#48 のあとなので計 6 名）。
- 衝突スイープ（実行済み）: RM で `code_string` を持つのは `CodePhrase`（`text.rb:61`）、`defining_code` は `DvCodedText`（`text.rb:141`）だけ。
- Issue の「討議の決着」2 項目は、このゲートの承認をもって Issue に記録する:
  (1) 許可リスト + `public_send` を維持するので fa6f6c4 の規則は保たれる。
  (2) 性能上の理由は見当たらない（数個の配列への `include?`。記録上も根拠なし）。
- Red から始める spec の見出し:
  1. `SELECT: value/defining_code/code_string が at コードを返す（ラベルではない）`
  2. `WHERE: code_string MATCHES {...} で絞れる`
  3. `許可リスト外の属性は従来どおり ExecutionError`（regression pin）
- 触るファイル: `lib/openehr/aql/engine/path_evaluator.rb`、spec。fixture は血圧ビルダーに coded_text の ELEMENT を 1 つ足す（合成）。
- 入れないもの: 型ごとの表（Option B）、台帳 25 項の `archetype_details`／`template_id`、`NoMethodError` の漏れの是正。
  これらは 3 件の実需（time、defining_code、archetype_details）がそろったので、2.6.0 向けに Option B としてまとめて設計する。

**見送る場合の影響:**

- anlage のデモ Q2 がラベル一致の暫定形のまま（`docs/demo/aql-queries.md:29`）。q20 の「診断確度 = at0074」はコード値で書けない。
- 撤去待ちのコードは下流に無い（文書上の暫定形が 1 件残るだけ）。openehr-rails 0.9.0 の内容にも影響しない。
- 利点: flat なリストを 2 名ぶん広げずに済み、Option B を一度で入れられる。

**推奨:** 最小形を入れる。変更は 1 行で、定数自身のコメントが求める条件（実クエリが必要としている）を満たす。
ただし順序は最後尾で、11/26 までに #58 がマージされていなければ 2.5.0 からは外す。

### 3.7 2.5.0 に入れないもの

- **#36（STRICT 既定化）:** 同意。openehr-rails の fixture 修正が前提で、挙動変更。なお rails の `Opt::Parser#parse` は
  自前で `Nokogiri::XML::Document.parse(source)` を呼ぶ（`parser.rb:20`）ので、上流で既定を変えても rails の経路には届かない
  （推論: 該当行の形から。実行での確認はしていない）。#36 を進めるときの論点として Issue に足す。
- **#59:** D5。

## 4. 独立軸: PR #57（マージの判断材料）

1. **中身は neutral で、状態はきれい。** `spec/`・`.github/workflows/`・`docs/`・`CLAUDE.md`・`History.txt` のみ。
   `MERGEABLE`／`CLEAN`。ただし CI の green は 9/20（Ruby 4.0.7）のものなので、マージ前に再実行が要る。
2. **先に入れると 2.5.0 の作業が楽になる。** `History.txt` の `=== Unreleased` 節をこの PR が作る（後回しにすると最初の実装 PR と衝突する）。
   同梱の `237a34c` は release 手順（artifact を `pkg/` に置き、publish 確認後に消す）の改訂で、2.5.0 の publish にそのまま効く。
3. **リスクは小さいが外部依存が増える。** 週次 workflow は CKM から実コーパスを取得する（約 7 分）。初回の `workflow_dispatch` は master に入ってからしか回せない。
   2.5.0 は ADL 文法に触れないので、2.5.0 の合否には関わらない。

## 5. 日付案（12/5 の openehr-rails 0.9.0 からの逆算）

| 日付 | 内容 |
| --- | --- |
| 11/20（金） | このゲートの承認。#57 と #61 のマージ判断 |
| 11/21（土）〜 11/24（火） | 首位群: #60 → #48 → #31 |
| 11/25（水）〜 11/26（木） | #43 → #58。#49 を入れるかの締切（D2）|
| 11/27（金） | #49 最小形（入れる場合）。予備日 |
| 11/28（土） | **棚卸し:** `git diff v2.4.3..master` で全コミットを分類し semver を確定。未マージの Issue は 2.5.1 へ |
| 11/30（月） | `Release 2.5.0` コミット → タグ `v2.5.0` → Release run の artifact を取得 → sha256 を run の出力と照合 → `gem push` |
| 12/1（火）〜 12/4（金） | openehr-rails 0.9.0（別セッション）: 依存の下限を 2.5.0 へ、`populate_term_bindings!` の撤去 |
| 12/5（土） | openehr-rails 0.9.0 の期限 |

- 各 PR のマージは人間。上の日付は「その日までにマージされていれば次へ進める」という意味。
- openehr-rails の依存は `'~> 2.3', '>= 2.3.1'`（`openehr-rails.gemspec:31`）なので、2.5.0 は公開した時点で rails の解決範囲に入る。
  迂回の撤去には下限の引き上げが要る（rails 側の判断）。
- 余裕は 11/29（日）の 1 日と 11/27。#58 が 11/26 を越えたら、#58 を 2.5.1 に回すか 11/30 を 12/1 にずらすかを再裁定に上げる。
