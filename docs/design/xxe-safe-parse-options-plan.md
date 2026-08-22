# Plan: XXE-safe ParseOptions の明示化 (openehr-ruby upstream sprint #33)

**Status: DRAFT — RECOVER/STRICT の裁定と plan 承認待ち**

## Context

`OPTParser#parse` と `XMLArchetypeParser#parse` は `Nokogiri::XML::Document.parse` を
`ParseOptions` 指定なしで呼んでおり、安全性が「たまたまリンクされている libxml2/Nokogiri の
既定値」に依存している。今回の調査で確定した通り、**現在の既定は既に安全**（`NONET` オン・
`NOENT`/`DTDLOAD` オフ）だが、これは Nokogiri 側の暗黙の既定値に乗っているだけで、
本 gem 自身がその安全性を保証・明示していない。将来の Nokogiri バージョンや、
古い Nokogiri を pin した downstream アプリでこの既定が変わっても検知できない。

Issue: [skoba/openehr-ruby#33](https://github.com/skoba/openehr-ruby/issues/33)
（hardening / security / enhancement）。Issue 本文と齟齬は見つからなかった。むしろ
本調査は Issue 本文が触れていなかった `DTDLOAD` フラグの関連性と、`RECOVER` 依存の
実在事例（openehr-rails 側の1 fixture）を新たに実証した — 詳細は下記。

## Step 1 実測結果（file:line・実行結果ベース）

### 1. 呼び出し箇所は正確に2箇所（grep で全数確認済み）

- `lib/openehr/parser/opt_parser.rb:43`:
  `@opt = Nokogiri::XML::Document.parse(File.open(@filename))`
- `lib/openehr/parser/xml_archetype_parser.rb:33`:
  `parsed = Nokogiri::XML::Document.parse(File.open(@filename, 'rb:bom|utf-8'))`

`grep -rn "Nokogiri::XML"` で lib/ 全体を検索し、他に `Nokogiri::XML::Document.parse` /
`Nokogiri::XML(...)` の呼び出しが無いことを確認済み（nokogiri を require するのは
この2ファイルのみ）。両方とも `File.open` の**戻り値を block なしで受け取っており、
ファイルハンドルが明示的に close されない**（Issue 本文の指摘通り、実測でも再確認）。

### 2. Nokogiri バージョンと DEFAULT_XML の実ソース確認

- `openehr.gemspec:32`: `gem.add_dependency('nokogiri')` — **バージョン制約なし**。
  「たまたまリンクされている版に依存する」というこの Issue の前提そのものが
  gemspec レベルで成立している。
- `Gemfile.lock`: 解決バージョンは `1.19.4`（各プラットフォーム）。
- インストール済み実体（`.../nokogiri-1.19.4-.../lib/nokogiri/xml/parse_options.rb`）を
  直接確認:
  - `:73` `RECOVER = 1 << 0`（既定オン。壊れた XML でも寛容にパースする）
  - `:80` `NOENT = 1 << 1`（既定**オフ**。ドキュメント自身が
    「🛡 UNSAFE to set this option when parsing untrusted documents」と明記）
  - `:85` `DTDLOAD = 1 << 2`（既定**オフ**。同じく
    「🛡 UNSAFE to set this option」と明記）— **Issue 本文が触れていなかった第3のフラグ**。
    外部 DTD サブセット自体の読み込みを制御し、`NOENT` が off でも `DTDLOAD` が on だと
    外部 DTD 内で定義された実体は解決され得る（3節の実証参照）。
  - `:115` `NONET = 1 << 11`（既定オン。
    「🛡 UNSAFE to unset this option when parsing untrusted documents」と明記）
  - `:148` `BIG_LINES = 1 << 22`（既定オン。行番号を `long int` で扱う。安全性とは無関係）
  - `:151` `DEFAULT_XML = RECOVER | NONET | BIG_LINES` — **`NOENT`/`DTDLOAD` を含まない**。
    Issue 本文の記載（RECOVER|NONET|BIG_LINES、NOENT オフ）と一致、`DTDLOAD` オフも
    確認済み。

### 3. 攻撃実証（tmp スクリプト、非コミット。両ケースとも file:// のみ使用し
実際のネットワーク宛先には一切アクセスしていない）

ローカル秘密ファイルを指す外部実体（`<!ENTITY xxe SYSTEM "file://...">`）と、
`file://` 経由の外部 DTD サブセット参照（サブセット内に実体 `&leaked;` を定義）の
2種類の攻撃 XML を作成し、以下を実測で対比:

| ケース | 現行既定（無指定 = `DEFAULT_XML`） | `NOENT`+`DTDLOAD` を意図的に有効化 |
|---|---|---|
| ローカルファイル実体 (`&xxe;`) | 解決されない（`root.text == ""`） | **解決される**（秘密ファイル内容が漏洩） |
| 外部 DTD サブセットの実体 (`&leaked;`) | 解決されない（`root.text == ""`） | **解決される**（`"EXTERNAL-DTD-WAS-LOADED"`） |

現行コードと全く同じ呼び出し形（`Nokogiri::XML::Document.parse(File.open(path))`、
options 無指定）で、両攻撃とも失敗することを確認。同じ入力に `NOENT`/`DTDLOAD` を
明示的に足すと両方成功することも確認 — 脅威そのものは実在し、Nokogiri のフラグ機構が
正しく効いていることの証左。`NONET` の効果（http/ftp 等ネットワーク経由の外部参照拒否）は
実際のネットワーク宛先へのアクセスを試みることを避けたため直接実証はしていないが、
Nokogiri 自身のドキュメント（上記 `:111-115`）が明記する既定挙動として引用する。

### 4. RECOVER 依存の実測（現行 STRICT 化した場合の破壊範囲）

`STRICT | NONET | BIG_LINES`（`RECOVER` を落とし、安全フラグのみ残した設定）で
以下を悉皆テスト:

- 本 repo の全 `.opt` fixture（4件: `code_reference_template.opt`, `eReferral.opt`,
  `minimum_template.opt`, `new_constraints_template.opt`）— **全て STRICT で問題なし**。
- anlage の実 OPT（`ProblemList.opt`, `LabResultReport.opt`,
  `CardiologyEncounter.opt`）— **全て STRICT で問題なし**。
- openehr-rails の実 OPT 10件（demo/spec 双方）— **9件は STRICT で問題なし**。
- 本 repo の ADL コーパス（`spec/lib/openehr/adl_parser/adl14/*.adl`、98件）を
  `ADLParser` → `XMLSerializer` でラウンドトリップし、生成された XML を STRICT で
  パース: 14件は ADLParser/XMLSerializer 側の理由（意図的な不正 ADL fixture・
  未対応構文等、Nokogiri とは無関係）で XML 生成自体に失敗するが、**XML が生成できた
  84件は全て STRICT で問題なし**。

**唯一の例外**: `/home/skoba/src/openehr-rails/spec/templates/lab_result_report_reduced.opt`
（同リポジトリの `docs/design/fix-terminology-scope-plan.md` に紐づく手書き回帰 fixture、
CKM/Archetype Designer 由来ではない）。冒頭コメント（同ファイル 2-15 行）が
「`-- ` を em dash 的に使う」英語の書き癖により、XML コメント構文上禁止された
二重ハイフンを複数含む:

```
5:10: FATAL: Double hyphen within comment
11:25: FATAL: Comment must not contain '--' (double-hyphen)
13:13: FATAL: Comment must not contain '--' (double-hyphen)
13:66: FATAL: Comment must not contain '--' (double-hyphen)
```

現行既定（`RECOVER`）ではこれらは `doc.errors`（警告相当）に留まり `doc.root` は
生成されてパース成功する。**`STRICT` にすると `Nokogiri::XML::Document.parse` 自体が
`Nokogiri::XML::SyntaxError` を raise し、パースが完全に失敗する**（`doc.errors` に
溜まるだけの現行既定より硬い失敗モード）。openEHR ドメインの内容自体の問題ではなく
コメント内の英文タイポ的な記法だが、**実在する downstream コンシューマの
現在パースできているファイルが STRICT 化で壊れる、という実例**として重い。

### 5. 影響面の整理（semver 判定材料）

| | Proposal A（NONET 等の明示化のみ、RECOVER 維持） | Proposal B（STRICT 同梱） |
|---|---|---|
| 実行時挙動 | **不変**（`DEFAULT_XML` と同一ビット。暗黙→明示にするだけ） | **変化**（4節の openehr-rails fixture 含め、既にパースできている一部入力が失敗するようになる） |
| 公開API | 不変（`parse` は引数無しのまま） | 不変 |
| インストール依存 | 不変 | 不変 |
| 既知の破壊 | 無し | 少なくとも1件（openehr-rails 側、他 repo なので本 repo の rspec では検知できない） |

Proposal A は影響面 3 要素（実行時挙動・公開API・インストール依存）のいずれにも
影響しないため **patch**。Proposal B は実行時挙動を変えるため **minor 相当**。

## 判定材料のまとめ（推奨: Proposal A のみ、B は見送り）

- 4節の実測により、STRICT 化は「理論上のリスク」ではなく**既に実在する
  downstream コンシューマの fixture を1件壊す**ことが分かった。しかもその fixture は
  openEHR ドメインの内容不備ではなく、英文の記法（`--` を em dash として使う）という
  ADL/OPT パーサの本質と無関係な理由で落ちる — STRICT 化のコストに対して
  得られるセキュリティ上の利益が小さい（3節の通り、脅威の実体は `NOENT`/`DTDLOAD` で
  ある。`RECOVER` の有無は XXE の可否を左右しない）。
- 結論として **Proposal A のみを本 Issue のスコープとし、Proposal B（STRICT 化）は
  見送りを推奨**。STRICT 化自体に価値が無いわけではないが、別 Issue として
  openehr-rails 側 fixture の記法修正とセットで再提案する方が筋が良い
  （本 plan の「備考」に記録）。

## 修正方針（提案 A・既定）

### 定数の設計

`OpenEHR::Parser::Base`（`lib/openehr/parser.rb:3-13`、両パーサの共通親クラス）に
追加する。**`Nokogiri::XML::ParseOptions::DEFAULT_XML` を参照するのではなく、
構成ビットを直接列挙する**のが本 Issue の趣旨そのもの — `DEFAULT_XML` を参照すると
将来 Nokogiri がその定義を変えた場合に無自覚に追従してしまい、「明示化」の意味が
なくなる。

```ruby
module OpenEHR
  module Parser
    class Base
      # Explicit, safe Nokogiri ParseOptions for untrusted OPT/archetype XML.
      # Deliberately lists RECOVER|NONET|BIG_LINES by name rather than
      # referencing Nokogiri::XML::ParseOptions::DEFAULT_XML - the whole
      # point is to not silently follow that constant if a future Nokogiri
      # release (or a downstream app pinning an older one) changes it.
      #
      # - RECOVER: parse malformed-but-well-intentioned XML leniently
      #   (matches today's implicit default; see
      #   docs/design/xxe-safe-parse-options-plan.md for real-fixture
      #   evidence that at least one downstream consumer OPT currently
      #   depends on this).
      # - NONET: forbid network access during parsing. Nokogiri's own docs:
      #   "UNSAFE to unset this option" for untrusted input.
      # - BIG_LINES: line numbers as `long int`, unrelated to safety.
      # - NOENT (entity substitution) and DTDLOAD (external DTD subset
      #   loading) are deliberately NOT set - both default off in Nokogiri
      #   and both documented "UNSAFE to set...for untrusted documents".
      #   This is what actually gates XXE (see the plan's attack-proof
      #   section: enabling either makes local-file and external-DTD
      #   entity resolution succeed).
      SAFE_PARSE_OPTIONS = Nokogiri::XML::ParseOptions.new(
        Nokogiri::XML::ParseOptions::RECOVER |
        Nokogiri::XML::ParseOptions::NONET |
        Nokogiri::XML::ParseOptions::BIG_LINES
      )
    end
  end
end
```

`lib/openehr/parser.rb` は現状 `nokogiri` を require していない（`opt_parser.rb`/
`xml_archetype_parser.rb` がそれぞれ `require 'nokogiri'` している）。`Base` に
定数を置く場合、`parser.rb` 自身にも `require 'nokogiri'` を追加する必要がある
（`parser.rb:19-23` の `require_relative` 群より前）。

### 呼び出し側が options を渡せる場合の扱い: **渡せない設計のまま据え置く**

`OPTParser.new(filename)`/`XMLArchetypeParser.new(filename)` は現在
`filename` 以外の引数を受け付けず、`parse` も引数無し
（`OpenEHR::Parser::Base#initialize`, `lib/openehr/parser.rb:6-8`）。
**この形を変えず、`parse` に options を渡す公開APIを新設しない**ことを推奨する:
呼び出し側が安全設定を上書きできる余地を作ること自体が防御を弱める。
「オプション上書き耐性」（Step 1 の要求どおり）は、この設計により
「上書きする手段が存在しない」という形で最も強く担保される。

### 呼び出し箇所の変更

Nokogiri 1.19.4 の `Document.parse` はキーワード引数 `options:` を受け付ける
（`.../nokogiri-1.19.4-.../lib/nokogiri/xml/document.rb:56-60`）。位置引数の
`nil, nil, options` より意図が明確なため、キーワード形を使う:

- `lib/openehr/parser/opt_parser.rb:43`:
  ```ruby
  @opt = Nokogiri::XML::Document.parse(File.open(@filename), options: SAFE_PARSE_OPTIONS)
  ```
- `lib/openehr/parser/xml_archetype_parser.rb:33`:
  ```ruby
  parsed = Nokogiri::XML::Document.parse(File.open(@filename, 'rb:bom|utf-8'), options: SAFE_PARSE_OPTIONS)
  ```

### ファイルハンドルの明示的 close（Issue 本文の付随指摘、同梱を推奨）

両呼び出しとも `File.open` の戻り値を block なしで受けており、GC 任せで
ファイルディスクリプタがリークする（実測で再確認済み）。今回まさにこの2行に
触れるため、block 形に直すことを提案する:

```ruby
# opt_parser.rb:43
@opt = File.open(@filename) { |f| Nokogiri::XML::Document.parse(f, options: SAFE_PARSE_OPTIONS) }

# xml_archetype_parser.rb:33
parsed = File.open(@filename, 'rb:bom|utf-8') { |f| Nokogiri::XML::Document.parse(f, options: SAFE_PARSE_OPTIONS) }
```

これは XXE と直接関係しないため、CLAUDE.md の「1 Issue = 1 branch = 1 PR」原則との
整合性をユーザ判断で確認いただきたい。Issue #33 本文が同じ変更箇所への
「ついでの修正」として明示的に提案しているため同梱を既定案とするが、
除外して別 Issue に切り出す判断も妥当。

## TDD 手順（率直な位置づけ: 一部は純粋な red→green ではない）

Proposal A は**挙動を変えない**（`DEFAULT_XML` と同一ビット列を明示するだけ）ため、
「外部実体が解決されない」という結果そのものは**今日から既に true**。これを
機械的に red スタートさせようとすると意味のない red になる。そのため、
下記のように「メカニズムの明示性」を red の基準にする:

### Cycle 1 — 定数

- **Red — 新規** `spec/lib/openehr/parser_spec.rb` またはベースクラス spec:
  `OpenEHR::Parser::Base::SAFE_PARSE_OPTIONS` が存在し、`.recover?` true /
  `.nonet?` true / `.noent?` false / `.dtdload?` false であることを assert。
  定数が存在しないため `NameError` で red。
- **Green**: 上記定数を追加。

### Cycle 2 — 呼び出し側（ここが実質的な red→green の中心）

- **Red — 新規** `spec/lib/openehr/parser/xxe_safety_spec.rb`:
  `Nokogiri::XML::Document` に `expect(...).to receive(:parse).with(anything,
  hash_including(options: OpenEHR::Parser::Base::SAFE_PARSE_OPTIONS))` 相当の
  スタブを張り、`OPTParser.new(fixture).parse` /
  `XMLArchetypeParser.new(fixture).parse` の両方でこの期待が満たされることを assert。
  現行コードは options を渡していないため red。
- **Green**: 呼び出し側を上記の通り変更。

### Cycle 3 — 攻撃 fixture による end-to-end 固定（regression pin、正直な位置づけ）

- **新規 fixture** `spec/lib/openehr/parser/security_fixtures/xxe_entity_attack.xml`
  と `xxe_external_dtd_attack.xml`。冒頭コメントで明記:
  「本ファイルは XXE 攻撃の再現用に作成した合成ペイロードであり、臨床データや
  実運用アーティファクトではない。CLAUDE.md の real-artifact-only ルールの
  適用除外（security fixture）に該当する」。
- **spec（regression pin。red→green ではなく、既に green であることを明記した上で
  固定する）**: `spec/lib/openehr/parser/xxe_safety_spec.rb` に追記。
  `OPTParser`/`XMLArchetypeParser` それぞれで両 fixture をパースし、外部実体が
  解決されていないこと（該当要素のテキストが空、または実体参照がリテラルのまま）を
  assert。**Cycle 2 の変更前後どちらでも green** である旨をコメントで明記
  （挙動が変わらないことの証明としてあえて残す）。
- **対比 spec（Nokogiri 自体の契約を固定する、依存契約テスト）**:
  同ファイルに、`SAFE_PARSE_OPTIONS` とは別に `NOENT|DTDLOAD` を明示的に有効化した
  `ParseOptions` を組み立て、同じ fixture で今度は実体が解決される
  （＝脅威が実在し、Nokogiri のフラグが機能している）ことを assert。これは
  openehr-ruby 自身のコードでなく Nokogiri の挙動そのものの固定だが、
  「なぜ SAFE_PARSE_OPTIONS の除外設定が安全なのか」の根拠を将来のリーダーに
  示す価値がある。

### Cycle 4 — 仕上げ

- `lib/openehr/version.rb` バージョン更新（semver は下記）。
- `History.txt` 追記（下記ドラフト）。
- `bundle exec rspec` 全走・`bundle exec rubocop`（todo 再生成禁止）。

## History.txt 記載案（草稿）

正直なフレーミングとして、「脆弱性を修正した」ではなく「既に安全だった既定を
明示化し、回帰テストで固定した」と書く:

```
=== 2.3.2 (または 2.4.0、Step 6 裁定による)
Hardening release: OPT/archetype XML parsing now pins its Nokogiri
ParseOptions explicitly instead of relying on Nokogiri's own default.

* OPTParser and XMLArchetypeParser now parse with an explicit
  OpenEHR::Parser::Base::SAFE_PARSE_OPTIONS (RECOVER | NONET |
  BIG_LINES) instead of calling Nokogiri::XML::Document.parse with no
  options argument. This is NOT a fix for an exploitable XXE - under
  the currently-resolved nokogiri (1.19.4), the implicit default
  (Nokogiri::XML::ParseOptions::DEFAULT_XML) already excludes NOENT
  and DTDLOAD, and both flags were confirmed (by reproduction) to be
  what actually gates XXE, not RECOVER. The change removes this gem's
  dependency on "whichever Nokogiri version happens to be linked" by
  asserting the safe bits explicitly and pinning them with a
  regression test, rather than inheriting them silently. Callers
  cannot override this - parse() takes no options argument.
* File handles opened for parsing are now closed deterministically
  (block-form File.open) instead of left to GC finalization.
```

## semver

Proposal A のみなら **patch**（実行時挙動・公開API・インストール依存のいずれも
不変 — CLAUDE.md 改訂後の Release convention の判定基準に照らして中立ではなく
「安全に保たれる変更」だが、挙動が変わらない以上 patch 相当と考える）。
File handle の close 挙動変更も観測可能な公開挙動の変化ではない。
**最終判定は Step 6 の棚卸しで確定**（規約どおり）。

## 備考: Proposal B（STRICT）を見送る場合の記録

- 4節で発見した openehr-rails 側の RECOVER 依存 fixture
  （`spec/templates/lab_result_report_reduced.opt`）の記法修正は、
  STRICT 化とは独立に「正しい XML コメント構文にする」だけの価値がある
  （現状 `doc.errors` に4件の FATAL 相当の警告を出し続けている）。
  openehr-rails 側への軽微な追補提案として別途検討の余地あり
  （本 Issue #33 のスコープ外、本 repo からは直接手を出せない）。
- STRICT 化そのものを将来提案する場合は、この fixture 側の修正とセットで
  提案するのが筋が良い。

## Issue 増補用サマリ（英語・ペースト用）

```markdown
## Investigation update (2026-08-22): DTDLOAD, attack reproduction, and RECOVER-dependency data

Verified against the actually-resolved nokogiri (1.19.4) source
(`lib/nokogiri/xml/parse_options.rb`), not just its documentation:

- `DEFAULT_XML = RECOVER | NONET | BIG_LINES` (line 151) - confirmed exactly as this
  issue states.
- A third relevant flag beyond NONET/NOENT: `DTDLOAD` (line 85, external DTD subset
  loading) is also off by default and also documented "UNSAFE to set... for untrusted
  documents". It's independently sufficient to enable external-DTD-based entity
  resolution even without NOENT.

Reproduced the actual attack, not just cited the docs: built a local-file entity
payload and a `file://`-based external-DTD-subset payload (no real network hosts
contacted). Both fail to resolve under this gem's exact current call pattern
(`Nokogiri::XML::Document.parse(File.open(path))`, no options). Enabling
`NOENT|DTDLOAD` on the identical input makes both resolve - confirming the mechanism
is real, not merely undocumented-safe-by-luck.

Also gathered RECOVER-dependency data for the STRICT question this issue raises as an
open question: parsed every real OPT fixture in this repo, the anlage repo, and the
openehr-rails repo (23 files total), plus every ADL file in this repo's own corpus
round-tripped through ADLParser -> XMLSerializer (98 files, 84 producing valid XML),
under STRICT. All clean except one: `openehr-rails/spec/templates/lab_result_report_reduced.opt`,
a hand-authored (non-CKM) regression fixture whose header comment uses `--` as
em-dash punctuation, which is illegal inside an XML comment. Under STRICT this raises
`Nokogiri::XML::SyntaxError` outright (a harder failure than today's lenient
`doc.errors` collection). This is real but narrow evidence against bundling STRICT
into this same change - recommending NONET/NOENT/DTDLOAD explicitness only, RECOVER
preserved, with STRICT left for a separate future issue (paired with fixing that one
fixture's comment syntax upstream in openehr-rails).
```
