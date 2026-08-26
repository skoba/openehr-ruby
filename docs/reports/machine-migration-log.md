# 開発機移行 検収ログ

旧開発機の破損に伴う本マシンでの環境再構築について、GitHub origin と
rubygems.org 上の公開物を正典として検収する。R1〜。

対象リポジトリは3つ（`openehr-ruby` / `openehr-rails` / `anlage`）。
`openehr-rails`・`anlage` への読み取り・実行は本タスクの明示指示に基づく
（CLAUDE.md「Repository boundary」）。各コマンドは `git -C <path>` ないし
明示的な `cd` で対象を固定した。

---

## R1: 検収実測（2026-08-26）

### Step 1: リポジトリ実体

| 項目 | openehr-ruby | openehr-rails | anlage |
|---|---|---|---|
| origin | `git@github.com:skoba/openehr-ruby.git` | `git@github.com:skoba/openehr-rails.git` | `git@github.com:skoba/anlage.git` |
| 追跡ブランチ | `master` | `master` | `main` |
| local HEAD | `c5b72e221786e18cfe77766192039b41297e09ea` | `89ec115a674d5d1a612195cf45ba64af76984338` | `81fd47520a87f5fb398cadb2b16953cd9c7853b4` |
| origin HEAD | 同上 | 同上 | 同上 |
| ahead / behind | 0 / 0 | 0 / 0 | 0 / 0 |
| working tree | clean | clean | clean（検収前） |
| 未push commit | 0 | 0 | 0 |

`git fetch --tags origin` を3リポジトリで実行。新規 ref の取得は無し
（既に origin と同一）。

**リリースタグ**（`git tag --sort=-v:refname` および
`git ls-remote --tags origin` の両方で実測、origin 側にも存在を確認）:

- `openehr-ruby`: 最新 `v2.4.2` → `4ffd57b3d9c0ce5af2577e3825a01b3e5e88563f`（タグ総数50）**期待どおり**
- `openehr-rails`: 最新 **`v0.6.0`** → `40800536737b85b8b0a8b1422cbea9acfb1c7929`（`v0.5.0` → `69db63ff...` も存在。タグ総数15）**期待（v0.5.0）とずれ — 下記 D1**
- `anlage`: タグ 0 件（`ls-remote --tags origin` も 0 件）**期待どおり**

### Step 2: 実行環境と gem 供給網

**Ruby / rbenv**（3リポジトリとも同一）:

- `.ruby-version` = `4.0.6`、`ruby -v` = `ruby 4.0.6 (2026-07-14 revision 03b6d3f889) +PRISM [x86_64-linux]` → **一致**
- `which ruby` = `/home/skoba/.rbenv/shims/ruby`（rbenv 解決を確認）
- `rbenv --version` = `1.3.2-25-g07e9b1e`、`rbenv global` = `4.0.6`
- `bundle --version` = `4.0.16`

**bundle install**:

- `openehr-ruby`: 完走。`Bundle complete! 12 Gemfile dependencies, 75 gems now installed.`
- `openehr-rails`: **初回失敗** → `MAKEFLAGS=-j1` 付きで完走
  （`Bundle complete! 11 Gemfile dependencies, 118 gems now installed.`）。**D5**
- `anlage`: 完走。`Bundle complete! 25 Gemfile dependencies, 136 gems now installed.`

**解決元の検証**（`Gemfile.lock` のセクション見出しと `remote:` 行を実測）:

| | PATH セクション | GIT セクション | GEM remote |
|---|---|---|---|
| openehr-ruby | 有（`remote: .`＝`gemspec` による自リポジトリ） | **無** | `http://rubygems.org/` **D7** |
| openehr-rails | 有（`remote: .`＝同上） | **無** | `https://rubygems.org/` |
| anlage | **無** | **無** | `https://rubygems.org/` |

