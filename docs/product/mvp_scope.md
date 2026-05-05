# MVP Scope Definition

**Document ID:** DOC_PROD_MVP_001  
**Last Updated:** 2026-05-04  
**Owner:** Chief Product Officer

**Version History:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-04 | Initial specification |

**Principles Referenced:** S1 (Human cannot be harmed by AI action), S2 (AI decisions through policy), G7 (Prohibited actions cannot be unlocked), E5 (Test at policy boundary)

**Scope:** Defines what is included in, excluded from, and explicitly deferred from the VocalIQ minimum viable product. Covers selected workflows, platform components, deployment assumptions, integration scope, and the criteria that distinguish "done enough for pilot" from "done enough for GA."

**Assumptions:** The MVP targets a single design-partner bank pilot in a single jurisdiction (UK or Singapore). The MVP uses cloud deployment (not private cloud or on-premise). The MVP supports English only. Bank connectors are built as custom integrations for the pilot partner, not as a generic connector marketplace.

**Decisions Made:** The MVP prioritizes safety, auditability, and compliance over feature breadth. A narrow set of workflows, fully governed, is more valuable than a wide set of workflows with partial controls. The MVP must produce the evidence pack that a bank risk team needs to approve pilot deployment.

**Alternatives Considered:** Considered a broader MVP with 8+ workflows (rejected: increases surface area and testing burden without proportional value). Considered a demo-only MVP without real bank integration (rejected: banks need to see production-grade controls against their own systems). Considered open-source MVP release (rejected for MVP: governance and multi-tenancy need hardening before community exposure).

**Risks:** A single-bank pilot creates dependency on one design partner's requirements, schedule, and internal approvals. MVP scope may be too narrow to demonstrate ROI convincingly. Custom connector integration may not generalize to other banks without rework.

**Source Links:** Handoff Sections 22-25, architecture_principles.md, workflow_catalog.csv, autonomy_matrix.md, eval_strategy.md, pilot_plan.md.

---

## 1. Product Thesis

VocalIQ is a governed voice automation layer for regulated banking contact centers. The bank buyer purchases lower operational risk, auditable execution, fraud-aware identity management, and compliance evidence. The product is not a general-purpose voice AI platform; it is purpose-built for workflows where getting it wrong has financial, regulatory, or reputational consequences.

The MVP must prove three things to a bank risk committee:

1. VocalIQ can handle selected banking calls safely, meaning no unauthorized disclosures, no policy violations, no fabricated financial information, and no missed fraud signals.
2. VocalIQ produces the audit evidence a compliance team requires.
3. VocalIQ's human oversight model works: supervisors can monitor, intervene, and take over in real time.

---

## 2. MVP Workflow Selection

### 2.1 Included Workflows

The MVP includes workflows at autonomy levels A0 through A4. These were selected based on three criteria: high call volume (drives ROI), low-to-moderate risk (reduces pilot approval friction), and clear procedural scripts (enables deterministic graph design).

| Workflow | Autonomy | Call Volume | Risk | Rationale |
|----------|---------|-------------|------|-----------|
| Lost/stolen card reporting and blocking | A4 | High | Moderate | High urgency, clear procedure, immediate ROI from 24/7 availability |
| Balance and recent transaction inquiry | A2 | Very High | Low | Highest volume single query type in retail banking |
| Card activation | A4 | Medium | Low | Procedural, identity-verified, quick resolution |
| Statement request | A4 | Medium | Low | Simple fulfillment, reduces agent workload |
| Payment to existing payee | A4 | High | Moderate | Requires AUTH_4 but uses pre-registered payees only |
| Branch/ATM locator and product FAQ | A0 | High | Very Low | No authentication required, pure information |
| Complaint intake | A3 | Medium | Moderate | Regulatory obligation to capture complaints; AI drafts, human reviews |
| Direct debit cancellation | A4 | Medium | Low | Clear procedure, identity-verified |

### 2.2 Explicitly Excluded from MVP

These workflows are prohibited (A6) or deferred due to risk, regulatory complexity, or integration scope.

| Workflow | Reason for Exclusion |
|----------|---------------------|
| Loan or mortgage origination | A6 prohibited. Requires suitability assessment and regulated advice. |
| Investment advice or fund switching | A6 prohibited. MiFID/MAS regulated advice. |
| Wire transfer or international payment | A6 prohibited. High fraud risk, complex compliance. |
| New beneficiary/payee creation | A6 prohibited. Primary ATO attack vector. |
| Account closure | A6 prohibited. Retention, regulatory, and operational complexity. |
| Dispute resolution (outcome) | Deferred to GA. MVP handles complaint intake (A3) only; resolution requires deep integration with dispute management systems. |
| Credit limit change | Deferred to GA. Requires credit decisioning integration. |
| Address or name change | Deferred to GA. Identity verification complexity; primary social engineering target. |
| Outbound calling campaigns | Deferred to GA. Regulatory constraints (TCPA, PECR) and consent management. |

### 2.3 Workflow-to-Component Mapping

