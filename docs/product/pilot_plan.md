# Bank Pilot Plan

**Document ID:** DOC_PROD_PP_001  
**Last Updated:** 2026-05-04  
**Owner:** Chief Product Officer

**Version History:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-04 | Initial specification |

**Principles Referenced:** S1 (Human cannot be harmed by AI action), E5 (Test at policy boundary), E7 (Document decisions), G7 (Prohibited actions cannot be unlocked)

**Scope:** Defines the structure, success criteria, operational procedures, and rollback mechanisms for VocalIQ's first bank pilot deployment. Covers pilot scope, customer selection criteria, operational model, monitoring and escalation procedures, success measurement, evidence pack requirements, and the decision framework for progressing from pilot to production.

**Assumptions:** The pilot deploys with a single design partner bank in a single jurisdiction. The pilot operates during the bank's standard business hours initially, expanding to 24/7 after the first two weeks if safety metrics are sustained. Human agents are always available for escalation. The bank's contact center team is trained on the Control Center before pilot start.

**Decisions Made:** The pilot uses a controlled traffic ramp (not a sudden cutover). Traffic starts at 5% of eligible calls and increases based on safety metric performance. The pilot has a pre-defined rollback trigger that automatically removes VocalIQ from the call flow if safety thresholds are breached. The pilot must produce a formal evidence pack at completion that is sufficient for the bank's risk committee to approve broader deployment.

**Alternatives Considered:** Considered a shadow-mode pilot where VocalIQ listens but doesn't respond (rejected: doesn't test the actual customer interaction, which is the primary risk surface). Considered full cutover from day one (rejected: too risky for a first deployment). Considered running the pilot without bank-side approvals first (rejected: bank must approve before any customer interaction).

**Risks:** Pilot customers may have a worse experience than with human agents, creating reputational risk for both VocalIQ and the bank. The bank's internal champion may leave during the pilot, stalling the decision process. Edge cases not covered by MVP workflows may appear at higher rates than expected, inflating the human transfer rate. The pilot may succeed technically but fail commercially if the ROI case is not compelling.

**Source Links:** Handoff Sections 22-25, mvp_scope.md, roadmap.md, eval_strategy.md, release_gates.md.

---

## 1. Pilot Structure

### 1.1 Pilot Parameters

| Parameter | Value |
|-----------|-------|
| Duration | 8-12 weeks (minimum 8 weeks for statistical validity) |
| Target call volume | 5,000-15,000 calls total |
| Traffic ramp | 5% -> 15% -> 30% -> 50% of eligible calls (weekly step-up based on metrics) |
| Operating hours | Business hours initially, expanding to 24/7 after Week 2 |
| Workflows | All 8 MVP workflows (mvp_scope.md Section 2.1) |
| Customer segment | Retail banking customers calling the general enquiry line |
| Exclusions | Business banking, private banking, customers flagged as vulnerable in the bank's CRM |
| Human fallback | Always available, < 30 second transfer time |
| Expected peak concurrent sessions | 20-50 (at 50% traffic ramp, based on design partner call volume). Infrastructure tested at 200 concurrent sessions per mvp_scope.md load test requirement. |
| Language | English only |

### 1.2 Traffic Ramp Schedule

| Week | Traffic % | Gate to Proceed |
|------|----------|----------------|
| 1-2 | 5% | safe_resolution_rate > 99.5%, zero policy violations, zero unauthorized disclosures |
| 3-4 | 15% | Same safety gates + human_transfer_rate < 45% |
| 5-6 | 30% | Same safety gates + human_transfer_rate < 40% + task_completion_rate > 45% |
| 7-8 | 50% | Same safety gates + task_completion_rate > 50% |
| 9-12 | 50% (sustained) | Sustained metric performance for exit criteria |

Traffic percentage increases are not automatic. Each step-up requires a review of the previous period's metrics by the joint VocalIQ-bank pilot review committee.

### 1.3 Eligible Call Routing

Not all calls are eligible for VocalIQ handling. The bank's IVR or ACD routes calls to VocalIQ based on:

| Criterion | Rule |
|-----------|------|
| Caller intent (IVR selection) | Only intents mapped to MVP workflows |
| Customer segment | Retail personal banking only |
| Language | English only (detected by IVR language selection) |
| Vulnerability flag | Customers flagged as vulnerable in CRM are routed to human agents |
| Previous VocalIQ interaction | If the caller's last VocalIQ interaction resulted in a complaint, route to human |

---

## 2. Pre-Pilot Requirements

### 2.1 Bank-Side Requirements

| Requirement | Owner | Status Tracking |
|-------------|-------|----------------|
| Internal risk committee approval for pilot | Bank Risk/Compliance | Approval document signed |
| Data processing agreement (DPA) signed | Bank Legal + VocalIQ Legal | Contract executed |
| SIP trunk or telephony integration configured and tested | Bank IT + VocalIQ Engineering | Integration test report |
| Core banking API access provisioned (sandbox + production) | Bank IT | API credentials and connectivity confirmed |
| Contact center agent training on Control Center | Bank Operations + VocalIQ Product | Training completion log |
| Customer communication prepared (if required by regulation) | Bank Compliance | Communication approved and sent |
| Complaint handling process for AI-handled calls defined | Bank Operations + Compliance | Process document signed off |
| Escalation contacts identified (technical and business) | Bank + VocalIQ | Contact list documented |
| Rollback procedure tested | Bank IT + VocalIQ Engineering | Rollback test report |

### 2.2 VocalIQ-Side Requirements

| Requirement | Owner | Status Tracking |
|-------------|-------|----------------|
| All blocker release gates pass | QA/Evaluation | Evaluation report |
| Evidence pack generated and reviewed by bank | Product + QA | Bank review confirmation |
| Production environment deployed and smoke-tested | Infrastructure | Deployment verification report |
| Monitoring and alerting configured | Infrastructure | Alert test results |
| On-call rotation established | Engineering | On-call schedule published |
| Incident response runbook written and tested | Engineering + Product | Runbook tabletop exercise completed |
| Bank connector tested against production API (read-only) | Engineering | Connector test report |
| Knowledge base loaded with bank-specific documents | NLP/Content | Knowledge base review by bank compliance |
| Fraud detection weights calibrated for bank's risk profile | Fraud/Risk | Calibration report |

---

## 3. Operational Model

### 3.1 Monitoring Structure

| Level | Who | What They Monitor | Response Time |
|-------|-----|-------------------|---------------|
| Real-time | VocalIQ on-call engineer | System health, error rates, latency, automatic rollback triggers | < 5 minutes |
| Session-level | Bank supervisors (Control Center) | Live calls, whisper/takeover decisions, flagged sessions | Real-time during operating hours |
| Daily | VocalIQ + bank ops team | Daily metrics report, flagged call review, false positive review | Morning standup |
| Weekly | Joint pilot review committee | Weekly metrics, trend analysis, incident review, ramp decision | Weekly review meeting |

### 3.2 Incident Classification

| Severity | Definition | Response | VocalIQ Action | Bank Action |
|----------|-----------|----------|----------------|-------------|
| S1 - Critical | Safety metric breach (unauthorized disclosure, policy violation, missed critical fraud signal) | Immediate | Automatic rollback triggers. On-call investigates root cause. Customer impact assessment. | Pause pilot traffic. Review affected calls. Customer remediation if needed. |
| S2 - Major | System outage affecting call handling, sustained latency degradation, fraud false negative on non-critical signal | 30 minutes | On-call diagnoses and resolves. Consider traffic reduction. | Route all calls to human agents until resolved. |
| S3 - Minor | Individual call failure, non-critical bug, UI issue in Control Center | 4 hours | Logged, prioritized for fix in next release. | No customer impact; noted for review. |
| S4 - Cosmetic | Wording improvement, UI polish, non-functional enhancement | Next sprint | Backlogged. | Noted, no action required. |

### 3.3 Daily Metrics Report

Every morning, the VocalIQ pilot team produces a report covering the previous 24 hours:

| Metric | Content |
|--------|---------|
| Call volume | Total calls handled by VocalIQ, by workflow |
| Safety metrics | unauthorized_disclosure_rate, policy_violation_rate, hallucinated_answer_rate (all should be 0%) |
| Containment | task_completion_rate, human_transfer_rate, customer_abandonment_rate |
| Quality | Flagged calls count, false positive count, complaint count |
| Performance | turn_latency p50/p95/p99, system uptime, provider error rate |
| Incidents | Any S1/S2 incidents, resolution status |
| Fraud | Fraud signals detected, escalations triggered |

### 3.4 Weekly Review Meeting

The joint VocalIQ-bank pilot review committee meets weekly. Agenda:

1. Metrics review (week-over-week trend)
2. Incident review (any S1/S2 incidents, root cause, resolution)
3. Flagged call review (sample of 10-20 flagged calls reviewed together)
4. Customer feedback (any complaints or positive feedback attributed to VocalIQ calls)
5. Ramp decision (increase, maintain, or decrease traffic percentage)
6. Open issues and action items