→ 外部への `path:` / `git:` / `github:` 参照は**3リポジトリとも0件**。
`openehr-ruby` / `openehr-rails` の PATH セクションは `gemspec` ディレクティブに
よる自リポジトリ参照であり、外部 path 参照ではない。
なお両リポジトリの `Gemfile.lock` は `.gitignore` 対象（`openehr-ruby/.gitignore:33`、
`openehr-rails/.gitignore:30`）のため、本検収で新規生成されたもの。

**`gem list openehr openehr-rails`**:

```
openehr (2.4.2)
openehr-rails (0.5.0)
```

→ **期待どおり**。`bundle list`（anlage）でも同一。

**anlage の checksum 照合**:

`anlage/Gemfile.lock` の `CHECKSUMS` セクション（`Gemfile.lock:533-534`）:

```
openehr (2.4.2) sha256=91556d3a7f9a105634d981de33f66e1427a2fc9efc4ee4e136d97d19f6586948
openehr-rails (0.5.0) sha256=e07815bd1c86736403cbb558fec869fbe04666f695e6cc12a41dad9be77230e6
```

`bundle install` は上記 lock に対して checksum エラー無しで完走した（＝bundler の
checksum 検証を通過）。加えて、これを推論に留めないため2系統を独立実測した:

1. gem cache 上の取得物 — `sha256sum ~/.rbenv/versions/4.0.6/lib/ruby/gems/4.0.0/cache/openehr-2.4.2.gem` ほか
2. rubygems.org からの再取得 — `gem fetch openehr -v 2.4.2 --source https://rubygems.org` ほかを scratch ディレクトリへ取得

```
91556d3a7f9a105634d981de33f66e1427a2fc9efc4ee4e136d97d19f6586948  openehr-2.4.2.gem
e07815bd1c86736403cbb558fec869fbe04666f695e6cc12a41dad9be77230e6  openehr-rails-0.5.0.gem
```

→ lock 記載値・cache 実物・rubygems.org 再取得物の**3者が完全一致**。

（当初は当該 gem を uninstall してから再取得させ bundler の検証経路そのものを
走らせる手順を試みたが、`gem uninstall` は権限で拒否された。上記は非破壊な
代替実測である。）

**`bundle outdated`（参考実行、更新はしない）**:

| Gem | Current | Latest | 該当リポジトリ |
|---|---|---|---|
| diff-lcs | 1.6.2 | 2.0.0 | 3リポジトリ全て |
| lumberjack | 1.4.2 | 2.0.5 | 3リポジトリ全て |
| marcel | 1.2.1 | 2.1.0 | openehr-rails / anlage |

いずれも間接依存（開発・テスト経路）。直接依存の遅れは無し。更新は行っていない。

**全 suite 実行**:

| リポジトリ | 実測 | 期待 | 判定 |
|---|---|---|---|
| openehr-ruby | **3973 examples, 0 failures**（15分2秒、行カバレッジ 6921/7109 = 97.35%） | 3973 / 0 | **一致** |
| openehr-rails | 初回 **281 examples, 3 failures** → 再実行 **281 examples, 0 failures**（2分4秒） | 281 / 0 | 再実行で一致（**D3**） |
| anlage | **97 examples, 1 failure**（1分17秒） | 97 / 0 | **乖離 — D4** |

**`rake build`（openehr-rails）**:

```
openehr-rails 0.6.0 built to pkg/openehr-rails-0.6.0.gem.
```

`pkg/openehr-rails-0.6.0.gem` sha256 =
`223e3b3897f85c38eaffe7ea39bd7c2acf4c5de9cab7d50fe38f754ff9d65db6`（報告のみ）。
生成できることを確認。`pkg/` は `.gitignore` 対象で作業ツリーは clean のまま。

**anlage: 開発 DB の復元と測定器の確認**:

- `bin/rails db:prepare` → exit 0。直後の `Template.count` = **0**
  （`db/seeds.rb` は雛形のままで seed データを持たない）。
