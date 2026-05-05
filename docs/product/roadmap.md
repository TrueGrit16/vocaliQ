# Implementation Roadmap

**Document ID:** DOC_PROD_RM_001  
**Last Updated:** 2026-05-04  
**Owner:** Chief Product Officer

**Version History:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-04 | Initial specification |

**Principles Referenced:** S1 (Human cannot be harmed by AI action), E7 (Document decisions), G5 (Model version pinning)

**Scope:** Defines the implementation roadmap from research completion through enterprise hardening. Covers four phases: technical spike, MVP platform build, bank pilot, and enterprise hardening. Each phase specifies build scope, gate criteria, team requirements, and key risks.

**Assumptions:** Build starts only after the build-readiness review (Step 10) confirms all pre-build deliverables are complete. The team is building from scratch using open-source frameworks (Pipecat or LiveKit Agents) and cloud-hosted model providers. The first pilot targets a single design partner bank in a single jurisdiction.

**Decisions Made:** The roadmap follows a phase-gate model rather than continuous delivery. Each phase has explicit exit criteria that must be met before proceeding. This reflects the banking buyer's expectation of controlled, evidence-backed releases. The roadmap does not prescribe specific sprint plans; those are the engineering team's responsibility within each phase.

**Alternatives Considered:** Considered a continuous delivery model without phase gates (rejected: banks require evidence packs per release). Considered building all components in parallel (rejected: the voice pipeline must work first, as it validates the fundamental architecture). Considered skipping the technical spike (rejected: voice pipeline latency and telephony integration carry the highest technical risk and must be proven early).

**Risks:** Phase 1 technical spike may reveal that the target latency budget (1650ms no-tool, 2150ms with-tool) is not achievable with the chosen model providers, forcing a pivot. Bank connector integration in Phase 2 depends on the design partner's API readiness, which is outside VocalIQ's control. Pilot timeline depends on the bank's internal approval process, which can extend 4-12 weeks beyond technical readiness.

**Source Links:** Handoff Section 22, mvp_scope.md, architecture_principles.md, reference_architecture.md.

---

## 1. Phase Overview

| Phase | Name | Duration | Primary Goal |
|-------|------|---------|-------------|
| 0 | Research and specification | Complete | Pre-build deliverables and build-readiness review |
| 1 | Technical spike | 6-8 weeks | Prove voice pipeline, telephony, graph runtime, and audit trail |
| 2 | MVP platform | 10-14 weeks | Build pilot-ready platform with all 12 components at MVP maturity |
| 3 | Bank pilot | 8-12 weeks | Deploy with design partner, collect evidence, measure success |
| 4 | Enterprise hardening | Ongoing | Multi-tenant, multi-region, connector SDK, certifications |

---

## 2. Phase 1: Technical Spike

### 2.1 Objective

Prove that the core voice pipeline can handle a realistic banking call with acceptable latency, that the graph runtime can execute a multi-step workflow deterministically, and that every action produces an audit event. This phase resolves the highest-risk technical unknowns before committing to the full platform build.

### 2.2 Build Scope

| Component | Spike Scope |
|-----------|------------|
| Media Gateway | SIP trunk connection to test telephony provider (Twilio or Telnyx). Inbound call handling, basic DTMF, call recording to object storage. |
| Speech Layer | Streaming ASR (Deepgram Nova-3), streaming TTS (ElevenLabs or Cartesia), Silero VAD, basic barge-in detection. PII redaction placeholder. |
| Conversation Runtime | Graph executor that can run a single hardcoded graph (lost/stolen card workflow). Slot filling for account number and card last-4. Context window management. |
| Policy Engine | Hardcoded policy rules for the spike workflow: AUTH_2 required for balance, AUTH_4 for card block. No dynamic policy loading yet. |
| Model Gateway | Single LLM provider integration (Anthropic Claude). Retry on failure. Token counting and logging. No fallback provider yet. |
| Tool Gateway | Mock bank connector that simulates card.block, card.status, account.balance responses with configurable latency (50-500ms). |
| Audit Ledger | Append-only event log in PostgreSQL. Events for: call_started, auth_completed, tool_called, tool_responded, turn_completed, call_ended. No integrity verification yet. |
| Control Center | Minimal supervisor view: live call list, real-time transcript, manual takeover button. No whisper, no analytics. |

### 2.3 What Spike Does Not Build

No Graph Compiler (graphs are hardcoded), no Knowledge Manager (no RAG), no Fraud/Identity Layer (mock auth only), no Evaluation Lab (manual testing), no multi-tenancy, no deployment automation.

### 2.4 Exit Criteria

| Criterion | Evidence |
|-----------|---------|
| End-to-end call works | Demo: phone call -> ASR -> graph -> LLM -> TTS -> response heard by caller |
| Latency within budget | Measured p95 turn latency < 2000ms (relaxed from production p95 target of 1500ms). The spike runs a single hardcoded graph with no RAG retrieval and a mock bank connector, so the reduced component count justifies a tighter ceiling than 2500ms. If the spike cannot achieve < 2000ms under these simplified conditions, the latency budget requires re-evaluation before Phase 2 proceeds. |
| Graph execution is deterministic | Same inputs produce same tool calls and same outcomes across 10 consecutive runs |
| No direct LLM-to-tool execution | Architecture review confirms all tool calls go through Tool Gateway with policy check |
| Audit trail complete for demo calls | Every call produces a full event sequence; events are reviewable in supervisor view |
| Telephony quality acceptable | Audio clarity, no echo, no excessive jitter on SIP trunk |
| Mock bank connector is realistic | Simulates latency distribution and error patterns from real banking APIs |

### 2.5 Key Risks

| Risk | Mitigation |
|------|-----------|
| ASR latency exceeds budget on streaming | Test multiple providers. If streaming doesn't meet target, evaluate batch with shorter segments. |
| LLM response latency is too high | Test prompt optimization, response streaming, and smaller models for simple intents. |
| SIP trunk quality issues | Test with at least two telephony providers. Evaluate WebRTC as a fallback for the demo. |
| Barge-in detection causes false positives | Tune VAD sensitivity; accept imperfect barge-in for spike, refine in Phase 2. |

### 2.6 Team Requirements

| Role | Count | Responsibilities |
|------|-------|----------------|
| Voice/Telephony Engineer | 1 | Media Gateway, SIP trunk, audio pipeline |
| ML/NLP Engineer | 1 | Speech Layer, ASR/TTS integration, VAD tuning |
| Backend Engineer | 2 | Conversation Runtime, Graph Executor, Policy Engine, Tool Gateway |
| Frontend Engineer | 1 | Control Center minimal UI |
| Infrastructure Engineer | 1 | Deployment, monitoring, audit logging |

---

## 3. Phase 2: MVP Platform

### 3.1 Objective

Build all 12 platform components to MVP maturity (as defined in mvp_scope.md Section 3.1). Implement the full evaluation harness. Pass all blocker-severity release gates. Generate the pilot evidence pack.

### 3.2 Build Scope by Component

Phase 2 takes the spike artifacts and builds them into production-grade components. The work is organized into three workstreams that run in parallel after the initial two weeks of foundation work.

**Foundation (Weeks 1-2):**

| Work Item | Description |
|-----------|------------|
| Graph Compiler | Build the compiler that validates and compiles declarative graph definitions. Implement safety rules (no direct LLM-to-tool, auth level enforcement, A6 prohibition). |
| Policy Engine v1 | Dynamic policy loading, auth-level enforcement, action-level policy matrix, rate limiting. Replace spike's hardcoded rules. |
| Audit Ledger v1 | Integrity verification (hash chain), retention policies, legal hold capability, structured query API. |
| CI/CD pipeline | Automated build, test, deploy pipeline with evaluation gate integration. |

**Workstream A: Conversation and Safety (Weeks 3-10):**

| Work Item | Description |
|-----------|------------|
| Conversation Runtime v1 | Full graph execution, multi-workflow support, conversation repair, context management, turn orchestration for all 8 MVP workflows. |
| Knowledge Manager v1 | Document ingestion, hybrid retrieval (keyword + vector), metadata filtering, approval workflow, version management. |
| Model Gateway v1 | Multi-provider routing, fallback, circuit breaker, version pinning, token budget enforcement, response caching for deterministic re-runs. |
| Fraud & Identity Layer v1 | KBA verification, OTP step-up, risk scoring, fraud signal detection (ATO, APP scam patterns), ANI validation. |
| Graph definitions | Design and compile graphs for all 8 MVP workflows. |

**Workstream B: Integration and Operations (Weeks 3-10):**

| Work Item | Description |
|-----------|------------|
| Tool Gateway v1 | Real bank connector integration (design partner API), validation schemas, idempotency, retry, circuit breaker, audit logging. |
| Media Gateway v1 | Production SIP trunking, WebRTC support, call recording, DTMF, hold/transfer, media streaming. |
| Speech Layer v1 | PII redaction (real-time), enhanced barge-in detection, noise handling, confirmation loops. |
| Control Center v1 | Live monitoring dashboard, whisper mode, takeover mode, session replay, transfer queue management. |

**Workstream C: Evaluation and Quality (Weeks 3-12):**

| Work Item | Description |
|-----------|------------|
| Evaluation Lab v1 | Test runner, suite selection engine, gate evaluator, report generator. |
| Golden call suite | Implement all 27 golden call scenarios from golden_call_suite.md. |
| Adversarial suite | Implement all 19 adversarial scenarios from adversarial_tests.md. |
| Fraud simulation suite | Implement all 8 fraud scenarios from fraud_simulations.md. |
| RAG evaluation suite | Implement all 17 RAG scenarios from rag_evaluation.md. |
| Load and chaos testing | Implement 5 load scenarios and 6 chaos scenarios from release_gates.md. |
| Evidence pack generator | Automated generation of the evidence pack (eval report, gate results, approvals, change diff). |

**Integration and Hardening (Weeks 11-14):**

| Work Item | Description |
|-----------|------------|
| End-to-end integration testing | All 8 workflows tested end-to-end with real bank connector. |
| Full evaluation run | Complete suite execution, gate evaluation, evidence pack generation. |
| Rollback testing | Verify rollback mechanism works for every deployment target. |
| Security review | Pen test, code review, dependency audit. |
| Performance tuning | Latency optimization to meet production targets. |

### 3.3 Exit Criteria

| Criterion | Evidence |
|-----------|---------|
| All 8 MVP workflows pass golden path tests | Evaluation report shows 100% pass rate on golden path suite |
| All blocker release gates pass | Gate evaluation report with zero blocker failures |
| Evidence pack generated | Structured evidence pack reviewable by bank risk team |
| Control Center operational | Live demo of monitoring, whisper, and takeover |
| Rollback tested and functional | Rollback test report showing clean rollback with session continuity |
| Load test passes at target concurrency | 200 concurrent sessions, p99 latency < 3000ms, error rate < 0.1% |
| Security review complete | Pen test report with no critical or high findings unresolved |

### 3.4 Team Requirements

| Role | Count | Responsibilities |
|------|-------|----------------|
| Voice/Telephony Engineer | 1-2 | Media Gateway, SIP trunk, audio pipeline |
| ML/NLP Engineer | 2 | Speech Layer, Knowledge Manager, Model Gateway |
| Backend Engineer | 3-4 | Conversation Runtime, Graph Compiler, Policy Engine, Tool Gateway, Fraud Layer |
| Frontend Engineer | 1-2 | Control Center, Graph Designer (basic) |
| Infrastructure/DevOps | 1-2 | Deployment, monitoring, CI/CD, Evaluation Lab infrastructure |
| QA/Evaluation Engineer | 1-2 | Test suite implementation, evaluation harness |
| Security Engineer | 1 | Threat model validation, pen testing, adversarial suite |
| Product Manager | 1 | Requirements, prioritization, bank liaison |
| **Total** | **11-16** | |

