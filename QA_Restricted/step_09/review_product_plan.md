# QA Review: Step 9 MVP and Pilot Plan

**Review ID:** QA-STEP09-001
**Date:** 2026-05-04
**Reviewer:** QA Agent (Independent)
**Scope:** Review of 4 product plan documents (mvp_scope.md, roadmap.md, pilot_plan.md, pricing_and_gtm.md)

---

## Document Structure Check

| Field | mvp_scope.md | roadmap.md | pilot_plan.md | pricing_and_gtm.md |
|-------|-------------|-----------|--------------|-------------------|
| Document ID | PASS | PASS | PASS | PASS |
| Last Updated | PASS | PASS | PASS | PASS |
| Owner | PASS | PASS | PASS | PASS |
| Version History | PASS | PASS | PASS | PASS |
| Principles Referenced | PASS | PASS | PASS | PASS |
| Scope | PASS | PASS | PASS | PASS |
| Assumptions | PASS | PASS | PASS | PASS |
| Decisions Made | PASS | PASS | PASS | PASS |
| Alternatives Considered | PASS | PASS | PASS | PASS |
| Risks | PASS | PASS | PASS | PASS |
| Source Links | PASS | PASS | PASS | PASS |
| Open Questions | PASS | PASS | PASS | PASS |

All four documents pass the structural header check. Every required metadata field is present and populated with substantive content. The Alternatives Considered sections are genuinely useful, not filler.

---

## Cross-Document Consistency

### 1. MVP Metrics vs. eval_strategy.md Metrics

**task_completion_rate mismatch (FINDING F-01):**
mvp_scope.md Section 6 sets MVP target at > 50%. eval_strategy.md Section 3.1 sets it at > 75% (MVP). These contradict each other. The mvp_scope target of 50% is the more realistic number for a first pilot, and pilot_plan.md Section 6.1 also uses > 50%, but eval_strategy.md's label "(MVP)" next to the 75% figure creates confusion about what the actual MVP gate is.

**human_transfer_rate mismatch (FINDING F-02):**
mvp_scope.md Section 6 sets MVP target at < 40%. eval_strategy.md Section 3.4 sets it at < 25% (MVP) and classifies it as gate severity "minor." The mvp_scope and pilot_plan documents align with each other at < 40%, but eval_strategy.md uses a stricter 25% threshold. The gate severity also creates an inconsistency: if human_transfer_rate is only a "minor" gate in eval_strategy.md, it shouldn't be a pilot success criterion driving ramp decisions in pilot_plan.md (where it's used as a gate at weeks 3-6).

**turn_latency_p95 mismatch (FINDING F-03):**
mvp_scope.md Section 6 targets < 2000ms for p95. eval_strategy.md Section 3.3 targets p95 < 1500ms. release_gates.md Section 4.2 explains this gap (component budget ceiling of 1650ms vs. observed target of 1500ms), but mvp_scope.md uses yet a third number (2000ms) without referencing the distinction. The pilot should be clear about which number is the actual gate.

**safe_resolution_rate:** Consistent at > 99.5% across mvp_scope.md, eval_strategy.md, and pilot_plan.md. No issue.

**Zero-tolerance metrics:** unauthorized_disclosure_rate (0%), policy_violation_rate (0%) are consistent everywhere. No issue.

**hallucinated_answer_rate:** Consistent at < 0.5% across documents. No issue.

**missed_fraud_signal_rate:** Consistent at < 3% across documents. No issue.

**system_uptime mismatch (FINDING F-04):**
mvp_scope.md Section 6 sets MVP target at > 99.5%. eval_strategy.md Section 3.4 sets it at > 99.9% as a blocker gate, with no MVP-specific relaxation noted. release_gates.md Section 2.3 (BG-O01) also uses 99.9%. The pilot_plan.md Section 6.1 uses > 99.5%. If the release gate blocker is 99.9% but the pilot success criterion is 99.5%, the documents are measuring different things (release candidate uptime vs. sustained pilot uptime), which should be made explicit.

### 2. MVP Workflows vs. autonomy_matrix.md Levels

mvp_scope.md maps workflows to autonomy levels A0, A2, A3, and A4. Cross-checking against autonomy_matrix.md:

- Branch/ATM locator and FAQ: A0 -- matches autonomy_matrix.md (UC-001/002 are A0).
- Balance and transaction inquiry: A2 -- matches (UC-005).
- Complaint intake: A3 -- matches (UC-007).
- Lost/stolen card: A4 -- matches (UC-008).
- Card activation: A4 -- matches (UC-009).
- Statement request: A4 -- matches (UC-010).
- Payment to existing payee: A4 -- consistent with A4 controlled execution for pre-registered payees.
- Direct debit cancellation: A4 -- consistent.

No autonomy level inconsistencies found. The MVP correctly avoids A5 and A6 workflows.

### 3. Pilot Success Criteria vs. release_gates.md Gates

pilot_plan.md Section 6.1 success criteria align with the blocker gates in release_gates.md for zero-tolerance items (BG-S01 through BG-S06, BG-C01 through BG-C04). The pilot adds additional success criteria (minimum call volume, pilot duration, bank signoff) that are appropriately pilot-specific and don't conflict with release gates.

The automatic rollback triggers in pilot_plan.md Section 4.1 are consistent with release_gates.md Section 6.1 rollback triggers. Both use the same thresholds for unauthorized disclosure, policy violation, error rate, and latency.

### 4. Roadmap Phases vs. Handoff Section 22

roadmap.md phases match handoff Section 22 structure:
- Phase 0 (Research): matches.
- Phase 1 (Technical spike): matches. roadmap.md expands the build list and adds exit criteria.
- Phase 2 (MVP platform): matches. roadmap.md adds workstream breakdown and team sizing.
- Phase 3 (Bank pilot): matches.
- Phase 4 (Enterprise hardening): matches. roadmap.md adds prioritized timeline.

The handoff lists "Graph designer or graph management UI" in Phase 2, while roadmap.md defers the visual graph designer to Phase 4 and uses CLI/API for MVP. mvp_scope.md Section 5.2 explicitly lists "Visual graph designer (CLI/API is sufficient for MVP)" as not required. This is a defensible decision that's clearly documented. No issue.

### 5. Pricing vs. market_map.md Competitor Data

pricing_and_gtm.md Section 3.6 references competitor pricing. Spot-checking against market_map.md:
- Retell AI per-minute pricing ($0.07-$0.20/min): market_map.md confirms Retell's per-minute model.
- PolyAI annual license ($200K-$1M+): market_map.md confirms PolyAI's enterprise pricing.
- GetVocal not publicly disclosed: market_map.md also notes limited pricing transparency for GetVocal.

Pricing references are consistent where verifiable.

---

## Completeness Check

### mvp_scope.md

| Required Element | Status | Notes |
|-----------------|--------|-------|
| Included workflows | PASS | 8 workflows with autonomy levels, volume, risk, rationale |
| Excluded workflows | PASS | 9 excluded with clear reasons (A6 prohibited vs. deferred) |
| Platform components | PASS | All 12 components listed with MVP maturity level |
| Integration scope | PASS | Bank connectors, model providers, deployment assumptions |
| Exit criteria | PASS | 8 specific exit criteria |
| Timeline | PASS | 4-phase timeline with durations |
| Success metrics | PASS | 10 metrics with MVP and GA targets |
| Workflow-to-component mapping | PASS | Table mapping workflows to dependencies |

### roadmap.md

| Required Element | Status | Notes |
|-----------------|--------|-------|
| All 4 phases | PASS | Phases 1-4 fully specified, Phase 0 referenced as complete |
| Build scope per phase | PASS | Detailed component-level scope |
| Exit criteria per phase | PASS | Measurable criteria for each phase |
| Team requirements | PASS | Headcount and roles per phase |
| Risks | PASS | Risk register with likelihood, impact, mitigation |
| Technology decisions | PASS | Deferred decisions documented with resolution criteria |

### pilot_plan.md

| Required Element | Status | Notes |
|-----------------|--------|-------|
| Pilot structure | PASS | Parameters, traffic ramp, eligible call routing |
| Pre-requisites | PASS | Bank-side and VocalIQ-side requirements |
| Operational model | PASS | Monitoring, incident classification, daily reports, weekly reviews |
| Rollback procedures | PASS | Automatic triggers, manual process, recovery procedure |
| Evidence pack | PASS | 14-section evidence pack structure |
| Success criteria | PASS | Minimum bar, excellence bar, and failure criteria |
| Customer communication | PASS | Disclosure requirements by jurisdiction, opt-out |
| Training plan | PASS | Five audience segments with content and duration |
| Post-pilot decision framework | PASS | Four decision paths |

