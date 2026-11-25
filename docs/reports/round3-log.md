# Round 3 log（openehr 2.6.0）

裁定 R-20261124-9（作業列 5）、R-20261124-12、R-20261124-17、R-20261124-18 にもとづく Round 3 の作業ログ。
1 ステップ 1 項目（`R` 番号）。計画は `docs/design/round3-plan.md`（7 節が改訂後の順序）。

## R1 — 実装（2026-11-24）

1 Issue = 1 PR。Red を確認した spec の見出しは各 PR の本文にある。変更履歴は `changelog.d/` の断片。
マージは #79 が人間、ほかはセッション（R-20261124-8 の 3）。master の CI run は push イベントのもの。

| Issue | PR | 形 | Red の件数 | master のコミット | master の CI run |
|---|---|---|---|---|---|
| #70 archetype_details/template_id | #76 | (b) enhancement | 5 | `e9ba19f` | 45395989088 success |
| #71 EVENT_CONTEXT の start_time・end_time・setting | #77 | (b) enhancement | 4 | `2a53dbd` | 45397206977 success |
| #65 name 述語のアポストロフィ | #78 | (a) bug | 4 | `273224c` | 45398308951 success |
| #72 ISO 8601 の入力の厳格化 | #79 | (a) bug | 13 | `35d8725` | 45401881473 success |
| #59 日付だけの DV_DATE_TIME | #83 | (b) enhancement | 13 | `83a1d18` | 45406194377 success |
| README の Ruby の版 | #84 | — | — | `7b616bd` | 45406940034 success |

docs のみ: #75（`changelog.d/` と計画書 7 節、`ace6a81`）、#81（CLAUDE.md の裁定台帳の節、`cf5c9f1`）、#82（#72 の断片の書き直し、`9ef603c`）。

起票: #71、#72、#73（週次 workflow）、#74（OPT の入口）、#80（ISO 8601 のコンパクト形式を読む）。

計画書からの差分（実行して確認）:

- **#70 の表の形。** 既存の 6 名は汎用のまま残し、`respond_to?` で守る。新しい名前だけを型ごとの表 `TYPED_TERMINAL_HOPS` に入れた。
  汎用の名前を、その名前を持たない値に投げたときの `NoMethodError` は `ExecutionError` になった
- **#65 は案 B。** 評価器が ID だけで引いてから名前で絞る。`OpenEHR::Path` の公開文法は変えていない
- **#72 の範囲。** 裁定の文面（`\A`／`\z`）より広く、`ISO8601Date` に日時の文字列を渡す使い方、時があって日が無い値、
  コンパクト形式も拒むようになった。R-20261124-17 で承認。コンパクト形式を正しく読む件は #80
- **#72 の断片。** 書き直し（`6458ab8`）は PR #79 がマージされたあとに PR のブランチへ push したので、master に入らなかった。
  PR #82 で入れ直した
- **#59 の比較の規則**（実装の前に実行して決めた）:
  - 欠けた部分は、いちばん早い値（1 月、1 日、0 時）として並べる
  - 等値は並びに従う。実装の前から `ISO8601DateTime` は `T14 == T14:00:00` が真だった（実行）。
    `DvDateTime` の `==` は `Comparable` 由来で `magnitude` を比べる。精度が違っても、いちばん早い時点が同じなら `==`。`#value` は違う
  - 実装の前、時の欠けた値（`2026-09-22T14`）の `DvDateTime` どうしの比較は `TypeError: nil can't be coerced into Float` だった（実行）。同じ修正で直った
  - C_DATE_TIME の妥当性判定は変えていない。時が任意なら日付だけの値を受け、時が必須なら拒む

途中のミス:

- #78 の rebase で spec の競合を解いたとき、ブロックの終わりの `end` を 2 行落として push した（head `2d854ed`、CI run 45397588417 failure）。
  マージの前に直し、`ad04043` で green を確かめてからマージした
- #79 で RuboCop の指摘を残したまま PR を出した（head `10e1eb1`、CI run 45399097883 failure）。`8abcb51` で直した

## R2 — 棚卸し（バンドル報告、2026-11-24）

