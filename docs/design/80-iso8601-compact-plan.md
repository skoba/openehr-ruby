# 計画: ISO 8601 のコンパクト形式を読む

Issue: #80。Refs R-20261126-9(作業列の 3)、R-20261127-7(作業列の続き)。

## 根拠(読み取り。BASE Foundation Types Release-1.2.0)

- 6.5.1 `valid_iso8601_date`: `YYYY-MM-DD`(extended)、部分形 `YYYY-MM`、`YYYY`。`YYYYMMDD`(compact)、部分形 `YYYYMM`
- 6.5.1 `valid_iso8601_time`: `hh:mm:ss[(,|.)s+][Z|±hh[:mm]]`(extended)、`hhmmss[(,|.)s+][Z|±hh[mm]]`(compact)、部分形 `hh:mm`(extended)、`hhmm`・`hh`(compact)
- 6.5.1 `valid_iso8601_date_time`: `YYYY-MM-DDThh:mm:ss[...]`(extended)、`YYYYMMDDThhmmss[...]`(compact)、部分形 `YYYY-MM-DDThh:mm`・`YYYY-MM-DDThh`(extended)、`YYYYMMDDThhmm`・`YYYYMMDDThh`(compact)
- 6.2 の注: 書くときと表示するときは extended を強く勧める。古いデータのため、両方を受けるべき
- 6.5.4〜6.5.6 `as_string`: "Return string value in extended format"(date、time、date-time)。6.5.8 timezone の `as_string` も extended
- 6.5.3〜6.5.6 `is_extended`: "True if this ... uses '-' and / or ':' separators"
- 2 つの形を 1 つの値の中で混ぜてよいかは、書かれていない。挙げられている形は、どれも 1 つの形で通している

## いまの挙動(実行。master `4289afb`)

| 入力 | いま |
|---|---|
| date `20260922`、`202609` | ArgumentError |
| date-time `20260922T143000`、`20260922T1430`、`20260922T14`、`20260922T143000.5Z`、`20260922T143000+0900` | ArgumentError |
| date-time の混ぜ形 `2026-09-22T143000`、`20260922T14:30:00` | ArgumentError |
| time `143000`、`1430`、`14`、`143000.5`、`143000Z`、`143000+0900` | 読める。`as_string` は extended(`14:30:00`)。オフセットは書かれたまま(`+0900`) |
| time の混ぜ形 `1430:00`、`14:3000` | 読める |
| 時だけのオフセット `±hh`(`143000+09`、`14:30:00+09`) | ArgumentError |
| `is_extended?`(date、time、date-time) | 入力の形によらず、いつも true |
| DvDate・DvTime・DvDateTime の `value` | 書かれた文字列のまま |

## 決めること(#80 の問い)と、この計画の答え

1. **読む形**: 仕様が挙げるコンパクト形式を、date と date-time でも読む(time は既に読める)。
   日付の部分と時刻の部分の形をそろえる(date-time は、全体が compact か、全体が extended か)
2. **`as_string`**: 仕様のとおり、いつも extended を返す。`value`(DvDate などが持つ文字列)は、書かれたまま
   - date と date-time の `as_string` は欄から組み立てるので、もともと extended になる
   - オフセットも extended にする(`+0900` → `+09:00`)。仕様 6.5.8 による。**いまの time の `as_string` の出力が変わる**(下の「裁定に無い判断」)
3. **混ぜ形**: date と date-time では拒む(いまも拒んでいる。pin する)
4. **`is_extended?`**: 入力の形を返す。compact なら false

## 裁定に無い判断(ゲート。実装は分けて、マージせずに止める)

- **A. time の混ぜ形を拒むか**: `1430:00`、`14:3000` はいま読めている。仕様の挙げる形ではない。拒むと、いま通る入力が通らなくなる。推奨: 拒む(date-time とそろえる)。答えが出るまで変えない
- **B. 時だけのオフセット `±hh`**: 仕様は `±hh[:mm]` を挙げるが、いまは拒んでいる。読むようにするのは #80 の外。推奨: 別の Issue にして読む
- **C. オフセットの `as_string` を extended にする**: 仕様のとおりだが、いま `14:30:00+0900` と出ているものが `14:30:00+09:00` になる。推奨: 仕様のとおり extended にする。
  #80 の PR とは分ける

## 実装(#80 の PR)

- `ISO8601Date`、`ISO8601DateTime` の正規表現に、compact の形を足す。extended と compact の 2 つの分岐にして、混ぜ形は通さない
- `is_extended?` を、入力の形を覚えて返すようにする(`ISO8601DateModule`、`ISO8601TimeModule`、`ISO8601DateTimeModule`)
- `valid_iso8601_date?`(`Date.parse` に頼っている)は、この計画では変えない
- DvDate・DvDateTime は ISO8601 のクラスで読むので、そのまま compact を受ける
- Red: 仕様の挙げる compact の形ごとに、extended と同じ欄の値になること。`as_string` が extended になること(date、date-time)。`is_extended?` が false になること
- regression pin: extended の形、date と date-time の混ぜ形を拒むこと
- semver: minor(受ける入力が増える。`is_extended?` の返す値が変わる)

## 今回は入れないもの

- 上の A、B、C(ゲート)
- compact 形式で書き出す手段(仕様は extended を勧める)
