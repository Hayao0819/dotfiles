---
name: natural-writing
description: Rewrites prose so it reads as if a human wrote it — stripping out LLM tells in both English and Japanese. Use whenever producing user-visible writing of any kind: documentation, README, markdown, blog posts, commit messages, PR descriptions, GitHub Issues, code-review comments, replies in issue threads, professional or casual emails, Slack/Discord/chat messages, release notes, design docs, academic-style writeups and 論文. Use it even when the user did not ask for "natural" prose — any drafted text leaving Claude that a human will read should pass through this checklist first. Triggers include: any request to "write", "draft", "compose", "summarize", "explain", "describe", "review", "comment", "reply", or 「書いて」「文章作って」「まとめて」「メール作って」「返信して」「PR/Issueの説明書いて」. Do NOT use for: pure code generation with no prose, raw data transformations, or terse tool output.
---

# Natural Writing

Strip LLM tells from any prose before it leaves the model. Two languages, many domains, one checklist.

## When this runs

Pass any drafted prose through the **Universal pass** first. Then add the **language pass** for the language(s) used. Then add the **domain pass** that matches the output's purpose.

Apply silently. Do not narrate "I removed the em-dashes." Just produce the cleaner draft.

## Why these patterns matter

LLM prose has a statistical fingerprint: high-probability words, uniform sentence length, balanced concessions, signposted structure, and tone that stays flat across the whole piece. None of these are "wrong" individually — clustering is the tell. Three or more in 300 words and a reader senses something is off, even if they can't name it. The goal is not to disguise an LLM but to write the way the user actually writes: specific, uneven, willing to be partial.

Two statistical concepts are useful to internalize:
- **Burstiness**: human sentence lengths vary wildly (3 words next to 38 words). LLM defaults compress to a narrow band. Aim for visible variance.
- **Perplexity**: humans use unexpected word choices; LLMs reach for the most-probable next token. When the third-most-likely word is the right word, use it.

Note that model fingerprints differ. Claude tends to over-hedge ("*I have to be honest,*" "*I want to be careful here*") and over-balance arguments; GPT-family tends to sycophant openers and rule-of-three; Gemini tends to emphatic affirmations and pseudo-empathy. Watch for the one you're producing.

---

## Universal pass (always)

### Lexical
- Drop **prestige nouns** that add no information: *tapestry, landscape, realm, mosaic, ecosystem, symphony, labyrinth, beacon, cornerstone, testament.*
- Drop **inflated adjectives**: *robust, seamless, vibrant, dynamic, transformative, groundbreaking, innovative, comprehensive, holistic, cutting-edge, paramount, pivotal, crucial, essential, key.* If everything is "crucial," nothing is.
- Drop **filler verbs**: *delve, leverage, utilize, foster, empower, elevate, navigate, illuminate, bolster, underscore, showcase, resonate.* Prefer the plain verb: *use, help, show, support.*
- Drop **vague abstractions** when a concrete word will do: 「本質」「価値」「最適化」「革新」 → name the specific thing.

### Sentence rhythm
- Vary length. Mix 4-word sentences with 25-word ones. LLM default is metronomic 14–22 words.
- Cut signposting: *"It's worth noting that," "When it comes to," "At its core," "In today's [adjective] world," "Let's unpack this."*
- Cut the **negated contrast** tic: "*It's not X — it's Y.*" Variants are equally dead: "*This isn't a job, it's a calling,*" "*This isn't a tool, it's a paradigm shift,*" "*Not just X, but also Y.*" Cognitive cost too: readers process the negated concept first. Use direct affirmation instead.
- Cut **tricolons** ("Fast. Simple. Effective.") unless one is genuinely earned. Same for "No X. No Y. Just Z."
- Cut **copula avoidance**: LLMs replace plain "*is/are*" with "*serves as, marks, represents, features, boasts, offers, stands as.*" Just use "*is*" when it's "*is*."
- Cut **significance inflation**: "*pivotal moment,*" "*marks a shift,*" "*reflecting broader trends,*" "*indelible mark,*" "*stands as a testament to.*" Don't editorialize the importance of the thing — describe the thing.
- Cut the **"Despite its X, it faces challenges"** outline formula. Real obstacles are specific; this template is generic.

