---
review_id: QA-STEP03-001
deliverable: docs/research/market/market_map.md, docs/research/market/competitor_matrix.csv
reviewer: QA Agent
date: 2026-05-03
verdict: CONDITIONAL PASS
---

# Step 3 QA Review: Market Map and Competitor Matrix

## Summary

The production team delivered a substantive market map and a well-structured competitor matrix. The market map reads as a genuine strategic analysis rather than a generic vendor list, with credible banking-specific positioning throughout. The competitor matrix follows the 37-field schema exactly. Both deliverables demonstrate real research effort and banking domain awareness.

That said, there are gaps against the handoff requirements that need to be closed before this step can fully pass.

---

## BLOCKER Findings

### B1: Missing market categories required by acceptance criteria

The acceptance criteria at line 2984 explicitly state: "Covers CCaaS, conversational AI, voice infra, fraud, BPO, open source."

The market map covers five of those six: CCaaS, conversational AI, voice infra, fraud, and open source. **BPO/contact-center outsourcing is absent.** The document's scope statement acknowledges this exclusion ("Does not cover BPO/outsourcing firms...those are addressed in the positioning and wedge strategy document"), but the acceptance criteria don't allow that deferral. The handoff acceptance table is unambiguous.

**Required action:** Add a section covering BPO/outsourcing firms (Accenture, Concentrix, Teleperformance, TTEC, Genpact, WNS, and similar) with banking relevance, threat assessment, and partnership potential. This can be shorter than the other sections, but it must exist in this document.

### B2: Section 6.5 claims quality bar not met at per-claim level

Section 6.5 requires every market claim to include: source URL, access date, source type, confidence rating, and counterpoint/limitation. The current approach collects sources at the end of the document in a references section, pointing to source_index.md entries. This is useful but doesn't meet the handoff's per-claim requirement.

Specific gaps:
- Individual claims (e.g., "AI-driven ARR grew 66% YoY in Q4 2025" for NICE, or "391% ROI" for PolyAI) are not individually annotated with source URL, access date, and source type.
- Confidence ratings are applied at the vendor level in the CSV but not at the claim level in the market map.
- Counterpoints and limitations are not attached to individual claims. The "Weaknesses" subsections cover vendor-level limitations, but Section 6.5 asks for claim-level counterpoints (e.g., "66% AI ARR growth - source: NICE Q4 earnings, vendor self-reported, may include different ARR definition than competitors").

**Required action:** Add inline source annotations to factual claims. At minimum, parenthetical citations with source type and confidence, such as: "AI ARR grew 66% YoY (NICE Q4 2025 earnings, vendor-reported, High confidence)." Counterpoints should be noted where the claim could be misleading. An acceptable alternative is a footnote-style system with numbered references that each include the five required fields.

---

## HIGH Findings

### H1: Six of twelve Section 6.1 categories not addressed as standalone sections

Section 6.1 lists 12 market categories. The market map consolidates these into 6 sections. The missing standalone categories are:

1. **STT providers** - Partially covered in a table within the Infrastructure section, but not a standalone category analysis.
2. **TTS providers** - Same as STT, table-only treatment.
3. **Speech-to-speech/realtime model providers** - Not addressed. OpenAI realtime API, Gemini multimodal, and similar offerings are not mentioned.
4. **Agent-assist platforms** - Not addressed as a category. Agent-assist features are mentioned within CCaaS vendor profiles, but dedicated agent-assist vendors (Cresta, Observe.AI, Balto, Level AI, etc.) are missing.
5. **BPO/contact-center outsourcing** - Covered in BLOCKER B1.
6. **Core-banking and CRM ecosystem vendors** - Explicitly deferred to another document.

The consolidation of STT/TTS into infrastructure tables is a reasonable editorial decision, but it means the structured per-category analysis (with threat level, partnership potential, and differentiation opportunities for each) is lost.

**Required action:** Add short sections or subsections for speech-to-speech/realtime providers and agent-assist platforms. STT and TTS table coverage is adequate if threat/partnership assessments are added to each provider row. Core-banking/CRM deferral is acceptable if the document cross-references where that analysis lives. BPO addressed under B1.