- fixture 4件（`ProblemList` / `LabResultReport` / `CardiologyEncounter` /
  `bmi_calculation`。`spec/fixtures/opt/` 配下）を `Template.build_from_opt_xml`
  で登録 → `Template.count` = 4。
- `bin/rails pathcards:backfill` → exit 0。登録時点で `pathcards` が既に
  埋まっていたため冪等に無変化（backfill の設計どおり）。
- カード総数の実測:

  | template_id | カード数 |
  |---|---|
  | ProblemList | 6 |
  | LabResultReport | 3 |
  | CardiologyEncounter | 2 |
  | bmi_calculation | 4 |
  | **合計** | **15** |

  → **期待（12カード）とずれ。ただしリポジトリの既存記録は一貫して15である**（**D2**）。
- `bin/rails pathcards:eval` 実測:

  ```
  Pathcard search evaluation (phase1-bigram)
  Questions: 17
  Top-1 accuracy: 14/17 (82.35%)
  Top-3 accuracy: 15/17 (88.24%)
  Complete failure rate: 2/17 (11.76%)
  MRR: 0.8529
  Intent breakdown (hits/questions):
    bigram成立想定: 11/11
    複合語: 4/4
    同義語ギャップ: 0/2
  Complete failures:
    q16: BMI
    q18: 既往
  ```

  → **top-1 14/17（82.35%）・top-3 15/17・MRR 0.8529 を完全再現**。測定器は無傷。
  完全失敗2問（q16・q18）も `docs/reports/wp4-eval-log.md` の
  2026-08-25T00:17:09Z エントリと同一内訳。

  副作用: 当タスクは `docs/reports/wp4-eval-log.md` へ追記する設計のため、
  anlage の作業ツリーは当該1ファイルのみ modified になっている（コミットせず）。

**Node / Sushi**:

- `node --version` = `v18.19.1`（`/usr/bin/node`）、`npm --version` = `9.2.0`
- `npm ls -g --depth=0` = `fsh-sushi@3.16.0`（prefix `/home/skoba/.npm-global`）
- `/home/skoba/.npm-global/bin/sushi --version` →
  `SUSHI v3.16.0 (implements FHIR Shorthand specification v3.0.0)` — 期待どおり
- ただし `/home/skoba/.npm-global/bin` が `PATH` に無く（`~/.zshrc` の PATH 追加は
  `.rbenv/bin`・`.rbenv/shims`・`.local/bin` の3つのみ）、素の `sushi` は
  `command not found` になる（**D6**）
- 実施経緯の明示: 検収開始時点（22:07）の `which sushi` は not found だった。
  その後 `/home/skoba/.npm-global` 配下の全ファイルが 22:14〜22:24 のタイムスタンプで
  存在するようになったが、**本セッションから `npm install` 相当は一度も実行していない**。
  導入経緯は不明であり、実測できるのは「現在 3.16.0 が存在し動作する」ことのみ。

**参考（損失ではない）**: 旧機 dev DB にあった `mml_referral` 診断ドロップ
（136カード）は fixture 化前のため復元対象外。実測結果は
`anlage/docs/reports/referral-intake-log.md` R1 に記録済みで、必要時に
`skoba/mml` から再ドロップ可能。上記15カードとの差分は損失ではない。

### Step 3: 損失の棚卸し

**`git stash list`**: 3リポジトリとも**0件**（空であることを確認）。

**`git branch -a`**（ローカル専用ブランチの有無）:

| | ローカル | リモート追跡 |
|---|---|---|
| openehr-ruby | `master` のみ | `origin/HEAD`, `origin/ci/update-action-versions`, `origin/gh-pages`, `origin/master`, `origin/rspec299` |
| openehr-rails | `master` のみ | `origin/HEAD`, `origin/feature/field-extractor-terminology-bindings`, `origin/master`, `origin/opt_base` |
| anlage | `main` のみ | `origin/HEAD`, `origin/dependabot/github_actions/actions/cache-6`, `origin/main` |

