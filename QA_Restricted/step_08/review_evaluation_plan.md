# QA Review: Step 8 - Evaluation Plan

**Review ID:** QA-STEP08-001
**Reviewer:** QA Agent (Independent)
**Date:** 2026-05-04
**Verdict:** PASS

---

## Summary Statistics

| Severity | Count |
|----------|-------|
| BLOCKER | 0 |
| HIGH | 3 |
| MEDIUM | 7 |
| LOW | 5 |
| **Total** | **15** |

All six deliverable files are present, well-structured, and substantively complete. The evaluation suite taxonomy covers all 14 required suites from the handoff. Metrics across all five domains are defined with thresholds and gate severities. Release gates capture nearly all handoff conditions. The eval report template is present and materially expanded beyond the handoff's version. No blockers were found. The three HIGH findings are: two missing economic metrics from the handoff, a missing blocker gate for security review of new connectors, and five of six documents missing the "Alternatives Considered" and "Risks" header fields required by Section 28. These should be resolved before the deliverables are presented to a bank audience, but they do not prevent forward progress.

---

## 1. Evaluation Suite Coverage (Handoff Section 20.2)

| # | Required Suite | Covered | Location | Notes |
|---|---------------|---------|----------|-------|
| 1 | Golden path tests | Yes | golden_call_suite.md, Section 2 | 7 golden path scenarios across 5 workflows |
| 2 | Edge-case tests | Yes | golden_call_suite.md, Section 2 | 5 edge-case scenarios |
| 3 | Adversarial prompt injection | Yes | adversarial_tests.md, Sections 2-3 | 7 scenarios (5 direct, 2 indirect) |
| 4 | Fraud and scam tests | Yes | fraud_simulations.md, Sections 2-5 | 8 scenarios across 4 fraud categories |
| 5 | Deepfake/spoofing signal tests | Yes | adversarial_tests.md, Section 6 | 2 scenarios (synthetic voice, replay attack) |
| 6 | Low audio quality tests | Yes | golden_call_suite.md, Section 3 | 3 scenarios (street noise, crowded room, hold music) |
| 7 | Accent and multilingual tests | Yes | golden_call_suite.md, Section 4 | 3 scenarios (Scottish, Indian English, elderly caller) |
| 8 | Compliance script tests | Yes | golden_call_suite.md, Section 2.1 (CO-LOST-001) | 1 explicit scenario; additional compliance assertions embedded in GP scenarios |
| 9 | RAG faithfulness tests | Yes | rag_evaluation.md, Section 2 | 4 faithfulness scenarios plus retrieval and no-answer tests |
| 10 | Tool call authorization tests | Yes | adversarial_tests.md, Section 5 | 3 scenarios covering wrong auth level, A6 prohibition, rate limit |
| 11 | Human handoff tests | Yes | golden_call_suite.md, Section 5 | 3 scenarios (explicit request, fraud-triggered, complaint-triggered) |
| 12 | Load and latency tests | Yes | release_gates.md, Section 4.1 | 5 load scenarios plus latency budget breakdown |
| 13 | Provider outage/chaos tests | Yes | release_gates.md, Section 4.3 | 6 chaos scenarios (LLM outage, DB failover, Redis, network partition, ASR outage, connector timeout) |
| 14 | Regression tests | Yes | golden_call_suite.md, Section 6 + eval_strategy.md, Section 4.3 | Regression policy defined; monotonic growth rule in place |

All 14 suites accounted for.

---

## 2. Metrics Coverage (Handoff Section 20.3)

### 2.1 Customer Outcome Metrics

| Handoff Metric | Defined | Threshold | Gate | File |
|---------------|---------|-----------|------|------|
| task_completion_rate | Yes | > 75% (MVP) | major | eval_strategy.md |
| safe_resolution_rate | Yes | > 99.5% | blocker | eval_strategy.md |
| repeat_call_rate | Yes | < 15% | major | eval_strategy.md |
| containment_rate_without_repeat | Yes | > 65% (MVP) | major | eval_strategy.md |
| customer_abandonment_rate | Yes | < 20% | minor | eval_strategy.md |
| customer_satisfaction_proxy | Yes | > 3.5/5.0 | minor | eval_strategy.md |
| complaint_rate | Yes | < 2% | major | eval_strategy.md |

All 7 customer outcome metrics present.

### 2.2 Safety Metrics

