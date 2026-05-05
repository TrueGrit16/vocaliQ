# Build Readiness Review

**Document ID:** DOC_BRR_001  
**Last Updated:** 2026-05-04  
**Owner:** Chief Product Officer  
**Status:** Pre-build review gate

---

## 1. Purpose

This document is the final checkpoint before coding begins. It assesses whether all pre-build deliverables are complete, identifies unresolved decisions and risks, recommends the MVP scope and technical stack, and declares whether any conditions block the start of Phase 1 (Technical Spike).

The mandate is clear: do not code until this review confirms readiness.

---

## 2. Completed Deliverables

### 2.1 Deliverable Checklist

| # | Deliverable | Document(s) | QA Status | Notes |
|---|------------|------------|-----------|-------|
| 1 | Context summary | docs/00_context_summary.md | QA PASS | Consolidated research and handoff |
| 2 | Research corpus | docs/research/ (market/, regulatory/, banking_workflows/) | QA PASS | Market map, competitor matrix, source indices |
| 3 | Market map and competitor matrix | docs/research/market/market_map.md, competitor_matrix.csv | QA PASS | 30+ competitors across 6 categories |
| 4 | Banking workflow catalog | docs/research/banking_workflows/ (use_case_taxonomy.md, autonomy_matrix.md, prohibited_use_cases.md, workflow_catalog.csv) | QA PASS | 6-level autonomy classification, 20+ workflows |
| 5 | Regulatory and risk matrix | docs/research/risk/ (ai_risk_register.md, fraud_risk_framework.md, model_risk_framework.md, operational_resilience.md), regulatory_matrix.csv | QA PASS | Multi-jurisdiction coverage (UK, SG, EU, US) |
| 6 | Architecture specs | docs/architecture/ (architecture_principles.md, reference_architecture.md, 12 component specs) | QA PASS | 12 component TDDs with APIs, data, failure modes |
| 7 | API and schema contracts | docs/architecture/api_contracts/ (6 OpenAPI YAMLs), data_architecture.md, security/threat_model.md | QA PASS | 6 contracts, 24 DB tables, 24 threats + 1 design constraint |
| 8 | Evaluation plan | docs/evaluation/ (eval_strategy.md, golden_call_suite.md, adversarial_tests.md, fraud_simulations.md, rag_evaluation.md, release_gates.md) | QA PASS | 14 suites, 47 metrics, 27 golden scenarios, 19 adversarial, 8 fraud, 17 RAG |
| 9 | MVP and pilot plan | docs/product/ (mvp_scope.md, roadmap.md, pilot_plan.md, pricing_and_gtm.md) | QA PASS | 8 MVP workflows, 4-phase roadmap, pilot structure, pricing model. Note: the "Buyer persona brief" deliverable from handoff Section 25.1 is subsumed into pricing_and_gtm.md Section 2.3 (Buyer Map), which maps 7 bank buyer/approver roles with their concerns and VocalIQ's value proposition for each. |

All 9 deliverable groups have passed independent QA review. Every QA review is documented in QA_Restricted/ with structured findings, remediation tracking, and re-review verification.

### 2.2 Deliverable Statistics

| Metric | Count |
|--------|-------|
| Total documents produced | 40+ |
| QA review cycles completed | 9 initial reviews + 6 re-reviews |
| QA findings identified and resolved | 100+ across all steps |
| Architecture principles defined | 19 (S1-S5 Safety, G1-G7 Governance, E1-E7 Engineering) |
| Component specifications | 12 |
| API contracts | 6 OpenAPI specs |
| Database tables specified | 37 |
| Threat model entries | 26 threats + 1 design constraint |
| Evaluation scenarios | 71 (27 golden + 19 adversarial + 8 fraud + 17 RAG) |
| Evaluation metrics | 37 across 5 domains |
| Release gates | 15 blocker + 10 major |

---

## 3. Build-Readiness Gate Assessment

The handoff (Section 25.2) defines 13 gate conditions. Assessment against each:

| Gate Condition | Status | Evidence |
|---------------|--------|---------|
| MVP workflows are selected | READY | mvp_scope.md Section 2: 8 workflows at A0-A4 |
| Target jurisdiction is selected | OPEN | mvp_scope.md Assumptions: UK or Singapore, not yet decided. See Open Question OQ-01. |
| Deployment mode assumption is selected | READY | mvp_scope.md Section 4.3: Cloud (AWS/GCP), single region, single tenant |
| CCaaS/telephony integration path is selected | PARTIALLY READY | mvp_scope.md Section 4.1: SIP trunk to bank's existing platform. Specific provider (Twilio vs. Telnyx) deferred to Phase 1 spike. Acceptable. |
| Model provider assumptions are selected | READY | mvp_scope.md Section 4.2: Primary Anthropic Claude, ASR Deepgram, TTS ElevenLabs/Cartesia. Subject to bank data requirements. |
| Use-case autonomy levels are approved | READY | autonomy_matrix.md: 6-level classification with per-workflow assignment. A6 prohibitions architecturally enforced. |
| Regulatory matrix is complete enough for target pilot | READY | regulatory_matrix.csv covers UK (FCA), Singapore (MAS), EU (AI Act), US (CFPB). Sufficient for either first-market option. |
| Graph DSL and policy model are specified | READY | graph_compiler.md: declarative graph spec with safety rules. policy_engine.md: auth/action matrix with 6 autonomy levels. graph_api.yaml: compile/publish API. |
| Tool gateway safety model is specified | READY | tool_gateway.md: three-layer enforcement (Graph, Policy, Gateway). tool_gateway_api.yaml: execute/validate/audit API. |
| Audit event schema is specified | READY | audit_ledger.md: append-only ledger with integrity verification. audit_api.yaml: ingest/query/verify API. data_architecture.md: 6 audit-related tables. |
| Evaluation release gates are specified | READY | release_gates.md: 15 blocker gates, 10 major gates, rollback procedures. eval_strategy.md: 47 metrics with thresholds. |
| Threat model is complete | READY | threat_model.md: 24 threats across 5 categories + 1 design constraint. OWASP LLM Top 10 coverage matrix in adversarial_tests.md. |
| Pilot success metrics are defined | READY | pilot_plan.md Section 6: minimum bar (11 criteria), excellence bar (7 criteria), failure criteria (5 conditions). |

**Assessment: 11 of 13 gates are READY. 1 is OPEN (jurisdiction selection). 1 is PARTIALLY READY (telephony provider). The partially ready gate is acceptable because the Phase 1 spike is designed to resolve it. The open gate (jurisdiction) must be resolved before Phase 2 but does not block Phase 1.**

---

## 4. Open Questions

Open questions are consolidated from all documents and categorized by urgency.

### 4.1 Must Resolve Before Phase 2 (MVP Build)

| ID | Question | Owner | Source | Impact |
|----|---------|-------|--------|--------|
| OQ-01 | Which jurisdiction is first: UK or Singapore? | CPO | mvp_scope.md, handoff 24.1 | Affects compliance scripts, regulatory disclosures, Knowledge Manager content, and fraud detection weights. Does not affect Phase 1 architecture. |
| OQ-02 | Which bank segment is the first design partner? | CPO | mvp_scope.md, pricing_and_gtm.md | Affects connector complexity, regulatory requirements, and API access timeline. |
| OQ-03 | Is the design partner willing to provide API access during pilot? | CPO / Sales | mvp_scope.md | If no direct API access, integration requires middleware that adds 4-6 weeks to Phase 2. |
| OQ-04 | Does the design partner require private cloud for pilot? | CPO / CTO | mvp_scope.md | Cloud deployment is assumed. Private cloud would significantly extend Phase 2 timeline. |

### 4.2 Must Resolve During Phase 1 (Technical Spike)

| ID | Question | Owner | Source | Impact |
|----|---------|-------|--------|--------|
| OQ-05 | Pipecat or LiveKit Agents for voice runtime? | CTO | roadmap.md Section 6 | The spike evaluates both. Decision locked by end of Phase 1. |
| OQ-06 | Twilio, Telnyx, or SIP BYOC for telephony? | CTO | roadmap.md Section 6 | Depends on call quality testing during spike. |
| OQ-07 | OPA/Rego, Cedar, or custom for policy engine? | CTO | roadmap.md Section 6, handoff 27.5 | Spike builds hardcoded rules; the abstraction decision must be made before Phase 2. |
| OQ-08 | PostgreSQL pgvector, OpenSearch, or managed vector DB for RAG? | NLP Lead | roadmap.md Section 6, handoff 27.6 | Depends on retrieval latency testing during Phase 1. |
| OQ-09 | PostgreSQL append-only or Kafka/NATS for event store? | CTO | roadmap.md Section 6, handoff 27.2 | Spike uses PostgreSQL. Decision on event streaming deferred to Phase 2 scaling requirements. |

### 4.3 Must Resolve Before Pilot (Phase 3)

