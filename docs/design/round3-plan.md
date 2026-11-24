# Round 3 計画

Issue: #59、#65、#70、#36（#36 は計画まで。実装の前にゲート報告）

裁定: R-20261124-9（作業列 5）。進め方は R-20261124-8（CLAUDE.md「全開の進め方」）による。
状態: 提出（2026-11-24）。事後の確認待ち。**実装は v2.5.0 のタグのあとに始める**（1 節）。

基準点: master `252ad18`、公開版 2.4.3、リリースの PR #69（2.5.0）は open。Ruby 4.0.10。
「実行」と書いた項目はこの基準点で実行した結果、「読み取り」「推論」はその旨を書く。

## 1. 順序と、始める条件

| 順 | Issue | 形 | 版の見込み | 止まるか |
|---|---|---|---|---|
| 0 | `changelog.d/` への切り替え | docs／規約 | — | 止まらない |
| 1 | #70 archetype_details/template_id | (b) enhancement | minor | 止まらない |
| 2 | #65 name 述語のアポストロフィ | (a) bug | patch | 止まらない（3.2 の案 B に限る） |
| 3 | #59 日付だけの DV_DATE_TIME | (b) enhancement | minor | **実装の前に止まる**（3.3。仕様の文面が食い違う） |
| 4 | #36 STRICT 既定化 | 挙動の変更 | minor 以上 | **計画まで**（裁定のとおり） |

- **始める条件: タグ `v2.5.0` が打たれていること。** それより前に `lib/` を触る PR を master に入れると、
  棚卸し（`docs/reports/round2-log.md` R3）で確定した 2.5.0 の中身が変わる。タグまでは、ブランチを切って PR を
  green にするところまで進め、マージはしない
- 順 0 は裁定の作業列 4。順 1 の PR が最初の断片を足す
- 公開はできた順。#70 と #65 がそろえば 2.5.1 または 2.6.0（#70 が入れば minor）として棚卸しに進む。#59 と #36 は待たない
- #70 は openehr-rails 側の変更と同じ版にそろえる、という裁定の条件がある。openehr-rails 側の変更の中身は
  このリポジトリからは決められないので、5 節に問いとして置く

## 2. 順 0 — `changelog.d/` への切り替え

- `changelog.d/README.md` を足す（断片の書式: 1 PR に 1 ファイル、`<Issue 番号>-<slug>.md`、本文は History.txt に
  そのまま入る項目の文と、semver の判定・理由）
- gem に入るのは `lib/*` と `README.rdoc` だけ（`openehr.gemspec:19-20`）なので、`changelog.d/` は gem に入らない（neutral）
- CLAUDE.md は `252ad18` で反映済み

## 3. 項目ごとの計画

### 3.1 #70 — archetype_details/template_id（順 1）

- **現状（実行）:** `SELECT c/archetype_details/template_id/value` →
  `ExecutionError: unsupported path attribute "archetype_details" on a OpenEHR::RM::Composition::Composition`
- **経路（読み取り）:** `navigate`（`path_evaluator.rb:55-63`）は、宣言された `path_attribute` でなければ
  `navigate_terminal` に落とし、`ALLOWED_TERMINAL_HOPS`（`:23`、2.5.0 で 6 名）に無い名前を拒む。
  リーダーはある: `Locatable#archetype_details`（`archetyped.rb:154`）、`Archetyped#template_id`（`archetyped.rb:203`）
- **修正形: 型ごとの表（#49 で見送った Option B）に切り替える。** 実需が 3 件（time、defining_code、archetype_details）
  そろったので、計画書 Round 2 の 3.6 節の予告どおりここでまとめる
  - `TERMINAL_HOPS = { クラス => [名前] }` を `is_a?` で引く。どのクラスにも当たらなければ、従来と同じ文面の
    `ExecutionError`（`unsupported path attribute ... on a ...`）
  - 表の中身（案。実装時に `lib/` の公開リーダーと突き合わせる）:
    `Locatable => name, archetype_details`／`Archetyped => template_id, archetype_id`／
    `Event => time`／`Action => time`／`Participation => time`／`FeederAuditDetails => time`／
    `DvQuantity => magnitude`／`DvCodedText => defining_code`／`CodePhrase => code_string`／
    `value` と `name` は、いま通っている型をすべて拾う（下の pin で固定する）
  - **互換:** いま通る query がすべて通り続けることを、切り替えの前に regression pin で固定する
    （既存の engine_spec が通ることに加え、flat なリストの 6 名それぞれについて、いま値を返す型の一覧を spec に書く）
  - **直る副作用:** 許可リストに載った名前を、その名前を持たない型に投げると `NoMethodError` が漏れる件
    （Round 2 の R1 で実行: `SELECT c/name/magnitude` → `NoMethodError`）が、`ExecutionError` になる。これは挙動の変更だが、
    例外の型が engine 自身のものに揃うだけで、値を返していた query は変わらない
