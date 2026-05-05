# QA Re-Review: Step 8 Evaluation Plan

**Review ID:** QA-STEP08-002
**Date:** 2026-05-04
**Reviewer:** QA Agent (Independent)
**Scope:** Re-review of 6 evaluation plan documents after remediation of QA-STEP08-001 findings
**Files Reviewed:**
- eval_strategy.md (DOC_EVAL_ES_001)
- golden_call_suite.md (DOC_EVAL_GC_001)
- adversarial_tests.md (DOC_EVAL_AT_001)
- fraud_simulations.md (DOC_EVAL_FS_001)
- rag_evaluation.md (DOC_EVAL_RAG_001)
- release_gates.md (DOC_EVAL_RG_001)

---

## Previous Finding Verification

### F-01 (HIGH): eval_strategy.md missing agent_after_call_work_reduction and qa_review_time_saved metrics

**Status: RESOLVED**

Evidence: agent_after_call_work_reduction is present in Section 3.4 Operational Metrics (line 124) with definition "Percentage reduction in after-call work (notes, categorization, wrap-up) compared to fully manual baseline," gate severity minor, and target "> 40% at GA." qa_review_time_saved is present in Section 3.5 Economic Metrics (line 135) with definition "Reduction in QA review time per call compared to manual QA workflow (transcript review, scoring, reporting)," gate severity minor, and target "> 50% at GA." Both metrics have appropriate "tracked" gating (non-blocking), which is reasonable for MVP.

### F-02 (HIGH): release_gates.md missing blocker gate for connector security review

**Status: RESOLVED**

Evidence: BG-S08 is present in Section 2.1 Safety Gates (line 56). The condition reads: "Security review is missing for any release that introduces or modifies a bank connector." The rationale explains credential handling, network exposure, and data classification verification requirements. This is correctly classified as a blocker gate with no override.

### F-03 (HIGH): All 5 companion docs missing Alternatives Considered and Risks header fields

**Status: RESOLVED**

Evidence verified in each file:
- golden_call_suite.md: Alternatives Considered (line 21) and Risks (line 23) present with substantive content.
- adversarial_tests.md: Alternatives Considered (line 20) and Risks (line 24) present with substantive content.
- fraud_simulations.md: Alternatives Considered (line 21) and Risks (line 24) present with substantive content.
- rag_evaluation.md: Alternatives Considered (line 21) and Risks (line 24) present with substantive content.
- release_gates.md: Alternatives Considered (line 20) and Risks (line 24) present with substantive content.

All 5 companion docs now match eval_strategy.md's header structure: Document ID, Last Updated, Owner, Version History, Principles Referenced, Scope, Assumptions, Decisions Made, Alternatives Considered, Risks, Source Links.

### F-04 (MEDIUM): golden_call_suite.md missing compliance scenarios for payment, dispute, maintenance

**Status: RESOLVED**

Evidence: Three new compliance scenarios added in Sections 2.6 and 2.7:
- CO-PAY-001 (line 442): Payment scam warning and confirmation disclosure for new payee payments.
- CO-DIS-001 (line 464): Dispute investigation rights and timeline disclosure.
- CO-MAINT-001 (line 480): Data protection notice for contact detail changes.

Each has appropriate severity (blocker for CO-PAY-001 and CO-DIS-001, major for CO-MAINT-001) and defined expected_outcomes with disclosure_contains checks.

### F-05 (MEDIUM): golden_call_suite.md missing dispute edge cases

**Status: RESOLVED**

Evidence: Two dispute edge cases added in Section 2.7:
- EC-DIS-001 (line 501): Dispute after chargeback deadline has passed (130 days, beyond 120-day window). Severity: major.
- EC-DIS-002 (line 521): Dispute on a pending transaction. Severity: major.

Both scenarios have clear expected_outcomes and appropriate severity levels.

### F-06 (MEDIUM): fraud_simulations.md missing deferred category notes for synthetic identity and mule account

**Status: RESOLVED**

Evidence: "Deferred Categories" subsection added under Section 5 (line 333). Contains two named paragraphs:
- Synthetic identity fraud (line 335): Deferral rationale references dependency on bank onboarding/KYC process, VocalIQ's contribution (flagging behavioral anomalies), and the need for synthetic-identity-specific account fixtures.
- Mule account activity (line 337): Deferral rationale references dependency on cross-account transaction pattern analysis beyond single voice session, the need for bank transaction monitoring system integration, and VocalIQ's contribution (flagging unusual payment patterns).

Both notes provide sufficient context for why the deferral is appropriate.

### F-07 (MEDIUM): rag_evaluation.md missing citation accuracy scenarios

**Status: RESOLVED**

Evidence: Section 4 "Citation Accuracy Tests" (line 238) added with three scenarios:
- RAG-CITE-001 (line 246): Single-document citation accuracy. Verifies correct attribution to source document.
- RAG-CITE-002 (line 265): Multi-document citation. Verifies per-claim attribution when answer spans two documents.
- RAG-CITE-003 (line 289): No phantom citation. Verifies AI does not fabricate document names or section references.

The citation_accuracy metric (> 98%, gate: major) is present in Section 7 metrics summary (line 463), consistent with eval_strategy.md.

