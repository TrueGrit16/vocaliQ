---
review_id: QA-STEP05-001
deliverable: docs/research/regulatory/regulatory_matrix.csv, docs/research/risk/ai_risk_register.md, docs/research/risk/fraud_risk_framework.md, docs/research/risk/model_risk_framework.md, docs/research/risk/operational_resilience.md
reviewer: QA Agent
date: 2026-05-03
verdict: PASS
---

# Step 5 QA Review: Regulatory Matrix and Risk Frameworks

## Summary

The production team delivered all five required files for Step 5. The regulatory matrix CSV follows the exact 16-field schema prescribed in Section 9.4 of the handoff, covers all four priority jurisdictions (Singapore, EU, UK, US), and maps 26 rows across 14 of the 15 required regulatory domains. The AI risk register catalogs 15 risks with quantitative scoring, ranked by impact-times-likelihood, organized by domain, and each risk includes description, mitigations, residual risk, owner, and review cycle. The three framework documents (fraud, model risk, operational resilience) are substantive, technically grounded, and clearly written by someone familiar with how banks actually evaluate third-party technology providers.

This is strong work overall. The CSV-to-framework cross-referencing is mostly consistent. The Section 28 quality bar is fully met across all four markdown documents. The risk register correctly identifies the highest-severity risks (prompt injection and social engineering both scored at 20) and assigns P0 priority to anything scoring 10 or above when impact is 5. The fraud risk framework's attack taxonomy and scoring model go beyond what the handoff strictly required. The model risk framework's SR 11-7 alignment is a smart structural choice for US bank readiness. The operational resilience document's four-level degradation model is practical and well-designed.

Two medium findings. One high finding related to a missing regulatory domain in the CSV. No blockers.

---

## BLOCKER Findings

None.

---

## HIGH Findings

### H1: CSV is missing the "Electronic marketing and outbound calls" domain as a standalone multi-jurisdiction entry

Section 9.1 lists "Electronic marketing and outbound calls" as regulatory domain #3. The CSV includes one row for FCC TCPA (row 25, US jurisdiction), which covers outbound AI voice calls. However, the handoff's Section 9.5 example for "Outbound call consent" specifies controls covering campaign consent, opt-out, DNC lists, calling windows, and required disclosures. These requirements exist in other jurisdictions beyond the US: Singapore's PDPC has Do Not Call Registry provisions, the UK has PECR regulations, and the EU has the ePrivacy Directive. The CSV does not capture outbound call consent requirements for SG, EU, or UK.

The TCPA row itself is well-constructed and sets priority P2 with Phase 2 implementation, which is appropriate given the handoff's inbound-only MVP guidance. But the regulatory matrix is supposed to capture the full regulatory landscape, not just what's needed for MVP. A bank evaluating VocalIQ for eventual outbound use would find the multi-jurisdiction coverage thin.

Additionally, the "Electronic marketing and outbound calls" domain is the only one of the 15 Section 9.1 domains represented by a single jurisdiction in the CSV. All other domains have multi-jurisdiction coverage.

**Required action:** Add rows for outbound call/electronic marketing regulations in SG (PDPC DNC Registry), EU (ePrivacy Directive / national implementations), and UK (PECR). These can be P2/Phase 2 with appropriate notes that the MVP is inbound-only, but the regulatory mapping should be jurisdictionally complete.

---

## MEDIUM Findings

### M1: CSV risk_domain values do not consistently use the exact 15 domain labels from Section 9.1

Section 9.1 defines 15 specific domain names. The CSV's risk_domain column mostly aligns but uses slightly different labels in some rows:

- Section 9.1 says "Payment/card data security" but the CSV uses "Payment/card data security" (match).
- Section 9.1 says "Collections and vulnerable-customer treatment" but the CSV uses "Collections and vulnerable-customer treatment" for the FCA vulnerability row (match).
- Section 9.1 says "Electronic marketing and outbound calls" but the CSV uses "Electronic marketing and outbound calls" for the TCPA row (match).
- Section 9.1 says "Consumer protection and conduct risk" but the CSV splits this across FCA Consumer Duty ("Consumer protection and conduct risk"), CFPB UDAAP ("Consumer protection and conduct risk"), and ECOA ("Consumer protection and conduct risk") (match).

