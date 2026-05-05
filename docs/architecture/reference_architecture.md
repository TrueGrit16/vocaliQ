# VocalIQ Reference Architecture

**Document ID:** DOC_REF_ARCH_001  
**Last Updated:** 2026-05-03  
**Owner:** CTO

**Version History:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-03 | Initial reference architecture |

**Purpose:** Define VocalIQ's end-to-end system architecture for governed voice automation in regulated banking contact centers. This document establishes the component topology, data flow, deployment model, and architectural constraints that every component spec, API contract, and implementation decision must conform to.

**Scope:** Covers the complete runtime architecture (call processing pipeline), control plane architecture (management and configuration), and sidecar services (audit, monitoring, security). Does not cover internal implementation of individual components (those are in component_specs/) or API contracts (those are in api_contracts/).

**Assumptions:** Primary deployment model is cloud-hosted SaaS with data plane isolation capability per bank requirements. Telephony integration via Twilio (primary) with provider abstraction for alternatives. Pipeline architecture (VAD -> STT -> LLM -> TTS) chosen over speech-to-speech for control, debuggability, and compliance. Singapore as primary jurisdiction with EU, UK, US as secondary.

**Decisions Made:** Pipeline architecture over speech-to-speech because the pipeline approach gives VocalIQ control at each processing stage (redaction between STT and LLM, policy validation between LLM and tool execution, audit at every boundary). This is a core differentiator: competitors using speech-to-speech cannot offer the same granularity of policy enforcement.

**Alternatives Considered:** Speech-to-speech architecture (lower latency but no control between speech and action). Monolithic architecture (simpler deployment but no bank VPC/hybrid deployment support). Event-driven architecture throughout (flexible but harder to reason about call processing latency).

**Risks:** Pipeline architecture adds latency compared to speech-to-speech. Component boundaries create integration complexity. Multi-provider abstraction adds development and testing surface area.

**Open Questions:** Should the Model Gateway support streaming inference for LLMs (reduced latency) or batch inference (simpler error handling)? Should the Graph Compiler be a build-time-only tool or also run at deployment time for dynamic graph updates?

**Source Links:** Handoff Section 11 (Target Reference Architecture), Sections 12-21 (Component Specifications).

---

## 1. Architecture Principles

See architecture_principles.md for the full set. Key principles governing this architecture:

1. Never build the unsafe architecture (customer speech -> LLM -> core banking API)
2. Every AI decision passes through policy validation before execution
3. Every external provider sits behind an abstraction interface
4. The data plane can be deployed independently of the control plane
5. Audit is a sidecar, not an afterthought: every component emits structured audit events
6. Failure modes default to human fallback, never to uncontrolled AI action

---

## 2. System Topology

### 2.1 Call Processing Pipeline (Data Plane)

The core call processing pipeline follows this sequence:

```
Telephony (SIP/WebRTC/Twilio)
    |
    v
Media Gateway
  - SIP/WebRTC termination
  - Call recording policy
  - DTMF secure capture (isolated path)
  - Audio stream routing
  - Region pinning
    |
    v
Real-Time Speech Layer
  - Voice Activity Detection (VAD)
  - Streaming ASR (Speech-to-Text)
  - Endpointing
  - Barge-in detection
  - TTS streaming (Text-to-Speech)
  - Language detection
  - PII/PCI redaction (pre-model)
    |
    v
Conversation Runtime
  - Graph state machine
  - Deterministic nodes (scripted flows)
  - LLM-assisted nodes (dynamic conversation)
  - Slot extraction and validation
  - Repair loops (clarification, re-prompting)
  - Handoff logic
    |
    +------> Policy & Risk Engine
    |          - Authentication rules
    |          - Action ACLs
    |          - Fraud rules
    |          - Conduct rules
    |          - Escalation triggers
    |
    +------> RAG / Knowledge Service
    |          - Approved content retrieval
    |          - Citation tracking
    |          - Answer boundary enforcement
    |          - Content versioning
    |
    +------> Model Gateway
    |          - LLM provider abstraction
    |          - Version pinning
    |          - Fallback routing
    |          - Token/cost tracking
    |
    v
Tool Execution Gateway
  - Scoped tool permissions
  - Schema validation
  - Two-phase confirmation
  - Idempotency
  - Rate limiting
  - Replay protection
    |
    v
Bank Systems
  - CRM, Core Banking, Card Processor
  - Fraud Platform, Identity/MFA
  - Complaint/Case Management
  - Collections, Knowledge Base
```

### 2.2 Sidecar Services

These services run alongside the pipeline but are not in the critical call path:

```
Audit / Event Ledger
  - Append-only event store
  - Tamper-evident (cryptographic hashing)
  - Call-level and event-level records
  - Retention policy enforcement

Fraud-Aware Identity Layer
  - Caller risk scoring (real-time)
  - Voice liveness detection
  - Multi-session correlation
  - Authentication state management

Human Control Center
  - Real-time supervisor dashboard
  - Call monitoring and intervention
  - Approval workflows (A5 actions)
  - Queue management integration

Evaluation & Assurance Lab
  - Automated test execution
  - Golden call suites
  - Adversarial testing
  - Performance benchmarking
  - Release gate validation

Observability
  - Distributed tracing (call-level)
  - Metrics collection
  - Alerting
  - Log aggregation
```

### 2.3 Control Plane

```
Tenant Management
  - Bank onboarding
  - Configuration management
  - Feature flags

Graph Designer
  - Visual workflow builder
  - Node library
  - Graph validation (pre-deployment)

Version Management
  - Graph versions
  - Policy versions
  - Knowledge base versions
  - Model versions

Policy Management UI
  - Rule authoring
  - Threshold configuration
  - Simulation testing

Analytics Dashboards
  - Call metrics
  - Containment rates
  - Error rates
  - Compliance reporting

Admin / RBAC
  - User management
  - Role-based access control
  - API key management
```

---

## 3. Data Flow

### 3.1 Inbound Call Flow

1. Caller dials bank number. Telephony provider routes to VocalIQ Media Gateway.
2. Media Gateway establishes audio stream, starts recording (per jurisdiction consent rules), assigns call ID.
3. Real-Time Speech Layer receives audio stream. VAD detects speech. Streaming ASR produces text. PCI redaction runs on text before forwarding.
4. Conversation Runtime receives transcribed text. Loads appropriate graph based on intent classification (or starts with root graph). Executes graph nodes.
5. For LLM-assisted nodes: Conversation Runtime sends prompt to Model Gateway. Model Gateway routes to LLM provider. Response returns through Model Gateway.
6. For tool calls: Conversation Runtime sends action request to Policy Engine for validation. If approved, Tool Gateway executes against bank systems.
7. Conversation Runtime generates response text. Text sent to Speech Layer for TTS. Audio streamed to caller via Media Gateway.
8. Throughout: Audit Ledger receives events from every component. Fraud-Aware Identity Layer continuously updates risk score. Human Control Center receives monitoring feed.

### 3.2 Data Boundaries

Critical data isolation rules:

- PCI data (card numbers, CVVs) must be redacted before reaching Model Gateway or Audit Ledger text storage
- Caller audio is routed to STT only, never directly to LLM
- LLM receives transcribed text only, never raw audio
- Bank system credentials are stored in Tool Gateway only, never in Conversation Runtime or Model Gateway
- Audit events are append-only; no component can modify or delete audit records
- Customer data from bank systems is scoped per call session; no cross-session data leakage

---

## 4. Deployment Architecture

### 4.1 Deployment Modes