### H2: Multiple vendors from Section 6.2 missing from competitor matrix CSV

The handoff lists specific vendors to research in each category. Several are absent from the CSV:

- **Category A:** Cisco Webex Contact Center, Avaya, Talkdesk (mentioned briefly in market map but not in CSV)
- **Category B:** Cognigy (noted as acquired by NICE, but handoff lists it separately), Rasa, Amelia/IPsoft, Omilia, Boost.ai, Avaamo (all mentioned briefly in market map but absent from CSV)
- **Category C:** Bland AI, Synthflow, Voiceflow, TEN Framework (mentioned in market map text, absent from CSV), LiveKit Agents and Pipecat are in CSV as open-source not dev-first
- **Category D:** ElevenLabs, Cartesia, AssemblyAI, Speechmatics, Google Cloud Speech, Azure Speech, Amazon Transcribe/Polly, Telnyx, Vonage (all covered in market map tables but not as CSV rows)
- **Category E:** Callsign, ThreatMetrix/LexisNexis, Socure (not mentioned anywhere)

The CSV has 19 vendor rows. A complete matrix covering all handoff-listed vendors would have roughly 40-45 rows.

**Required action:** Add CSV rows for vendors mentioned in the market map text but absent from the CSV (Talkdesk, Cisco Webex, Avaya at minimum from Category A; Rasa, Omilia, Amelia from Category B; Bland AI, Synthflow, Voiceflow from Category C). Infrastructure providers can be added with N/A for non-applicable fields. Fraud/identity vendors Callsign, ThreatMetrix/LexisNexis, and Socure should be added per Section 6.2E.

### H3: GetVocal.ai included without handoff basis

GetVocal.ai appears as row 13 in the CSV. The handoff does not list GetVocal as a vendor to research in any of its Category A-E lists. Its inclusion is reasonable given VocalIQ's stated inspiration from GetVocal, but it should be explicitly justified. The CLAUDE.md memory file references "Building a GetVocal.ai competitor," so this is contextually appropriate but should be transparent in the document.