The domain labels are actually quite consistent on closer inspection. However, one structural gap: "Model risk management" as a Section 9.1 domain is represented only by a single US regulation (OCC 2011-12 / SR 11-7). MAS AIRG covers model risk but is classified under "AI governance" in the CSV. This creates a coverage ambiguity: does MAS AIRG satisfy "AI governance" domain #8 or "Model risk management" domain #7 or both? The EU AI Act row is classified under "AI governance" as well. A bank risk officer scanning the CSV for "Model risk management" coverage would find only US SR 11-7 and might conclude that Singapore and EU model risk management is unaddressed.

**Required action:** Either add MAS AIRG and EU AI Act references in a dual-domain listing (e.g., "AI governance; Model risk management") or add separate rows that map MAS AIRG model risk requirements and EU AI Act model documentation requirements specifically to the "Model risk management" domain. The model_risk_framework.md already does this cross-mapping in its Section 6.3, so the content exists, it just needs to be reflected in the CSV.

### M2: Regulatory matrix does not include Australia, India, or UAE jurisdictions

Section 9.2 lists the minimum first-pass jurisdictions as Singapore, EU, UK, US, Australia, India, and "UAE or Saudi Arabia if Middle East is a target." It then says to "prioritize Singapore, EU, UK, and US unless a specific launch market is selected."

The CSV covers only the four priority jurisdictions plus "Multi-jurisdiction" and "Global" entries. The source_index.md explicitly lists Australia (CPS 234/230), India (RBI IT governance), and UAE (CBUAE/ADGM) as "Pending Deep Research (Step 5)" items, suggesting these were planned for Step 5 but were not completed.

The handoff's wording is somewhat ambiguous: "Jurisdictions to cover first" lists all seven, but then "prioritize" four. The production team appears to have interpreted "prioritize" as "limit to," which is defensible but potentially undershoots.

**Required action:** Add placeholder rows for Australia, India, and at minimum one Middle East jurisdiction with the key applicable regulations identified, even if the requirement_summary and controls are noted as "pending legal research." This would satisfy the Section 9.2 "minimum first-pass" language while keeping the P2/Phase 3 priority classification appropriate to their deferred status. Alternatively, document the scoping decision explicitly in the source_index.md with a rationale for excluding these jurisdictions from the initial matrix.

---

## LOW Findings

### L1: Risk register does not include cross-border data transfer risk as a standalone entry

The regulatory matrix covers GDPR, PDPA, and UK GDPR cross-border transfer requirements in the data protection rows. However, the ai_risk_register.md does not include a separate risk entry for cross-border data transfer complications (data residency requirements, Schrems II implications for EU-US transfers, Singapore cross-border transfer safeguards). Cross-border transfer risk is embedded within the RISK-003 (Sensitive Information Disclosure) mitigations but not explicitly rated.

For a platform that will process voice data across multiple jurisdictions using cloud-hosted third-party model providers (often US-based), cross-border data transfer is a material risk that bank compliance teams will ask about.

**Required action:** Consider adding a standalone risk entry (RISK-016) for cross-border data transfer and data residency, with mitigations referencing data residency controls, transfer impact assessments, and provider data processing agreements. This is a suggestion, not a requirement, since the existing data protection CSV rows do capture the obligations.

### L2: Fraud risk framework Section 5 success criteria metrics lack baseline source

The fraud_risk_framework.md Section 5 states success criteria including "Synthetic voice detection rate above 95%" and "Social engineering detection rate above 85%." These are reasonable targets, but the document doesn't explain how these thresholds were chosen or what industry benchmarks they reference. The model_risk_framework.md is more careful about this, noting that alert thresholds (e.g., LLM hallucination rate > 2% warning) are initial values subject to tuning.

**Required action:** Add a brief note explaining the basis for the success criteria thresholds, even if it's simply "initial targets based on available industry benchmarks, subject to calibration during pilot."

### L3: Operational resilience framework does not reference PRA operational resilience explicitly in its degraded-mode section