基準点: 前のタグ `v2.5.0`（`12d7518`）、master `7b616bd`（CI run 45406940034 success）。
手元の全 suite は 4080 examples、0 failures、1 pending（Ruby 4.0.10）。

### `git log v2.5.0..master` の分類（10 コミット）

gem に入るのは `lib/*` と `README.rdoc` だけ（`openehr.gemspec:19-20`）。

| コミット | 触ったもの | 分類 |
|---|---|---|
| `83a1d18` #59 | `lib/openehr/assumed_library_types.rb`、`lib/openehr/rm/data_types/quantity/date_time.rb` | minor（受け付ける値が増える） |
| `35d8725` #72 | `lib/openehr/assumed_library_types.rb` | patch（bug。受け付ける入力が狭まる。下記） |
| `273224c` #65 | `lib/openehr/aql/engine/path_evaluator.rb` | patch（bug） |
| `2a53dbd` #71 | `lib/openehr/aql/engine/path_evaluator.rb` | minor（届く path が増える） |
| `e9ba19f` #70 | `lib/openehr/aql/engine/path_evaluator.rb` | minor（届く path が増える。新しい定数 `TYPED_TERMINAL_HOPS`） |
| `7b616bd` | `README.rdoc`（1 行） | patch（gem に入るファイル。実行時の挙動は変わらない） |
| `9ef603c`・`cf5c9f1`・`ace6a81`・`86f9f8a` | `changelog.d/`、`CLAUDE.md`、`docs/` | neutral |

`lib/` の差分は 3 ファイル、92 行追加、40 行削除（README を含む）。`openehr.gemspec` と `Gemfile` は変わっていない
（依存、`required_ruby_version`、`files` は同じ）。

### semver の判定: minor（2.6.0）

- 公開 API が増える: AQL で届く path（`archetype_details`、`template_id`、`archetype_id`、EVENT_CONTEXT の 3 つ）、
  定数 `PathEvaluator::TYPED_TERMINAL_HOPS`、日付だけの DV_DATE_TIME。削除と、シグネチャの変更は無い
- **major にしない理由。** 2 つの挙動の変更がある
  - #72: 前後の空白・余分な文字、`ISO8601Date` への日時の文字列、日の無い時、コンパクト形式を拒むようになった。
    これまでの寛容さは値を黙って捨てるか読み違えていたので、bug の修正として扱う（R-20261124-17）。断片は「Behaviour change」で始まる
  - #70: 汎用の名前を持たない値への hop が `NoMethodError` から `ExecutionError` に変わった。影響するのは、もともと失敗していた query だけ
- 下流の確認（読み取り。R-20261124-17 の本文による）: anlage と openehr-rails は、#72 で拒むようになった入力に頼っていない。
  確かめるのは、下流が 2.6.0 に上げるときの CI

### リリースの PR で行うこと

- `changelog.d/` の断片 6 件を `History.txt` の `=== 2.6.0` にまとめ、断片を消す（`changelog.d/README.md` は残す）
- `lib/openehr/version.rb` を 2.6.0 に
- 版番号を変える PR なので、マージは人間。タグも人間

## R3 — 2.6.0 の公開（2026-11-25）

- リリースの PR #86 は人間がマージ → master `284a457`（CI run 45599787027 success）
- タグの前の確認（実行）: `git diff --stat v2.5.0..284a457 -- lib '*.gemspec' Gemfile Gemfile.lock` は `lib/` の 3 ファイルと
  `version.rb` だけ。R2 の判定（minor）と食い違いは無い
- タグ `v2.6.0` → `284a457`。人間の指示で、このセッションが打って push した
- Release run 45600042365 success。「Record sha256」の値は
  `e6c4040352792b90e2895789068e81c64d36c85aff4a2273631c14334d410ee4`
- artifact を空の `pkg/` に取り、手元の sha256 が上の値と一致（実行）
- `gem push` は人間。公開のあとの照合（実行）: `/api/v1/gems/openehr.json` は version 2.6.0、`sha` が上の値と一致。
  `https://index.rubygems.org/info/openehr` の 2.6.0 の `checksum:` も一致
- 照合のあと `pkg/openehr-2.6.0.gem` を消した。`pkg/` は空
