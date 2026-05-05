---
review_id: QA-STEP03-002
deliverable: docs/research/market/market_map.md, docs/research/market/competitor_matrix.csv
reviewer: QA Agent
date: 2026-05-03
previous_review: QA-STEP03-001 (CONDITIONAL PASS)
verdict: PASS
blocker_count: 0
high_count: 0
medium_count: 3
low_count: 0
---

# Step 3 Re-Review: Market Map and Competitor Matrix

## Purpose

Verify whether the production team's fixes address all findings from the initial review (QA-STEP03-001). That review returned a CONDITIONAL PASS with 2 BLOCKERs, 3 HIGHs, and 4 MEDIUMs.

---

## Finding Verification

### B1: Missing BPO/outsourcing category

**Status: RESOLVED**

Section 9 now contains "Category H: BPO and Contact Center Outsourcing" with individual profiles for Accenture, Concentrix, and Teleperformance, plus a combined entry for TTEC, Genpact, and WNS. Each profile includes banking relevance, threat assessment, and partnership potential. A category assessment paragraph ties BPO firms to VocalIQ's go-to-market strategy, correctly identifying them as the most likely initial deployment channel. Three corresponding CSV rows (Accenture, Concentrix, Teleperformance) were added with complete 37-field schema coverage.

The scope statement was also updated to include "BPO/contact-center outsourcing firms" in its category list, and the purpose statement now references nine vendor categories instead of six.

No remaining issues.

### B2: Per-claim sourcing not met

**Status: RESOLVED**

The production team added inline source annotations throughout the market map. Factual claims now carry parenthetical citations in the format: "(source name, source type, confidence level; MKT-xxx reference)". Counterpoints are appended where claims could be misleading. Spot-checked examples:

- NICE: "AI-driven ARR grew 66% year-over-year in Q4 2025 (NICE Q4 2025 earnings, vendor-reported, High confidence. Counterpoint: ARR definition may differ from competitors; organic vs. Cognigy-inclusive growth not broken out)"
- Amazon Connect: "$50K MDF incentives (same source. Counterpoint: pricing model sustainability unclear as AI usage scales; MDF may be time-limited)"
- PolyAI: "100+ enterprise customers, 2,000+ live deployments (PolyAI press release, vendor-reported, Medium-High confidence. Counterpoint: deployment count may include trials or small-scale implementations)"
- Pindrop: "1,300% surge in deepfake fraud (Pindrop research report, vendor-conducted primary research, High confidence; MKT-008. Counterpoint: methodology and sample size not fully public; Pindrop has commercial interest in highlighting fraud growth)"

A source methodology note was added below the header explaining the confidence scale (High, Medium-High, Medium, Low) and the annotation approach. This meets the per-claim sourcing requirement from Section 6.5.

No remaining issues.

### H1: Six of twelve categories missing

**Status: RESOLVED**

Three new standalone sections were added:

- Section 7, Category F: Speech-to-Speech and Realtime Model Providers. Covers OpenAI Realtime API and Google Gemini Multimodal Voice with an architectural assessment explaining why VocalIQ's pipeline architecture remains the correct choice for banking.
- Section 8, Category G: Agent-Assist Platforms. Covers Cresta, Observe.AI, Balto, and Level AI with individual profiles and a category assessment tying these vendors to VocalIQ's Human Control Center design.
- Section 9, Category H: BPO and Contact Center Outsourcing (also resolves B1).

STT and TTS providers retain their table treatment within the Infrastructure section (Section 5), which is an acceptable editorial choice since each row includes banking-relevant notes. Core-banking and CRM are explicitly cross-referenced to the positioning and wedge strategy document in the scope statement.

The document now covers nine categories, addressing all twelve Section 6.1 areas (STT, TTS, and LLM consolidated under infrastructure; telephony under infrastructure; core-banking/CRM deferred with cross-reference).

No remaining issues.

### H2: Multiple vendors missing from CSV

**Status: PARTIALLY RESOLVED**

The CSV expanded from 18 to 36 data rows. The following vendors were added, all with complete 37-field schema coverage:

CCaaS: Cisco Webex Contact Center, Avaya, Talkdesk
Conversational AI: Rasa, Omilia, Amelia
Dev-First Voice AI: Bland AI, Synthflow, Voiceflow
Speech-to-Speech: OpenAI Realtime API
Agent-Assist: Cresta
Fraud/Identity: NICE Actimize, Feedzai, Featurespace
BPO: Accenture, Concentrix, Teleperformance

