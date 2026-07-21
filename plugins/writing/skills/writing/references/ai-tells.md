# AI writing tells

The patterns that mark text as machine-written. The root cause is one thing: a model reaches for the most statistically average phrasing, so it inflates importance, hedges, and pads instead of committing to specifics. Strip these when editing your own or another model's prose.

Most of the content tells below are Orwell's rule 1 (dead, ready-made phrasing) and rule 3 (needless words) made specific: the rules say avoid stale phrases; this list names the ones a current model actually emits, so you catch "delve" or "stands as a testament" instead of nodding past them. The formatting and chatbot tells are the part Orwell predates.

Judge by clusters, not single hits. One `however` or one em-dash proves nothing; significance inflation plus a rule-of-three plus "vibrant tapestry" plus a "Challenges" section is a confession. See "Before you flag it" below before gutting clean prose.

Filler phrases, excessive hedging, em/en dashes, passive and subjectless fragments, and hyphenated-pair overuse are also tells; they live in [`mechanics.md`](mechanics.md) to keep one source of truth.

## Inflated significance and promotion

- **Significance inflation.** Claims that an ordinary fact represents a broader trend: "marked a pivotal moment in the evolution of", "stands as a testament to", "setting the stage for". Cut the framing; state the fact.
- **Notability padding.** Listing outlets or follower counts to assert importance ("cited in the NYT, BBC, and FT; maintains an active social media presence"). Replace with one specific, sourced fact.
- **Promotional language.** Travel-brochure adjectives: "nestled in the heart of", "boasts a", "vibrant", "breathtaking", "rich cultural heritage". Say what the thing is and what it does.
- **Persuasive authority tropes.** "The real question is", "at its core", "what really matters", "the heart of the matter". They pretend to cut to a deeper truth, then restate an ordinary point. Delete the windup.
- **Generic positive conclusions.** "The future looks bright", "exciting times lie ahead". Replace with a concrete next fact or cut.

## Fake depth

- **-ing participle padding.** Trailing phrases that add fake analysis: "..., highlighting its importance", "..., reflecting a deep connection", "..., ensuring success". Delete, or make it a real clause with a real claim.
- **Vague attribution / weasel words.** "Experts argue", "observers have noted", "studies show" with no source. Name the source or drop the claim.
- **Formulaic "Challenges and Future Prospects".** "Despite its X, it faces several challenges... Despite these challenges, it continues to thrive." Replace with specific events and dates, or omit.
- **Speculative gap-filling and cutoff disclaimers.** "While details are scarce, it likely...", "as of my last update", "maintains a low profile". A guess dressed as fact. Say what isn't known, or cut the sentence.

## Vocabulary and constructions

- **AI vocabulary.** Overused post-2023 words that co-occur: delve, showcase, underscore, tapestry, testament, intricate, pivotal, landscape (abstract), foster, garner, crucial, vibrant, enhance, interplay, realm, robust, seamless. Not banned individually; a cluster is the tell.
- **Copula avoidance.** Dodging "is/are" with "serves as", "stands as", "boasts", "features". Use the plain copula: "Gallery 825 is the exhibition space", not "serves as".
- **Negative parallelism.** "Not only X but Y", "it's not just about X, it's about Y", and clipped tail negations ("..., no guessing", "..., no wasted motion"). State the positive claim directly.
- **Rule of three.** Forcing ideas into triads to sound complete ("innovation, inspiration, and insight"). Keep the items that carry information; drop the padding to two or one.
- **Elegant variation.** Cycling synonyms for one referent ("the protagonist... the main character... the central figure... the hero"). Pick one name and repeat it.
- **False ranges.** "From X to Y" where X and Y aren't on a real scale ("from the Big Bang to dark matter"). List the actual items.

## Formatting

- **Boldface overuse.** Bolding terms mechanically mid-sentence. Bold only what a scanning reader must find.
- **Inline-header vertical lists.** Bullets whose bold label restates itself and carries no information beyond the sentence ("**Performance:** Performance has been improved..."). The defect is the empty, self-repeating label, not a bold lead-in term that anchors real content the sentence doesn't already state (the device these very bullets use). Fold the empty ones into prose; cut the redundant label.
- **Title Case In Headings.** Sentence case is the human default: "Strategic negotiations", not "Strategic Negotiations And Global Partnerships".
- **Emojis** decorating headings or bullets. Remove them from technical and reference text.
- **Curly quotes** (`“ ”`) where straight quotes (`" "`) belong. A weak tell alone (editors auto-curl); counts only in a cluster.

## Chatbot artifacts

- **Collaborative artifacts.** Chat framing pasted as content: "Great question!", "I hope this helps!", "Let me know if you'd like...". Delete.
- **Sycophancy.** "You're absolutely right!", "That's an excellent point." Delete.
- **Signposting.** Announcing instead of doing: "Let's dive in", "here's what you need to know", "without further ado". Cut and start.
- **Fragmented headers.** A heading followed by a one-line paragraph that just restates it before the real content. Delete the restatement.
- **Diff-anchored writing.** Prose that narrates a change instead of describing the thing ("this was added to replace the old approach"). Unless the doc is version-scoped (changelog, migration guide), describe what is, not what changed.

## Before you flag it

A clean human writer trips several of these without any AI involvement. On their own, these are not evidence: polished grammar, mixed casual and formal register, plain or dry prose, formal vocabulary, a single common transition word, curly quotes, a lone em-dash, unsourced claims, correct complex formatting. Look for clusters.

## Signs of a human, preserve these

- Specific, hard-to-fabricate detail: a real address, a weird quote, an odd exact number. Models round specifics off; people hoard them.
- Mixed feelings and unresolved tension ("mostly good, but it bothers me and I can't say why").
- Dated, era-bound references: slang or in-jokes tied to a year and a subculture.
- Editorial choices the writer could defend: a deliberate cut, a chosen odd word.
- Varied sentence length. AI cadence is even and mid-length; human writing alternates short and long.
- Genuine asides and self-corrections that interrupt the flow.

## Sources

- Wikipedia, "Signs of AI writing" (WikiProject AI Cleanup): https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing
