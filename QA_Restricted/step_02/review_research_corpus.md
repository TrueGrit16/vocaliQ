# QA Review: Step 2 - Research Corpus

**Reviewer:** QA Agent  
**Review Date:** 2026-05-03  
**Deliverables Under Review:**  
- `docs/research/market/source_index.md`  
- `docs/research/regulatory/source_index.md`  
- Folder structure (Section 10.1)

**Verdict: CONDITIONAL_PASS**

The two source index files are substantive, well-structured, and demonstrate genuine research depth. Metadata fields align with Section 10.2. The regulatory index covers a strong spread of jurisdictions and risk domains. The market index captures the competitive landscape across CCaaS incumbents, conversational AI, developer-first voice, voice infra, and fraud/identity. Both files include counterpoints and flag items for deeper research in later steps, which shows intellectual honesty.

The pass is conditional on resolving the HIGH findings below. No BLOCKERs were found.

---

## Findings

### HIGH-01: Folder structure is incomplete against Section 10.1

Section 10.1 specifies a full folder tree with subdirectories for `banking_workflows/`, `risk/`, `architecture/`, `product/`, `evaluation/`, and `operations/`, plus the top-level `docs/00_master_brief.md`. Currently the only directories that exist are `docs/research/market/` and `docs/research/regulatory/`. None of the other required directories have been created.

Step 2 says "Create the folder structure in Section 10." This means the entire tree should exist now, even if most files are empty or contain placeholder front matter. Creating the structure upfront prevents later steps from having to create directories ad hoc and ensures the corpus is navigable from day one.

**Required action:** Create all directories and placeholder files listed in Section 10.1. Each placeholder should contain at minimum the Section 28 front matter (Purpose, Scope, Assumptions, Last Updated, Owner) with a note that content will be produced in the relevant step.

---

### HIGH-02: Missing Section 28 documentation quality bar fields

Section 28 requires every document to include: Purpose, Scope, Assumptions, Decisions made, Alternatives considered, Risks, Open questions, Source links, Last updated date, and Owner.

Both source index files include Purpose, Last Updated, and Owner. They are missing:

- **Scope** (what is in and out of scope for this index)
- **Assumptions** (e.g., that English-language sources are sufficient for initial research; that vendor marketing claims are treated as unverified until independently confirmed)
- **Decisions made** (e.g., why these specific sources were prioritized; decision to separate market from regulatory)
- **Alternatives considered** (e.g., alternative source taxonomies, alternative metadata schemas)
- **Risks** (e.g., risk of source staleness, risk of over-reliance on vendor marketing, geographic coverage gaps)
- **Open questions** (e.g., whether to include academic research, how to handle paywalled sources)

**Required action:** Add the missing Section 28 fields to both source index files.

---

### HIGH-03: No clear separation of "legal requirement" vs. "product best practice"

Section 10.3 explicitly requires separating legal requirements from product best practices. The regulatory source index blends these in the Product Implications sections. For example, REG-011 (FCA Consumer Duty) lists vulnerability detection and complaint detection as product implications, but doesn't distinguish which are legally mandated outcomes vs. which are VocalIQ design choices that exceed the legal minimum.

This distinction matters for bank buyers and compliance teams. A bank needs to know: "If we deploy VocalIQ, which controls does it provide because the law requires them, and which are value-adds?"

**Required action:** Add a field to regulatory source entries (e.g., `Requirement Type: legal_requirement | product_best_practice | hybrid`) or split Product Implications into two subsections: "Legal Obligations" and "Product Best Practices."

---

### MEDIUM-01: Metadata schema deviates from Section 10.2 template

The Section 10.2 template includes a `doc_id` field, `risk_domains` as a list, `jurisdiction`, `owner`, and `legal_review_required`. The regulatory index follows this closely but formats `risk_domains` as a comma-separated string rather than a YAML list. The market index omits `risk_domains`, `legal_review_required`, and `doc_id` (uses section headers like MKT-001 instead of a metadata field). Neither file uses the YAML front matter format shown in Section 10.2.

This isn't necessarily wrong since Markdown headings with bullet metadata are readable, but the schema should be consistent and explicitly documented.

**Required action:** Either adopt the YAML front matter format from Section 10.2, or document the decision to use Markdown-native formatting as a deliberate deviation and ensure all fields from the template are present in each entry.

---

### MEDIUM-02: Confidence ratings lack calibration criteria

Both indexes use confidence ratings (High, Medium-High, Medium, Low) but don't define what these levels mean. "High (primary legislation)" and "High (official press release, deal closed)" suggest different confidence standards. A reader can't tell whether "Medium-High" means the source is reliable but the claims within it are unverified, or whether it means the source itself is of mixed quality.

**Required action:** Add a short calibration key to each file (or a shared reference), for example:
- High: Primary legislation, official regulator publications, audited financial disclosures, confirmed deal announcements
- Medium-High: Vendor official documentation, named customer references, established industry body publications
- Medium: Analyst reports, vendor marketing without independent verification, community-sourced data
- Low: Placeholder entries pending research, unverified claims, single-source information

---

### MEDIUM-03: Market index has entries with Low confidence flagged for Step 3 that arguably shouldn't be in the corpus yet