Each MVP workflow exercises specific platform components. All workflows share the core pipeline (Media Gateway, Speech Layer, Conversation Runtime, Policy Engine, Model Gateway, Audit Ledger, Control Center). The table below shows additional component dependencies.

| Workflow | Knowledge Manager | Tool Gateway | Fraud/Identity Layer |
|----------|------------------|-------------|---------------------|
| Lost/stolen card | Product terms | card.block, card.status | Step-up auth, ATO detection |
| Balance inquiry | - | account.balance, transaction.list | Step-up auth |
| Card activation | Product terms | card.activate | Step-up auth |
| Statement request | - | statement.request | Step-up auth |
| Payment (existing payee) | - | payment.initiate, payee.list | Step-up auth, APP scam detection |
| Branch/FAQ | FAQ docs, branch data | branch.locator | - |
| Complaint intake | Complaint handling guide | complaint.create | Vulnerability detection |
| DD cancellation | DD terms | direct_debit.cancel | Step-up auth |

---

## 3. Platform Component Scope

### 3.1 Components Included in MVP

All 12 components from the reference architecture are included in the MVP, but at varying maturity levels.

| Component | MVP Maturity | What's Built | What's Deferred |
|-----------|-------------|-------------|----------------|
| Media Gateway | Full | SIP trunking, WebRTC, DTMF, call recording, media streaming | Multi-region failover, outbound dialing |
| Speech Layer | Full | Streaming ASR, TTS, PII redaction, VAD, barge-in detection | Non-English language packs, custom voice training |
| Conversation Runtime | Full | Graph execution, slot filling, context management, turn orchestration | AI caller testing mode, A/B variant routing |
| Graph Compiler | Full | Graph validation, compilation, version control, publish workflow | Visual graph designer UI (CLI/API only for MVP) |
| Policy Engine | Full | Auth-level enforcement, action-level policy, tool-call gating, rate limiting | Bank-configurable policy templates, policy simulation mode |
| Model Gateway | Full | Provider routing, retry, circuit breaker, token tracking, response caching | Multi-model comparison, fine-tuned model support, cost optimization routing |
| Knowledge Manager | Core | Document ingestion, hybrid retrieval, metadata filtering, approval workflow | Automatic document refresh, multi-format ingestion (video, audio) |
| Tool Gateway | Full | Bank connector execution, validation, idempotency, audit logging | Connector marketplace, self-service connector builder |
| Fraud & Identity Layer | Core | KBA, OTP step-up, risk scoring, fraud signal detection, ANI validation | Voice biometrics integration, device fingerprinting, behavioral analytics |
| Control Center | Core | Live session monitoring, whisper/takeover, transfer queue, session replay | Advanced analytics dashboard, workforce management integration |
| Evaluation Lab | Full | All 14 test suite categories, gate evaluation, report generation | AI caller test mode, production shadow evaluation |
| Audit Ledger | Full | Append-only event log, integrity verification, retention policies, legal hold | Cross-tenant analytics, blockchain-anchored verification |

### 3.2 Component Maturity Definitions

"Full" means the component implements all capabilities specified in its component spec that are required by the MVP workflows. "Core" means the component implements the primary capabilities but defers advanced features that require either bank-specific integration (voice biometrics vendor), production traffic data (behavioral analytics), or UI investment beyond what the pilot needs (analytics dashboard).

---

## 4. Integration Scope

### 4.1 Bank Connector Strategy

The MVP builds custom connectors for the design partner bank's core banking system. These connectors implement the Tool Gateway's standardized interface but are purpose-built for the partner's API surface.

| Integration Point | MVP Approach | GA Target |
|-------------------|-------------|-----------|
| Core banking API | Custom connector, partner-specific | Connector SDK + pre-built templates for major platforms (FIS, Temenos, Thought Machine, Mambu) |
| Card management | Custom connector | Pre-built connectors for major card processors |
| Payment rails | Custom connector, existing payees only | Faster Payments, SEPA, SWIFT integration modules |
| KYC/identity | OTP via bank's existing SMS gateway | Pluggable identity provider framework |
| Complaint management | Custom connector or file-based handoff | CRM integration (Salesforce, ServiceNow) |
| Telephony | SIP trunk to bank's existing contact center platform | CCaaS native integration (Genesys, NICE, Amazon Connect) |

### 4.2 Model Provider Assumptions

The MVP uses cloud-hosted LLM APIs. The model provider selection for pilot is:

| Capability | Primary Provider | Fallback | Notes |
|-----------|-----------------|----------|-------|
| Conversation LLM | Anthropic Claude (pinned version) | OpenAI GPT-4 | Version-pinned per Principle G5 |
| ASR | Deepgram Nova-3 | Google Cloud Speech-to-Text | Streaming mode required |
| TTS | ElevenLabs or Cartesia | Google Cloud TTS | First-byte latency < 300ms target |
| Embedding model | OpenAI text-embedding-3-small | Cohere Embed v3 | For RAG retrieval |

