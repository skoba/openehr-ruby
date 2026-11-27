# 計画: AQL で、日時そのものをリテラルと時点で比べる(段 A)

Issue: #134。Refs R-20261127-18(段 A)。段 B(`…/value` の比較)は #135 で、別の計画書。

## 根拠

- AQL の仕様(QUERY、3.12.5 Dates and Times。統括の読みによる): 日時のリテラルは、引用符で囲んだ ISO 8601 の文字列。
  WHERE の例は、日時そのもの(`composition/context/start_time`)とリテラルを比べる。
  処理系は、比べる相手のパスの型から、日時として扱う。オフセットと部分的な値の比べ方は書かれていない
- EHRbase は magnitude で比べる(openEHR Discourse 11954。統括の読みによる)
- 順序の計算は R-20261127-4・#117・#120(部分的な値はいちばん早い時点、オフセットが無ければ UTC)

## いまの挙動(実行。master `892e6d4`)

- `WHERE c/context/start_time >= '2026-01-01'` は `NoMethodError: undefined method 'magnitude' for an instance of String`。パラメータでも同じ
- 原因: `PredicateEvaluator.compare`(`lib/openehr/aql/engine/predicate_evaluator.rb:126`)が `left.public_send(:>=, right)` を呼び、
  `DvQuantified#<=>`(`lib/openehr/rm/data_types/quantity.rb:71`)が `right.magnitude` を呼ぶ
- 文法(`identifiedExpr : identifiedPath COMPARISON_OPERATOR terminal`)により、左はいつもパス。日時のリテラルは、パーサの中では String(`parser.rb:324`、`:448`)

## 直し方

- `PredicateEvaluator.compare` で、左が DvDateTime か DvDate のとき、右をそろえる
  - 右が String: 左と同じクラスで読む(`DvDateTime.new(value: right)`、`DvDate.new(value: right)`)。
    読める形は値と同じ(拡張形式、#80 のコンパクト形式、部分的な値)
  - 読めないとき(ISO 8601 でない、時刻だけのリテラルを日時と比べる、日時のリテラルを DV_DATE と比べる): `ExecutionError`。
    文に、パスの型と、リテラルと、読める形を書く。黙って「当たらない」にしない
  - 右が DV_TEMPORAL(パスどうし): いまのまま
  - 右が String でも DV_ でもない(数値など): `ExecutionError`(いまは NoMethodError)
- そろえたあとは、`<=>`(順序の計算)で比べる。`=` と `!=` も時点で比べる(`2026` と `2026-01-01` は等しい)
- DV_TIME と DV_DURATION は、変えない(右をそろえない)
- `compare` は `contains_resolver.rb:254`・`:283`(パスの述語)からも呼ばれる。そこでも同じに働く

## 変わる結果

- いまは例外になる問いが、値を返すようになる。いま値を返している問いの結果は変わらない
  (`…/value` の比較は String どうしで、ここを通らない)

## spec

- Red: 演算子 6 つ × リテラルとパラメータ × DV_DATE_TIME と DV_DATE。オフセットのある値と部分的な値は、時点で比べる。
  読めないリテラル、時刻だけのリテラル、数値で `ExecutionError`
- regression pin: `…/value` の比較(文字列のまま)、DV_TIME のパスとリテラル(いまのまま)

## semver

棚卸しで決める。いまの見込みは minor(例外になっていた問いが動く)
