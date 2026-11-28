# ゲート報告: AQL の `…/value` を時点で比べるか(段 B)

Refs R-20261127-18。Issue #135。計画書: `docs/design/135-aql-value-instant-plan.md`。

## 決めてほしいこと

1. `…/value`(持ち主が DV_DATE_TIME か DV_DATE)と ISO 8601 のリテラル・パラメータの比較を、時点の比較にするか
2. 1 を「する」なら、次も
   - `=` と `!=` を時点で比べるか(同じ時点で書き方の違う値を等しいとする)。文字列そのものは `LIKE` で比べる
   - `ORDER BY …/value` も時点の順にするか
   - ISO 8601 として読めないリテラル: エラー(推奨、段 A とそろえる)か、文字列の比較のまま(後方互換)か
3. semver(minor か major か)と、Upgrade note の文(計画書の案)
4. openEHR Discourse に問いを出すか(案は計画書)

## 実測の要点(実行)

- いま: `…/value` は文字列の比較。オフセットか精度がそろっていない値で、時点の順と食い違う(計画書の表で 6 つの形)
- オフセットと精度がそろっていれば、結果は変わらない(表で 3 つの形)
- `ORDER BY c/context/start_time`(時点)と `ORDER BY c/context/start_time/value`(文字列)は、いま逆の順を返す例がある

## 読んだだけのもの

- AQL の仕様の 3.12.5・3.8.1.1、EHRbase の振る舞い(Discourse 11954)、openehr-rails の `dataset_adapter.rb:55` は、統括の読みによる

## 回答(2026-11-28)

R-20261128-11 で決まった。時点で比べる案(上の「決めてほしいこと」の 1・2)は採らず、書かれた成分を年から比べ、
共通の精度まで同じなら等しいとする。時刻帯は、両方にあるときだけ UTC に直す。読めないリテラルはエラー。
ORDER BY は、いちばん早い時点の順で、同じ時点なら粗い値が先。Discourse への問いは、この実装からは出さない。
実装の計画は `docs/design/135-aql-value-instant-plan.md`(書き直した)。