### F-08 (MEDIUM): release_gates.md latency budget not reconciled with eval_strategy.md p95 threshold

**Status: RESOLVED**

Evidence: The latency budget table in release_gates.md Section 4.2 (line 122) now includes an explicit reconciliation note in the "Total (no tool call)" row: the 1650ms component budget ceiling is described as headroom per component, while eval_strategy.md's turn_latency_p95 < 1500ms is the observed target. The note clarifies that exceeding 1500ms observed p95 triggers gate MG-01 evaluation regardless of individual component budgets. The "Total (with tool call)" row explains tool-call turns are measured against p99 < 3000ms instead. This reconciliation is clear and internally consistent.

### F-09 (MEDIUM): adversarial_tests.md missing OWASP LLM Top 10 coverage matrix

**Status: RESOLVED**

Evidence: Section 10 "OWASP LLM Top 10 Coverage Matrix" (line 505) added with a complete table mapping all 10 OWASP LLM risks (LLM01 through LLM10). Each entry specifies coverage status (Covered, Partial, or Architectural), test scenario references where applicable, and explanatory notes. Two items are marked "Partial" with GA targets (LLM04: Model Denial of Service, LLM09: Overreliance), and three items are marked "Architectural" with design-level mitigations explained (LLM03, LLM05, LLM10). This is a thorough and realistic mapping.

### F-10 (MEDIUM): eval_strategy.md approver roles undefined

**Status: RESOLVED**

Evidence: An "Approver role definitions" paragraph is present after the approver matrix table (line 174). It references operational_resilience.md Section 7 for full role definitions, explains the distinction between "Lead" roles (domain owners with technical authority) and "Review" roles (cross-functional validators), defines "Bank Liaison," and specifies that all approvers must be named individuals (not team aliases) for audit traceability. This appropriately defers to the operational resilience doc for full definitions while providing enough context to understand the matrix.

### F-11 (LOW): golden_call_suite.md missing non-English language deferral note

**Status: RESOLVED**

Evidence: A deferral note is present at the top of Section 4 "Accent and Language Scenarios" (line 597). It specifies that full non-English language support (Mandarin, Hindi, Malay, Arabic) is deferred to GA, explains MVP covers accented English only for English-speaking markets (UK, Singapore English), and notes that GA will require language-specific golden path scenario sets mirroring core workflows with language-specific compliance scripts.

### F-12 (LOW): eval_strategy.md missing deepfake severity:major rationale

**Status: RESOLVED**

Evidence: A footnote after the evaluation suite taxonomy table (line 67) provides the rationale. It explains that VocalIQ's primary authentication defense is multi-factor (KBA + OTP), not voice biometrics; voice biometric capability depends on the bank's deployed vendor and is an additive signal, not a sole gatekeeper; and if a bank deploys voice biometrics as a primary authentication factor, these tests should be elevated to blocker severity in the bank-specific extension. This is a clear and defensible rationale.

### F-13 (LOW): release_gates.md fraud signal miss rate monitoring unclear

**Status: RESOLVED**