→ origin に対応の無いローカルブランチは**0件**。新機ゆえ空、という期待どおり。

**最新 R エントリ・規約末尾の照合**（「進行中だった未 push 作業」への言及の有無）:

- `openehr-ruby/docs/reports/round2-prep-log.md` R5 — 末尾は
  「Task complete. Filed: `skoba/openehr-ruby#48`, `#49`. Returning to dormant.」。
  3コミットの push SHA（`3a1843d..a695efa`）と CI run `32832899623` の green を
  記録済みで、未 push の残件への言及なし。
- `openehr-rails/docs/reports/fsh-generator-log.md` R6 — 末尾は
  「Gate: reporting to the user for approval before implementation.」。
  `#33` の explore と設計文書 `docs/design/multi-leaf-non-observation-plan.md`
  までで承認待ちに入っており、未 push の実装作業は存在しない。
- `anlage/docs/reports/referral-intake-log.md` R1 / `docs/backlog.md` 8項 —
  末尾は `mml_referral` 取り込みの「見送りを推奨、判断は人間へ委ねる」。
  人間判断待ちであって、失われた作業ではない。
- `anlage/CLAUDE.md`「進行中のワークストリーム」節 — マイルストーン
  （2026-11-05 デモビルド凍結／2026-11-12 デモ本番／2026-12 世界公開）の記載のみ。
  未 push 作業への言及なし。
- 3リポジトリの `docs/reports/` と `CLAUDE.md` を
  `未push|未コミット|作業中|進行中|WIP|途中|次回セッション|持ち越し|継続作業|やりかけ`
  で横断 grep した結果、該当は上記ワークストリーム節と WP4 の人間レビュー記述のみで、
  **未 push 作業を示すものは0件**。

→ **旧機ローカルで失われた既知の作業は無し（損失なし）**。

### 乖離一覧

- **D1 — `openehr-rails` の最新タグは `v0.6.0`（期待 `v0.5.0`）**。
  `4080053 Release: bump version to 0.6.0` と
  `b3617d6 Docs: record R5 (v0.6.0 tagged, release.yml green, artifact match)` が
  origin に存在し、タグも origin 側にある。一方 **rubygems.org 上の
  `openehr-rails` 最新は `0.5.0`**（`gem list -r -a openehr-rails` 実測）で、
  `0.6.0` は未公開。これは `fsh-generator-log.md` R5 の
  「RubyGems publish is the human's step next」と整合しており、想定より1手先に
  進んでいるだけで損失ではない。タスク Step 2-5 の「0.6.0 リリース作業の前提」
  という前置きは、実態としてはタグ済み・公開待ちの段階にある。
  なお `openehr` は rubygems.org 上も `2.4.2` が最新で、タグと一致。
- **D2 — anlage のカード総数は 15 で、期待の 12 と一致しない**。
  リポジトリ側の既存記録は一貫して15を示す:
  `docs/reports/wp3-log.md:21`（「4テンプレート…合計**15枚**」）、
  `docs/reports/wp4-log.md:24`（「カードは15枚だが、ユニークな archetype_id は7種類」）、
  `docs/design/wp3-plan.md:25,46`、`docs/backlog.md:126`。
  golden fixture 3件のみなら 11 枚（2+3+6）で、これも12にはならない。
  「12」の出典はリポジトリ内に見当たらない。かつ eval が 14/17・MRR 0.8529 を
  完全再現していることから、**復元された DB の内容は評価基盤として正しい**と判断できる。
  → 期待値12の方を訂正すべき乖離と見る。