- **衝突スイープ（必須項目・実行: `grep` across `lib/`）:**
  - `archetype_details`: 公開リーダーは `Locatable`（`archetyped.rb:154`）だけ
  - `template_id`: `Archetyped`（`archetyped.rb:203`）と `OpenEHR::AM::Template::OperationalTemplate`（`am/template.rb:11`）。
    後者は AM で、AQL が歩く RM の木には現れない。型ごとの表にすれば、そもそも `Archetyped` にしか効かない
  - `archetype_id`（表に足す場合）: 実装時に同じ sweep をする
- **Red から始める spec の見出し:**
  1. `SELECT: c/archetype_details/template_id/value がテンプレート ID を返す`
  2. `archetype_details の無い COMPOSITION では null の列を返す（例外にしない）`
  3. `表に無い型と名前の組は ExecutionError（NoMethodError を漏らさない）`
  4. `flat なリストで通っていた型と名前の組は、すべて従来どおり値を返す`（regression pin）
- **nil の扱い（読み取り）:** 歩行は `current.nil? ? nil : navigate(...)`（`path_evaluator.rb:50-51`）なので、
  `archetype_details` が nil なら以降の hop は呼ばれない。2 は実装なしで通る見込み（推論）。通れば pin として書く
- **fixture:** 血圧ビルダーに、ルートへ `archetype_details`（架空の template_id）を持たせる引数を足す（合成）
- **触るファイル:** `lib/openehr/aql/engine/path_evaluator.rb`、`spec/lib/openehr/aql/engine_spec.rb`、ビルダー、断片 1 件
- **下流:** anlage のデモクエリ 5 が `c/name/value` の代替から本来形に戻せる。ただしフォーム経路の Composition は
  ルートに `archetype_details` を持たないので（anlage#54、読み取り: anlage `docs/upstream-candidates.md` 25 項）、そちらは null のまま

### 3.2 #65 — name 述語のアポストロフィ（順 2）

- **現状（実行、Issue #65 の本文）:** `data[at0001, "O'Brien"]` → `OpenEHR::Path::InvalidPathError: invalid node id`
- **原因（読み取り）:** `path_evaluator.rb` が述語を `"#{code}, '#{value}'"` の文字列に戻し、
  `OpenEHR::Path.parse_segment`（`path.rb:127-141`）の `/\A([^,]+),\s*'([^']*)'\z/` が、引用符の中の `'` を受けない
- **案 A: `OpenEHR::Path` にエスケープを足す。** 公開のパス文法が変わる。openEHR のパス文法に対応する規定があるかを
  確かめる必要があり、`Path#to_s` の往復にも波及する
- **案 B（採る）: AQL の評価器が、パス文字列に戻さずに名前で絞る。** `Pathable#items_at_path` には名前なしのパス
  （`/attr[code]`）を渡し、返ってきた候補を `name.value == 述語の値` で絞る。`ContainsResolver` は #60 で
  すでにこの形（`node_name_matches?`）。公開のパス文法には触れない
  - 止まらずに進めるのは案 B に限る。案 A が要ると分かったら、公開 API の変更なので止まってゲート報告を出す
- **Red から始める spec の見出し:**
  1. `node 述語: [at-code, "O'Brien"] が名前の合う 1 件を返す`
  2. `archetype 述語: [archetype_id, "O'Brien"] が名前の合う 1 件を返す`
  3. `アポストロフィを含まない名前の述語は従来どおり`（regression pin。#60 の spec がすでに覆う）
  4. `OpenEHR::AQL.execute から InvalidPathError が漏れない`
- **確かめること（実装時）:** 名前なしで引いて絞る形が、名前つきで引く形と同じ結果になること
  （`items_at_path` の名前つきの分岐 `select_by_predicate` を読み、全 suite で確かめる）。
  CONTAINS 側（`ContainsResolver`）はパス文字列を通らないので、アポストロフィで落ちないはず（推論。spec 2 の CONTAINS 版で確かめる）
- **触るファイル:** `lib/openehr/aql/engine/path_evaluator.rb`、spec、ビルダー（名前に `'` を含む合成）、断片 1 件

### 3.3 #59 — 日付だけの DV_DATE_TIME（順 3。実装の前に止まる）