### Structure
- No mandatory five-section essay. Short things stay short. One paragraph is a complete answer.
- No closing recap ("In conclusion," "In summary," 「まとめると」「いかがでしたか」). End on the last real point.
- Don't reach for bullet lists when prose flows better. Lists are for genuinely parallel items, not for visual padding.
- Don't bold a phrase in every other sentence. Bold once or twice per page, for emphasis that actually matters.
- Avoid the **"Bold Header: explanatory sentence"** list pattern when the items are short — write them as prose. The pattern itself reads as AI.
- Limit emoji to zero unless the user uses them. Rockets and fire icons are AI-coded. Emoji *inside* headings (`## 🚀 Getting Started`) is a strong tell.
- Don't synonym-shuffle to avoid repeating a word in a short passage. If "config" is the word, use "config" three times. Forced synonyms ("configuration," "settings," "setup") within one paragraph read as machine.
- Don't skip heading levels (H2 → H4). Don't apply Title Case to every heading (`## The Importance Of Testing`); follow the surrounding doc's convention (usually sentence case).

### Tone
- No sycophancy: cut "*Great question!*" "*Absolutely!*" 「素晴らしいご質問ですね」.
- No false balance ("*while critics argue X, supporters maintain Y*") unless the topic actually has balanced sides.
- No universal-truth openings ("*Change is the only constant.*" 「人生において…」).
- Maintain mood drift: a long piece should not have identical register from paragraph 1 to paragraph 8.

### Punctuation
- Em-dashes — use sparingly, for breaks, not as a default joiner. LLM prose uses them ~3× human baseline. Comma or period is usually fine.
- Don't pad with semicolons to look literary.
- Hyphens, parens, commas: pick the simplest that works.
- Use the punctuation the surrounding doc already uses. If the codebase uses straight quotes (`"foo"`), don't introduce curly ones (`"foo"`). The mismatch is a tell.

---

## English pass

Add to the universal pass when output is in English.

### Hit-list (search for these and cut or rewrite)
- Core overused vocab: *delve, intricate, multifaceted, nuanced, meticulous, commendable, surpass, foster, tapestry, realm, navigate, landscape, pivotal, resonate, testament, underscore, showcasing, compelling, paramount, unwavering, alignment, holistic, robust, seamless, leverage, utilize, myriad, plethora, scalable, synergy.*
- Cliché phrases: *"In today's fast-paced world," "In today's digital age," "A treasure trove," "Dive deeper," "Game-changer," "At its core," "It's worth noting that," "Ultimately," "Furthermore," "Moreover," "That being said," "Imagine a world," "Unlock the potential of," "A paradigm shift," "The intersection of," "A wealth of," "Rich cultural heritage," "Enduring legacy."*
- Email-only: *"I hope this email finds you well," "Please don't hesitate to reach out," "I trust this message finds you well."*
- "LinkedIn slop" patterns: "*This isn't a job — it's a calling*"-style negation reframes (see Universal pass).
- Note that the AI-vocab list keeps evolving — *delve* peaked in 2023, *align with / enhance / fostering* in 2024, *emphasizing / highlighting* in 2025+. Patterns drift but the underlying habit (statistically-favored verb + abstract object) persists; treat any vogue verb cluster with suspicion.