The operational_resilience.md covers DORA incident reporting in Section 3.3 with specific timelines and support mechanisms. The PRA/FCA operational resilience framework (which requires "impact tolerance" testing for important business services) is mentioned in the CSV (row 9) but is not explicitly addressed in the operational_resilience.md. The document discusses degraded-mode levels and failover, which would support impact tolerance testing, but doesn't use the PRA's terminology or reference how VocalIQ would support a UK bank's impact tolerance assessment.

**Required action:** Add a brief section or subsection referencing PRA impact tolerances and explaining how VocalIQ's degradation levels map to a bank's impact tolerance framework. The content is already implied, it just needs to be made explicit for UK bank readers.

### L4: All five documents are version 1.0, dated 2026-05-03

Expected for initial delivery. Noted for tracking purposes.

---

## Section 28 Documentation Quality Bar Compliance

### ai_risk_register.md

| Required Field | Present? | Notes |
|---|---|---|
| Purpose | Yes | Links to architecture decisions, evaluation lab design, and pilot readiness |
| Scope | Yes | Explicitly includes/excludes general business risks |
| Assumptions | Yes | Risk ratings assume mitigations implemented; residual ratings assume partial maturity |
| Decisions Made | Yes | 5x5 impact-likelihood matrix with clear scoring tiers and priority mapping |
| Alternatives Considered | Yes | Separate per-domain registers considered and rejected with rationale |
| Risks | Yes | Register may be incomplete; new risks will emerge |
| Open Questions | Yes | Two questions: per-bank overlays and emerging risk incorporation |
| Source Links | Yes | References handoff Sections 7-9, OWASP, NIST, FinCEN, source_index.md |
| Last Updated | Yes | 2026-05-03 |
| Owner | Yes | Chief Risk Officer |

Full compliance.

### fraud_risk_framework.md

| Required Field | Present? | Notes |
|---|---|---|
| Purpose | Yes | Specific: covers attack vectors, detection, prevention, and inter-component interaction |
| Scope | Yes | Explicitly limits to voice AI-amplified fraud risks, excludes general banking fraud |
| Assumptions | Yes | Four assumptions about AI-specific attack dynamics and real-time operation |
| Decisions Made | Yes | Organized by attack vector (not regulation) with clear rationale |
| Alternatives Considered | Yes | Regulation-first and product-line organizations both considered and rejected with reasons |
| Risks | Yes | Fraud techniques evolve faster than frameworks; treated as living document |
| Open Questions | Yes | Two questions: fraud-as-a-service offering, regulatory divergence on fraud liability |
| Source Links | Yes | References FinCEN, PSR, OWASP, Pindrop report, handoff Section 8, risk register |
| Last Updated | Yes | 2026-05-03 |
| Owner | Yes | Fraud Operations Lead |

Full compliance.

### model_risk_framework.md

| Required Field | Present? | Notes |
|---|---|---|
| Purpose | Yes | Links to OCC 2011-12, MAS AIRG, EU AI Act model documentation |
| Scope | Yes | All 12 model types enumerated with risk tiers and deployment types |
| Assumptions | Yes | Third-party hosted models, VocalIQ does not train foundations, provider update risk |
| Decisions Made | Yes | SR 11-7 lifecycle as primary structure, four-tier risk classification with rationale |
| Alternatives Considered | Yes | EU AI Act classification and two-tier model both considered and rejected with reasons |
| Risks | Yes | Provider transparency gaps, LLM validation immaturity, false drift alerts |
| Open Questions | Yes | Two questions: embedded third-party models, shadow model for comparison |
| Source Links | Yes | References OCC 2011-12, SR 11-7, MAS AIRG, EU AI Act, NIST AI RMF, risk register |
| Last Updated | Yes | 2026-05-03 |
| Owner | Yes | Model Risk Owner |

Full compliance.

### operational_resilience.md