Evidence: A "Note on fraud signal miss rate monitoring" paragraph is present at the end of Section 7 (line 268). It explains that the real-time metric is a proxy measure (comparing flagging rate against expected baseline from pre-release evaluation), not a true detection accuracy measure. It clarifies that true accuracy requires retrospective fraud outcome analysis (weekly, coordinated with the bank's fraud operations team), which provides the authoritative miss rate and feeds back into threshold calibration. This adequately explains the metric's limitations.

### F-14 (LOW): fraud_simulations.md behavioral anomaly signal testing column unclear

**Status: RESOLVED**

Evidence: The "Behavioral anomaly" row in Section 6 Fraud Detection Signal Matrix (line 358) now has an expanded "Tested In" entry. It reads: "Cross-cutting signal; tested indirectly through all scenarios via session metadata. Dedicated behavioral anomaly scenarios deferred to GA pending integration with bank-specific customer profiling data." This clarifies both the current indirect coverage and the deferral plan.

### F-15 (LOW): eval_strategy.md AI caller scenarios not noted as deferred

**Status: RESOLVED**

Evidence: The scenario definition format in Section 6 (line 277) includes a comment block under scenario_type explaining that ai_caller scenario type is defined in the schema but deferred to GA. The note explains that MVP testing uses scripted and adversarial types only, and that AI caller testing introduces evaluation challenges (non-deterministic paths, evaluation of evaluation) requiring a dedicated validation framework. This is an appropriate deferral with clear rationale.

---

## New Findings

### NF-01 (LOW): golden_call_suite.md scenario inventory table undercounts scenarios

**Severity:** LOW
**File:** golden_call_suite.md, Section 7, lines 746-753

The inventory summary table does not reflect the scenarios added as part of the F-04/F-05 remediation. Discrepancies:

| Workflow | Column | Table says | Actual count | Missing |
|----------|--------|-----------|-------------|---------|
| Payment/Transfer | CO | 0 | 1 | CO-PAY-001 |
| Dispute/Chargeback | EC | 0 | 2 | EC-DIS-001, EC-DIS-002 |
| Dispute/Chargeback | CO | 0 | 1 | CO-DIS-001 |
| Dispute/Chargeback | Total | 1 | 4 | 3 missing |
| Account Maintenance | CO | 0 | 1 | CO-MAINT-001 |
| Account Maintenance | Total | 1 | 2 | 1 missing |
| CO column total | | 1 | 4 | 3 missing |

The table claims 22 total scenarios, but the actual count across all defined scenarios in the document is 27. The table appears to reflect the pre-remediation state before F-04 and F-05 fixes were applied.

**Recommendation:** Update the inventory summary table to match the actual scenario definitions in the document. The corrected table should show:
- Payment/Transfer: GP=1, EC=2, CO=1, Total=4
- Dispute/Chargeback: GP=1, EC=2, CO=1, Total=4
- Account Maintenance: GP=1, EC=0, CO=1, Total=2
- CO column total: 4
- Grand total: 27

---

## Cross-Document Consistency Check

### Scenario ID Uniqueness
All scenario IDs across the 6 documents are unique. No duplicates found. Prefix conventions are consistent and well-differentiated:
- GP-/EC-/CO-/AQ-/AL-/HO- (golden_call_suite.md)
- ADV- (adversarial_tests.md)
- FRAUD- (fraud_simulations.md)
- RAG- (rag_evaluation.md)
- LT-/CT-/BG-/MG- (release_gates.md)

### Metric Name Consistency
Metric names in eval_strategy.md Section 3 align with references in companion documents. Specific verified cross-references:
- turn_latency_p95 in eval_strategy.md (line 109) matches the reconciliation note in release_gates.md (line 122)
- missed_fraud_signal_rate in eval_strategy.md (line 97) matches the monitoring definition in release_gates.md (line 262, 268)
- hallucinated_answer_rate / rag_unsupported_answer_rate in eval_strategy.md (lines 94-95) match RAG evaluation metrics in rag_evaluation.md Section 7 (lines 457-458)
- citation_accuracy in rag_evaluation.md (line 463) is not separately listed as a metric in eval_strategy.md Section 3 but is implicitly covered under the RAG dimension. This is acceptable since rag_evaluation.md is the authoritative source for RAG-specific metrics.

### Threshold Consistency
- p95 latency: eval_strategy.md says < 1500ms (line 109). release_gates.md acknowledges this and reconciles the component budget ceiling of 1650ms (line 122). Consistent.
- p99 latency: eval_strategy.md says < 3000ms (line 109). release_gates.md LT-001 says p99 < 3000ms (line 102). MG-01 triggers on p99 > 3000ms (line 83). Consistent.
- missed_fraud_signal_rate: eval_strategy.md says < 3% blocker (line 97). fraud_simulations.md Section 8 says < 3% blocker for all signals (line 383). release_gates.md post-release monitoring uses > 5% alert / > 10% rollback for the proxy measure (line 262). The different thresholds for the proxy vs. true metric are explained in the monitoring note (line 268). Consistent.
- unauthorized_disclosure_rate: eval_strategy.md says 0% blocker (line 91). release_gates.md BG-S01 blocks on any policy violation (line 49). Post-release monitoring auto-rolls back on > 0 (line 259). Consistent.

### Gate-to-Metric Mapping
release_gates.md blocker gates map to eval_strategy.md blocker metrics:
- BG-S01 (policy violation) -> policy_violation_rate, unauthorized_tool_call_rate, unauthorized_disclosure_rate
- BG-S03 (RAG unsupported) -> rag_unsupported_answer_rate
- BG-S04 (prompt injection) -> tested in adversarial_tests.md
- BG-S06 (fraud simulation) -> missed_fraud_signal_rate
- BG-S07 (cross-tenant) -> cross_tenant_leakage_rate (in rag_evaluation.md)
- BG-S08 (connector security) -> process gate, not a metric

Major gates map to corresponding eval_strategy.md major metrics appropriately.

### Document Structure
All 6 documents have the required header fields: Document ID, Last Updated, Owner, Version History, Principles Referenced, Scope, Assumptions, Decisions Made, Alternatives Considered, Risks, Source Links. Structure is consistent across all documents.

### Cross-Reference Integrity
- eval_strategy.md references companion docs in the suite taxonomy table (Section 2). All 5 companion doc filenames are correct.
- release_gates.md Source Links reference eval_strategy.md. Confirmed consistent.
- adversarial_tests.md OWASP matrix references scenario IDs from both adversarial_tests.md and rag_evaluation.md. All referenced IDs exist.

---

## Verdict: PASS

All 15 findings from QA-STEP08-001 have been properly resolved. The fixes are substantive, well-integrated, and internally consistent across all 6 documents.

One new LOW-severity finding was identified (NF-01: scenario inventory table undercount in golden_call_suite.md). This is a cosmetic bookkeeping issue where the summary table was not updated to reflect the scenarios added during F-04/F-05 remediation. It does not affect the test definitions themselves or any other document, and carries no risk of missed test coverage since the actual scenario definitions are complete and correct.

No new HIGH or blocker findings. The evaluation plan document set is fit for purpose as the Step 8 deliverable.