---

## 4. Phase 3: Bank Pilot

### 4.1 Objective

Deploy VocalIQ with the design partner bank on the selected workflows. Operate under controlled conditions with human oversight. Collect performance data, identify gaps, and validate the ROI model. Produce the evidence that proves VocalIQ is ready for broader deployment.

The pilot plan (pilot_plan.md) contains the detailed pilot structure, success criteria, and operational procedures. This section covers the build work that happens during the pilot phase.

### 4.2 Build Scope During Pilot

| Work Item | Description |
|-----------|------------|
| Real bank connector refinement | Fix connector issues discovered during production operation. Handle edge cases in bank API responses. |
| Pilot dashboards | Operational dashboards showing call volume, containment rate, escalation patterns, and safety metrics. |
| Bank-specific policies | Tune policy thresholds, fraud detection weights, and compliance scripts based on pilot observations. |
| QA review process | Establish the operational cadence for reviewing flagged calls, false positives, and near-misses. |
| Pilot runbook | Operational runbook covering on-call procedures, incident response, and escalation paths. |
| Knowledge base tuning | Refine RAG documents and retrieval parameters based on production query patterns. |
| Graph tuning | Adjust conversation graphs based on observed caller behavior and edge cases. |

### 4.3 Exit Criteria

Detailed in pilot_plan.md Section 6 (Success Criteria). Summary:

| Criterion | Target |
|-----------|--------|
| Pilot duration completed | Minimum 8 weeks of live operation |
| Safety metrics sustained | safe_resolution_rate > 99.5%, zero unauthorized disclosures |
| Call volume target met | Minimum 5,000 calls processed through VocalIQ |
| Bank risk team signoff | Written approval from bank's risk/compliance function |
| ROI evidence produced | Measured cost-per-call, containment rate, agent time saved |
| No unresolved critical incidents | All severity-1 incidents resolved before pilot exit |

### 4.4 Team Requirements During Pilot

| Role | Count | Responsibilities |
|------|-------|----------------|
| On-call Engineer | 1 (rotating) | Production support, incident response |
| Bank Integration Engineer | 1 | Connector maintenance, API troubleshooting |
| QA/Evaluation Engineer | 1 | Ongoing evaluation, flagged call review |
| Product Manager | 1 | Bank relationship, requirement triage |
| ML/NLP Engineer | 0.5 | Graph and knowledge base tuning |
| **Total** | **4-5** | |

---

## 5. Phase 4: Enterprise Hardening

### 5.1 Objective

Transform the single-tenant pilot platform into a multi-tenant, multi-region enterprise product. Build the connector SDK and marketplace. Achieve security certifications. Enable self-service bank onboarding.

### 5.2 Build Scope

| Capability | Description | Priority |
|-----------|-------------|----------|
| Multi-tenancy | Tenant isolation at every layer (data, policy, graphs, knowledge base, audit). Per-tenant configuration and customization. | P0 |
| Multi-region deployment | Support for EU, APAC, and US regions with data residency controls. Active-passive or active-active depending on bank requirements. | P0 |
| Private cloud / VPC deployment | Support deployment in bank's own cloud infrastructure (AWS, Azure, GCP). | P1 |
| Connector SDK | Developer SDK for building bank connectors. Standardized interface, testing harness, certification process. | P1 |
| Connector marketplace | Pre-built connectors for major core banking platforms (FIS, Temenos, Thought Machine, Mambu). | P2 |
| Visual graph designer | Web-based graph design tool for non-technical users. Drag-and-drop workflow builder with built-in validation. | P1 |
| Advanced analytics | Conversation analytics, intent heatmaps, containment funnel, ROI calculator. | P2 |
| SOC 2 Type II | Formal audit and certification. Architecture already supports it; this is the process and evidence work. | P0 |
| ISO 27001 | Information security management certification. | P1 |
| Advanced fraud integration | Voice biometrics vendor integration, behavioral analytics, device fingerprinting. | P2 |
| Non-English language support | Language packs for Mandarin, Hindi, Malay, Arabic based on market demand. | P1 |
| Advanced evaluation | AI caller testing, production shadow evaluation, drift detection, automated regression expansion. | P2 |
| Outbound calling | Consent management, TCPA/PECR compliance, campaign orchestration. | P3 |