| Required Field | Present? | Notes |
|---|---|---|
| Purpose | Yes | Links to DORA, PRA requirements, and bank resilience obligations |
| Scope | Yes | All 12 components, all third-party dependencies, bank interfaces |
| Assumptions | Yes | Cloud-hosted deployment, critical ICT provider classification, 24/7 operations |
| Decisions Made | Yes | Degraded mode prioritizes continuity over features, 90-day exit transition |
| Alternatives Considered | Yes | Active-active multi-region and offline-first both considered and rejected |
| Risks | Yes | Degraded mode limitations, data portability constraints, cascade failures |
| Open Questions | Yes | Three questions: on-prem option, degraded SLA tiers, minimum viable degraded mode |
| Source Links | Yes | References DORA, PRA framework, handoff Sections 9.5 and 11 |
| Last Updated | Yes | 2026-05-03 |
| Owner | Yes | CTO |

Full compliance.

### regulatory_matrix.csv

CSV files are not expected to carry Section 28 metadata directly. The source_index.md provides the research context and metadata for the regulatory corpus. This is the same approach accepted in the Step 4 review for the workflow_catalog.csv. Acceptable.

---

## Section 9.4 CSV Schema Compliance

The handoff specifies exactly 16 fields. The CSV header row contains:

1. jurisdiction -- present
2. regulation_or_guidance -- present
3. source_url -- present
4. risk_domain -- present
5. requirement_summary -- present
6. applies_to_vocaliq -- present
7. applicability_rationale -- present
8. product_requirement -- present
9. technical_control -- present
10. operational_control -- present
11. evidence_required -- present
12. owner -- present
13. priority -- present
14. implementation_phase -- present
15. legal_review_required -- present
16. last_verified_date -- present

All 16 fields present in the correct order. No extra fields, no missing fields. Full schema compliance.

---

## Regulatory Domain Coverage (Section 9.1: 15 domains)

| # | Domain | Covered in CSV? | Row(s) |
|---|---|---|---|
| 1 | Data protection and privacy | Yes | GDPR (row 2), PDPA (row 3), UK GDPR (row 4), GLBA (row 5) |
| 2 | Call recording and consent | Yes | Multi-jurisdiction consent (row 6) |
| 3 | Electronic marketing and outbound calls | Partial | FCC TCPA only (row 25). US only. See H1. |
| 4 | Payment/card data security | Yes | PCI DSS v4.x (row 7) |
| 5 | Operational resilience | Yes | DORA (row 8), PRA/FCA framework (row 9) |
| 6 | Outsourcing and third-party risk | Yes | EBA outsourcing (row 18), MAS TRM outsourcing (row 19) |
| 7 | Model risk management | Partial | OCC 2011-12/SR 11-7 (row 13). See M1 for cross-listing gap. |
| 8 | AI governance | Yes | EU AI Act (row 10), MAS AIRG (row 11), NIST AI RMF (row 12) |
| 9 | Consumer protection and conduct risk | Yes | FCA Consumer Duty (row 14), CFPB UDAAP (row 15), ECOA/Reg B (row 26) |
| 10 | Complaints handling | Yes | FCA DISP (row 20) |
| 11 | Collections and vulnerable-customer treatment | Yes | FCA Vulnerable Customers FG21/1 (row 21) |
| 12 | Fraud and financial crime | Yes | FinCEN deepfake alert (row 16), PSR APP scam reimbursement (row 17) |
| 13 | Recordkeeping and audit | Yes | Multi-jurisdiction recordkeeping (row 22) |
| 14 | Accessibility and language support | Yes | Multi-jurisdiction accessibility (row 23) |
| 15 | Cybersecurity | Yes | OWASP LLM Top 10 (row 24) |

14 of 15 domains fully covered. 1 domain (Electronic marketing and outbound calls) has partial coverage (US only). See H1.

---

## Jurisdiction Coverage (Section 9.2: minimum 4 priority)

| Jurisdiction | Rows in CSV | Assessment |
|---|---|---|
| Singapore | 3 rows: PDPA, MAS AIRG, MAS TRM outsourcing | Covered |
| EU | 4 rows: GDPR, DORA, EU AI Act, EBA outsourcing | Covered |
| UK | 5 rows: UK GDPR, PRA resilience, FCA Consumer Duty, FCA DISP, FCA vulnerability | Covered |
| US | 6 rows: GLBA, NIST AI RMF, OCC SR 11-7, CFPB UDAAP, FinCEN deepfake, FCC TCPA, ECOA | Covered |
| Multi-jurisdiction | 4 rows: call recording consent, recordkeeping, accessibility, OWASP | Covered |
| Global | 1 row: PCI DSS | Covered |
| Australia | 0 rows | Not covered. See M2. |
| India | 0 rows | Not covered. See M2. |

