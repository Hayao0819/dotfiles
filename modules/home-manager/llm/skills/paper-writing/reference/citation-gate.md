# Citation gate (Phase 5)

The point: never let the model be the source of bibliographic truth. The model
generates queries and prose; every citation is resolved against an authoritative
API. Studies put fabricated/erroneous citation rates at 18–55% unconstrained,
worse on niche topics, and 64% of fabricated DOIs resolve to an unrelated real
paper — so a resolving DOI is NOT proof.

`scripts/verify_citations.py` automates this. When scripts can't run, do it by
hand with the curl commands below.

## Rule set (hard gate)

1. **Pool only.** In-text citations use only ids from the candidate pool
   (citation.schema.json) with `verification.status == verified`. No citation
   from memory. Unknowns become `[CITATION NEEDED]`.
2. **Match on the whole record**, not the identifier: title AND first author AND
   year AND venue (AND pages where available) must agree. A resolving DOI alone
   fails the gate.
3. **Faithfulness, not just existence.** Confirm the cited work supports the
   specific claim. Attach a `support_quote` (≤25 words) and a `locator`. Reject
   post-hoc citations (real source, doesn't support the claim).
4. **Authors and page numbers** are checked explicitly — a frequent failure.
5. **BibTeX from the API only** (`scripts/fetch_bibtex.py`), never written by the
   model.
6. **Distributional skew:** warn if ≥70% of cited sources share one
   year/region/method/venue.
7. Unverifiable → leave the body, surface as `UNVERIFIED` to the human.

## API cascade and manual fallback

Send a contact email to enter polite pools: `?mailto=you@example.com`.
Never use Google Scholar as an authority (no API, no stable ids) — discovery only.

- **Crossref** (general; DOI + BibTeX):
  - exists: `curl -s "https://api.crossref.org/works/{DOI}?mailto=$MAIL"`
  - search: `curl -s "https://api.crossref.org/works?query.bibliographic=TITLE&rows=5&mailto=$MAIL"`
  - BibTeX: `curl -sL -H "Accept: application/x-bibtex" "https://doi.org/{DOI}"`
- **DBLP** (CS/ML venues; cleanest BibTeX):
  - search: `curl -s "https://dblp.org/search/publ/api?q=TITLE&format=json&h=5"`
  - BibTeX: `curl -s "https://dblp.org/rec/{key}.bib"`
- **Semantic Scholar** (cross-links DOI↔arXiv↔DBLP via externalIds):
  - `curl -s "https://api.semanticscholar.org/graph/v1/paper/DOI:{doi}?fields=title,year,authors,externalIds,venue"`
- **OpenAlex** (broad; 2026 may require a free key):
  - `curl -s "https://api.openalex.org/works?filter=title.search:TITLE&per-page=1&mailto=$MAIL"`
- **arXiv** (preprints; insert a 3s delay between calls):
  - `curl -s "http://export.arxiv.org/api/query?id_list={id}"`
- **PubMed** (biomedical):
  - `curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=TITLE&retmode=json"`

## Procedure per citation

1. Require a stable id (DOI / arXiv / PMID / DBLP key). If only author+title+year,
   resolve it first via OpenAlex `title.search` + Crossref `query.bibliographic`,
   fuzzy-matching title (normalized ≥0.9) + first-author surname + year (±1).
2. Resolve existence against the matching API; cross-check a second source via
   Semantic Scholar `externalIds`.
3. Confirm title/first-author/year/venue/pages all agree (step fails on mismatch
   — do not silently "fix" by trusting the model).
4. Fetch BibTeX from DBLP (CS) else Crossref content negotiation; store the id.
5. Confirm the source supports the claim; record quote+locator.
6. Admit to the `.bib` only if all pass; else tag `UNVERIFIED`.
7. Final sweep: every `\cite{key}` maps to a verified entry; any orphan blocks
   the build.

Sources: CiteCheck (arXiv 2605.27700); deployment-constraints study (2603.07287);
Walters & Wilder 2023; Crossref/DBLP/Semantic Scholar/OpenAlex/arXiv API docs.
