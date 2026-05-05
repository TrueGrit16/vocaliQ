---
review_id: QA-STEP04-001
deliverable: docs/research/banking_workflows/use_case_taxonomy.md, docs/research/banking_workflows/workflow_catalog.csv, docs/research/banking_workflows/autonomy_matrix.md, docs/research/banking_workflows/prohibited_use_cases.md
reviewer: QA Agent
date: 2026-05-03
verdict: PASS
---

# Step 4 QA Review: Banking Workflow Catalog

## Summary

The production team delivered all four required files for Step 4. The deliverables form a cohesive and technically rigorous banking workflow catalog that covers every workflow and classification the handoff specifies. The taxonomy maps 17 workflows across autonomy levels A0 through A6, the CSV captures all 17 in a structured format with 27 fields per row, the autonomy matrix documents authentication, policy, handoff, integration, and evaluation requirements per level and per workflow, and the prohibited use cases document provides detailed regulatory justification for all eight A6 categories.

This is strong work. The documents read like they were written by someone who has actually worked in banking operations or fintech compliance. Regulatory citations are specific (ECOA/Reg B, MiFID II, FCA Consumer Duty, MAS TRM, PCI DSS, PSR mandatory reimbursement), not generic. The three-layer defense-in-depth model for prohibited workflows (Graph Compiler, Policy Engine, Tool Gateway) is thoughtfully designed. Cross-referencing between the four documents is consistent.

No blockers found. A small number of medium and low findings, mostly around gaps between the CSV schema and the handoff's Section 7.5 YAML template.

---

## BLOCKER Findings

None.

---

## HIGH Findings

None.

---

## MEDIUM Findings

### M1: CSV schema does not fully match Section 7.5 use-case approval template

The handoff's Section 7.5 defines a YAML template with 20+ fields that "each use case must be documented" against. The CSV uses a 27-column schema that covers most of these fields but deviates in naming and omits a few.

Specific gaps:

- **retention_policy**: Present in both Section 7.5 and the CSV. Match is good.
- **business_owner, risk_owner, compliance_owner**: Present in CSV. Match is good.
- **jurisdictions**: Present in CSV. Match.
- **permitted_actions / prohibited_actions**: Present in CSV. Match.
- **fraud_controls**: Present in Section 7.5 template. Present in CSV. Match.
- **success_metrics**: Present in Section 7.5 as a list. CSV column is called "success_metrics." Match.
- **pre_release_tests**: Section 7.5 lists specific test types (golden_calls, adversarial_prompt_injection, noisy_audio, accent_suite, fraud_simulation, policy_violation_tests). The CSV column is called "pre_release_tests" but the values are less specific than the template's example. For instance, UC-001 lists "Ambiguous location queries; coverage gap queries; after-hours queries; multilingual location names" which are evaluation scenarios rather than test types. This conflates evaluation scenarios with pre-release test categories.

The CSV also adds columns not in the Section 7.5 template: risk_level, priority, wave, deferred_reason. These additions are sensible and don't violate any requirement.

**Missing from CSV but present in Section 7.5 template:**
- **customer_segment**: Actually present as "customer_segment" column. Match.
- **required_disclosures**: Present in Section 7.5. Present in CSV as "required_disclosures." Match.

The gap is narrow. The main issue is that the "pre_release_tests" column content appears to duplicate the "evaluation_scenarios" column content rather than listing test category types (golden calls, adversarial tests, etc.) as the template suggests.

**Required action:** Review the pre_release_tests column to ensure it lists test *types* (golden calls, adversarial prompt injection, fraud simulation, etc.) rather than repeating the evaluation scenario descriptions. The Section 7.5 example distinguishes between pre_release_tests (test methodology categories) and what the taxonomy document calls evaluation scenarios (specific test case descriptions).

### M2: Autonomy matrix does not explicitly label the "allow / defer / prohibit" decision per workflow

The acceptance criteria at line 2987 state: "Includes allow/defer/prohibit decisions." The use_case_taxonomy.md handles this well in Section 4 ("Decision Framework: Allow, Defer, Prohibit") with clear criteria and workflow assignments. The autonomy_matrix.md references the taxonomy and classifies by autonomy level, but it never explicitly uses the terms "allow," "defer," or "prohibit" as decision labels for individual workflows. The CSV includes a "wave" column with values "First" and "Later" but no explicit "allow/defer/prohibit" column.

The information is there across the documents, but a reviewer looking for a single clear decision label per workflow in the CSV or matrix would need to cross-reference the taxonomy.