**Required action:** No removal needed, but add a note in the market map explaining why GetVocal is included (closest product-level reference point for VocalIQ's architecture).

---

## MEDIUM Findings

### M1: Competitive positioning matrix in Section 8 lacks source grounding

The positioning matrix in Section 8 makes comparative assertions (e.g., "No" for risk-aware graph compiler across all competitors, "Basic rules" for policy engine at NICE/Genesys/Amazon Connect). These are analytical judgments, but per Section 6.5, they should be tagged with confidence level and any counterpoint. A competitor could reasonably dispute being labeled "No" for a capability they believe they offer.

**Required action:** Add a confidence note to the positioning matrix, or a footnote explaining the assessment methodology (e.g., "Capability assessed based on publicly available product documentation and press materials as of May 2026. 'No' means no publicly documented evidence was found; vendors may have unreleased or undocumented capabilities.").

### M2: CSV confidence_level column is vendor-level, not claim-level

The CSV has a confidence_level column, but it applies a single rating per vendor row (e.g., "High" for the entire NICE row). Section 6.5 requires confidence at the claim level. Some fields within a vendor row may be high confidence (publicly reported financials) while others are lower confidence (inferred capabilities).

**Required action:** Either add claim-level confidence annotations within relevant CSV cells (e.g., "Yes - voice biometrics [Medium confidence]") or add a separate column for fields where confidence diverges from the row-level rating.

### M3: Source URLs in CSV are often generic

Several CSV source_urls entries point to top-level domains (e.g., "https://www.nice.com/; MKT-002; MKT-014") rather than specific pages. While the MKT-xxx references presumably resolve to specific URLs in source_index.md, the CSV itself should be usable standalone.

**Required action:** Replace generic domain URLs with specific source page URLs where possible, or ensure MKT-xxx references are sufficient by including source_index.md as a companion file.

### M4: No mention of speech-to-speech or realtime model providers

OpenAI's Realtime API, Google's Gemini multimodal voice, and similar speech-to-speech offerings represent a potential architectural disruption. These are listed as Category 7 in Section 6.1 but receive no coverage in either deliverable. As these could bypass the traditional STT-LLM-TTS pipeline VocalIQ is building on, the omission is strategically significant.

**Required action:** Add at least a brief assessment of speech-to-speech providers and their implications for VocalIQ's pipeline architecture.

---

## LOW Findings

### L1: Document file path diverges from Section 6.4 specification

Section 6.4 specifies the path as `docs/research/market_map.md`. The actual file is at `docs/research/market/market_map.md`. The nested market subfolder is a reasonable organizational choice but doesn't match the spec.

**Required action:** Either update the file path to match the spec or document the deviation.

### L2: No version history

The document has a "Last Updated" field but no version history or changelog. For a bank-grade deliverable that will undergo multiple revision cycles, version tracking is expected.

**Required action:** Add a brief version history table.

### L3: Market map does not mention analyst report procurement decision

Open Question 1 asks whether Gartner/Forrester reports should be procured. This is a valid open question, but the document doesn't note what the interim approach is (relying on public information only) or what incremental value the reports would add.

**Required action:** Expand the open question with a brief note on the current approach and what specifically the analyst reports would add.

---

## Section 28 Documentation Quality Bar Compliance

| Required Field | Present? | Notes |
|---|---|---|
| Purpose | Yes | Clear and specific |
| Scope | Yes | Explicitly states what is and isn't covered |
| Assumptions | Yes | Four assumptions listed, appropriate |
| Decisions Made | Yes | Category segmentation rationale provided |
| Alternatives Considered | Yes | Two alternatives noted with rejection rationale |
| Risks | Yes | Four risks identified |
| Open Questions | Yes | Two open questions |
| Source Links | Partial | References section exists but per-claim sourcing is missing (see B2) |
| Last Updated | Yes | 2026-05-03 |
| Owner | Yes | Chief Product Officer |

Section 28 compliance is strong except for per-claim source linking.

---

## CSV Schema Compliance (Section 6.3)

All 37 fields from the schema are present as column headers in the correct order. Field naming matches exactly. No extra or missing columns. Schema compliance is complete.

---

## Overall Assessment

The deliverables demonstrate genuine strategic thinking about VocalIQ's competitive landscape in banking. The market map reads as an informed analysis by someone who understands both the voice AI vendor landscape and banking operations. The vendor profiles include specific data points (funding amounts, customer names, deal sizes, feature releases with dates) rather than generic descriptions. The strategic implications section in the market map is particularly strong, identifying specific capability gaps no current vendor fills.

The two blockers are real but fixable. B1 (missing BPO category) requires adding a section that the production team explicitly chose to defer. B2 (per-claim sourcing) requires annotation work on existing content rather than new research.

The HIGH findings around missing vendors and categories require incremental work but don't invalidate the existing analysis. The CSV is well-structured and most of the missing vendors already have text coverage in the market map; they just need CSV rows.

**Verdict: CONDITIONAL PASS**

This passes on substance and analytical quality. The two blockers and high-severity items must be resolved before Step 3 can be marked complete. Once B1 and B2 are addressed and the HIGH items are resolved, this should pass without further QA review (assuming no new issues are introduced).

## Required Actions for Full PASS

1. [BLOCKER] Add BPO/outsourcing category section to market_map.md
2. [BLOCKER] Add per-claim source annotations (source type, confidence, counterpoint) to factual claims in market_map.md
3. [HIGH] Add sections for speech-to-speech/realtime providers and agent-assist platforms
4. [HIGH] Add CSV rows for missing vendors listed in Section 6.2 (minimum: Talkdesk, Cisco, Avaya, Rasa, Omilia, Amelia, Bland AI, Synthflow, Voiceflow, Callsign, ThreatMetrix/LexisNexis, Socure)
5. [HIGH] Add note explaining GetVocal.ai inclusion
6. [MEDIUM] Add confidence methodology note to Section 8 positioning matrix
7. [MEDIUM] Improve claim-level confidence granularity in CSV
8. [MEDIUM] Replace generic domain URLs with specific source URLs in CSV
9. [MEDIUM] Add speech-to-speech provider assessment