| Handoff Metric | Defined | Threshold | Gate | File |
|---------------|---------|-----------|------|------|
| unauthorized_disclosure_rate | Yes | 0% | blocker | eval_strategy.md |
| unauthorized_tool_call_rate | Yes | 0% | blocker | eval_strategy.md |
| policy_violation_rate | Yes | 0% | blocker | eval_strategy.md |
| hallucinated_answer_rate | Yes | < 0.5% | blocker | eval_strategy.md |
| rag_unsupported_answer_rate | Yes | < 1% | blocker | eval_strategy.md |
| missed_complaint_signal_rate | Yes | < 5% | major | eval_strategy.md |
| missed_fraud_signal_rate | Yes | < 3% | blocker | eval_strategy.md |
| missed_vulnerability_signal_rate | Yes | < 5% | major | eval_strategy.md |

All 8 safety metrics present.

### 2.3 Voice Metrics

| Handoff Metric | Defined | Threshold | Gate | File |
|---------------|---------|-----------|------|------|
| word_error_rate_by_language | Yes | < 8% (EN), < 12% (other) | major | eval_strategy.md |
| word_error_rate_by_accent | Yes | < 15% | major | eval_strategy.md |
| intent_accuracy | Yes | > 92% | major | eval_strategy.md |
| slot_f1 | Yes | > 0.90 | major | eval_strategy.md |
| barge_in_success_rate | Yes | > 85% | minor | eval_strategy.md |
| turn_latency_p50_p95_p99 | Yes | p50 < 800ms, p95 < 1500ms, p99 < 3000ms | major | eval_strategy.md |
| tts_first_audio_latency | Yes | < 300ms | major | eval_strategy.md |
| conversation_repair_rate | Yes | > 70% | minor | eval_strategy.md |

All 8 voice metrics present.

### 2.4 Operational Metrics

| Handoff Metric | Defined | Threshold | Gate | File |
|---------------|---------|-----------|------|------|
| average_handle_time | Yes | < 4 min (simple), < 8 min (complex) | minor | eval_strategy.md |
| human_transfer_rate | Yes | < 25% (MVP) | minor | eval_strategy.md |
| human_rescue_rate | Yes | < 5% | major | eval_strategy.md |
| supervisor_approval_rate | Yes | tracked, no threshold | minor | eval_strategy.md |
| agent_after_call_work_reduction | **No** | - | - | - |
| system_uptime | Yes | > 99.9% | blocker | eval_strategy.md |
| provider_error_rate | Yes | < 1% | major | eval_strategy.md |
| fallback_rate | Yes | < 10% | major | eval_strategy.md |

7 of 8 operational metrics present. Missing: `agent_after_call_work_reduction`.

### 2.5 Economic Metrics

| Handoff Metric | Defined | Threshold | Gate | File |
|---------------|---------|-----------|------|------|
| cost_per_call | Yes | < $0.50 | minor | eval_strategy.md |
| cost_per_safe_resolution | Yes | < $0.65 | minor | eval_strategy.md |
| live_agent_minutes_saved | Yes | > 200 min | minor | eval_strategy.md |
| integration_maintenance_cost | Yes | tracked | minor | eval_strategy.md |
| fraud_loss_avoidance_proxy | Yes | tracked | minor | eval_strategy.md |
| qa_review_time_saved | **No** | - | - | - |

5 of 6 economic metrics present. Missing: `qa_review_time_saved`.

---

## 3. Release Gate Conditions (Handoff Section 20.4)

| Handoff Condition | Captured | Gate ID | File |
|------------------|----------|---------|------|
| Any blocker policy test fails | Yes | BG-S01 | release_gates.md |
| Any high-risk tool can execute without required authentication | Yes | BG-S02 | release_gates.md |
| RAG provides unsupported regulated answers above threshold | Yes | BG-S03 | release_gates.md |
| Fraud simulations fail for critical scenarios | Yes | BG-S06 | release_gates.md |
| Complaint detection fails for core complaint phrases | Yes | BG-C01 | release_gates.md |
| Human handoff does not preserve context | Yes | BG-O03 | release_gates.md |
| Audit events are incomplete | Yes | BG-C04 | release_gates.md |
| Rollback is not configured | Yes | BG-O02 | release_gates.md |
| Security review is missing for new connectors | **No** | - | - |

8 of 9 handoff release gate conditions captured. The missing condition ("Security review is missing for new connectors") is partially addressed through the eval_strategy.md approver matrix (line 168), which requires Security Review for connector config changes, but it is not formalized as a blocker gate in release_gates.md.

---

## 4. Eval Report Template (Handoff Section 20.5)

The eval report template in eval_strategy.md Section 5 is present and expands significantly on the handoff version. It adds:

- `environment` block (sandbox/staging, infra version, data snapshot)
- `errored` and `skipped` counts
- `gate_results` with structured pass/fail per gate type
- `conditions` with severity, remediation, and deadline
- `known_limitations` with risk assessment and mitigation
- `metric_summary` broken out by all five domains
- `comparison_to_previous` with improved/degraded tracking
- `bank_liaison` approval role
- Report provenance fields (generated_at, generated_by)

This is a quality improvement over the handoff template. Fully satisfactory.

---

## 5. Section 28 Quality Standards Compliance

| Required Field | eval_strategy.md | golden_call_suite.md | adversarial_tests.md | fraud_simulations.md | rag_evaluation.md | release_gates.md |
|---------------|:---:|:---:|:---:|:---:|:---:|:---:|
| Purpose (via Scope) | Yes | Yes | Yes | Yes | Yes | Yes |
| Scope | Yes | Yes | Yes | Yes | Yes | Yes |
| Assumptions | Yes | Yes | Yes | Yes | Yes | Yes |
| Decisions Made | Yes | Yes | Yes | Yes | Yes | Yes |
| Alternatives Considered | Yes | No | No | No | No | No |
| Risks | Yes | No | No | No | No | No |
| Open Questions | Yes | Yes | Yes | Yes | Yes | Yes |
| Source Links | Yes | Yes | Yes | Yes | Yes | Yes |
| Last Updated | Yes | Yes | Yes | Yes | Yes | Yes |
| Owner | Yes | Yes | Yes | Yes | Yes | Yes |

Five of six documents are missing "Alternatives Considered" and "Risks" header fields.

---

## 6. Cross-Reference Consistency

### 6.1 Tool Names in Test Scenarios vs. API Contracts

| Tool Name in Scenarios | Appears in tool_gateway_api.yaml | Consistent |
|----------------------|:---:|:---:|
| card.block | Yes (example in ToolDefinition) | Yes |
| card.order_replacement | Yes (example in ToolDefinition) | Yes |
| balance.read | Yes (example in ToolDefinition) | Yes |
| transactions.list | Implied (follows naming convention) | Yes |
| transactions.get | Implied (follows naming convention) | Yes |
| payment.initiate | Yes (example in policy_api.yaml) | Yes |
| dispute.create | Implied (follows naming convention) | Yes |
| account.update_address | Implied (follows naming convention) | Yes |

Tool naming is consistent with the dot-notation convention used throughout the architecture.

### 6.2 Authentication Levels in Test Scenarios vs. Handoff

| Scenario | Auth Used | Expected Auth | Match |
|----------|-----------|--------------|:---:|
| GP-LOST-001 | AUTH_2 | AUTH_2 (lost card = A3, requires KBA) | Yes |
| EC-LOST-001 | AUTH_0 | AUTH_0 (pre-auth scenario) | Yes |
| GP-BAL-001 | AUTH_2 | AUTH_2 (read-only = A1, requires KBA) | Yes |
| EC-BAL-001 | AUTH_0 | AUTH_0 (denial test) | Yes |
| GP-PAY-001 | AUTH_4 | AUTH_4 (payment = A5, requires OTP) | Yes |
| EC-PAY-002 | AUTH_2 | AUTH_2 (insufficient auth test) | Yes |
| GP-DIS-001 | AUTH_3 | AUTH_3 (dispute = A3, strong KBA/OTP) | Yes |
| GP-MAINT-001 | AUTH_3 | AUTH_3 (maintenance = A3) | Yes |
| ADV-TOOL-001 | AUTH_2 | AUTH_2 (wrong level test for payment) | Yes |

Authentication levels are consistent with the autonomy matrix and handoff specifications.

### 6.3 Autonomy Levels in Test Scenarios

| Workflow | Autonomy Used | Expected | Match |
|----------|-------------|----------|:---:|
| Lost/stolen card | A3 (act with confirmation) | A3 | Yes |
| Balance inquiry | A1 (inform, read-only) | A1 | Yes |
| Payment/transfer | A5 (human approval required) | A5 | Yes |
| Dispute/chargeback | A3 (act with confirmation) | A3 | Yes |
| Account maintenance | A3 (act with confirmation) | A3 | Yes |
| Account closure (ADV-TOOL-002) | A6 (prohibited) | A6 | Yes |

### 6.4 Cross-Document References