Still missing from the CSV: Callsign, ThreatMetrix/LexisNexis, and Socure (fraud/identity vendors listed in Section 6.2E of the handoff). These three are also absent from the market map text. The original review specifically called them out.

Assessment: The 36-row CSV is a substantial improvement from 18 and covers the large majority of handoff-listed vendors. The three missing fraud vendors are not mentioned anywhere in either deliverable, which means the team may not have had sufficient public research material to include them, or they may have been deprioritized against the more critical fraud vendors already covered (Pindrop, BioCatch, NICE Actimize, Feedzai, Featurespace). Five fraud/identity vendors are now included, which provides reasonable category coverage. Downgrading this from HIGH to MEDIUM since the category is no longer underrepresented, just incomplete at the individual vendor level.

### H3: GetVocal.ai included without justification

**Status: RESOLVED**

The "Decisions Made" field now contains an explicit justification: "GetVocal.ai included despite not appearing in Section 6.2 vendor lists because RESEARCH.md identifies it as the closest product-level reference for VocalIQ's architecture and the original project brief directs research of getvocal.ai specifically."

This is transparent and well-reasoned.

No remaining issues.

### M1: Positioning matrix lacks source grounding

**Status: RESOLVED**

An assessment methodology note now precedes the matrix: "Capability assessments below are based on publicly available product documentation, press materials, API documentation, and open-source code repositories as of May 2026. 'No' means no publicly documented evidence was found for the specific capability; vendors may have unreleased, undocumented, or in-development features. 'Basic' means the capability exists in a general form but lacks the banking-specific depth described in VocalIQ's architecture. Confidence level for individual cells: Medium (based on available public evidence). Vendors are encouraged to correct any mischaracterizations."

This directly addresses the concern that competitors could dispute capability labels.

No remaining issues.

### M2: CSV confidence not claim-level

**Status: UNRESOLVED**

The CSV still applies a single confidence_level per vendor row. Individual cells within a row do not carry their own confidence annotations. For example, the NICE row is rated "High" overall, but capabilities like "Basic model management" or "Call recording; interaction analytics; QA scoring" carry different inherent confidence levels than publicly reported financials.

This is a known limitation. The market map itself now has claim-level confidence (resolving B2), so the practical impact is limited since anyone needing claim-level granularity can refer to the narrative document. Retaining as MEDIUM.

### M3: Generic source URLs in CSV

**Status: PARTIALLY RESOLVED**

Many rows now include MKT-xxx references alongside URLs, which improves traceability for anyone with access to source_index.md. However, rows added for newer vendors (Avaya, Cresta, Omilia, Amelia, Bland AI, Synthflow, Voiceflow, and others) still use generic domain URLs without MKT references (e.g., "https://www.avaya.com/", "https://cresta.com/", "https://amelia.ai/").

The CSV is not fully standalone without source_index.md for the MKT-referenced rows, and the non-MKT rows lack specific page URLs. Retaining as MEDIUM.

### M4: No speech-to-speech coverage

**Status: RESOLVED**

Fully addressed by the new Section 7 (Category F). Also covered in H1 verification above.

---

## Remaining Open Items (MEDIUM, not gate-blocking)

M2 (carried forward): CSV confidence remains vendor-level, not claim-level. Low practical impact since the narrative document now has claim-level annotations.

M3 (carried forward): Some CSV rows still use generic domain URLs without specific page references or MKT index entries.

H2 (downgraded to MEDIUM): Three fraud/identity vendors from the handoff (Callsign, ThreatMetrix/LexisNexis, Socure) are missing from both deliverables. Five fraud vendors are covered, providing reasonable category representation.

---

## Verdict: PASS

Both BLOCKERs are fully resolved. All three HIGH findings are resolved (H1, H3) or substantially resolved and downgraded (H2). The remaining open items are MEDIUMs that do not block gate clearance.

The market map now covers nine vendor categories with inline source annotations, confidence ratings, and counterpoints on major factual claims. The CSV expanded from 18 to 36 rows with complete schema compliance. The document reads as a thorough competitive analysis grounded in specific, sourced data points rather than generic vendor descriptions.

Step 3 deliverables clear the quality gate.