| Mode | Control Plane | Data Plane | Target Buyer |
|------|--------------|------------|--------------|
| SaaS multi-tenant | Shared | Shared (tenant-isolated) | Pilots, non-sensitive workflows |
| Single-tenant SaaS | Shared | Dedicated | Mid-market regulated banks |
| Customer VPC | Shared (SaaS) | Customer cloud account | Banks with data controls |
| Hybrid | SaaS | Customer-hosted | Enterprise banks |
| Full on-premises | Customer-hosted | Customer-hosted | Highly regulated banks |
| Air-gapped | Customer-hosted | Customer-hosted, self-hosted models | Sovereign/high-security |

### 4.2 Provider Abstraction Interfaces

Every external provider sits behind a typed interface:

```
ASRProvider       - Speech-to-text providers (Deepgram, Google, Whisper, Azure)
TTSProvider       - Text-to-speech providers (Cartesia, ElevenLabs, Azure)
LLMProvider       - Large language model providers (commercial LLM APIs)
TelephonyProvider - Telephony providers (Twilio, Telnyx, Vonage)
VectorStoreProvider - Vector database for RAG (Postgres pgvector, Pinecone)
FraudSignalProvider - External fraud signals (bank fraud platform)
IdentityProvider  - Authentication services (bank identity/MFA)
RealtimeModelProvider - Speech-to-speech model providers (future, for latency-optimized paths)
```

Banks can swap providers, use their own approved providers, or run self-hosted alternatives without architecture changes.

---

## 5. Component Inventory

| # | Component | Location | Critical Path? |
|---|-----------|----------|---------------|
| 1 | Media Gateway | component_specs/media_gateway.md | Yes |
| 2 | Real-Time Speech Layer | component_specs/speech_layer.md | Yes |
| 3 | Conversation Runtime | component_specs/conversation_runtime.md | Yes |
| 4 | Risk-Aware Graph Compiler | component_specs/graph_compiler.md | Build-time |
| 5 | Policy & Risk Engine | component_specs/policy_engine.md | Yes |
| 6 | Model Gateway | component_specs/model_gateway.md | Yes |
| 7 | RAG / Knowledge Service | component_specs/rag_service.md | Conditional |
| 8 | Tool Execution Gateway | component_specs/tool_gateway.md | Yes (for A2+) |
| 9 | Fraud-Aware Identity Layer | component_specs/fraud_identity_layer.md | Yes (for A2+) |
| 10 | Human Control Center | component_specs/control_center.md | Sidecar |
| 11 | Audit / Event Ledger | component_specs/audit_ledger.md | Sidecar |
| 12 | Evaluation & Assurance Lab | component_specs/evaluation_lab.md | Build/test-time |

Each component spec includes: purpose, responsibilities, non-responsibilities, inputs, outputs, APIs, data models, dependencies, failure modes, security controls, audit events, metrics, test cases, and open questions.

---

## 6. Cross-Cutting Concerns

### 6.1 Latency Budget

Target end-to-end latency for a single turn (caller speaks -> AI responds):

| Stage | Budget | Notes |
|-------|--------|-------|
| VAD + endpointing | 200-400ms | Depends on endpointing strategy |
| STT (streaming) | 100-300ms | Final transcript after endpointing |
| Conversation Runtime | 50-100ms | Graph traversal, slot extraction |
| LLM inference | 500-1500ms | Provider-dependent, streaming preferred |
| Policy Engine check | 10-50ms | Pre-computed rules, in-memory evaluation |
| Tool Gateway call | 100-500ms | Bank API dependent |
| TTS (streaming) | 100-200ms | Time to first audio chunk |
| **Total** | **1060-3050ms** | Target: < 2000ms for 90th percentile |

### 6.2 Security Model

- All inter-component communication via mTLS
- All data encrypted at rest (AES-256)
- All API calls authenticated (service mesh identity)
- Role-based access control for control plane
- API key rotation for bank integrations
- Security monitoring and anomaly detection

### 6.3 Observability

- Distributed tracing: every call has a trace ID that follows the request through all components
- Structured logging: JSON logs with call ID, component, event type, timestamp
- Metrics: Prometheus-compatible metrics from every component
- Alerting: configurable alerts on SLOs (latency, error rate, containment rate)