### pricing_and_gtm.md

| Required Element | Status | Notes |
|-----------------|--------|-------|
| Positioning | PASS | Core statement, differentiation table |
| Target segments | PASS | 5 priority segments, 3 segments to avoid, buyer map |
| Pricing model | PASS | 4-component pricing, tiers, usage fees, integration packages |
| Design partner program | PASS | Structure, selection criteria, pitch |
| Sales evidence | PASS | Collateral requirements, demo environment |
| GTM timeline | PASS | 12-month timeline, Year 2 channel strategy |
| Competitive response | PASS | Playbook against 4 competitor categories |

---

## Findings

### F-01: task_completion_rate MVP target inconsistency
**Severity:** HIGH
**File:** mvp_scope.md Section 6 vs. eval_strategy.md Section 3.1
**Description:** mvp_scope.md and pilot_plan.md set the MVP target at > 50%, but eval_strategy.md labels its > 75% target as "(MVP)" in the same metric row. A bank risk team reading both documents will see contradictory MVP targets for the same metric. This is not just a documentation issue; it affects what the evaluation lab actually gates on.
**Recommendation:** Align eval_strategy.md to use > 50% as the MVP/pilot target and > 75% as the GA target, matching mvp_scope.md and pilot_plan.md. Alternatively, add an explicit note in eval_strategy.md that the "(MVP)" label refers to post-pilot production targets, not the pilot itself.

### F-02: human_transfer_rate MVP target inconsistency
**Severity:** HIGH
**File:** mvp_scope.md Section 6 vs. eval_strategy.md Section 3.4
**Description:** mvp_scope.md and pilot_plan.md set this at < 40%. eval_strategy.md sets it at < 25% and labels it "(MVP)." Additionally, eval_strategy.md classifies it as gate severity "minor," but pilot_plan.md uses it as a ramp gate (weeks 3-6 require < 45% then < 40% to proceed). A metric can't be a "minor" gate in the eval framework and simultaneously a ramp-blocking gate in the pilot.
**Recommendation:** Set eval_strategy.md MVP target to < 40% to match the other documents. Elevate the gate severity from "minor" to "major" if it's being used as a pilot ramp gate, or clarify that pilot ramp gates are separate from release gates.

### F-03: turn_latency_p95 uses three different numbers
**Severity:** MEDIUM
**File:** mvp_scope.md Section 6, eval_strategy.md Section 3.3, release_gates.md Section 4.2
**Description:** Three different p95 latency targets appear: 2000ms (mvp_scope.md), 1500ms (eval_strategy.md), and 1650ms component budget ceiling (release_gates.md). release_gates.md does explain the distinction between component budget and observed target, but mvp_scope.md's 2000ms doesn't fit into either framework.
**Recommendation:** mvp_scope.md should use 1500ms as the p95 target (matching eval_strategy.md) and note the 2000ms as a relaxed pilot-period tolerance if that's the intent. Cross-reference release_gates.md Section 4.2 for the component budget breakdown.

### F-04: system_uptime MVP target vs. blocker gate
**Severity:** MEDIUM
**File:** mvp_scope.md Section 6 vs. release_gates.md Section 2.3
**Description:** mvp_scope.md and pilot_plan.md target > 99.5% uptime. release_gates.md BG-O01 sets the blocker gate at 99.9% during evaluation runs. These measure different windows (pilot sustained uptime vs. evaluation run uptime), but neither document makes this distinction explicit. A reader could reasonably conclude that the pilot would fail the blocker gate at 99.5% uptime.
**Recommendation:** Add a clarifying note in mvp_scope.md that the 99.5% target applies to sustained pilot operating hours, while the 99.9% blocker gate applies to individual evaluation runs. Alternatively, add this distinction to release_gates.md.