**Required action:** Add a column to the CSV (e.g., "implementation_decision") with explicit values: Allow, Defer, or Prohibit. This makes the allow/defer/prohibit classification machine-readable and directly satisfies the acceptance criteria without requiring cross-referencing.

### M3: Evaluation scenarios in autonomy_matrix.md are organized by autonomy level, not per workflow

The handoff Step 4 requirement says to include "evaluation scenarios." The autonomy_matrix.md provides evaluation focus areas grouped by autonomy level (A0, A1, A2, etc.) in Section 5, which is useful for understanding what each level needs to test. However, per-workflow evaluation scenarios are only found in the use_case_taxonomy.md (within each UC entry) and the CSV's evaluation_scenarios column.

The autonomy matrix's evaluation section is valuable as a testing framework, but it doesn't map individual scenarios to individual workflows. Someone building the Evaluation Lab would need to combine the matrix's level-based focus areas with the taxonomy's per-workflow scenarios.

**Required action:** Either add a brief per-workflow evaluation scenario summary to the autonomy matrix, or add a cross-reference note directing readers to the taxonomy and CSV for per-workflow scenarios. The current structure works, but the connection between the two documents should be explicit.

---

## LOW Findings

### L1: Workflow IDs use different prefix conventions across documents

The use_case_taxonomy.md uses UC-001 through UC-017 for first-wave and later-wave workflows. The prohibited_use_cases.md uses P-001 through P-008 for prohibited workflows. The CSV uses UC-001 through UC-017 (prohibited workflows are not in the CSV since they have no implementation details).

This is internally consistent, but the Section 7.5 template example uses the format "UC_CARD_LOST_001" (descriptive ID with underscores). The current IDs are simpler sequential numbers. This is a minor style difference, not a functional gap, but worth noting because the handoff template uses a more descriptive naming convention that could help identify workflows at a glance.

**Required action:** No change needed for this review cycle. If the project later adopts the handoff's descriptive ID convention (UC_CARD_LOST_001 style), a bulk rename would be required.

### L2: The CSV does not include rows for A6 prohibited workflows

The CSV covers UC-001 through UC-017 (first-wave and later-wave). The eight prohibited use cases (P-001 through P-008) exist only in prohibited_use_cases.md. For a complete "workflow catalog" CSV, having all workflows in one structured file (with an "autonomy_level" value of A6 and "wave" value of "Prohibited") would make the catalog fully self-contained.

**Required action:** Consider adding rows for P-001 through P-008 to the CSV with A6 autonomy level and Prohibited wave designation. Many fields would be N/A, but having all workflows in the CSV makes automated processing easier. This is optional, not required.

### L3: No explicit mention of the handoff's Section 8 banking-specific practical issues

Section 8 of the handoff covers banking-specific practical issues (hold/transfer/conference, DTMF, callback, multi-party, accessibility). The workflow documents focus on workflow-level requirements and don't reference Section 8 as a cross-cutting input. These are operational concerns that would affect workflow implementation but aren't workflow-specific.

**Required action:** Add a note in the taxonomy or matrix referencing Section 8 as a source of cross-cutting operational requirements that apply across workflows.

### L4: Version 1.0 across all four documents

All four documents are at version 1.0, dated 2026-05-03. This is expected for initial delivery and not a problem. Noted for tracking purposes only.

---

## Section 28 Documentation Quality Bar Compliance

### use_case_taxonomy.md

| Required Field | Present? | Notes |
|---|---|---|
| Purpose | Yes | Specific and actionable: drives architecture, policy, graph, and MVP scoping |
| Scope | Yes | Explicitly includes/excludes product lines, geographies, and call types |
| Assumptions | Yes | Four assumptions covering auth scale, autonomy scale, risk basis, and selection criteria |
| Decisions Made | Yes | Taxonomy organized by autonomy level (not product line), with rationale |
| Alternatives Considered | Yes | Product-line organization and simpler allow/defer/prohibit classification considered and rejected with reasons |
| Risks | Yes | Three risks: bank model variance, risk appetite overrides, regulatory reclassification |
| Open Questions | Yes | Three substantive questions: vulnerability as workflow vs. control, multi-intent handling, bereavement classification |
| Source Links | Yes | References handoff Sections 7, 7.5, 8, and context summary |
| Last Updated | Yes | 2026-05-03 |
| Owner | Yes | Chief Product Officer |

Full compliance.

### workflow_catalog.csv

CSV files are not expected to carry Section 28 metadata in the same way as markdown documents. The CSV is a structured data companion to the taxonomy document, which provides the metadata context. This is acceptable.