### 5.3 Timeline

Phase 4 is ongoing and parallel with expanding pilot deployments to additional banks. Rough prioritization:

| Timeline | Focus |
|---------|-------|
| Months 1-3 post-pilot | Multi-tenancy, SOC 2 prep, connector SDK, second bank onboarding |
| Months 4-6 | Multi-region, private cloud, visual graph designer, ISO 27001 |
| Months 7-12 | Connector marketplace, advanced analytics, non-English, advanced fraud |
| Year 2+ | Outbound, advanced evaluation, industry expansion beyond banking |

---

## 6. Technology Decisions Deferred to Phase 1

The following technology decisions are intentionally left open until the technical spike validates or invalidates the options.

| Decision | Options | Resolution Criteria |
|----------|---------|-------------------|
| Voice pipeline framework | Pipecat vs. LiveKit Agents | Which achieves target latency with telephony integration? Which has better WebRTC support? |
| Telephony provider | Twilio vs. Telnyx vs. SIP BYOC | Which provides the best call quality, SIP trunk reliability, and geographic coverage for the first market? |
| Primary LLM provider | Anthropic Claude vs. OpenAI GPT-4 | Which meets the bank's data processing requirements? Which achieves better intent accuracy on banking queries? |
| Policy engine implementation | OPA/Rego vs. Cedar vs. custom | Which integrates most cleanly with the graph runtime? Which provides the right abstraction for banking policy rules? |
| Event store | PostgreSQL append-only vs. Kafka/NATS vs. both | Which meets the write throughput requirement? Which provides the right query interface for audit replay? |
| Vector store for RAG | PostgreSQL pgvector vs. OpenSearch vs. managed vector DB | Which achieves the retrieval latency target (< 200ms p99) at the expected document volume? |

These decisions will be documented with rationale in an Architecture Decision Record (ADR) format at the end of Phase 1.

---

## 7. Risk Register (Roadmap-Specific)

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Design partner bank delays API access | High | Phase 2 timeline extends 4-8 weeks | Begin connector development against mock API. Negotiate API sandbox access early. |
| LLM latency exceeds budget | Medium | Requires architecture changes (smaller models, caching, pre-computation) | Phase 1 spike specifically tests latency. If budget is not met, adjust model strategy before Phase 2. |
| Bank's internal approval process extends pilot start | High | Total timeline extends 1-3 months | Begin approval process in parallel with Phase 2 build. Provide evidence pack early for pre-review. |
| Key personnel departure | Medium | Delays across affected workstream | Cross-train on critical components. Document architecture decisions thoroughly. |
| Regulatory change during build | Low | Scope change for compliance components | Monitor regulatory calendar. Maintain flexible compliance script architecture. |
| Model provider pricing change | Medium | Economic model changes | Maintain fallback providers. Track cost-per-call continuously. |

---

## 8. Open Questions

1. What is the realistic engineering team size? The roadmap assumes 11-16 people for Phase 2. If the team is smaller, the timeline extends proportionally.

2. Should Phase 1 and Phase 2 overlap, or is a hard gate between them necessary? Overlapping saves time but risks building on unvalidated foundations.

3. Is there a hard deadline for pilot launch (e.g., bank's fiscal year end, regulatory deadline, competitive pressure)? If so, the roadmap may need to trade feature scope for speed.

4. Should VocalIQ pursue SOC 2 Type II before or during the pilot? Starting early is expensive but having the certification at pilot completion is a strong sales enabler.

5. At what point does the team need a dedicated compliance/regulatory specialist? The MVP relies on engineering understanding of regulatory requirements, but GA will need dedicated expertise.
