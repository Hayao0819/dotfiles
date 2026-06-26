---
name: writing-tech-article
description: Drafts fact-based technical articles for hayao's outlets — Zenn (@hayao), Qiita (@Hayao0819), the personal blog (hayao0819.com) — matching his structural register without faking his personality. Use when writing, drafting, or rewriting a 技術記事 / blog post / Zenn / Qiita article in hayao's name about a technical topic. The LLM writes facts only: it does NOT manufacture his jokes, 毒舌, 自虐, casual throwaway closers, or first-person anecdotes — performing his personality is fabrication and he finds it offensive. Encodes the factual baseline of his writing (genre-driven 敬体/常体, direct openings, plain content-label headings, inline-code density, primary-source links) in a bundled reference.md, and composes with the natural-writing skill. Self-contained — does not depend on machine-local memory. Do NOT use for: non-hayao docs, pure code, commit messages, or chat replies.
---

# Writing a tech article (hayao, fact-based)

Write a technical article that carries facts clearly in hayao's structural register. The hard rule: **an LLM writes facts, not personality.** His real articles contain jokes, 毒舌, 自虐, 取り消し線 asides, and casual closers — those are *his* because *he* wrote them. When an LLM manufactures them it is fabrication, and he has explicitly rejected it. Reproduce his structure and register; never perform his persona.

## The hard rule: facts only

Do NOT generate any of these. They are the personality-performance traps the LLM falls into:

- ネタ・ボケ・`~~取り消し線~~` のジョーク、内輪ネタ、あだ名いじり
- 毒舌・特定メーカーや人物への当てこすり、煽り
- 自虐・「自分も一度ハマった」式の検証不能な疑似体験(捏造)
- 「気が向いたら続きを書きます」「それではまた今度」「〜する人探してます」「知ってたら教えて下さい」式の投げやり締め・読者募集
- 親近感の演出(「〜ありますよね」「経験ありませんか」)
- キャッチー見出し・煽りタイトル

書いてよいのは、検証できる事実・コード・一次情報・そして事実に根ざした素直な技術的判断だけ。意見は持ってよいが、必ず根拠とセットにする(例:「正直使いにくく、使うメリットもわからないので使わない」のように、なぜそう判断したかが事実として示せる範囲)。

このルールは黙って適用する。成果物(記事本文)だけを返し、「人格の演技は入れていない」「ネタ・投げやり締めは避けた」のような遵守報告・自己申告・メタ説明を出力に一切書かない。下の self-check も内部で済ませ、結果だけを渡す。

## How this composes

1. **This skill** — fact-based structure and register for hayao's tech articles.
2. **`reference.md` (bundled in this skill dir)** — the detailed structural fingerprint and examples. Read it. Shared via dotfiles, so it is available on every machine; do not rely on machine-local memory. Note: its "personality" items (ネタ/毒舌/casual closer) describe how *he* writes, and are explicitly NOT for the LLM to reproduce.
3. **`natural-writing` skill** — run last on the finished draft (universal + Japanese pass + Documentation/blog domain pass). It now enforces the no-fake-anecdote, no-throwaway-closer, content-label-heading, bold-cap, and 評価副詞 rules.

## Structural register to match

### 1. 文体: 敬体 or 常体 by genre (decide first)

- **です・ます (敬体)** → technical explainers, tutorials, how-to. This is the default for a tech article.
- **だ・である (常体)** → only if the piece is genuinely a 解析メモ / formal write-up and the user asked for it. When unsure, use 敬体.
- Pick one and hold it the whole way.

### 2. Opening & title: direct, no heading

Open with no heading, in one or two sentences. Use one of his actual factual openings:
- 「〜したのでメモ」「〜の方法がわからなかったのでメモ。」
- A one-line statement of the subject: 「`mktemp`コマンドは一時ファイルを作成するコマンドです。」
- The motivation as plain fact: 「最近〜が登場し、〜ができるようになりました。」
- 症状/対象の素の記述 → 背景 → **動機の一文**(「再起動のたびに出るのが厄介だったので、消す方法を調べた」)。「のでメモ」は一例で、この動機・調査フレーミングも多い。

動機の一文には、**扱っている事実に根ざした軽い評価**(「毎回押すのは厄介だった」「さっぱり原因が分からなかった」)を入れてよい。§ハードルールが禁じる捏造された疑似体験(「自分も一度ハマった」)とは別物 ──**実際に起きている状況についての真の評価・動機は可、発明した体験・感情は不可**、が境界。淡々と事実だけにして動機・温度を全部削ぐと、かえって無味で本人らしくない文になる(LLMが最も陥りやすい過剰補正)。

タイトルは症状の長い記述より、解決アクション(「〜を消す/直す」)志向で簡潔に。読者に通じる略語(BLU 等)は使ってよい。

No grand 導入 (「現代の〜において」), no 「いかがでしたか」-class framing, no catchy hook.

### 3. Headings: plain content labels