### autonomy_matrix.md

| Required Field | Present? | Notes |
|---|---|---|
| Purpose | Yes | Configuration source for Policy Engine and Graph Compiler validation |
| Scope | Yes | All 17 workflows plus A6 category |
| Assumptions | Yes | Four assumptions covering auth scale, policy engine, handoff center, risk scoring |
| Decisions Made | Yes | Matrix by autonomy level with per-workflow overrides |
| Alternatives Considered | Yes | Per-workflow flat listing and spreadsheet format rejected with reasons |
| Risks | Yes | Three risks: rule language variance, auth provider capabilities, threshold tuning |
| Open Questions | Yes | Two questions: dynamic autonomy reclassification, identity layer fallback |
| Source Links | Yes | References handoff Sections 7, 7.1, 7.5, 12, 13, and use_case_taxonomy.md |
| Last Updated | Yes | 2026-05-03 |
| Owner | Yes | Chief Product Officer |

Full compliance.

### prohibited_use_cases.md

| Required Field | Present? | Notes |
|---|---|---|
| Purpose | Yes | Defines A6 prohibitions with regulatory justification and technical enforcement |
| Scope | Yes | All A6 workflows, all target jurisdictions, explicitly excludes deferred workflows |
| Assumptions | Yes | Clear distinction between prohibited autonomous execution and permitted AI-assisted human execution |
| Decisions Made | Yes | Strictest-jurisdiction standard applied across all jurisdictions, with rationale |
| Alternatives Considered | Yes | Jurisdiction-specific and per-bank opt-in approaches considered and rejected with reasons |
| Risks | Yes | Three risks: competitive positioning, regulatory evolution, deployment team confusion |
| Open Questions | Yes | Two questions: formal reclassification process, banks insisting on autonomous execution |
| Source Links | Yes | References handoff 7.4, 7.1, 12, 14 plus specific regulations (EU AI Act, MAS TRM, FCA, ECOA, FINRA) |
| Last Updated | Yes | 2026-05-03 |
| Owner | Yes | Chief Product Officer |

Full compliance.

---

## Coverage Verification

### First-wave workflows (Section 7.2: 11 workflows)

| Handoff Workflow | Covered? | Use Case ID |
|---|---|---|
| Branch and ATM locator | Yes | UC-001 |
| Opening hours and appointment booking | Yes | UC-003 |
| Product FAQ from approved knowledge | Yes | UC-002 |
| Intelligent routing | Yes | UC-004 |
| Application status | Yes | UC-006 |
| Lost or stolen card intake | Yes | UC-008 |
| Card activation | Yes | UC-009 |
| Statement request | Yes | UC-010 |
| Balance and recent transactions | Yes | UC-005 |
| Complaint intake | Yes | UC-007 |
| Fraud-alert confirmation | Yes | UC-011 |

All 11 first-wave workflows covered.

### Later-wave workflows (Section 7.3: 6 workflows)

| Handoff Workflow | Covered? | Use Case ID |
|---|---|---|
| Transaction dispute intake | Yes | UC-012 |
| Fee waiver request | Yes | UC-013 |
| Contact detail update | Yes | UC-014 |
| Collections reminder | Yes | UC-015 |
| Travel notification | Yes | UC-016 |
| Card replacement | Yes | UC-017 |

All 6 later-wave workflows covered.

### Prohibited workflows (Section 7.4: 8 categories)

| Handoff Prohibited Category | Covered? | Prohibited ID |
|---|---|---|
| Loan approval or decline | Yes | P-001 |
| Credit score or affordability determination | Yes | P-002 |
| Investment advice | Yes | P-003 |
| Wire transfer initiation | Yes | P-004 |
| New beneficiary creation | Yes | P-005 |
| Final complaint resolution | Yes | P-006 |
| Fraud investigation conclusion | Yes | P-007 |
| Vulnerable customer management without human fallback | Yes | P-008 |

All 8 prohibited categories covered.

---

## Step 4 Required Elements Checklist

| Required Element | Present? | Location |
|---|---|---|
| Autonomy classification | Yes | All four documents classify workflows by A0-A6 |
| Required auth level | Yes | Taxonomy per-workflow entries, CSV columns, autonomy matrix Section 1 |
| Required policy controls | Yes | Autonomy matrix Section 2 with per-level and per-workflow overrides |
| Required human handoff triggers | Yes | Taxonomy per-workflow entries, CSV column, autonomy matrix Section 3 |
| Integration requirements | Yes | Taxonomy per-workflow entries, CSV column, autonomy matrix Section 4 |
| Evaluation scenarios | Yes | Taxonomy per-workflow entries, CSV column, autonomy matrix Section 5 |

