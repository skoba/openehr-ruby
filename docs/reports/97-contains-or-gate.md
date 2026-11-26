# ゲート報告: CONTAINS の OR で束縛されない変数（#97）

Refs R-20261125-12。2026-11-26。

## 結論

**止まる。** 仕様から決まらない。決めてほしいのは、OR の 2 つの枝がどちらも当たった COMPOSITION の行の形だけ。

## 再現（実行）

- master `3e97eb0`。COMPOSITION を 2 つ用意した。1 つは血圧の OBSERVATION だけ、もう 1 つは体温の OBSERVATION だけを持つ
- `CONTAINS (OBSERVATION o[…blood_pressure.v1] OR OBSERVATION o2[…body_temperature.v1])` は失敗する
  - `SELECT o, o2`: `SemanticError: unbound variable: "o2"`
  - `SELECT o/name/value, o2/name/value`: 同じ
  - WHERE で `o` だけを使う: `unbound variable: "o"`
- 原因は 2 か所
  - `ContainsResolver#resolve_containment_or` は、2 つの枝の結果をつなげるだけ（`lib/openehr/aql/engine/contains_resolver.rb:110-112`）。行には、当たった枝の変数しか入らない
  - `Binding#[]` は、持っていない名前で必ず例外を出す（`lib/openehr/aql/engine/binding.rb:9`）。FROM で宣言されたが束縛されなかった変数と、宣言されていない名前を区別していない

## 仕様とほかの実装（読み取り）

### AQL 仕様

Release 1.1.0（`specifications.openehr.org/releases/QUERY/latest/AQL.html`）を読んだ。

- CONTAINS の中の OR は認められている（3.13.2.2、文法の `containsExpr`）
- 当たらなかった枝の変数が何になるかは書かれていない
- 近い記述は 4 節（Result structure）の「the `NULL` value in the case where the data item is missing or unknown」
- FROM の変数がすべての行で束縛されている必要があるかも書かれていない

### openEHR Discourse

「Questions on AQL CONTAINS formalism」（2024 年 8〜9 月）を読んだ。

- 仕様のグレーゾーンで、SEC で扱う必要があるとされた。結論は出ていない
- EHRbase の扱い: 枝の変数を left join し、少なくとも 1 つは存在することを条件にする。null を返すのは、片方の枝が何も当たらないときだけ
- ほかの実装者は「少なくとも 2 つの実装が、それぞれ違う扱いをしている」と書いている

## 2 つの読み

違いが出るのは、**両方の枝が当たる COMPOSITION** だけ。

| COMPOSITION の中身 | (A) 和集合。もう片方の変数は null | (B) left join（EHRbase） |
|---|---|---|
| O1 だけ | `[O1, null]` | `[O1, null]` |
| O2 だけ | `[null, O2]` | `[null, O2]` |
| O1 と O2 | `[O1, null]` と `[null, O2]` の 2 行 | `[O1, O2]` の 1 行 |

どちらの読みでも、次の 2 つは変わらない。

- FROM で宣言されていない名前は `SemanticError` のまま
- 束縛されなかった変数を通るパスは null になる。WHERE の比較は、既存の null の扱いに従う

### 下流の使い方

下流は、1 つの COMPOSITION に版 v1 か v2 のどちらか一方しか持たない。これは表の上の 2 行で、どちらの読みでも結果は同じ。

## 推奨

**(A)**。理由は次のとおり。

- 今の実装（2 つの枝をつなげる）に、束縛されなかった変数を null にする処理を足すだけで済む。行の数は変わらない
- (B) は、両方の枝が当たったときに組み合わせを作る。行の数と重複の扱いが変わり、OR の意味が AND に近づく
- 仕様の 4 節の「欠けているデータは NULL」と、表のどの行も矛盾しない

(B) を選ぶなら、EHRbase と結果がそろう。

## 決めてほしい点

1. (A) と (B) のどちらにするか
2. 仕様が決まっていないことを、変更履歴と spec の注釈に書くか（推奨: 書く）

決まるまで #97 には手を付けない。同じ裁定のもう 1 件（`archetype_node_id`、#96）は先に進めている。
