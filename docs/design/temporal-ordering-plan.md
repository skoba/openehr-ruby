# 計画: 日時の値の順序を 1 か所の計算にそろえる

Issue: #120(順序の計算)、#121(`as_string` がオフセットを落とす)。前提: #117(PR #119)、#112(PR #114)。
Refs R-20261127-4。

## 原則

1. DV_DATE_TIME(RM)の仕様が正。ISO8601DateTime は、その値の表現形式
2. 値は、分かっている精度までを書く。それより細かい部分は補わず、表現しない

## 根拠(読み取り)

- RM Data Types(Release 1.1.0)
  - 7.2.2 DV_DATE.magnitude: "Numeric value of the date as days since the calendar origin date `0001-01-01`."
    Release 1.0.3 の改訂の記録に "SPECRM-20: Correct wrong `DV_DATE._magnitude_` origin to '0001-01-01'" がある
  - 7.2.4 DV_DATE_TIME.magnitude: "seconds since the calendar origin date/time `0001-01-01T00:00:00Z`"
  - 7.2.3 DV_TIME.magnitude: "seconds since the start of day"
  - 部分的な値の magnitude の計算は書かれていない
- BASE Foundation Types 6.5: 時刻の型は順序を持つとされるが、部分的な値の比べ方は書かれていない
- openEHR Discourse
  - 11954(CDR implementation of partial DV_TEMPORALs): EHRbase は、欠けた部分をいちばん小さい値で埋めて magnitude を計算し、元の文字列を別に持つ
  - 17524(#59): 日付だけの DV_DATE_TIME を許すかの問い

## 1. 表現: 値を補わない(実行して確かめた。master `d371b30`)

| 確かめたこと | 結果 |
|---|---|
| ISO8601DateTime と DvDateTime の `month`、`day`、`hour`、`minute`、`second`(`2026` から `2026-11-27T10:30:15` まで 6 つの精度) | 欠けた部分は nil。0 や 1 を作って返していない |
| `value` と `as_string`(DvDateTime、DvDate、ISO8601Date、ISO8601DateTime) | 書かれた精度のまま |
| JSON の直列化(`RMJSONSerializer`。DV_DATE_TIME、DV_DATE、DV_TIME) | `value` の文字列だけを書く。補わない |
| ISO8601Time と DvTime の `as_string` | **秒の小数が無いとオフセットを落とす**(`10:30:15+09:00` が `10:30:15` になる)→ #121 |

### #121 の直し方

- `ISO8601TimeModule#as_string`(`assumed_library_types.rb:392-407`)で、オフセットを付ける処理を、秒の小数の分岐の外に出す。
  時・分・秒のどこまで書かれていても、オフセットがあれば付ける
- (a) bug。Red: `hh:mm:ss±hh:mm`、`hh:mm±hh:mm`、`hh±hh:mm`、`hh:mm:ssZ` の 4 つ。オフセットの無い形は regression pin

## 2. 順序の計算(#120)

### いまの数え方(実行)

| クラス | 数え方 | 欠けた月・日 | `2026 <=> 2026-01-01` | 月末 |
|---|---|---|---|---|
| DvDateTime(#117 のあと) | 0001-01-01T00:00:00Z からの暦の秒 | 1 | 0 | 正しい |
| ISO8601DateTime | 1 年を 365.24 日、1 月を 30.42 日 | 0 | -1 | 逆になる(`2026-01-31T12:00:00Z` が `2026-02-01T00:00:00Z` より後) |
| ISO8601Date | 同上(日数) | 0 | -1 | 日の単位では逆にならない |
| DvDate | `Date.new(y, m, d) - Date.new(0000, 1, 1)`(Ruby の既定の暦) | 落ちる(TypeError) | 落ちる | 正しい |

### 直し方

- 計算を 1 か所に置く。`ISO8601DateModule` に、暦の日数を返す private のメソッド
  (0001-01-01 からの日数。先発グレゴリオ暦。欠けた月と日は 1)を足す。
  `ISO8601DateTimeModule` に、それに時刻とオフセット(#112 の `utc_offset_seconds`)を足した秒を返すメソッドを置く
- 使う側
  - `DvDateTime#magnitude`: その秒(#117 で入れた計算を、この共通のメソッドに移す)
  - `ISO8601DateTime#<=>`: 同じ秒で比べる
  - `DvDate#magnitude`: 共通の日数。RM 7.2.2 のとおり 0001-01-01 からの日数になる
  - `ISO8601Date#<=>`: 同じ日数で比べる
- `to_days`(`ISO8601DateModule`、`assumed_library_types.rb:256-261`)は公開のメソッドなので、残す。
  比較には使わない。注釈に、名目の日数で順序のためのものではないと書く
- 欠けた部分をいちばん早い時点として数えるのは、この計算の中だけ。値にも文字列にも書き戻さない
- 精度まで同じかを見る手段: `value`(または `as_string`)の比較。`==` は Comparable の順序に従うので、
  `DvDateTime('2026') == DvDateTime('2026-01-01')` は true のまま。これを文書に書き、spec で pin する
- 根拠をコードの注釈に書く: RM 7.2.2・7.2.4、BASE 6.5、Discourse 11954 と 17524。
  仕様が決めていない点で、議論で結論が出たら改めることも書く

### 挙動の変わるところ

- `DvDate#magnitude` の数が変わる(2026-11-27 は 740314 から 739946)。順序は変わらない(完全な日付どうし)
- DvDate の部分的な値は、magnitude を持ち、比べられるようになる(いまは落ちる)
- ISO8601Date と ISO8601DateTime の、精度の違う値どうしの順序(`2026` と `2026-01-01` は 0)と、ISO8601DateTime の月末の順序
- `DvDate#diff` は magnitude で前後を決めるだけなので、完全な日付どうしでは結果が変わらない。実装のときに実行して確かめる

### 裁定に無い判断(PR を分け、マージせずにゲートにする)

- **DvDate の起点**: R-20261127-4 の 2 は DvDate#magnitude を「確かめる」までで、直すとは書いていない。
  原則 1(仕様が正)により、RM 7.2.2 の 0001-01-01 に直す案にする。数が変わるので、この点だけ別の PR にする

## 順番

1. #119(#117)と #114(#112)が master に入るのを待つ(同じメソッドに触る)
2. #121(`as_string`)。ほかと独立なので先に進める
3. #120 のうち、ISO8601DateTime と ISO8601Date を共通の計算にそろえる。DvDate の部分的な値を落とさないようにする(起点はいまのまま)
4. #120 のうち、DvDate の起点(ゲート)

## 今回は入れないもの

- 部分的な値を期間として読む手段(いちばん早い時点と、いちばん遅い時点)。`docs/backlog.md` に残す
- DV_TIME と ISO8601Time の順序(#113 のとおり、書かれた時刻のまま)