All six required elements present.

---

## Internal Consistency Check

The four documents cross-reference each other consistently:

- Autonomy levels (A0-A6) are defined identically across all documents and match the handoff Section 7.1 definitions.
- Workflow IDs (UC-001 through UC-017) are used consistently in taxonomy, CSV, and matrix.
- Prohibited workflow IDs (P-001 through P-008) are used consistently in prohibited_use_cases.md and referenced from taxonomy Section 4.
- Authentication levels (AUTH_0 through AUTH_5) are consistent across taxonomy, CSV, and matrix.
- The taxonomy's Section 4 allow/defer/prohibit framework aligns with the CSV's wave column values and the prohibited document's scope.
- The autonomy matrix's per-workflow authentication overrides (Section 1) match the authentication details in the taxonomy's per-workflow entries.
- The autonomy matrix's policy overrides (Section 2) reference specific workflows that match the taxonomy's UC numbering.
- The prohibited document's technical enforcement mechanisms (Graph Compiler, Policy Engine, Tool Gateway) are consistent with the autonomy matrix's A6 description.

No inconsistencies found between the four documents.

---

## Regulatory Justification Quality (prohibited_use_cases.md)

The regulatory justifications are substantive. Each prohibited workflow cites specific regulations by name and jurisdiction:

- P-001 (Loan approval): ECOA/Reg B, EU AI Act Annex III 5(b), FCA Consumer Duty, MAS TRM. Includes CFPB guidance on algorithmic adverse action explanations. Correctly identifies fairness/disparate impact risk from LLM training data.
- P-002 (Credit score): FCRA, FCA, MAS. Correctly notes AI cannot access full financial picture needed for affordability.
- P-003 (Investment advice): FINRA suitability, SEC Reg Best Interest, MiFID II, FCA COBS, MAS FAA. Correctly identifies mis-selling as primary risk.
- P-004 (Wire transfer): PSR mandatory APP reimbursement, MAS scam prevention guidance, Reg E, UCC 4A. Correctly identifies asymmetric risk profile.
- P-005 (Beneficiary creation): UK CRM Code, PSR, MAS cooling-off guidance. Correctly identifies this as the setup step for APP fraud.
- P-006 (Complaint resolution): FCA complaint handling, FOS review, MAS fair dealing, CFPB patterns. Correctly scopes AI role to intake only.
- P-007 (Fraud investigation): PSR reimbursement caution standard, multi-jurisdictional liability rules.
- P-008 (Vulnerable customer): FCA Consumer Duty, vulnerability categories (financial, health, life events, capability).

The justifications avoid generic "ensure compliance" language and provide specific, actionable reasoning. The three-layer technical enforcement model and the reclassification process in Section 3 add operational depth that goes beyond what the handoff strictly required.

---

## Overall Assessment

This is the strongest step delivery reviewed so far. The four documents function as a coherent system rather than four independent files. The taxonomy provides the domain model, the CSV makes it machine-processable, the autonomy matrix translates it into platform control requirements, and the prohibited document provides the regulatory guardrails. Every workflow from the handoff is accounted for. Every required element (auth, policy, handoff, integration, evaluation) is present across the documents.

The medium findings are legitimate but not structural. M1 (pre_release_tests column conflation) is a data quality issue in one CSV column. M2 (missing explicit allow/defer/prohibit column) is a presentation gap that could be closed with a single column addition. M3 (evaluation scenarios organized by level, not workflow, in the matrix) is an organizational choice that works but could be clearer.

The regulatory analysis in prohibited_use_cases.md is particularly strong. It goes beyond the handoff requirements by providing jurisdiction-specific citations, identifying the reclassification pathway, and designing the three-layer enforcement model. This is the kind of detail that would survive scrutiny from a bank's risk or compliance team.

**Verdict: PASS**

The deliverables meet Step 4 requirements. The medium and low findings should be addressed in the next revision cycle but do not block progress to Step 5.

## Recommended Improvements (Non-Blocking)

1. [MEDIUM] Review CSV pre_release_tests column to distinguish test types from evaluation scenarios
2. [MEDIUM] Add an explicit implementation_decision column (Allow/Defer/Prohibit) to the CSV
3. [MEDIUM] Add per-workflow evaluation scenario cross-references in the autonomy matrix
4. [LOW] Consider adding A6/prohibited workflow rows to the CSV for completeness
5. [LOW] Add a cross-reference to handoff Section 8 (banking operational issues) in the taxonomy or matrix