- **現状（実行、Round 2 の R1）:** `DvDateTime.new(value: '2026-09-22')` → `ArgumentError: format invalid`。
  `ISO8601DateTime#initialize` の正規表現（`assumed_library_types.rb:528`）が `T` と時を必須にしている
- **仕様の文面が食い違っている**（読み取り: openEHR BASE Release-1.2.0 `foundation_types.html`、2026-11-24 に取得。
  取得はサブエージェントによる。引用は短く抜いたもの）:
  - 許す側: 6.2 節「Partial variants of Iso8601_date_time can include missing hours, days and months」、
    6.5.6 節のクラス説明「any part of the date/time up to the month may be missing」
  - 許さない側: 6.5.1 節 `valid_iso8601_date_time` が挙げる部分形は `YYYY-MM-DDThh:mm` と `YYYY-MM-DDThh` だけ。
    6.5.6 節の不変条件に `Partial_validity_hour: not hour_unknown`、`Partial_validity_day: not day_unknown`
- **このリポジトリの実装の現状（読み取り）:** `ISO8601DateTimeModule` は `hour_unknown?` を持つ（`:495`）。
  実行: いまの正規表現は `2026T14`（月と日が無く、時がある）を通し（`as_string` は `2026`）、`2026-09-22` を通さない。
  どちらの読みとも合っていない。正規表現に `\A`／`\z` が無く、`x2026-09-22T14zz` も通る（別件。5 節）
- **案:** 仕様の「意図」を述べた 2 箇所に合わせ、`YYYY-MM-DD`、`YYYY-MM`、`YYYY` を受ける。Issue #59 の依頼とも合う。
  `as_string` は時が無ければ日付の部分だけを返す（`:499-520` の既存の分岐で、推論では追加の変更なしに往復する）
- **止まる理由:** 仕様の不変条件に反する値を受け入れる変更で、計画の時点でどちらの読みを採るかが決まっていない。
  臨床データの精度の扱いでもある。**裁定を求める点は 6 節の 1**
- **Red から始める spec の見出し（案が通った場合）:**
  1. `ISO8601DateTime が YYYY-MM-DD を受け、hour_unknown? が true`
  2. `DvDateTime が日付だけの値を、入力した精度のまま as_string／RMJSONSerializer で往復する`
  3. `YYYY-MM と YYYY も同じ`
  4. `時を持つ値の扱いは従来どおり`（regression pin）
  5. `日付だけの値どうし、日付だけの値と時つきの値の比較`（`Comparable` の挙動を実装の前に実行して決める）
- **衝突スイープ:** 名前を足さない。影響を受けるのは `ISO8601DateTime.new` を呼ぶ箇所
  （`date_time.rb:215`、`constraint_model/primitive.rb:445-465` の `hour_validity`）。後者は「時が無い」値が来たときに
  C_DATE_TIME の妥当性判定がどう答えるかを実装の前に実行して確かめる
- **下流:** anlage の `dv_date_time_partial` の迂回が撤去できる（読み取り: Round 2 の R1）

### 3.4 #36 — STRICT 既定化（順 4。計画まで）

- **現状（読み取り）:** `SAFE_PARSE_OPTIONS` は `RECOVER | NONET | BIG_LINES`（`parser.rb:26-29`）。
  使うのは `opt_parser.rb:44` と `xml_archetype_parser.rb:34`
- **下流の事情（読み取り、Issue #36 のコメント `issuecomment-7130601375`）:** openehr-rails は `OPTParser#parse` を
  上書きして自前で Nokogiri を呼ぶので、ここの既定を変えても届かない
- **計画の骨子:**
  1. 上流に「パスまたは生の XML」を受ける入口を持たせ、openehr-rails の上書きを不要にする（これ自体は enhancement で、STRICT とは独立に価値がある）
  2. STRICT で落ちる入力の悉皆調査をやり直す（Issue 本文の数字は 2026-08 時点。fixture が増えている）
  3. 既定を STRICT に変える（挙動の変更。壊れた XML がいま通っている利用者は落ちるようになる）
- **この計画書では 1 と 2 までを Round 3 の範囲とし、3 はゲート報告のあと。** 1 は別の Issue として起票してから着手する
- **裁定を求める点は 6 節の 2**

## 4. 触らないもの

- `OPTSerializer` の JSON にルートごとの term を載せるか（Round 2 の R2 で「これまでと同じ出力」を選んだ件）
- 週次 workflow「CKM corpus conformance」の失敗（CI のワークフローを変える PR は人間がマージ。5 節）

## 5. 見つけたが、この計画に入れていないもの