MKT-012 (Kasisto) and MKT-013 (Kore.ai) have "Low" confidence with notes like "minimal research completed; flagged for deep dive." The entries contain thin summaries and no counterpoints. These read more like research task reminders than source index entries.

Similarly, the "Sources Pending Deep Research" tables at the bottom of both files list 25+ market entries and 14 regulatory entries with no metadata beyond company name and priority. This is useful as a research backlog, but mixing backlog items with completed source entries in the same index creates ambiguity about what's been researched and what hasn't.

**Required action:** Either (a) separate the backlog into a distinct file (e.g., `research_backlog.md`) or (b) add a clear status field to each entry (e.g., `Status: completed | partial | pending`) so readers can filter.

---

### MEDIUM-04: No contradictions or unresolved points section

Section 10.3 requires capturing contradictions and unresolved points. Individual entries include counterpoints, which is good. But there's no synthesis of cross-source contradictions. For example:

- The market index records vendor claims about cost reduction (McKinsey: 45%, Genesys: various) but doesn't flag that these figures vary widely and may not be comparable.
- The regulatory index covers multiple jurisdictions but doesn't flag where regulatory requirements conflict (e.g., EU data residency vs. US cloud deployment preferences).

**Required action:** Add a "Contradictions and Unresolved Points" section to each file that synthesizes tensions across sources. This can be brief at this stage but must exist.

---

### MEDIUM-05: Vendor concentration risk in market index

Section 10.3 says "Do not overfit to one vendor's marketing claims." The market index draws heavily from vendor-official sources (9 of 13 completed entries use vendor websites or press releases as primary sources). Only MKT-001 (McKinsey) is from an independent analyst. No sources come from bank CIOs/CTOs, banking industry associations, customer reviews, or independent testing.

This is partially acceptable for an initial corpus, but the gap should be acknowledged.

**Required action:** Add a note in the Risks or Open Questions section acknowledging the vendor-heavy source mix and flagging the need for independent/buyer-side sources in Step 3 (analyst reports like Gartner/Forrester, banking conference proceedings, Aite-Novarica or Celent research).

---

### LOW-01: All retrieved dates are 2026-05-03

Every single entry across both files shows the same retrieved date. This is plausible if all research was conducted in a single session, but it means none of these sources have been verified for freshness against their original publication dates. Some sources (e.g., PCI DSS v4.x, FCA Consumer Duty) may have had updates between their original publication and the retrieval date.

**Suggestion:** Add a `Publication Date` field to each entry where known, separate from `Retrieved Date`, so readers can assess source age.

---

### LOW-02: Market index source_index.md is missing GetVocal as a source_type category

MKT-005 (GetVocal.ai) is tagged as "Vendor official + press" but this is the closest competitor and primary inspiration per the handoff. It would benefit from a distinct source_type or at minimum a tag indicating its strategic significance (e.g., `Strategic Relevance: Primary competitor / design reference`).

**Suggestion:** Consider adding a strategic-relevance tag to market entries that feed directly into VocalIQ's positioning.

---

### LOW-03: Regulatory index owner listed as "Chief Product Officer"

The market index lists "Product Strategy" as owner and the regulatory index lists "Chief Product Officer." For a source index that will feed into legal and compliance decisions, the regulatory index owner should arguably be a legal/compliance function, or at minimum co-owned.

**Suggestion:** Clarify ownership model. Consider listing both a content owner and a review owner (e.g., "Owner: Product Strategy | Legal Review: [TBD]").

---

## Summary of Required Actions

| ID | Severity | Action |
|----|----------|--------|
| HIGH-01 | HIGH | Create full folder structure per Section 10.1 |
| HIGH-02 | HIGH | Add missing Section 28 fields to both source indexes |
| HIGH-03 | HIGH | Separate legal requirements from product best practices in regulatory index |
| MEDIUM-01 | MEDIUM | Standardize metadata schema or document deviations |
| MEDIUM-02 | MEDIUM | Define confidence rating calibration criteria |
| MEDIUM-03 | MEDIUM | Separate completed entries from research backlog |
| MEDIUM-04 | MEDIUM | Add cross-source contradictions section |
| MEDIUM-05 | MEDIUM | Acknowledge vendor-heavy source mix, flag need for independent sources |
| LOW-01 | LOW | Add publication dates where known |
| LOW-02 | LOW | Consider strategic-relevance tags for key competitors |
| LOW-03 | LOW | Clarify regulatory index ownership model |

---

## Gate Decision

**CONDITIONAL_PASS.** The research content is strong and demonstrates genuine analytical effort. The counterpoints in each entry show the team isn't just collecting sources uncritically. The regulatory coverage across EU, Singapore, US, and UK is solid for an initial corpus.

However, the three HIGH findings must be addressed before proceeding to Step 3. The incomplete folder structure means downstream steps will be working without the expected directory layout. The missing Section 28 fields are a documentation quality gap that will compound across every subsequent deliverable if not corrected now. And the legal-requirement vs. best-practice distinction is foundational for a bank-grade product; getting this right early prevents compliance confusion later.

MEDIUM findings should be resolved before final submission but do not block Step 3.