| ID | Question | Owner | Source | Impact |
|----|---------|-------|--------|--------|
| OQ-10 | Does the bank require customer consent before AI routing, or is in-call disclosure sufficient? | Bank Compliance | pilot_plan.md | Affects IVR design and call routing. |
| OQ-11 | What is the bank's process for approving AI-generated content in regulated communications? | Bank Compliance | pilot_plan.md | Affects complaint intake workflow. |
| OQ-12 | Should the pilot include a control group for ROI comparison? | CPO + Bank Ops | pilot_plan.md | Strengthens ROI analysis but adds complexity. |
| OQ-13 | How will post-pilot data retention be handled? | Legal | pilot_plan.md | DPA must cover pilot data lifecycle. |

### 4.4 Can Resolve After Pilot (GA Planning)

| ID | Question | Owner | Source | Impact |
|----|---------|-------|--------|--------|
| OQ-14 | Should evaluation infrastructure be shared or isolated per tenant? | CTO | eval_strategy.md | Affects multi-tenant architecture in Phase 4. |
| OQ-15 | Should VocalIQ maintain a bug bounty program? | CISO | adversarial_tests.md | Market positioning decision for GA. |
| OQ-16 | Should canary deployment percentage be bank-configurable? | CTO | release_gates.md | Phase 4 multi-tenant feature. |
| OQ-17 | How should conflicting information in RAG documents be resolved? | NLP Lead | rag_evaluation.md | Architecture decision for Knowledge Manager v2. |
| OQ-18 | Should VocalIQ pursue SOC 2 before or during pilot? | CFO / CPO | roadmap.md | Certification timing vs. sales enablement. |

---

## 5. Major Risks

Risks are consolidated from all documents and ranked by combined likelihood and impact.

| Risk | Likelihood | Impact | Mitigation | Owner |
|------|-----------|--------|-----------|-------|
| Design partner delays API access | High | High | Begin connector development against mock API. Negotiate sandbox access early. | CPO |
| LLM latency exceeds budget | Medium | High | Phase 1 spike specifically tests latency. If budget unmet, adjust model strategy before Phase 2. | CTO |
| Bank internal approval extends pilot start | High | Medium | Begin approval in parallel with Phase 2. Provide evidence pack early for pre-review. | CPO |
| False negatives in adversarial suites | Medium | High | Monthly payload updates, quarterly red team exercises. Known-payload testing is necessary but not sufficient. | CISO |
| Synthetic test scenarios miss real-world edge cases | Medium | Medium | Supplement with production shadow evaluation post-pilot. Quarterly expert review protocol. | QA Lead |
| Single design partner dependency | High | Medium | Engage 2-3 candidates simultaneously. Structure partnership for mutual benefit, not lock-in. | CPO |
| Model provider pricing changes | Medium | Medium | Maintain fallback providers. Track cost-per-call continuously. Architecture supports provider swap. | CTO |
| Key personnel departure | Medium | Medium | Cross-train on critical components. Thorough architecture documentation (this deliverable set). | CTO |
| Regulatory change during build | Low | High | Monitor regulatory calendar. Flexible compliance script architecture. Maintain regulatory working group. | Compliance Lead |
| Pilot succeeds technically but fails commercially | Medium | High | Define ROI model before pilot. Agree on measurement methodology with bank. Track leading indicators weekly. | CPO |

---

## 6. Recommended MVP Scope

Fully specified in mvp_scope.md. Summary:

**8 workflows** at autonomy levels A0-A4: lost/stolen card, balance inquiry, card activation, statement request, payment to existing payee, branch/FAQ, complaint intake, direct debit cancellation.

**12 platform components** at varying maturity levels (Full or Core), with all safety-critical components (Policy Engine, Tool Gateway, Audit Ledger, Evaluation Lab) at full maturity.

**Single design partner bank**, single jurisdiction, English only, cloud deployment.

**Success criteria**: safe_resolution_rate > 99.5%, zero unauthorized disclosures, zero policy violations, task_completion_rate > 50%, human_transfer_rate < 40%, audit_completeness 100%.

---

## 7. Recommended Technical Stack

These are evaluation candidates, not final decisions. Phase 1 resolves them through hands-on testing.