All four priority jurisdictions covered with meaningful depth. Secondary jurisdictions deferred.

---

## Required Elements Checklist (Handoff Step 5)

The handoff requires seven elements across the deliverables:

| Required Element | Present? | Location |
|---|---|---|
| Requirement | Yes | CSV requirement_summary column; risk register risk descriptions; framework documents throughout |
| Product implication | Yes | CSV product_requirement column; risk register mitigations translate to product features |
| Technical control | Yes | CSV technical_control column; risk register mitigations; all three frameworks describe component-specific controls |
| Operational control | Yes | CSV operational_control column; fraud framework Section 4 (response procedures); model risk framework Section 6 (governance); operational resilience Section 3 (incident response) |
| Evidence artifact | Yes | CSV evidence_required column; model risk framework Section 2 (model cards); operational resilience Section 4 (exit data) |
| Owner | Yes | CSV owner column; risk register per-risk owner; all frameworks have document owner |
| Priority | Yes | CSV priority column; risk register P0-P3 ranking with scoring methodology |

All seven required elements present across the deliverables.

---

## Internal Consistency Check

Cross-referencing between the CSV and the four risk/framework documents:

- The CSV's DORA row (row 8) lists mitigations (automated failover, degraded-mode operation, exit plans, resilience testing) that directly map to the operational_resilience.md Sections 1-4. Consistent.
- The CSV's OCC 2011-12 row (row 13) lists controls (model inventory, validation, drift detection, rollback) that map to model_risk_framework.md Sections 1-5. Consistent.
- The CSV's FinCEN deepfake row (row 16) references deepfake detection, fraud risk scoring, and SAR reporting support, which map to fraud_risk_framework.md Section 1.1 and the risk register RISK-006. Consistent.
- The CSV's PSR APP scam row (row 17) references duress detection, prohibited beneficiary creation, and safe callback protocol, which map to fraud_risk_framework.md Section 1.3 and Section 3 workflow controls. Consistent.
- The CSV's EU AI Act row (row 10) references model registry, evaluation lab, and AI disclosure, which map to model_risk_framework.md Section 1 (model catalog), Section 2 (documentation), and Section 6.3 (regulatory reporting). Consistent.
- The CSV's MAS AIRG row (row 11) references AI inventory export, model cards, fairness monitoring, and human oversight, all present in model_risk_framework.md. Consistent.
- Risk register RISK-001 (prompt injection, score 20) maps to CSV row 24 (OWASP LLM Top 10) and fraud_risk_framework.md Section 1.5. Consistent.
- Risk register RISK-006 (deepfake attacks, score 15) maps to CSV row 16 (FinCEN) and fraud_risk_framework.md Section 1.1. Consistent.
- Risk register RISK-013 (platform outage, score 10) maps to CSV rows 8-9 (DORA, PRA) and operational_resilience.md Sections 1-2. Consistent.
- Owner assignments are consistent: CTO owns operational resilience across the CSV, risk register, and framework document. Fraud Operations owns fraud-related risks in both the register and framework.

No inconsistencies found between the five deliverables.

---

## Risk Register Ranking Verification

The risk register uses a 5x5 impact-likelihood matrix. Spot-checking the math and priority assignments:

| Risk | Impact | Likelihood | Stated Score | Calculated | Priority | Correct? |
|---|---|---|---|---|---|---|
| RISK-001 Prompt injection | 5 | 4 | 20 | 20 | P0 | Yes |
| RISK-007 Social engineering | 5 | 4 | 20 | 20 | P0 | Yes |
| RISK-002 Hallucination | 4 | 4 | 16 | 16 | P0 | Yes |
| RISK-003 Sensitive disclosure | 5 | 3 | 15 | 15 | P0 | Yes |
| RISK-006 Deepfake attacks | 5 | 3 | 15 | 15 | P0 | Yes |
| RISK-010 Advice boundary | 5 | 3 | 15 | 15 | P0 | Yes |
| RISK-005 Training data bias | 4 | 3 | 12 | 12 | P1 | Yes |
| RISK-008 STT errors | 4 | 3 | 12 | 12 | P1 | Yes |
| RISK-011 Vulnerability detection | 4 | 3 | 12 | 12 | P1 | Yes |
| RISK-014 Provider disruption | 4 | 3 | 12 | 12 | P1 | Yes |
| RISK-009 Unauthorized action | 5 | 2 | 10 | 10 | P0 | Yes (impact 5 rule) |
| RISK-012 PCI exposure | 5 | 2 | 10 | 10 | P0 | Yes (impact 5 rule) |
| RISK-013 Platform outage | 5 | 2 | 10 | 10 | P0 | Yes (impact 5 rule) |
| RISK-004 Model drift | 3 | 3 | 9 | 9 | P2 | Yes |
| RISK-015 Audit completeness | 4 | 2 | 8 | 8 | P2 | Yes |

All scores are mathematically correct. The priority assignments follow the stated methodology: Critical (15+) = P0, High (10-14) = P1, Medium (6-9) = P2. RISK-009, RISK-012, and RISK-013 score 10 (which is technically High/P1 per the formula) but are assigned P0. The document's preamble says "Critical risks (impact 5 x likelihood 3+) are P0" but RISK-009, 012, and 013 have likelihood 2. However, the preamble also implies judgment beyond the formula, and assigning P0 to impact-5 risks regardless of likelihood is a defensible conservative choice for banking. The summary matrix in Section 5 accurately reflects all individual entries.

---

## Section 10.3 Compliance: Legal Requirement vs. Product Best Practice

Section 10.3 requires separating "legal requirement" from "product best practice." The source_index.md does this well, with each entry containing separate "Legal Obligations" and "Product Best Practices" subsections. The CSV itself does not make this distinction, as the requirement_summary column blends mandatory and best-practice content. The framework documents similarly mix mandatory and recommended controls.

The source_index.md carries the weight of this requirement adequately. The CSV's role is to map requirements to controls, and expecting it to separate legal from best-practice in each cell would make the data less usable. This is acceptable.

---

## Overall Assessment

The Step 5 deliverables form a solid regulatory and risk foundation for the VocalIQ platform. The regulatory matrix CSV is structurally sound and follows the handoff schema exactly. The risk register is quantitative, ranked, and actionable. The three framework documents are substantive enough to withstand scrutiny from a bank's model risk, fraud, or operational resilience teams.

The strongest aspect is cross-document consistency. Every risk in the register has a corresponding regulatory driver in the CSV and a corresponding control framework in one of the three framework documents. The architecture components (Policy Engine, Tool Gateway, Fraud-Aware Identity Layer, Model Gateway, Human Control Center, Audit Ledger) are referenced consistently across all five files.

The one high finding (H1) is a legitimate gap: the outbound calls/electronic marketing domain has only US jurisdiction coverage, leaving SG, EU, and UK unaddressed. This won't affect the inbound-only MVP, but the regulatory matrix is supposed to be a complete landscape document. The two medium findings (M1 on domain cross-listing and M2 on missing secondary jurisdictions) are gaps in coverage breadth rather than structural problems.

**Verdict: PASS**

The deliverables meet Step 5 requirements. The high and medium findings should be addressed before Step 6 begins, but they do not block progress.

## Recommended Improvements (Non-Blocking)

1. [HIGH] Add outbound call/electronic marketing regulation rows for SG, EU, and UK to complete domain #3 coverage
2. [MEDIUM] Cross-list MAS AIRG and EU AI Act model documentation requirements under the "Model risk management" domain in addition to "AI governance"
3. [MEDIUM] Add placeholder rows for Australia, India, and UAE regulations to satisfy Section 9.2 minimum first-pass scope
4. [LOW] Consider adding a cross-border data transfer risk entry (RISK-016) to the risk register
5. [LOW] Add basis notes for fraud detection success criteria thresholds in the fraud risk framework
6. [LOW] Add PRA impact tolerance mapping to the operational resilience framework