Model provider selection is subject to the design partner bank's data processing requirements. If the bank prohibits sending customer data to specific providers, the provider matrix adjusts accordingly.

### 4.3 Deployment Assumptions

| Dimension | MVP Assumption |
|-----------|---------------|
| Hosting | Cloud (AWS or GCP), single region |
| Data residency | Same region as bank's primary data center |
| Tenancy | Single-tenant deployment for pilot |
| Network | VPN or private link to bank systems |
| Environments | Production + staging + sandbox |
| CI/CD | Automated pipeline with gate evaluation |

---

## 5. What "Done" Means for MVP

### 5.1 MVP Exit Criteria

The MVP is considered complete when all of the following are true:

1. All 8 MVP workflows pass their golden path test scenarios in the evaluation lab.
2. All blocker-severity release gates pass (safety, compliance, operational).
3. The pilot evidence pack is generated and reviewable by the bank's risk team.
4. The Control Center supports live monitoring, whisper, and takeover for all MVP workflows.
5. The Audit Ledger produces a complete, tamper-evident event trail for every call.
6. Human handoff works for every escalation path, with context preserved in the transfer package.
7. The rollback mechanism is tested and functional.
8. Load testing demonstrates stable operation at the pilot's expected call volume (target: 200 concurrent sessions minimum).

### 5.2 What MVP Explicitly Does Not Need to Achieve

These are not required for pilot launch but are tracked for GA:

- Task completion rate above 75% (the MVP target is to prove safety and governance, not to maximize containment).
- Non-English language support.
- Visual graph designer (CLI/API is sufficient for MVP).
- Self-service bank onboarding.
- Connector marketplace.
- SOC 2 Type II certification (the audit architecture supports it; the certification process runs in parallel with pilot).
- Multi-region deployment.
- Production shadow evaluation and drift detection.

---

## 6. MVP Success Metrics

These metrics define what the pilot must demonstrate, not what it must achieve at production scale.

| Metric | MVP Target | GA Target | Measurement |
|--------|-----------|-----------|-------------|
| safe_resolution_rate | > 99.5% | > 99.9% | No policy violations, no unauthorized disclosures, no hallucinated financial info |
| task_completion_rate | > 50% | > 75% | Calls resolved without human escalation |
| unauthorized_disclosure_rate | 0% | 0% | Zero tolerance |
| policy_violation_rate | 0% | 0% | Zero tolerance |
| hallucinated_answer_rate | < 0.5% | < 0.1% | RAG faithfulness evaluation |
| missed_fraud_signal_rate | < 3% | < 1% | Fraud simulation suite |
| turn_latency_p95 | < 1500ms | < 1500ms | End-to-end, no-tool-call turns. See release_gates.md Section 4.2 for the component latency budget breakdown. Tool-call turns measured against p99 < 3000ms. |
| human_transfer_rate | < 40% | < 25% | Higher tolerance for MVP as workflows are being tuned |
| system_uptime | > 99.5% | > 99.9% | Measured over sustained pilot operating period (weekly rolling). Note: the > 99.9% blocker gate in release_gates.md (BG-O01) applies to individual evaluation runs, not sustained production uptime. The pilot tolerates brief planned maintenance windows that would not occur during an evaluation run. |
| repeat_call_rate | < 20% | < 15% | Callers calling back within 48 hours for same issue. Tracked during pilot; gating at GA. |
| containment_rate_without_repeat | > 40% | > 65% | task_completion_rate minus repeat_call_rate. Tracked during pilot; gating at GA. |
| audit_completeness | 100% | 100% | Every call produces a complete audit trail |

---

## 7. MVP Timeline Assumptions

| Phase | Duration | Key Deliverable |
|-------|---------|----------------|
| Phase 0: Research and specification | Complete | This document set |
| Phase 1: Technical spike | 6-8 weeks | Working voice pipeline with mock bank, audit trail, supervisor view |
| Phase 2: MVP platform | 10-14 weeks | All 12 components at MVP maturity, evaluation harness passing |
| Phase 3: Bank pilot | 8-12 weeks | Live deployment with design partner, evidence pack, success metrics |
| Phase 4: Enterprise hardening | Ongoing | Multi-tenant, multi-region, connector SDK, SOC 2 |

Total time from build start to pilot launch: approximately 6-8 months.

---

## 8. Open Questions

1. Which bank segment is the first design partner: digital bank, regional bank, credit union, card issuer, or BPO? The answer affects connector complexity, regulatory requirements, and sales cycle length.

2. Which jurisdiction is first: UK (FCA, strong APP scam regulation) or Singapore (MAS, strong AI governance)? Each has distinct compliance requirements that affect the Knowledge Manager content and compliance script tests.

3. Is the design partner willing to provide API access to their core banking system during the pilot, or will VocalIQ need to work through an integration middleware layer?

4. What is the design partner's existing contact center platform? SIP trunk integration complexity varies significantly across platforms.

5. Does the design partner require on-premise or private cloud deployment for the pilot, or is cloud acceptable? This affects the Phase 2 timeline significantly.
