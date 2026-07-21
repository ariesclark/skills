# Writing for humans

Principles for prose a person reads (READMEs, docs, commit and PR messages), on top of [Orwell's six rules](../SKILL.md). For the sentence- and word-level drills behind these, see [`mechanics.md`](mechanics.md); for machine-written patterns to strip, [`ai-tells.md`](ai-tells.md).

- **Lead with the point.** Put the conclusion first; cut the throat-clearing that walks up to it. A reader who stops after one sentence should still have the answer.
- **Concrete over abstract.** Name the thing, the number, the file. Abstractions ("robust", "seamless") carry no information and read as filler.
- **Characters as subjects, actions as verbs.** Make the doer the subject and its action the verb. Actions buried in nouns bloat a sentence and hide who acts: "make an assessment of" is "assess", "provide validation for" is "validate". This is the mechanism under Orwell's rule 4.
- **Old information first, new last.** Open a sentence with something the reader already holds (a link back to the sentence before), and end on the new or important part. The reader stresses whatever lands last, so put the word that carries the point there. "Lead with the point" orders a document; this orders a sentence.
- **Every sentence earns its place.** Delete a line that restates the one before it or says what the reader already knows. Length is a cost, not a signal of effort.
- **Plain, not promotional.** Say what a thing does, not how good it is. Inflated significance, the rule of three, em-dash overuse, and negative parallelism are AI tells that read as filler; [`ai-tells.md`](ai-tells.md) catalogs them and their fixes.