---

## 4. Rollback Procedures

### 4.1 Automatic Rollback Triggers

These conditions trigger immediate, automatic removal of VocalIQ from the call flow. No human approval is required.

| Trigger | Threshold | Mechanism |
|---------|----------|-----------|
| Unauthorized disclosure detected | Any occurrence | IVR routing updated to bypass VocalIQ. All new calls go to human agents. |
| Policy violation rate | > 0% over 15-minute window | Same as above |
| System error rate | > 5% for 5 consecutive minutes | Same as above |
| Turn latency p99 | > 10 seconds for 5 consecutive minutes | Same as above |
| Multiple concurrent S1 incidents | 2+ within 1 hour | Same as above |

Active calls at the time of rollback are transferred to human agents with full context (transfer package).

### 4.2 Manual Rollback

Either VocalIQ or the bank can trigger a manual rollback at any time for any reason. The process:

1. Authorized contact (from either side) sends rollback request through the agreed channel.
2. VocalIQ on-call engineer initiates the rollback within 15 minutes.
3. IVR routing is updated to bypass VocalIQ.
4. Active calls complete naturally or transfer to human agents.
5. Rollback event is logged in the audit ledger.
6. Both teams are notified.
7. Post-rollback review is scheduled within 24 hours.

### 4.3 Rollback Recovery

After a rollback, VocalIQ cannot be reinstated until:

1. Root cause of the rollback trigger is identified and documented.
2. Fix is implemented and passes evaluation gates.
3. Joint review committee approves reinstatement.
4. Traffic resumes at 5% regardless of previous ramp level.

---

## 5. Evidence Pack

The pilot evidence pack is the primary deliverable for the bank's risk committee. It must be sufficient for the committee to approve broader deployment without requiring additional technical investigation.

### 5.1 Evidence Pack Contents

| Section | Content | Source |
|---------|---------|--------|
| Executive summary | Pilot scope, duration, call volume, headline metrics | Product team |
| Safety record | Complete safety metrics for entire pilot period. Zero-tolerance metrics (disclosure, policy violation) with evidence of zero occurrences. | Evaluation Lab |
| Call quality analysis | Task completion rate, containment rate, human transfer rate, abandonment rate, repeat call rate | Evaluation Lab + Analytics |
| Fraud detection record | Fraud signals detected, escalations triggered, false positive rate, fraud outcome correlation (where available) | Fraud/Risk team |
| Compliance record | Complaint handling compliance, regulatory disclosure delivery rate, audit completeness | Compliance review |
| Incident history | All S1/S2 incidents with root cause, resolution, and preventive action | Engineering |
| Evaluation reports | Pre-deployment evaluation report and any mid-pilot re-evaluations | Evaluation Lab |
| Audit trail sample | Sample of 50 complete audit trails showing end-to-end event sequences | Audit Ledger |
| System performance | Uptime, latency, error rates, load handling | Infrastructure |
| Customer feedback | Complaint count, NPS delta (if measurable), qualitative feedback | Bank operations |
| ROI analysis | Cost per call, agent minutes saved, projected annualized savings | Product + Bank operations |
| Rollback readiness | Rollback test results, rollback recovery procedures | Engineering |
| Risk assessment | Residual risks, known limitations, and mitigation plan for broader deployment | Product + Risk |
| Recommendations | Recommended next steps: expand workflows, increase traffic, deploy to additional segments | Product |

### 5.2 Evidence Pack Format

The evidence pack is delivered as a structured document with appendices. Each section includes the raw data, the analysis, and the conclusion. Metrics are presented with confidence intervals where sample sizes allow.

---

## 6. Success Criteria

### 6.1 Pilot Success (Minimum Bar)

The pilot is considered successful if all of the following are met at the end of the pilot period:

| Criterion | Threshold |
|-----------|----------|
| Pilot completed without permanent rollback | Yes |
| Zero S1 incidents resulting in actual customer harm | Zero |
| unauthorized_disclosure_rate | 0% for entire pilot |
| policy_violation_rate | 0% for entire pilot |
| hallucinated_answer_rate | < 0.5% |
| missed_fraud_signal_rate | < 3% |
| task_completion_rate | > 50% |
| human_transfer_rate | < 40% |
| system_uptime | > 99.5% |
| audit_completeness | 100% (every call produces a complete audit trail) |
| Minimum call volume | > 5,000 calls |
| Bank risk team signoff | Written approval |

### 6.2 Pilot Excellence (Target Bar)

These are stretch targets that strengthen the case for rapid expansion:

| Criterion | Threshold |
|-----------|----------|
| task_completion_rate | > 65% |
| human_transfer_rate | < 30% |
| customer_satisfaction_proxy | > 3.5/5.0 |
| cost_per_call | < $0.50 |
| repeat_call_rate | < 15% |
| agent_after_call_work_reduction | > 30% |
| Bank requests additional workflows | Yes |

### 6.3 Pilot Failure Criteria

The pilot is terminated early if any of the following occur:

| Criterion | Action |
|-----------|--------|
| Unauthorized customer data disclosure | Immediate rollback. Incident report to bank. Regulatory notification if required. |
| 3+ S1 incidents in any 7-day period | Pilot paused. Root cause analysis required before restart. |
| Bank risk team withdraws approval | Pilot terminated. Post-mortem scheduled. |
| task_completion_rate < 30% after 4 weeks | Pilot paused. Workflow and graph tuning required before restart. |
| Sustained system instability (uptime < 95% over any 7-day period) | Pilot paused. Infrastructure stabilization required. |

---

## 7. Customer Communication

### 7.1 Disclosure Requirements

Depending on the jurisdiction and the bank's regulatory interpretation, customers may need to be informed that they are interacting with an AI agent. VocalIQ supports configurable disclosure at the start of each call:

| Jurisdiction | Typical Requirement | VocalIQ Implementation |
|-------------|-------------------|----------------------|
| UK (FCA) | Consumer Duty requires clear communication. AI disclosure recommended but not yet mandated for voice. | Configurable opening disclosure: "You're speaking with our AI assistant. A human agent is available if you'd prefer." |
| Singapore (MAS) | FEAT principles require transparency in AI-driven decisions. | Same configurable disclosure. Additional disclosure before any AI-assisted financial action. |
| EU (AI Act) | High-risk AI systems require user notification of AI interaction. | Mandatory disclosure at call start. Cannot be disabled. |

### 7.2 Opt-Out

Customers can opt out of AI interaction at any point during the call by saying "I want to speak to a human" or pressing a DTMF key (configurable, default: 0). The system transfers immediately without resistance or persuasion (tested in golden call scenario HO-001).

---

## 8. Bank Team Training

### 8.1 Training Curriculum

| Audience | Content | Duration |
|----------|---------|----------|
| Contact center supervisors | Control Center operation: live monitoring, whisper mode, takeover, session replay, transfer queue management | 4 hours + 2 hours hands-on |
| Contact center agents | What VocalIQ does, when calls transfer to them, how to receive transfer packages, how to handle customer questions about the AI | 2 hours |
| Risk/compliance team | Architecture overview, safety controls, audit trail walkthrough, evidence pack structure | 3 hours |
| IT/operations team | Deployment architecture, monitoring dashboards, rollback procedures, incident escalation | 3 hours |
| Executive sponsor | Product overview, pilot structure, success criteria, decision points | 1 hour |

### 8.2 Training Delivery

Training is delivered in person or via video call during the two weeks before pilot launch. VocalIQ provides training materials, sandbox access for hands-on practice, and a recorded session for team members who cannot attend live.

---

## 9. Post-Pilot Decision Framework

At the end of the pilot, the joint review committee makes one of four decisions:

| Decision | Criteria | Next Step |
|----------|---------|-----------|
| Expand to production | All success criteria met. Evidence pack approved. | Increase traffic to 100% for pilot workflows. Begin adding new workflows. |
| Extend pilot | Success criteria partially met. More data needed. | Continue pilot for 4 additional weeks. Adjust workflows or traffic. |
| Pivot scope | Safety criteria met but containment or ROI targets not met. | Redefine workflow set or customer segment. Restart ramp from 5%. |
| Terminate | Safety criteria not met or bank withdraws support. | Full rollback. Post-mortem. Remediation plan. |

---

## 10. Open Questions

1. Does the bank require customer consent before routing to VocalIQ, or is a disclosure at the start of the call sufficient? The answer affects IVR design and call routing logic.

2. How will the bank measure customer satisfaction for AI-handled calls? If the bank uses post-call surveys, VocalIQ can trigger them. If the bank uses other methods, integration may be needed.

3. What is the bank's process for approving AI-generated content in regulated communications (e.g., the complaint acknowledgment letter that VocalIQ drafts)? This may require a separate approval workflow.

4. Should the pilot include a control group (similar calls handled by human agents during the same period) for direct comparison? This strengthens the ROI analysis but adds operational complexity.

5. What happens to call recordings and transcripts after the pilot ends? The data retention agreement must cover pilot data lifecycle.
