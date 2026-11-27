# 計画: AQL の `…/value` とリテラルの比較を、時点の比較にするか(段 B。ゲート)

Issue: #135。Refs R-20261127-18(段 B)。段 A(日時そのものとリテラルの比較)は #134(PR #139)。

**この計画は、決めるための材料。実装は、答えが出てから。**

## 前提

- 段 A(PR #139)で、日時そのもの(`c/context/start_time`)とリテラルは、時点で比べる
- `…/value` は RM の上では String(DV_DATE_TIME.value: String)。いまの `PredicateEvaluator.compare`
  (`lib/openehr/aql/engine/predicate_evaluator.rb:126`)は、String どうしの比較になる

## 仕様とほかの実装(読み取り)

- AQL(QUERY、3.12.5。統括の読みによる): 日時のリテラルは引用符つきの ISO 8601。例は日時そのものとの比較。
  処理系は、比べる相手のパスの型か文字列の形から日時として扱う。オフセットと部分的な値の比べ方は書かれていない
- AQL 3.8.1.1: LIKE を日時の文字列に使う例がある(統括の読みによる)
- EHRbase: 比較の演算子は magnitude の比較(openEHR Discourse 11954 の 7 番めの投稿。統括の読みによる)。
  `…/value` の比較も magnitude になるかは、確かめていない
- **仕様に無い点: オフセットの違う値、部分的な値、`=` の意味。ここでの答えは「この実装の決め」**

## 結果が変わる問いと、変わらない問い(実行。段 A のブランチ `fix/134-aql-date-time-literal` で、`…/value` の形と日時そのものの形を比べた)

| 問いの形(`S = c/context/start_time`) | 値 | `S/value`(いま、文字列) | `S`(時点) | 変わるか |
|---|---|---|---|---|
| `>= '2026-03-01T00:00:00Z'`、値も Z だけ | `2026-02-28T23:30:00Z`、`2026-03-01T00:30:00Z` | 後者 | 後者 | 変わらない |
| `>= '2026-03-01T00:00:00Z'`、オフセットが混じる | `2026-03-01T08:00:00+09:00`、`2026-03-01T00:30:00Z` | 両方 | 後者だけ | **変わる** |
| `>= '2026-03-15T00:00:00Z'`、日までの値 | `2026-03-15`、`2026-03-16T00:00:00Z` | 後者だけ | 両方 | **変わる** |
| `>= '2026-03-01'`(日までのリテラル) | `2026-03-01T08:00:00+09:00`、`2026-03-01T10:00:00Z` | 両方 | 後者だけ | **変わる** |
| `= '2026-03-01T08:00:00+09:00'`(同じ文字列) | `2026-03-01T08:00:00+09:00` | 当たる | 当たる | 変わらない |
| `= '2026-02-28T23:00:00Z'`(同じ時点、違う文字列) | `2026-03-01T08:00:00+09:00` | 当たらない | 当たる | **変わる** |
| `>= '20260301'`(コンパクト形式のリテラル) | `2026-03-15T00:00:00Z` | 当たらない | 当たる | **変わる** |
| `>= '2026-03-01T00:00:00Z'`、値にオフセットが無い | `2026-03-01T08:00:00` | 当たる | 当たる | 変わらない |
| `ORDER BY S/value` と `ORDER BY S` | `2026-03-01T08:00:00+09:00`、`2026-02-28T23:30:00Z` | 文字列の順(Z が先) | 時点の順(+09:00 が先) | **変わる**(ORDER BY も時点にするなら) |
| `S/value LIKE '2026-03*'` | 上と同じ | 文字列で当たる | — | 変えない案 |
| `S/value >= 'abc'`(ISO 8601 でない) | 上と同じ | 当たらない(文字列の比較) | 段 A ではエラー | 下の 5 |
| `S/value >= $t`(パラメータ) | 上と同じ | 文字列の比較 | — | リテラルと同じ扱い |
| `S/value = c/context/start_time/value`(パスどうし) | 上と同じ | 文字列の比較 | — | 下の 4 |

まとめ: オフセットと精度がそろっていて、リテラルも同じ形なら、結果は変わらない。そろっていないときだけ変わる。
openehr-rails は、いま AQL に渡す値を UTC の時点にそろえている(統括の読み: `lib/openehr_rails/aql/dataset_adapter.rb:55`)ので、
openehr-rails 経由の問いは、日までのリテラル(`>= '2026-03-01'`)を除いて、ほぼ変わらない(推論。実行していない)

## 案(統括の案。決めるのは人間)

1. **比べ方**: 左が `…/value` で、その持ち主が DV_DATE_TIME か DV_DATE、右が ISO 8601 として読めるリテラルかパラメータなら、
   持ち主どうしを時点で比べる(段 A と同じ計算)
2. **`=` と `!=`**: 時点で比べる(`2026-03-01T08:00:00+09:00` と `2026-02-28T23:00:00Z` は等しい)。
   書かれた文字列そのものを比べたいときは、ワイルドカードの無い `LIKE`(`S/value LIKE '2026-03-01T08:00:00+09:00'`)を使う。LIKE は文字列のまま
3. **ORDER BY `…/value`**: 持ち主が DV_DATE_TIME か DV_DATE なら、時点の順にする(`ORDER BY S` とそろえる)。
   同じ時点の値どうしの順は、いまの安定でない sort のまま(決めない)
4. **パスどうし**(`S/value = T/value`): 両方の持ち主が日付の型なら時点で比べる。片方だけなら、いまのまま文字列
5. **ISO 8601 として読めないリテラル**: 2 案
   - 5a(推奨): エラー(段 A とそろえる)。DV_DATE_TIME の value はいつも ISO 8601 なので、読めないリテラルと比べても意味のある結果にならない
   - 5b: いまのまま文字列の比較(後方互換)。黙って当たらないことがある
6. **LIKE と MATCHES**: 文字列のまま(仕様の 3.8.1.1 の例に合う)
7. **DV_TIME の `…/value`**: 文字列のまま(R-20261127-3: 書かれたまま比べる)。DV_DURATION も変えない

## エンジンが value の持ち主の型を知る作り

- いまの `PathEvaluator.evaluate`(`path_evaluator.rb:48-57`)は、最後の値(String)だけを返す
- 案: `PredicateEvaluator.evaluate_comparison` と `Engine#compare_bindings` で、左のパスの最後の区切りが `value` のとき、
  1 つ手前までを評価して持ち主を得る(`PathEvaluator` に「最後の 1 区切りを除いて評価する」関数を足す)。
  持ち主が DV_DATE_TIME か DV_DATE なら、持ち主で比べる。そうでなければ、いまのまま
- パスの評価は 1 回増える(最後の 1 区切りの分)。行の数が多いときの重さは、実装のときに測る

## semver と Upgrade note

- いま動いている問いの結果が変わる(上の表の「変わる」の行)。シグネチャは変わらない
- 前例(#97 で行の数が変わったのを minor にした)にならうなら minor。結果が黙って変わるので major も考えられる。棚卸しで決める
- Upgrade note の文の案:

  > AQL: comparing `…/value` of a DV_DATE_TIME or DV_DATE with an ISO 8601 literal or parameter now compares instants, not strings,
  > and `ORDER BY …/value` on those types orders by instant. Results change only where the stored values or the literal differ in UTC
  > offset or precision (e.g. `2026-03-01T08:00:00+09:00` no longer matches `>= '2026-03-01T00:00:00Z'`; a date-only value `2026-03-15`
  > now matches `>= '2026-03-15T00:00:00Z'`). To compare the stored text itself, use `LIKE` without wildcards.

## openEHR Discourse に出す問いの案(投稿は人間)

> **AQL: should `…/value` of a DV_DATE_TIME be compared as a date-time or as a string?**
>
> AQL 1.1 (3.12.5) compares date-time paths with quoted ISO 8601 literals, and its examples use the DV_DATE_TIME itself
> (`composition/context/start_time >= '2024-01-01'`). Many real queries write `…/start_time/value >= '…'` instead.
> Since `value` is a String in the RM, a straightforward implementation compares strings, which agrees with instant order only when
> offset and precision match (`2026-03-01T08:00:00+09:00` sorts after `2026-03-01T00:00:00Z` as a string, but is earlier as an instant).
>
> 1. Should an implementation compare `…/value` of DV_DATE_TIME / DV_DATE by instant (as for the DV_DATE_TIME itself), or as a string?
> 2. For `=`, are `2026-03-01T08:00:00+09:00` and `2026-02-28T23:00:00Z` equal?
> 3. How should a partial value (`2026-03-15`) compare with a full literal (`2026-03-15T00:00:00Z`)?
>
> EHRbase compares magnitudes (thread 11954). We would like the specification to say which, so that the same AQL gives the same rows
> on every CDR.

## 実装に進むとき(答えが出たら)

- Issue #135 を (a) bug か (b) enhancement として、Red から。上の表の「変わる」の行を spec にする
- 案 5 の答えにより、読めないリテラルのテストを足す
- openehr-rails の #92 は、段 A と段 B の両方を見て進める(R-20261127-18 の公開の節)