### F-05: eval_strategy.md containment_rate_without_repeat metric not referenced in MVP docs
**Severity:** LOW
**File:** eval_strategy.md Section 3.1 vs. mvp_scope.md
**Description:** eval_strategy.md defines containment_rate_without_repeat (> 65% MVP, major gate) and repeat_call_rate (< 15%, major gate). Neither metric appears in mvp_scope.md's success metrics table. These are meaningful metrics for a pilot but their absence from the MVP scope could mean they're intentionally deferred or accidentally omitted.
**Recommendation:** Either add these metrics to mvp_scope.md Section 6 with MVP targets, or explicitly note they are tracked but not gating for the pilot.

### F-06: Pricing document references "fintechs with regulated servicing operations" from handoff but doesn't include them
**Severity:** LOW
**File:** pricing_and_gtm.md Section 2.1 vs. handoff Section 23.2
**Description:** Handoff Section 23.2 lists "Fintechs with regulated servicing operations" as a priority segment. pricing_and_gtm.md's priority segments table omits fintechs entirely. The segment may have been intentionally dropped, but there's no documented rationale.
**Recommendation:** Either add fintechs as a segment in pricing_and_gtm.md Section 2.1, or note in the Decisions Made header that fintechs were considered but excluded from the initial segment list with a reason.

### F-07: roadmap.md Phase 1 spike latency target inconsistency
**Severity:** MEDIUM
**File:** roadmap.md Section 2.4 vs. release_gates.md Section 4.2
**Description:** roadmap.md sets the spike exit criterion for p95 turn latency at < 2500ms (noted as "relaxed from production target for spike"). However, release_gates.md lists the production p99 target at 3000ms and production p95 at 1500ms. The spike relaxation to 2500ms at p95 is actually higher than the production p99 target. If the spike can't beat the production p99 target at p95, that's a significant risk signal, and the document should acknowledge this gap explicitly.
**Recommendation:** Clarify whether the spike's 2500ms p95 is measured under different conditions (mock bank, no RAG, hardcoded graph) that justify the relaxation. Add a note about what p95 latency the spike must approach before Phase 2 proceeds.

### F-08: No mention of audit_completeness metric in pilot success criteria
**Severity:** LOW
**File:** pilot_plan.md Section 6.1
**Description:** mvp_scope.md Section 6 lists audit_completeness at 100% as an MVP metric. pilot_plan.md Section 6.1 success criteria don't include this metric, even though producing complete audit trails is one of the three core things the MVP must prove (mvp_scope.md Section 1, point 2).
**Recommendation:** Add audit_completeness = 100% to pilot_plan.md Section 6.1 success criteria.

### F-09: pricing_and_gtm.md Principles Referenced is thin
**Severity:** LOW
**File:** pricing_and_gtm.md header
**Description:** pricing_and_gtm.md only references E7 (Document decisions). Given the document discusses competitive positioning against fraud-unaware platforms and emphasizes the three-layer enforcement model as a differentiator, referencing S1 (safety) and G7 (prohibited actions) would strengthen the traceability between the sales narrative and the architecture principles that underpin it.
**Recommendation:** Add S1 and G7 to the Principles Referenced field.

### F-10: Pilot plan doesn't specify minimum concurrent session target for pilot
**Severity:** LOW
**File:** pilot_plan.md
**Description:** mvp_scope.md Section 5.1 requires load testing at 200 concurrent sessions minimum. pilot_plan.md specifies total call volume targets (5,000-15,000 calls) but doesn't specify expected concurrent session load during the pilot. At 50% traffic and normal business hours, the concurrent session count matters for infrastructure planning.
**Recommendation:** Add expected peak concurrent sessions to pilot_plan.md Section 1.1 parameters, cross-referencing the 200 concurrent session load test target from mvp_scope.md.

---

## Internal Consistency Across the 4 Documents

**Timeline alignment:** All four documents use consistent phase durations. Phase 1 (6-8 weeks), Phase 2 (10-14 weeks), Phase 3 (8-12 weeks) appear identically in mvp_scope.md and roadmap.md. pilot_plan.md's 8-12 week pilot duration matches Phase 3. pricing_and_gtm.md's GTM timeline (months 5-8 for pilot operation) is consistent with the cumulative Phase 1+2 duration of 16-22 weeks before pilot starts. No conflicts found.