### Voice
- Prefer active voice. Passive defaults are a strong tell.
- Use contractions where natural (*it's, don't, we'll*). LLMs over-correct to *it is, do not*.
- First and second person are fine. *"I think," "you'll want to,"* not *"one might consider."*

### Specificity
- Replace abstract metaphors with concrete ones. Not *"a tapestry of approaches"* → *"three methods, none of them clean."*
- Name things: people, files, line numbers, dates, error messages. Generic prose is the AI tell; specifics break it.

---

## Japanese pass (日本語)

ユニバーサルパスに加えて、出力が日本語のときに適用。

### 文体（敬体／常体）の選択 — 最初に決める

リズムを変える前に「敬体（です・ます）か、常体（だ・である）か」を文脈から決定する。一度決めたら最後まで揃える。混在は LLM 臭以前の文法レベルの違和感。文体を決めるのが先、リズムを変えるのはそのあと。

判断指針:

- **敬体（です・ます）が既定**:
  - ビジネスメール、社外向け文書、顧客向け案内、UI 文言・エラーメッセージ
  - README、公式ドキュメント、チュートリアル（特に初心者向け）
  - PR / Issue 説明文（チーム文化が常体でない限り）
  - チームでの報告・議事録
  - 文脈が不明、相手が不明、混在文化の場と判断したら **敬体を選ぶ**（安全側）

- **常体（だ・である）が適切**:
  - 学術論文・学位論文（学会の慣習として）
  - 個人ブログ・エッセイで著者が常体を使う場合
  - 社内 Wiki の技術ノート、設計メモ、ADR（チーム文化次第）
  - 書籍・雑誌記事の地の文
  - メモ、走り書き、コミットメッセージ本文（短く言い切る場面）

- **チャット**: 口語・体言止め・短い断片が中心で、敬体/常体の判断はそもそも当てはまらないことが多い。相手のトーンに合わせる。

ユーザーが明示的に「だ・である調で」または「ですます調で」と指定した場合はそれが最優先。指定がなくサンプル文（既存の周辺文書、過去のメール、ブログの他記事など）があれば、それと合わせる。

### 語彙
- カタカナ語の多用をやめる: 「インサイト」「アウトプット」「スケーラビリティ」「コミット」「タスク」など、和語・漢語で素直に書ける場面ではそちらを優先。原文や技術用語として必要な場合のみ残す。
- 抽象語を具体化: 「本質的」「最適化」「価値を提供」「革新的」「重要なポイント」→ 具体的に何が・どう・なぜを書く。
- 比喩のクリシェを避ける: 「土台」「柱」「羅針盤」「DNA」「エンジン」「スパイス」「栄養」「設計図」「地図」。比喩を使うなら陳腐でないものを選ぶ。

### 文末・リズム
**前提**: 文体（敬体／常体）は前項で決定済みであること。以下は **選んだ文体の内側でリズムを変える** ための指針。敬体に常体を混ぜたり、常体に敬体を混ぜたりしない。

- 同じ語尾の連続を避ける。敬体なら「〜です」「〜ます」「〜ません」「〜でしょう」「〜と考えます」「体言止め」「疑問形（〜でしょうか）」を回す。常体なら「〜だ」「〜である」「〜だろう」「〜と思う」「〜か」「体言止め」を回す。どちらの場合も体言止めと疑問形は文体を跨いで使える。
- 同一文末（例: 「〜です。」「〜です。」「〜です。」）が 3 連続したら、必ず 1 つは別の形に変える。
- 接続詞を切る: 「さらに、また、したがって、そして、加えて」を毎段落入れない。意味的に不要なら削除。
- 文の長さを揃えない。短文（10 字以下）を時々入れて緩急を作る。
- 一段落の閉じ方を毎回同じにしない（「〜が重要です」「〜と言える」「〜となる」で全部終わる文章は機械的）。

### 構造・定型句
- 「いかがでしたか」「ぜひ〜してみてください」「〜について見ていきましょう」「結論から言うと」「まとめると」「ポイントは3つあります」を機械的に使わない。
- 「〜と言えるでしょう」「〜と考えられます」「〜することが大切です」「〜することが重要です」を文末に反射で添えない。
- 「〜について解説します」「〜について説明します」を冒頭に毎回置かない。本題から入る。
- 重要性の煽りを切る:「〜は欠かせません」「〜は不可欠です」「〜の鍵となります」「〜の要となる」「〜が問われています」。重要性を主張するのでなく、具体例で示す。
- 見出しを乱発しない。短い回答に H2/H3 を並べない。
- 「ステップ1 / STEP 1 / ステップ①」のような定型ナンバリングを毎回出さない。
- 段落の最後に「重要です」「ぜひ覚えておきましょう」と添えない。
- 過剰敬語を避ける: 「ご確認いただけますと幸いです」を連発しない。場面に合った素直な敬語で。

### 視覚記号
- 全角コロン「：」のあとに不要な半角スペースを入れない。
- 「**太字**」を多用しない。和文の太字は英文より目立つ。
- 「／」による安易な並列（「メリット／デメリット」を毎回使う等）を避ける。
- 引用符「」と『』を混ぜない、必要な使い分けだけ。

### 中身
- 一人称・体験・主観を許す: 「実際に試したら〜だった」「個人的にはこう感じた」など人間味の混入は OK（ただし嘘の体験は捏造しない）。
- 両論併記の事なかれ主義をやめる: 「メリットもあればデメリットもあります」だけで終わらせず、どちらかに踏み込む。
- 結論ファースト型の表面性: 結論を冒頭に置くなら、その後に必ず具体例・根拠・反証を続ける。

### 翻訳調 (translationese)

LLM は内部的に英語で考えてから日本語に出力するため、英文直訳的な構文が混入しやすい。これは「カタカナ語が多い」とは別軸の問題。

- **冗長な可能表現を縮める**: 「設定することができます」→「設定できます」。「確認を行う必要があります」→「確認してください」。「実行することが可能です」→「実行できます」。LLM は can / be able to を直訳しがち。
- **不要な主語を落とす**: 「あなたはこのコマンドを実行してください」→「このコマンドを実行してください」。「私たちはこの設計を採用した」→「この設計を採用した」。総称の you / we / one / they は原則カット。
- **代名詞を消す**: 「彼は彼の鍵を彼のポケットに入れた」のような所有代名詞の連発は英語直訳の典型。日本語は文脈で省略する。「それ」「これら」「彼ら」も同様、本当に必要なときだけ残す。
- **無生物主語を副詞化**: "*The script enables users to…*" を「スクリプトはユーザーが〜することを可能にする」と直訳しない。「このスクリプトを使えば〜できる」「スクリプトで〜できる」。
- **一文を短く切る**: 関係代名詞や分詞構文を全部 1 文に詰めない。「〜である X が、〜という性質を持ち、〜の場面で使われ、…」と続けず、文を分ける。
- **「において」「に関する」「に対して」の機械的多用**: "*in,*" "*about,*" "*for,*" "*regarding*" の安易な訳。「設定において重要」→「設定で重要」。「Python に関する質問」→「Python の質問」。
- **訳語の癖を疑う**: 「提供する」(provide/offer)、「含む」(include/contain)、「もたらす」(bring)、「完全な」(complete/perfect)、「豊富な」(rich)、「対応する」(support/handle) は文脈に合っているか毎回確認。
- **主部と述部を近づける**: 修飾節で主語と動詞が遠く離れる文は読みにくい。長い修飾は別の文に独立させる。

---

## Domain passes

Apply on top of universal + language. Pick the one that matches the output.

### Email / メール

**English**
- Skip "*I hope this email finds you well*" and its cousins. Start with the actual reason for the email, or a one-line context tied to the prior thread.
- Skip "*Please don't hesitate to reach out.*" Closing should be the next concrete step or just *Thanks, — name*.
- Don't bullet-list a 3-sentence email. Prose.
- Use the recipient's name once at most. Avoid "*Dear [Name], I trust this message finds you well.*"

**日本語**
- **文体は敬体（です・ます）固定**。社外メールで常体は不可。社内メールでも、相手・関係性・先方の文体を上回る丁寧さで揃える。
- 冒頭の「お世話になっております」は社外メールの慣習で必要だが、その後に意味のない丁寧な前置きを重ねない（「日頃より格別のご高配を賜り…」を冗長に積み上げない）。
- 用件を 2–3 行で先に書く。説明は後。
- 「何卒よろしくお願い申し上げます」を機械的に閉じに置く前に、次のアクションが明示されているか確認。
- 箇条書きで埋めない。短いメールは普通の文で書く。

### Pull Request / Issue 説明文

- テンプレートに従いつつも、テンプレートの見出しを機械的に埋めない。該当しないセクション（例: テストが無い変更で `## Test plan` を「N/A」と書くなら、セクションごと省略してよい）。
- 「## Summary」に同じ内容を 3 回違う表現で書かない。1 回で済む。
- なぜこの変更が必要か（動機・原因・チケット）を、何を変えたか（diff の言い換え）より先に書く。diff は読めば分かる。
- 副作用・既知の制約・残タスクを正直に書く。「fully tested」「all edge cases handled」のような hyperbolic 表現を避ける。
- **日本語 PR/Issue の文体**: チームの既存 PR の文体に必ず合わせる。リポジトリを確認して既存の PR が常体（「〜を修正」「〜とした」体言止め中心）なら常体、敬体（「〜を修正しました」）なら敬体。判別不能なら敬体。「対応しました」「修正いたしました」を全文で繰り返さない（敬体でも「修正」「追加」と体言止めに切るのは可）。

### Code review コメント / レビュー返信

- 行・ファイル・関数名を具体的に引く。「I noticed that this could be improved」だけのコメントは AI 的。
- ヘッジを減らす: "*Consider perhaps maybe…*" や「もしよろしければ〜してもよいかもしれません」の重ね掛けをやめる。提案なら提案、ブロッカーならブロッカーとはっきり書く。
- 質問と提案を分ける。"*Why this approach?*" は質問、"*Use X instead*" は提案。LLM は両者を混ぜて曖昧にしがち。
- "*Great work!*" 「お疲れさまです、素晴らしいですね」で始めない。本題から入る。

### Commit message

- Conventional Commits を使う場合も、`feat: improve user experience` のような中身ゼロの動詞を避ける。何を・なぜを 1 行目に詰める。
- 「update X」「improve Y」「refactor Z」だけの 1 行コミットは AI 的。動詞 + 対象 + 理由 or 効果 を短く。
- 本文（2 行目以降）を機械的に箇条書きにしない。1 段落で済むなら段落で。

### Slack / Discord / チャット

- 段落の改行や丁寧な敬語を持ち込まない。短く、口語で。
- 箇条書きにする前に、本当に並列か確認。会話の途中で `### 見出し` は不要。
- 絵文字は相手の使用頻度に合わせる。ゼロ vs 連発の両極を避ける。

### Conversational reply / 返信・回答そのもの

When drafting a reply (in a chat, an email thread, an issue comment, a code-review response) the LLM's own conversational tics tend to leak through. Watch for these and cut them:

- **Pseudo-empathy openers** the user did not ask for: *"I completely understand your concern,"* *"That makes total sense,"* 「お気持ちよく分かります」「ご懸念はごもっともです」. Just answer.
- **Performative honesty hedges**: *"I have to be honest with you,"* *"To be completely candid,"* *"I want to be careful here,"* 「正直に申し上げると」「率直に言えば」 — used as a tic, not because honesty is actually in tension with the answer. If you're not about to say something uncomfortable, don't preface.
- **Reflexive agreement**: *"You're absolutely right,"* *"Great point,"* *"Excellent question,"* 「素晴らしいご指摘です」「おっしゃる通りです」. Especially bad when followed by a contradiction ("You're absolutely right — actually, no, X is wrong"). Drop both halves; just engage with the substance.
- **Apology padding**: *"I apologize for the confusion,"* *"Sorry for any inconvenience,"* 「ご迷惑をおかけして申し訳ありません」 — appropriate when you actually did cause a problem, mechanical when you didn't. Don't apologize for things that weren't errors.
- **Confirm-and-restate**: starting the reply by paraphrasing the question back ("*So you're asking whether X…*"). Skip it unless disambiguation is genuinely needed.
- **"Let me know if…" closers**: *"Let me know if you have any other questions!"* *"Feel free to ask if anything is unclear,"* 「何かご不明点があればお知らせください」 — stop adding these by default. End on the actual answer.

### Documentation / README / blog

- 5 段落構成 (intro → 3 body → recap) を反射的に作らない。必要な節だけ書く。
- "Conclusion" / 「まとめ」セクションは、本当に要約価値があるときだけ。短い記事には不要。
- コード例は最小再現にする。装飾的な import や使わない引数を入れない。
- 見出し階層は実際の構造に合わせる。H2 を 7 個並べるための見出しを作らない。
- **日本語の文体**: README・公式ドキュメント・チュートリアルは原則 **敬体**。ブログは著者の慣習に合わせる（既存記事があれば必ず合わせる）。指定なしで一からブログを書く場合、技術的な解説記事はどちらも可だが、迷ったら敬体を選ぶ方が安全（読者層が広い）。同じ記事内で混在させない。

### Titles / headlines / 見出し・タイトル

- Avoid the SEO-bait formulas: *"The Ultimate Guide to X,"* *"A Comprehensive Guide to X,"* *"How to Master X in N Steps,"* *"X 101: Everything You Need to Know,"* *"Why X Matters in 2026."*
- Avoid the **colon-subtitle** reflex: *"Building Systems: A Modern Approach,"* *"React Hooks: A Deep Dive."* Use it when the colon actually adds info, not as default formatting.
- Japanese 見出し: 「〜の完全ガイド」「〜を徹底解説」「初心者でもわかる〜」「【保存版】〜」「〜のすべて」を機械的に出さない。
- A good title is specific and falsifiable. *"How we cut p99 latency from 800ms to 120ms"* beats *"Optimizing Performance: A Complete Guide."*

### API documentation / docstrings / コメント

- Don't restate the signature in prose. `def parse_url(url: str) -> URL` doesn't need a docstring saying *"This function parses a URL string and returns a URL object."* That's the signature.
- Skip the *"This function …"* / *"This method …"* preamble. Start with the verb: *"Parses a Slack-formatted URL."*
- Document the **non-obvious**: failure modes, units, side effects, edge cases the caller can't see. Skip the obvious: that `x: int` is an int.
- Don't bullet every parameter when half are self-explanatory. Mention the surprising ones.
- 日本語コメント: 「この関数は〜する関数です」のような重複説明をしない。動詞から始める (「〜を返す」「〜を解析する」)。「上記の通り」「以下の処理を行う」のような冗長な接続を削る。
- Avoid the AI-generated `// Returns the result` style comment that adds nothing. If the comment doesn't tell the reader something the code doesn't, delete it.

### 論文 / 学術的な文章 (academic writing)

学術文章は LLM 臭が読み手 (査読者・編集者・他研究者) に強く検出される領域。PubMed の縦断研究で 2022 年以降に急増した語彙が同定されており、これらは現在「ChatGPT を使った」シグナルとして機能する。

**書き出し**
- アブストラクトと introduction の冒頭に universal-generic な書き出しを置かない: *"In recent years, X has gained significant attention,"* *"With the rapid development of X,"* 「近年、〜が注目を集めている」「〜の重要性はますます高まっている」。最初の 1 文で具体的な問題・ギャップ・発見を述べる。
- *"A growing body of research has shown…"* *"It is well known that…"* *"It has been widely recognized that…"* を多用しない。代わりに具体的な先行研究を引いて事実を述べる。

**動詞のヒットリスト (cut or replace with plain verbs)**
*delve, elucidate, embark, emerge, employ, encompass, endeavor, enhance, explore, facilitate, foster, garner, grapple, harness, illuminate, integrate, interplay, juxtapose, leverage, navigate, necessitate, outperform, revolutionize, scrutinize, showcase, surpass, transcend, transform, underscore, unearth, unveil, boast, bolster, catalyze, fortify*

**形容詞のヒットリスト**
*comprehensive, exhaustive, holistic, multifaceted, nuanced, intricate, meticulous, intriguing, noteworthy, novel, groundbreaking, innovative, ingenious, pivotal, paramount, robust, versatile, well-rounded, actionable, invaluable, transformative*

**副詞のヒットリスト**
*notably, particularly, primarily, predominantly, profoundly, seamlessly, effectively, effortlessly, methodically, thoroughly, ultimately, undoubtedly, compellingly*

**名詞のヒットリスト**
*landscape, realm, ecosystem, tapestry, testament, journey, milestone, foundation, essence, insight, intricacy, prowess, advancement* — および定型句 *deep dive, driving force, game changer, shed light on, vital role, knowledge gap*

**主張・新規性の書き方**
- *"We propose a novel framework"* を反射で書かない。何が新しいか (既存の何と違うか) を 1 文で具体的に。
- *"To the best of our knowledge, this is the first…"* を冗長に積まない。事実なら 1 回で足りる。誇張なら削除。
- 過度なヘッジング ("may potentially possibly suggest") を避ける。仮説なら *"we hypothesize"*、観察なら *"we observe"* と区別する。

**構造**
- セクション末の自己要約 ("In this section, we have shown…" 「本節では〜を示した」) を毎回つけない。論理的に必要な架け橋がある場合のみ。
- セクション冒頭の roadmap 文 ("In this section, we first…, then…, and finally…") の機械的反復を避ける。
- 三分割の見せかけ列挙 ("first, second, third") を、本当に並列でない箇所で使わない。

**日本語論文・解説記事**
- 「興味深いことに」「特筆すべきは」「ここで重要なのは」を強調語として連発しない。1 編に 1〜2 回まで。
- 「先行研究によれば」「〜が報告されている」を曖昧な引用で繰り返さない。著者名 (年) を具体的に。
- 「本研究では〜を提案する」「本稿の貢献は〜である」を箇条書きで 5 つも並べない。本当の貢献に絞る。
- 受動態の連発 (「〜が示された」「〜が観察された」) を切り替える。能動 (「我々は〜を示す」) と混ぜる。

**引用**
- 引用は実在を確認する。著者名・年・誌名・DOI が曖昧なら、出典なしで書くか、確認するまで保留にする。捏造はしない (ハルシネーション引用は学術的に致命的)。
- 「〜である [1, 2, 3, 4, 5]」と束ね引用を機械的に並べない。各引用が個別に何を支持するかが明確になる書き方を。

---

## Self-check before sending

4 項目を確認すれば足りる:

1. **抽象を 1 つ具体に**: 抽象名詞や inflated adjective を 1 か所、具体的な事実・固有名・数値に置き換えた？
2. **長さと構造の必然性**: この長さ・この見出し数・この箇条書きは内容上必要？ 反射で出していない？
3. **テンプレ語の駆除**: hit-list の語句（English/日本語両方）が残っていない？ "*delve, leverage, navigate, robust*"、「することができる」「重要です」「いかがでしたか」など。
4. **burstiness**: 文の長さがほぼ揃っていないか？ 一段落の中で短文と長文が混ざっている？

4 つ OK ならそのまま出す。1 つでも怪しければその箇所を直す。全文を書き直さなくてよい。

**Clustering rule**: 1 つの段落 (300 字 / 50 words) に LLM 臭の表現が 3 つ以上集まっていたら、それだけで読み手に違和感を与える。3 個未満に減らせば、個々の表現が残っていても自然に読める。

## What this skill is NOT

- これは「AI 検出ツールを欺く」ためのスキルではない。読み手が普通に読んで違和感のない文章を書くためのもの。
- ユーザーの指示や事実を曲げてまで「人間っぽさ」を演出しない。捏造された体験談・嘘の主観は入れない。
- ユーザーが LLM 的な定型表現（"In conclusion" など）を明示的に求めた場合は、その指示が優先。