- **D3 — `openehr-rails` の初回 suite で3失敗、再実行で0**。
  失敗は全て `spec/generators/openehr/scaffold/opt_scaffold_generator_spec.rb`。
  実測エラーは
  `Errno::ENOENT: No such file or directory @ rb_sysopen - /home/skoba/src/openehr-rails/tmp/config/routes.rb`。
  当該 spec は `tmp/` を generator の `destination_root` に使う
  （`opt_scaffold_generator_spec.rb:9`）が、`tmp/` は `.gitignore:26` 対象で
  新規 clone には存在しない。当該ファイル単独実行は 40 examples, 0 failures、
  `tmp/` 生成後の全 suite 再実行も 281 examples, 0 failures。
  **新規 clone 直後の初回実行に限る環境事象**で、コード側の欠損ではない。
- **D4 — anlage suite が 97 examples, 1 failure（再現性あり）**。
  失敗は
  `spec/system/polymorphic_dropzone_spec.rb:25`
  「shows template-ize guidance for a dropped bare ADL archetype」。
  単独再実行でも同じく失敗（2 examples, 1 failure）。
  `log/test.log` 実測により原因を特定: ADL を投じた
  `POST /templates/preview` は **200 OK で `templates/preview_adl.html.erb` を
  正しくレンダリングしている**が、所要時間が **2761ms / 3875ms**（2回の実測）で、
  `Capybara.default_max_wait_time` = **2**（実測、リポジトリ側に上書き設定なし）を
  超過するため、レスポンス到達前にアサーションが時間切れする。
  → **アプリの挙動の欠損ではなく、本機の単発処理速度が旧機より遅いことによる
  タイムアウト**。同ファイルのもう1例（composition JSON）は成功しており、
  ブラウザ実行系（Selenium Manager が `~/.cache/selenium` へ Chrome /
  chromedriver を自動取得）自体は健全。
- **D5 — native extension のビルドが `make -j3` 下で不安定**。
  `openehr-rails` の初回 `bundle install` が `date 3.5.1` のビルドで失敗:
  `Assembler messages: Fatal error: can't create date_core.o: No such file or directory`。
  同一ソースを直列 (`make V=1 date_core.o`) で再ビルドすると 2,429,448 バイトの
  `date_core.o` が正常生成される。ディスク・inode は潤沢
  （`/` 946G avail / IUse 1%）。`MAKEFLAGS=-j1` で `openehr-rails`・`anlage` とも完走。
  WSL2 環境の並列ビルド起因と見られる。**再現時は `MAKEFLAGS=-j1` を付ける**。
- **D6 — `sushi` が `PATH` に無い**。実体は
  `/home/skoba/.npm-global/bin/sushi` にあり 3.16.0 で動作するが、`~/.zshrc` に
  `/home/skoba/.npm-global/bin` の PATH 追加が無い。
  `export PATH="$HOME/.npm-global/bin:$PATH"` 1行の追記で解消する見込み（未実施）。
- **D7 — `openehr-ruby/Gemfile` の source が `http://rubygems.org`**（https ではない）。
  `openehr-rails`・`anlage` は `https://rubygems.org`。
  gem 供給網の検収項目として記録に残す（本タスクでは変更しない）。

### 判定

Step 2-4 の受入条件「全 suite いずれも 0 failures」を **anlage が満たさない**
（D4、97 examples / 1 failure、再現性あり）ため、指示どおり**追加作業を行わず停止し、
裁定を待つ**。

ただし D1〜D7 のいずれも **origin / rubygems.org 上の正典に対する欠落ではない**:

- リポジトリ実体は3つとも origin と SHA 単位で一致、stash 0・ローカル専用ブランチ 0
- gem 供給網は全て rubygems.org 解決、anlage の sha256 は lock・cache・再取得の3者一致
- `openehr-ruby` は 3973/0 で完全一致、`openehr-rails` は再実行で 281/0
- anlage の測定器（`pathcards:eval`）は 14/17・MRR 0.8529 を完全再現

→ **損失なし**。残る乖離は本機固有の環境事象（D3・D4・D5・D6）と、
タスク側の期待値の更新漏れ（D1・D2）、および既存の設定事項（D7）に分類される。