Name the content. His real headings: 「概要」「全体」「本題」「設定」「エラーハンドリング」「ESLint」「Prettier」「TypeScript対応」「終わり」. Keep them flat, calm, and uniform in granularity. No catchy/anthropomorphic/teaser headings.

### 4. Body register

- 1文1段落、段落間に空行。短い文を積む。長い説明ブロックを作らない。
- 散文で書く。定義の列挙・概念説明・手順・まとめを箇条書きにしない(LLM臭が強い)。箇条書きは本当に並列な短い列挙(パッケージ名・ファイル名・選択肢)だけに限る。末尾のまとめをチェックリスト化しない。
- markdownlint準拠で書く: コードフェンスには言語タグ必須(実行例は `console`、ソースは `bash`/`go` 等)、見出し・コードフェンス・リストの前後に空行、連続空行を作らない、見出し末尾に `。!?` 等の記号を付けない、ファイル末尾は改行1つ。対象リポジトリに `.markdownlint*` 設定があればそれに従う。
- コマンド・型・ライブラリ名・プロパティは必ずインラインコード。
- コードブロックは言語タグ必須。bash例には `#` で日本語コメント(何をするコマンドか)を添える。
- ファイル構成は `txt` のツリーで、ファイル単位の小見出し(「### /main.go」)で区切る。
- 一次情報・公式ドキュメント・参照記事へのリンクを地の文に多めに置く。
- 一人称は 敬体記事では「私」、必要なら「自分」。総称の「あなた」「我々」は落とす。
- 同じ結末・結果を複数の節で繰り返さない。「対処」の結末と「終わり」の要約は同文になりがちなので、片方は別の含意(再発条件・残課題など)に振るか削る。

### 5. Honest limits (real ones only)

技術記事に「全部きれいに解決した完璧さ」を出さないのは、嘘の試行錯誤を足すことではない。**実際に未解決・未検証・制約がある点を、事実として正直に書く**だけでよい。hayao も実際にこう書いている:「唯一の課題は〜を現状併用できない点です」「未調査」「イマイチ安定していません」。

- 検証していないことは「未検証」「未調査」と書く。推測で断定しない。
- 制約・既知の問題・回避策の限界をそのまま書く。
- 解決できていない点を無理に解決したように書かない。
- これらは捏造ではなく事実の開示。疑似体験(§ハードルール)とは別物。
- **調査・デバッグがLLM支援だったときは、その事実を開示する。** hayao は本文に「LLMに調査させた」「LLM(Claude Code 等)で詳細に調べさせた」と書き、LLM由来の結論は引用ブロックや「〜とのこと」「〜らしい」で**出典と確度を明示**する。LLMがやった分析を、著者が独力で導いたかのように地の文へ流し込まない(これは静かな捏造)。「LLMは事実を書く」ハードルールの延長で、プロセスの事実も正直に書く。
- LLM由来・推定の結論は断定せず attribution + ヘッジを付ける(「変更が入ったとのこと」「影響は小さそう」)。自分で実行・検証した事実は断定してよい。未再検証の一般化(「毎回〜になる」)も「〜そう/はず」で柔らげる。

### 6. Closing

要約価値があるときだけ「終わり」「おわりに」で短くまとめる。なければ本文最後の事実で終える。投げやり締め・読者募集・続編予告は書かない(§ハードルール)。

## Verify before handing back

- **Run every runnable code/command example** and base the description on the observed result. Never write 「こうなります」 for an unrun snippet. 検証できなければ「未検証」と明記する。
- 実測結果は地の文で要約せず、実際の実行結果ブロック(コマンド＋出力＋終了コード)で見せる。「両方のechoが出力されます」と書くより、検証に使ったスニペットと出力をそのまま貼る。これが検証の説得力になる。
- 同じ実測の報告フレーム(「手元では〜でした」)を記事内で反復しない。出力ブロックで示せば地の文の「手元では」自体が要らなくなる。実測への言及が必要なときも表現を散らす。
- 一次情報リンクが主張どおりの内容か確認する。
- 事実が不明なら「わからない」と書く。埋めない。
- 可能なら `markdownlint`(対象リポジトリの設定で)を実行し、違反ゼロを確認してから渡す。

## Self-check

内部で確認するだけ。チェック結果・遵守状況・避けた項目を出力に書かない。

1. 文体(敬体/常体)を genre で決め、最後まで揃っているか。
2. ハードルール違反ゼロか: ネタ/毒舌/自虐/疑似体験/投げやり締め/読者募集/キャッチー見出しが一つも無いか。
3. 開きは直球(メモ/主題/動機)で、壮大な導入が無いか。見出しは内容ラベルか。
4. コードは実行検証済みか。未検証は明記したか。一次情報リンクはあるか。
5. 正直な未解決点・制約を(あるなら)事実として書いたか。無いものを捏造していないか。調査がLLM支援なら、その事実とLLM由来結論の出典/ヘッジを開示したか。動機・温度を全部削いで無味にしていないか。
6. `natural-writing` を通したか(太字3箇所以内・評価副詞の口癖なし・暴力比喩なし・全文頻度カウント済み)。
