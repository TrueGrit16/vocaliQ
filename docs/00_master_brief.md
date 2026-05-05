# Context Summary: VocalIQ Bank-Grade Voice AI Platform

**Document ID:** DOC_CONTEXT_001  
**Last Updated:** 2026-05-03  
**Owner:** Chief Product Officer  
**Status:** Pre-build research phase

**Purpose:** Consolidate what is known, what has changed, and what remains unresolved before proceeding with the bank-grade research corpus and architecture specification. This document serves as the single orientation point for all downstream workstreams.

**Scope:** Covers the existing VocalIQ platform research (RESEARCH.md), the CPO's Bank-Grade Research & Architecture Handoff, and the starter source list referenced in Section 31 of the handoff. Does not include deep regulatory analysis or architecture specifications; those are produced in Steps 2-6.

**Source Links:**
- [RESEARCH.md](../RESEARCH.md) - Initial VocalIQ/GetVocal competitive research, completed 2026-05-03
- [VocalIQ_Bank_Grade_Research_Architecture_Handoff.md](../VocalIQ_Bank_Grade_Research_Architecture_Handoff.md) - CPO handoff document, 32 sections
- [GetVocal Homepage](https://www.getvocal.ai/)
- [GetVocal $26M Series A](https://www.cmswire.com/customer-experience/getvocal-raises-26m-series-a-to-scale-governed-ai-agents/)
- [GetVocal Control Center Launch](https://www.businesswire.com/news/home/20260330718259/en/)
- [Pipecat GitHub](https://github.com/pipecat-ai/pipecat)
- [LiveKit Agents GitHub](https://github.com/livekit/agents)
- [Dograh GitHub](https://github.com/dograh-hq/dograh)
- [Voice AI Stack 2026 - AssemblyAI](https://www.assemblyai.com/blog/the-voice-ai-stack-for-building-agents)

**Starter Source List Status:** The handoff's Section 31 lists regulatory sources (ESMA DORA, EU AI Act, MAS TRM Guidelines, NIST AI RMF, OWASP LLM Top 10, FinCEN deepfake alert, FCC TCPA ruling, PCI DSS v4.x), market sources (McKinsey AI-powered bank customer care, NICE/Cognigy acquisition, Genesys AI, Amazon Connect), and open-source references. These sources are cataloged for full ingestion in Step 2 (research corpus build). Initial review confirms they are accessible and relevant. Their detailed product implications will be documented per-source in the research corpus with metadata per Section 10.2 of the handoff.

## 1. What the Existing Research Already Covers

The initial research (RESEARCH.md, completed 2026-05-03) established a foundation across six areas:

**GetVocal.ai Analysis:** GetVocal is a Paris-based startup ($30M raised, Series A led by Creandum) building hybrid human-AI voice agents for enterprise CX. Key product components include a graph-based Agent Blueprint conversation designer, a real-time Control Center for human-AI collaboration (launched March 2026), and a Hybrid Workforce Platform managing both agent types. Their customers include Vodafone, Glovo, Movistar, and a Deutsche Telekom pilot. Published results include 31% fewer live escalations, 45% more self-service resolutions, and 70% deflection within 3 months.

**Competitive Landscape:** The research mapped three tiers of competitors. Enterprise platforms (Retell AI at $0.07/min, Bland AI, Cognigy, PolyAI, Replicant) handle high-volume enterprise deployments. Developer tools (Vapi with 4,200+ configuration points, Voiceflow, Synthflow) target builder-led teams. Open-source frameworks (Pipecat by Daily.co, LiveKit Agents, TEN Framework, Dograh) provide infrastructure-level orchestration.

**Open-Source Frameworks:** Pipecat offers a frame-based Python pipeline with Twilio/SIP telephony. LiveKit Agents provides WebRTC-native agent infrastructure with SIP trunking and semantic turn detection. Dograh offers a visual workflow builder, self-hosted deployment, and is positioned as the "n8n of voice AI."

**Tech Stack Mapping:** The pipeline architecture (VAD, STT, LLM, TTS) is the production default for controlled deployments. Recommended components include Deepgram Nova-3 for STT, Cartesia Sonic-3 or ElevenLabs Flash v2.5 for TTS, Silero for VAD, and Pipecat or LiveKit Agents for orchestration. Target latency: 300-600ms first syllable.

**Product Positioning:** The research identified GetVocal's gaps: EU-only focus, closed source, sales-led with no self-serve, and no public pricing. It recommended an open-core, developer-first, PLG model targeting US/APAC with transparent pricing.

**Build-vs-Buy Decisions:** Custom build recommended for conversation graph designer, human-AI control center, and agent management. Use existing frameworks for voice pipeline (Pipecat/LiveKit), telephony (Twilio SDK), knowledge base (LangChain/LlamaIndex), and authentication (NextAuth/Clerk).

## 2. What This Handoff Adds

The CPO handoff document fundamentally reframes the product for banking. It introduces eight critical dimensions absent from the initial research:

**Product Thesis Shift:** The product is no longer a general voice AI platform. It is a "governed voice automation layer for regulated banking contact centers." The bank buyer purchases lower operational risk, auditable execution, fraud-aware identity, and compliance evidence, not "human-like voice."

**Banking Workflow Taxonomy:** A six-level autonomy classification with specific use-case assignments:

| Level | Name | Example Use Cases |
|-------|------|-------------------|
| A0 | Informational only | Branch hours, ATM locator, product FAQ |
| A1 | Triage and routing | Intent classification, queue routing |
| A2 | Authenticated read-only | Application status, balance inquiry |
| A3 | Draft action | Complaint intake, case creation |
| A4 | Controlled execution | Lost card block, card activation, statement request |
| A5 | Human-approved execution | Fee waiver above threshold |
| A6 | Prohibited autonomy | Loan approval, wire transfer, investment advice, new beneficiary |

First-wave targets prioritize A0-A4 workflows with high volume, low-to-moderate risk, and clear procedural scripts.

**Regulatory Corpus Mandate:** Requirement to map regulations across Singapore, EU, UK, US, Australia, and India covering 15 risk domains: data protection, call recording consent, PCI DSS, operational resilience, outsourcing risk, model risk management, AI governance, consumer protection, complaints handling, collections, fraud, recordkeeping, accessibility, and cybersecurity. Critically, these regulatory requirements are not a parallel compliance workstream. They directly shape component architecture: call recording consent rules determine Media Gateway behavior per jurisdiction; PCI DSS constrains what data the Model Gateway can receive; MAS TRM and DORA requirements define the operational resilience and exit-plan features the platform must support; and consumer protection rules (FCA Consumer Duty, CFPB UDAAP) shape the Policy Engine's complaint and vulnerability detection triggers.

**Bank-Safe Architecture:** A layered architecture where the state machine owns the conversation, the policy engine decides what's allowed, the tool gateway executes only validated actions, and the LLM only proposes language. The explicit anti-pattern is "Customer speech -> LLM -> core banking API." The safe pattern interposes a media gateway, speech layer, conversation runtime, policy/risk engine, scoped tool gateway, and audit ledger.

**Component Specifications:** Twelve major components each requiring a technical design document: Media Gateway, Real-Time Speech Layer, Conversation Runtime, Risk-Aware Graph Compiler, Policy and Risk Engine, Model Gateway, Knowledge/RAG Service, Tool Execution Gateway, Fraud-Aware Identity Layer, Human Control Center, Audit/Event Ledger, and Evaluation/Assurance Lab.

**Graph DSL and Policy Model:** Formal conversation graph specification with risk metadata per node, 16 required node types (SpeakNode through FallbackNode), graph compiler validation rules (no high-risk tool without auth, no PCI data to LLM, no graph without human fallback), and a policy-as-code engine with authentication levels (AUTH_0 through AUTH_5) and action permission matrices.

**Threat Model Requirements:** 25+ threat categories including prompt injection by caller, synthetic voice/deepfake attacks, social engineering of AI agents, authorized push payment scams, cross-tenant data leakage, hallucinated policy terms, and DTMF/PSTN attacks. The architectural response to these threats is structural, not prompt-based: LLM output is treated as a proposal that deterministic controllers validate before action; tool permissions are enforced by the tool gateway outside the LLM's control; prompts are versioned, approved, and tested before deployment; no raw PCI sensitive authentication data reaches any model call; and user speech is classified as untrusted input at every stage. This "least agency" principle is a defining characteristic of the bank-grade architecture.

**Evidence Pack for Bank Procurement:** Banks require security questionnaires, architecture diagrams, data-flow diagrams, SOC 2/ISO 27001 evidence, penetration test reports, model-risk assessments, AI governance packs, and incident response policies. These are product requirements, not afterthoughts.

## 3. Unresolved Assumptions

The following assumptions remain open and require decisions before architecture finalization:

**Geography:** No first launch market selected. Singapore, EU, UK, and US are all candidates. Each has different regulatory requirements, language needs, and market dynamics. This choice affects compliance scope, language support, deployment options, and go-to-market strategy.

**Target Segment:** No first buyer segment selected. Digital banks, regional banks, credit unions, card issuers, and bank BPOs are all candidates. This affects feature priority, sales cycle expectations, deployment requirements, and pricing model.

**CCaaS Integration:** No contact-center platform selected for first integration. Banks typically run NICE CXone, Genesys Cloud CX, Amazon Connect, Five9, Cisco, Avaya, Talkdesk, or Twilio Flex. The integration path shapes the media gateway design and go-to-market approach.

**Voice Runtime:** Pipecat vs. LiveKit Agents is unresolved. Both support telephony and streaming pipelines, but differ in WebRTC maturity, community size, provider abstraction, and self-hosting story. This is a foundational architecture decision.

**Model Providers:** No approved LLM, STT, or TTS providers selected for prototype or pilot. Banks may require approved providers, self-hosted options, or integration with bank-owned model gateways. Data residency and contractual terms vary by provider.

**Policy Engine:** OPA/Rego, Cedar, or custom DSL remains unresolved. This affects explainability, business-user maintainability, versioning, testability, and runtime latency.

**Event Store:** Postgres append-only vs. Kafka/NATS stream vs. both. Affects audit replay, tamper evidence, and operational complexity.

**RAG Backend:** Postgres pgvector vs. OpenSearch vs. Vespa vs. managed vector DB. Affects metadata filtering, ACL support, hybrid search, and on-prem deployment.

**Deployment Mode:** Unknown whether the first target requires SaaS multi-tenant, single-tenant SaaS, customer VPC, hybrid, or full on-prem. This affects infrastructure investment and timeline.

**Inbound vs. Outbound:** Unclear whether first wedge is inbound servicing only (lower risk, simpler consent) or includes outbound (requires campaign consent, DNC lists, calling windows).

## 4. Decisions Required Before Build

These decisions must be made to unblock architecture finalization and implementation:

1. **Launch Market:** Select one of SG, EU, UK, or US as the primary jurisdiction. This gates regulatory scope, language requirements, and compliance investment.

2. **First Buyer Segment:** Select digital bank, regional bank, or bank BPO as first target. This gates feature prioritization and sales approach.

3. **MVP Workflow Selection:** Confirm the 12 MVP workflows listed in Section 21.2 of the handoff, or narrow the scope further for the technical spike.

4. **Voice Runtime Selection:** Evaluate and select Pipecat or LiveKit Agents based on telephony support, latency, observability, self-hosting, and community maturity.

5. **Telephony Path:** Select Twilio, Telnyx, SIP BYOC, or CCaaS-native integration for the first deployment.

6. **Model Provider Assumptions:** Select initial STT, TTS, and LLM providers for prototype, with abstraction layer for future swaps.

7. **Policy Engine Selection:** Evaluate OPA/Rego, Cedar, and custom DSL against explainability, bank-user maintainability, and performance requirements.

8. **Event Store Design:** Select initial architecture for the audit ledger (Postgres append-only for MVP, with migration path to streaming).

9. **RAG Backend Selection:** Select vector store technology considering metadata filtering, ACL support, and on-prem deployment needs.

10. **Graph Designer Scope:** Determine minimum viable graph designer UI needed before pilot (declarative YAML + viewer vs. full visual drag-and-drop builder).

## 5. Recommended Decision Approach

For decisions 1-3 (market, segment, workflows), the CPO or product lead should decide based on business relationships and market access.

For decisions 4-10 (technical stack), the research corpus (Steps 2-3) and architecture specification (Step 6) should produce evidence-based recommendations. Each recommendation should include alternatives considered, tradeoffs, and reversibility assessment.

**IMPORTANT: The defaults below are provisional research assumptions only.** They carry no approval authority and exist solely to unblock research and specification work. Any downstream document that depends on these assumptions must flag that dependency explicitly. These defaults will be formally reviewed and either confirmed or replaced during Step 10 (Build Readiness Review).

Default assumptions for research purposes (subject to override):

- **Geography:** Singapore as primary (MAS regulatory framework is well-documented and the existing AURA/UOB context provides domain familiarity), with EU and UK as secondary.
- **Segment:** Digital banks and bank BPOs as first targets (shorter sales cycles, more open to new vendors).
- **Wedge:** Inbound servicing only in first release.
- **Runtime:** Evaluate both Pipecat and LiveKit Agents; recommend one.
- **Telephony:** Twilio as primary (global coverage, developer ecosystem), with Telnyx as alternative.
- **Models:** Deepgram Nova-3 (STT), Cartesia Sonic-3 (TTS), Claude/GPT-4o (LLM) for prototype. Provider-agnostic abstraction from day one.
- **Event store:** Postgres append-only for MVP, Kafka migration path documented.
- **RAG:** Postgres pgvector for MVP (simpler deployment, adequate for approved-content-only use case).
- **Policy:** Evaluate OPA/Rego as first candidate (mature ecosystem, versioning, testability).
- **Graph designer:** Declarative YAML/JSON with validation API + basic viewer UI for MVP. Full visual builder for Phase 2.

## 6. Key Risks

These risks are drawn from Section 29 of the handoff and represent the most material threats to the project:

**Gimmick Risk:** The product becomes a polished voice demo that no bank can actually approve. Mitigation: build around policy, audit, fraud, and compliance evidence from day one. The handoff's 12 architecture principles (Section 30) exist specifically to prevent this.

**Incumbent Platform Risk:** CCaaS vendors (NICE/Cognigy, Genesys, Amazon Connect) bundle similar AI features into platforms banks already use. Mitigation: differentiate on bank-grade governance (risk-aware graph compiler, tool gateway, fraud-aware identity, assurance lab) and integrate with incumbents rather than only competing.

**LLM Autonomy Risk:** The LLM makes decisions or calls tools outside policy boundaries. Mitigation: enforce the "least agency" principle structurally. The LLM proposes, the policy engine decides, the tool gateway executes. This is architectural, not prompt-based.

**Fraud Amplification Risk:** The AI agent becomes a new attack surface for account takeover or authorized push payment scams. Mitigation: fraud-aware identity layer, action restrictions, step-up authentication, safe callback protocol, and fraud simulation testing before every release.

**Integration Underestimation Risk:** Bank-system integration consumes most project time and budget. Mitigation: build a connector framework and bank-system simulator early. Do not defer integration design.

**Evaluation Debt Risk:** Product works in demo but fails on production phone calls with real audio conditions. Mitigation: make the Evaluation/Assurance Lab a P0 component, not a Phase 2 afterthought.

## 7. Open Questions

Beyond the 10 decisions listed in Section 4, these questions are flagged for resolution during the research and specification phases:

- What exact data fields will be sent to external model providers, and what redaction is required?
- Can bank customer data be used for model training? (Default assumption: no.)
- How will PCI scope be minimized for card-related workflows?
- What is the incident response process for wrong AI answers that cause customer harm?
- What is the exit plan if a bank terminates the VocalIQ service?
- Who approves prompt, graph, model, and policy changes in the production workflow?
- How will audit logs be made tamper-evident (hash chains, append-only, or external timestamping)?
- What is the minimum viable model registry for tracking which models are approved for which tasks?