- `ISO8601DateTime` の正規表現に `\A`／`\z` が無い（`assumed_library_types.rb:528`）。前後に余分な文字があっても通る（実行: `x2026-09-22T14zz` → `2026-09-22T14`）。
  #59 を実装するなら同じ行を触るので、そのとき別の Issue にするかを決める
- `README.rdoc:11` の「Developed with CRuby 4.0.7」（`.ruby-version` は 4.0.10）。gem に入るファイルなので、直すと patch
- 週次 workflow の失敗: 「Assemble CKM_CORPUS_DIR」で `cp` が同名の ADL の重複で止まる（run 45171501557）。
  直すなら Issue を起票し、ワークフローの PR として人間のマージに回す

## 6. 裁定を求める点（事後の確認で答えてほしいもの）

1. **#59: 日付だけの DV_DATE_TIME を受けるか。** 仕様の意図（6.2 節、6.5.6 節の説明）に合わせて受ける案を出している。
   不変条件（`not hour_unknown`）に合わせて受けず、「DV_DATE を使う」と文書に書く、という選択もある。
   答えが出るまで #59 は実装しない
2. **#36: 「パスまたは生の XML」の入口を上流に持たせる変更を、Round 3 に入れてよいか。** 公開 API の追加になる
3. **#70 を openehr-rails のどの変更と同じ版にそろえるか。** openehr-rails 側の予定（0.9.0 か 0.9.1 か）が決まれば、
   こちらの版の切り方を合わせる。決まるまでは、#70 と #65 がそろった時点で出す

## 7. 事後の確認への対応（裁定 R-20261124-12、2026-11-24）

計画は承認。6 節の 3 点への回答と、足された項目を受けて、次のように改める。上の節と食い違う箇所は、この節が優先する。

| 順 | Issue | 内容 | PR の分け方 |
|---|---|---|---|
| 0 | — | `changelog.d/README.md`（この PR） | docs |
| 1 | #70 | 型ごとの表への切り替えと、archetype_details/template_id | 1 PR |
| 2 | #71 | EVENT_CONTEXT の start_time・end_time・setting | #70 のあと、別の PR |
| 3 | #65 | name 述語のアポストロフィ（案 B） | 1 PR |
| 4 | #72 | `ISO8601DateTime` の正規表現に `\A`／`\z` | #59 と同じ時期。別の PR で、#59 より先 |
| 5 | #59 | 日付だけの DV_DATE_TIME を受ける | 1 PR |
| 6 | #74 | OPT の「パスまたは生の XML」の入口（追加だけ） | 1 PR |
| — | #73 | 週次 workflow の修正 | ワークフローの PR。マージは人間 |
| — | — | `README.rdoc` の Ruby の版 | 小さな PR。gem に入るファイルなので patch |
| — | #36 | STRICT 既定化 | #74 のあと、ゲート報告 |

- **#71 を #70 と分ける理由。** 1 Issue = 1 PR。#70 が表の仕組みを入れ、#71 はその表に行を足すだけになる。
  現状（実行、master `86f9f8a`）: `c/context/start_time/value`、`c/context/setting/value`、`c/context/end_time/value` は
  どれも `unsupported path attribute ... on a OpenEHR::RM::Composition::EventContext`。`context` の hop 自体は通る
  （`composition.rb:14` の `path_attribute :content, :context`）。リーダーは `composition.rb:71-72`
  - 表に足す行: `EventContext => start_time, end_time, setting`。`setting` の先の `defining_code`／`code_string`／`value` は
    #49 と既存の行で届く
  - COMPOSITION のほかの属性（`composer`、`language`、`territory`、`category`、`uid`）も同じ形で届かない（実行）。実需が出たら足す
- **#59 の読み。** 日付だけの値（`YYYY-MM-DD`、`YYYY-MM`、`YYYY`）を受け、入力した精度のまま往復させる。時刻は補わない。
  仕様の不変条件（`not hour_unknown` など）とは食い違う。採った読み（BASE の 6.2 節と 6.5.6 節の説明文）を、
  コードのコメントと変更履歴の断片に書く
  - 比較と大きさ: 欠けた部分はいちばん早い時点（1 月、1 日、0 時）として扱う
  - 精度の違う値どうしの等値と、C_DATE_TIME の妥当性判定（`primitive.rb:445-465`）が時の無い値にどう答えるかは、
    実装の前に実行して決め、決めた規則を spec と文書に書く
- **#72 を先にする理由。** #59 は同じ正規表現を書き換える。先に「余分な文字を拒む」「時があって日が無い値を拒む」を
  bug として固定しておくと、#59 の差分が「受ける形を増やす」だけになる
- **#70 は openehr-rails を待たない。** #70 と #71 が master に入った時点で、その時の中身で棚卸しに進む