| Layer | Primary Candidate | Alternatives to Evaluate | Decision Criteria |
|-------|------------------|------------------------|-------------------|
| Voice runtime | Pipecat | LiveKit Agents | Telephony support, SIP quality, barge-in, latency, community maturity |
| Telephony | Twilio | Telnyx, SIP BYOC | Call quality, reliability, geographic coverage, cost |
| Backend framework | Python FastAPI | - | Ecosystem fit with voice/ML libraries. Single language reduces complexity. |
| Frontend | Next.js + React | - | WebSocket/SSE for live monitoring. React Flow for future graph designer. |
| Primary database | PostgreSQL | - | Proven at scale, pgvector for RAG, append-only patterns for audit. |
| Event store | PostgreSQL (initial) | Kafka, NATS, Pulsar | Start simple. Evaluate streaming platforms if write throughput requires it. |
| Cache | Redis | - | Ephemeral session state only. Never audit source of truth. |
| RAG vector store | PostgreSQL pgvector | OpenSearch, Vespa, managed vector DB | Retrieval latency, metadata filtering, tenant isolation, hybrid search quality |
| Policy engine | OPA/Rego | Cedar, custom | Explainability, versioning, runtime latency, graph compiler integration |
| Primary LLM | Anthropic Claude | OpenAI GPT-4 | Bank data processing requirements, intent accuracy, cost, latency |
| ASR | Deepgram Nova-3 | Google Cloud STT | Accuracy on phone audio, streaming latency, accent support |
| TTS | ElevenLabs / Cartesia | Google Cloud TTS | First-byte latency, voice quality, cost |
| Embedding model | OpenAI text-embedding-3-small | Cohere Embed v3 | Retrieval quality, cost, latency |
| Infrastructure | AWS or GCP | Azure (if bank requires) | Region availability, managed services, compliance certifications |
| CI/CD | GitHub Actions | GitLab CI | Team familiarity, integration with evaluation lab |

---

## 8. Build Plan

Fully specified in roadmap.md. Summary timeline:

| Phase | Duration | Key Milestone |
|-------|---------|--------------|
| Phase 1: Technical spike | 6-8 weeks | Working voice pipeline, telephony, graph runtime, audit trail demo |
| Phase 2: MVP platform | 10-14 weeks | All 12 components at MVP maturity, evaluation gates passing, evidence pack |
| Phase 3: Bank pilot | 8-12 weeks | Live deployment, 5,000+ calls, bank risk committee signoff |
| Phase 4: Enterprise hardening | Ongoing | Multi-tenant, multi-region, connector SDK, SOC 2 |

Total to pilot launch: approximately 6-8 months from build start.

Team size: 11-16 people for Phase 2 (detailed role breakdown in roadmap.md Section 3.4).

---

## 9. No-Build Blockers

These conditions, if true, would prevent the start of Phase 1.

| Blocker | Status | Resolution |
|---------|--------|-----------|
| Pre-build deliverables incomplete | CLEAR | All 9 deliverable groups complete with QA PASS |
| Threat model not reviewed | CLEAR | 26 threats + 1 design constraint documented |
| Evaluation gates not defined | CLEAR | 15 blocker + 10 major gates specified |
| MVP workflows not selected | CLEAR | 8 workflows selected with autonomy level assignments |
| No pilot plan | CLEAR | Pilot structure, rollback, evidence pack, success criteria defined |
| Architecture not specified | CLEAR | 12 component specs, 6 API contracts, data architecture, reference architecture |
| No pricing model | CLEAR | 4-component pricing with segment-specific tiers |

**No blockers exist for Phase 1.** The open question on jurisdiction (OQ-01) must be resolved before Phase 2 begins, but Phase 1 architecture work is jurisdiction-agnostic.

---

## 10. Recommendation

**The project is ready to begin Phase 1 (Technical Spike).**

All pre-build deliverables are complete and QA-verified. The architecture is specified to the level of API contracts and database schemas. The evaluation framework defines what "safe enough for banking" means in measurable terms. The pilot plan defines how to deploy, measure, and roll back. The pricing model defines how the product generates revenue.

The first action items:

1. Resolve OQ-01 (jurisdiction) and OQ-02 (design partner segment) at the CPO level.
2. Begin design partner outreach in parallel with Phase 1.
3. Assemble the Phase 1 team (6 people per roadmap.md Section 2.6).
4. Set up the development environment, repository structure, and CI/CD pipeline.
5. Start the Phase 1 spike with the lost/stolen card workflow as the first end-to-end proof.

The pre-build phase produced a body of specification work that is unusual in its depth for a startup. That depth is deliberate: for banking, the cost of getting it wrong in production is orders of magnitude higher than the cost of specifying it correctly upfront. The specifications are living documents. They will evolve as the team builds, as the design partner provides feedback, and as the product encounters reality. But they start from a position of informed, structured intent rather than ad-hoc discovery.

Do not code before this review is approved. Once approved, build with confidence.