| From Document | References | Target Exists | Consistent |
|--------------|-----------|:---:|:---:|
| eval_strategy.md | golden_call_suite.md | Yes | Yes |
| eval_strategy.md | adversarial_tests.md | Yes | Yes |
| eval_strategy.md | fraud_simulations.md | Yes | Yes |
| eval_strategy.md | rag_evaluation.md | Yes | Yes |
| eval_strategy.md | release_gates.md | Yes | Yes |
| eval_strategy.md | evaluation_lab.md | Yes (architecture doc) | Yes |
| golden_call_suite.md | workflow_catalog.csv | Yes (architecture doc) | Yes |
| golden_call_suite.md | autonomy_matrix.md | Yes (architecture doc) | Yes |
| adversarial_tests.md | threat_model.md | Yes (architecture doc) | Yes |
| fraud_simulations.md | fraud_risk_framework.md | Yes (architecture doc) | Yes |
| rag_evaluation.md | knowledge_manager.md | Yes (architecture doc) | Yes |
| release_gates.md | eval_strategy.md | Yes | Yes |
| release_gates.md | operational_resilience.md | Yes (architecture doc) | Yes |

All cross-document references resolve correctly.

---

## 7. Detailed Findings

| ID | Severity | File | Finding | Required Action |
|----|----------|------|---------|-----------------|
| F-01 | HIGH | eval_strategy.md | Two metrics from Handoff Section 20.3 are missing: `agent_after_call_work_reduction` (operational) and `qa_review_time_saved` (economic). These metrics are listed in the handoff as required. A bank compliance team comparing the eval strategy against the handoff will flag this omission. | Add both metrics to their respective tables with definition, target (can be "tracked" initially), and gate severity. |
| F-02 | HIGH | release_gates.md | Handoff Section 20.4 lists "Security review is missing for new connectors" as a release gate condition. This is not captured as a blocker gate in release_gates.md. The eval_strategy.md approver matrix requires Security Review for connector changes, but approver requirements and hard gate conditions serve different purposes. A connector could theoretically be deployed without a formal security review if the approver matrix is bypassed. | Add a blocker gate (e.g., BG-S08) requiring security review sign-off for any release that introduces or modifies a bank connector. |
| F-03 | HIGH | golden_call_suite.md, adversarial_tests.md, fraud_simulations.md, rag_evaluation.md, release_gates.md | Five of six documents are missing the "Alternatives Considered" and "Risks" fields required by Section 28. Only eval_strategy.md includes both. For a bank CRO/CISO audience, consistent document structure across all deliverables matters. Incomplete headers will raise questions about documentation rigor. | Add "Alternatives Considered" and "Risks" to the header metadata of each of the five affected documents. Content should be specific, not boilerplate. |
| F-04 | MEDIUM | golden_call_suite.md | Only 1 explicit compliance scenario (CO-LOST-001) is defined. While compliance assertions are embedded within some golden path scenarios (e.g., GP-DIS-001 includes compliance_disclosure), the handoff treats "Compliance script tests" as a distinct suite category (item 8). A bank compliance team would expect dedicated scenarios for each workflow's regulatory disclosure requirements, not just for lost card. | Add at least one compliance scenario per workflow where regulatory disclosures are required (payments, disputes, account changes). |
| F-05 | MEDIUM | golden_call_suite.md | The golden call suite contains 22 scenarios total. While adequate for MVP, the document itself acknowledges a GA target of 200+. For the dispute/chargeback workflow, there is only 1 scenario (GP-DIS-001). No edge cases for disputes (e.g., dispute after chargeback deadline, dispute on a pending transaction, dispute on recurring payment). | Add at least 2-3 edge case scenarios for the dispute workflow before pilot launch. |
| F-06 | MEDIUM | fraud_simulations.md | No "Synthetic identity fraud" or "Mule account activity" scenarios are defined, despite both categories appearing in the fraud category taxonomy (Section 1). The taxonomy promises these categories but delivers no test scenarios for them. | Either add at least one scenario per category or explicitly defer them with a justification note (e.g., "deferred to GA; requires bank-specific transaction history data"). |
| F-07 | MEDIUM | rag_evaluation.md | The citation accuracy dimension is defined in the metrics table (Section 6, target > 98%) but no dedicated test scenarios exercise citation accuracy. Faithfulness tests check whether claims are grounded, but they don't verify that the AI correctly attributes its answer to the specific source document. | Add 2-3 citation accuracy scenarios that verify the AI's source attribution matches the actual document used. |
| F-08 | MEDIUM | release_gates.md | The latency budget table (Section 4.2) sums to 1650ms for no-tool-call and 2150ms for tool-call turns at p95. The metric threshold in eval_strategy.md defines p95 < 1500ms. The budget exceeds the threshold by 150ms (no tool call) and 650ms (with tool call). This inconsistency will confuse implementers. | Reconcile the latency budget with the metric threshold. Either adjust the p95 target to match the budget analysis, or optimize the budget to fit within 1500ms. Document the distinction between the budget (theoretical ceiling) and the metric threshold (measured target) if they are intentionally different. |
| F-09 | MEDIUM | adversarial_tests.md | The document covers OWASP LLM Top 10 categories partially but does not explicitly map scenarios to OWASP categories. For a security-focused audience (CISO), showing which OWASP LLM risk each scenario covers, and which risks remain uncovered at MVP, would strengthen the deliverable. | Add an OWASP LLM Top 10 coverage matrix as an appendix, mapping each scenario to the relevant OWASP category. |
| F-10 | MEDIUM | eval_strategy.md | The approver matrix (Section 4.2) lists role titles (Graph Designer Lead, Compliance Review, ML Lead, etc.) but these roles are not defined in this document or cross-referenced to a roles/RACI document. A bank reviewing the evidence pack may question who fills these roles. | Either define each approver role briefly in this document or add a cross-reference to the document where these roles are defined. |
| F-11 | LOW | golden_call_suite.md | Accent/language scenarios (AL-001 through AL-003) cover Scottish English, Indian English, and elderly speech patterns. No scenarios for Welsh English, Nigerian English, Caribbean English, or non-English languages (despite the eval_strategy.md referencing "supported non-English languages" and WER targets for "others"). | Add non-English language scenarios for at least one supported language before pilot, or explicitly note that non-English support is deferred to GA. |
| F-12 | LOW | adversarial_tests.md | The deepfake scenarios (ADV-DF-001, ADV-DF-002) are severity:major with a note explaining that VocalIQ's core defense is multi-factor auth, not voice biometrics. This is pragmatic and defensible, but the eval_strategy.md suite taxonomy table marks deepfake tests as severity:major while all other adversarial tests are blocker. A bank CISO may question why voice spoofing is treated as lower priority than other attack vectors. | Add an explicit rationale note in the eval_strategy.md suite taxonomy table explaining why deepfake tests are major rather than blocker. The reasoning in adversarial_tests.md is sound but should also appear where the severity is assigned. |
| F-13 | LOW | release_gates.md | The post-release monitoring table (Section 7) monitors "Fraud signal miss rate" with a 15-minute interval. This is a derived metric that requires comparing fraud outcomes against signals. The document does not explain how this metric is computed in near-real-time during the 24-hour monitoring window when ground truth (confirmed fraud vs. false alarm) is not yet available. | Add a note explaining that the 24h monitoring uses a proxy measure (e.g., known fraud patterns from simulation data replayed against live traffic) or clarify that this metric is only computed retrospectively. |
| F-14 | LOW | fraud_simulations.md | The fraud detection signal matrix (Section 6) includes "Behavioral anomaly (unusual call time, location)" as a signal tested "All scenarios," but no specific scenario actually exercises this signal with explicit assertions. It is a residual signal rather than a tested one. | Either add a dedicated scenario that tests behavioral anomaly detection or change the "Tested In" column to "implicit/background signal" for clarity. |
| F-15 | LOW | eval_strategy.md | The test scenario definition format (Section 6) includes `scenario_type: scripted | ai_caller | adversarial | load` but the companion documents only use scripted and adversarial types. No AI caller scenarios are defined at MVP. The format supports it, but there are no examples. | This is acceptable for MVP. Add a note that AI caller scenarios will be introduced at GA for exploratory coverage. |

---

## 8. Specificity and Actionability Check

The evaluation documents avoid the vague language that Section 28 warns against. Scenarios include concrete utterance sequences, specific tool call expectations, named authentication levels, and quantified thresholds. The fraud simulations are grounded in real-world fraud typologies (ATO, APP scam, impersonation scam) with plausible caller dialogue. The RAG evaluation tests reference specific document names, content excerpts, and exact values to match against. The release gates use numeric thresholds throughout, not qualitative language.

One area where specificity could improve: the compliance scenarios would benefit from actual regulatory text (FCA DISP rules, PSR requirements) rather than generic compliance references. This is captured in F-04.

---

## 9. Verdict

**PASS**

The evaluation plan deliverables are substantively complete, internally consistent, and specific enough for a bank-grade deployment. All 14 evaluation suites from the handoff are accounted for. The vast majority of metrics, release gates, and quality standard requirements are met. The three HIGH findings (missing metrics, missing connector security gate, missing document header fields) are real gaps that should be addressed before presenting to a bank audience, but none represent architectural or structural deficiencies. The deliverables demonstrate a mature understanding of what banks expect from an evaluation evidence pack.