**Workflow scope:** All documents consistently reference the same 8 MVP workflows. pricing_and_gtm.md's demo environment lists 4 workflows (lost/stolen, balance, payment, complaint) which is a subset of the 8 -- appropriate for a demo. No conflicts.

**Metrics alignment across the four docs:** mvp_scope.md and pilot_plan.md are tightly aligned. The only cross-doc metric inconsistencies are with eval_strategy.md, documented in F-01 through F-04 above.

---

## Handoff Alignment (Sections 22-25)

| Handoff Requirement | Addressed | Document |
|-------------------|-----------|----------|
| Section 22: Phase-gate roadmap with spike, MVP, pilot, hardening | Yes | roadmap.md |
| Section 22: Pilot evidence pack as Phase 3 gate | Yes | pilot_plan.md Section 5 |
| Section 23.1: Positioning ("safely automate selected banking calls...") | Yes | pricing_and_gtm.md Section 1.1 uses the exact recommended framing |
| Section 23.2: Target segments (digital banks, tier-2, credit unions, card issuers, BPOs) | Partial | pricing_and_gtm.md covers all except fintechs (see F-06) |
| Section 23.3: Pricing model (platform + usage + integration + compliance) | Yes | pricing_and_gtm.md Section 3.1 implements all recommended components |
| Section 23.4: Design partner pitch structure | Yes | pricing_and_gtm.md Section 4.3 |
| Section 23.5: Sales evidence requirements | Yes | pricing_and_gtm.md Section 5.1 maps to all 9 handoff requirements |
| Section 24: Open questions | Partially | Several Section 24 questions are addressed in the Open Questions sections of the four documents, though not all are resolved (which is expected at this stage) |
| Section 25: Pre-build deliverables | Yes | mvp_scope.md covers MVP definition, pilot_plan.md covers pilot plan -- both are required Section 25 deliverables |

---

## Enterprise Quality Assessment

All four documents are written at a level appropriate for bank CRO, CISO, and Enterprise Architect audiences. Specific strengths:

- The documents avoid marketing language and focus on specifics. Metrics have defined thresholds, not aspirational ranges. Timelines have specific durations, not vague commitments.
- The risk sections are honest about dependencies on bank cooperation (API access, internal approvals, champion continuity).
- The pilot_plan.md rollback procedures are detailed enough that a bank risk team could evaluate them independently.
- The pricing_and_gtm.md competitive response playbook is specific and differentiated, not generic "we're better" claims.
- Evidence pack requirements in pilot_plan.md are comprehensive and structured for committee consumption.

One note: the documents consistently use "Chief Product Officer" as the Owner, which is appropriate for product-stage documents but a bank buyer might expect to see named individuals rather than role titles. This is a minor point for current stage.

---

## Verdict: FAIL

**Summary Statistics:**
- BLOCKER findings: 0
- HIGH findings: 2 (F-01, F-02)
- MEDIUM findings: 3 (F-03, F-04, F-07)
- LOW findings: 5 (F-05, F-06, F-08, F-09, F-10)

**Rationale:** The deliverables fail due to two HIGH severity findings. Both F-01 and F-02 involve metric target contradictions between the Step 9 documents (mvp_scope.md, pilot_plan.md) and eval_strategy.md. The task_completion_rate shows > 50% in the MVP docs but > 75% labeled as "(MVP)" in eval_strategy.md. The human_transfer_rate shows < 40% in MVP docs but < 25% labeled as "(MVP)" in eval_strategy.md, with an additional inconsistency in gate severity classification.

These aren't just documentation nits. If a bank's risk team reads the evaluation strategy and sees a 75% task completion gate labeled "MVP," then reviews the pilot plan targeting 50%, they'll question whether the team understands its own success criteria. The same applies to human_transfer_rate. These numbers must match across every document a bank reviewer might see.

**Required remediation for PASS:**
1. Resolve the task_completion_rate target contradiction (F-01) by aligning eval_strategy.md with mvp_scope.md's 50% MVP target.
2. Resolve the human_transfer_rate target and gate severity contradiction (F-02) by aligning eval_strategy.md with mvp_scope.md's 40% MVP target and adjusting the gate severity.

The MEDIUM and LOW findings should also be addressed but are not blocking.
