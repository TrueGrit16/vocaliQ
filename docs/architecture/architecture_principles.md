# VocalIQ Architecture Principles

**Document ID:** DOC_ARCH_PRINC_001  
**Last Updated:** 2026-05-03  
**Owner:** CTO

**Version History:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-03 | Initial architecture principles |

**Purpose:** Establish the non-negotiable architecture principles that govern every design decision, component specification, and implementation choice in the VocalIQ platform. These principles exist because VocalIQ operates in regulated banking environments where design mistakes can cause direct customer harm, regulatory violation, or institutional risk. Every component spec and API contract must trace back to these principles.

**Scope:** Applies to all VocalIQ platform components, APIs, deployment configurations, and operational procedures. These principles bind the engineering team, product team, and any third-party integration work.

**Assumptions:** VocalIQ serves regulated financial institutions. The regulatory landscape spans multiple jurisdictions (Singapore, EU, UK, US) with different but overlapping requirements. Banks will scrutinize architecture decisions during procurement. The principles must hold across all deployment modes (SaaS through air-gapped).

**Decisions Made:** Principles are organized into three tiers: Safety (non-negotiable, never compromised), Governance (required for regulatory compliance, may be configured per bank), and Engineering (best practices that guide implementation). This tiering prevents "principle inflation" where everything is declared equally critical.

**Alternatives Considered:** Flat list of principles (rejected because it doesn't communicate which principles are truly non-negotiable vs. important-but-flexible). Domain-organized principles (rejected because the most important principles cut across domains).

**Risks:** Principle rigidity could slow development. Mitigation: Engineering-tier principles allow justified exceptions with documented rationale. Safety-tier principles never allow exceptions.

**Open Questions:** Should principles be versioned independently of the architecture documents they govern? Should bank-specific principle overrides be supported (e.g., a bank that requires stricter data residency than VocalIQ's default)?

**Source Links:** Handoff Section 11.1 (Architecture Principle), Sections 8-10 (banking context, regulatory context), reference_architecture.md.

---

## Tier 1: Safety Principles (Non-Negotiable)

These principles cannot be overridden, relaxed, or deferred. Any design that violates a Safety-tier principle is rejected regardless of business justification.

### S1. Never Build the Unsafe Architecture

The unsafe architecture is: customer speech -> LLM -> core banking API.

The safe architecture interposes controlled processing at every stage: media gateway, speech layer with redaction, conversation runtime with deterministic control flow, policy engine validation, scoped tool gateway with schema validation, and audit at every boundary.

No shortcut, prototype, demo, or MVP may bypass this layered control structure. If a faster path exists that skips a control layer, that path is not an optimization; it is a safety violation.

### S2. Every AI Decision Passes Through Policy Validation Before Execution

The LLM proposes. The policy engine decides. The tool gateway executes.

No action against a bank system may be triggered directly by LLM output. Every proposed action must pass through the Policy and Risk Engine, which evaluates authentication state, fraud risk, action permissions, conduct rules, and regulatory constraints before the Tool Execution Gateway accepts the request.

This separation is architectural, not prompt-based. It cannot be circumvented by prompt injection, model misbehavior, or software bugs in the conversation runtime, because the policy check is a separate service with independent authorization logic.

### S3. Failure Defaults to Human Fallback, Never to Uncontrolled AI Action

When any component fails, enters an unexpected state, or encounters conditions outside its design envelope, the system transfers the caller to a human agent. It never guesses, retries with reduced safety checks, or continues operating with degraded policy enforcement.

This applies to: model timeouts, STT failures, policy engine crashes, tool gateway errors, authentication service outages, and any other component failure. The degradation path always moves toward more human control, never toward less.

### S4. PCI and Sensitive Data Never Reach the LLM

Card numbers, CVVs, PINs, and other PCI-scoped data are captured through an isolated DTMF path in the Media Gateway and transmitted directly to the bank's card processor. This data never enters the speech-to-text pipeline, never appears in LLM prompts, and never lands in the audit ledger's text storage.

PII redaction runs between the STT output and the conversation runtime. Any data classified as PCI is stripped before the transcript reaches any AI component. The redaction layer is not optional and cannot be disabled per-tenant.

### S5. Caller Audio Never Goes Directly to the LLM

The LLM receives transcribed text only. Raw audio is processed by the Real-Time Speech Layer and converted to text before the conversation runtime sees it. This boundary prevents audio-based attacks, ensures redaction can operate on text, and maintains a clean audit trail of exactly what the model received.

Even in future architectures that support speech-to-speech models, a parallel text pipeline must exist for policy enforcement, redaction, and audit purposes. The speech-to-speech path is a UX optimization, not a replacement for the text-based control pipeline.

---

## Tier 2: Governance Principles (Required, Configurable)

These principles are required for regulatory compliance and bank trust. They may be configured per bank (e.g., different retention periods, different authentication methods) but cannot be turned off entirely.

### G1. Every External Provider Sits Behind an Abstraction Interface

Banks must be able to swap STT providers, TTS providers, LLM providers, and telephony providers without architecture changes. Banks must be able to use their own approved providers, run self-hosted alternatives, or disable external model calls entirely.

This means: typed provider interfaces (ASRProvider, TTSProvider, LLMProvider, TelephonyProvider, VectorStoreProvider, FraudSignalProvider, IdentityProvider, RealtimeModelProvider), version pinning, fallback routing, and provider-agnostic data formats throughout the pipeline.

### G2. The Data Plane Can Be Deployed Independently of the Control Plane

Banks have varying requirements for where call processing runs. Some accept SaaS. Others require their VPC. Others require on-premises deployment. The architecture must support control plane (configuration, analytics, graph design) hosted separately from the data plane (live call processing, model inference, tool execution, audit events).

This means: no runtime dependency from data plane to control plane during call processing. Configuration is loaded at startup or via asynchronous sync. A data plane outage does not affect the control plane, and a control plane outage does not drop active calls.

### G3. Audit Is a Sidecar, Not an Afterthought

Every component emits structured audit events to the Audit/Event Ledger. Audit events capture what happened (action), why it happened (policy decision, model output), what data was involved (with redaction), who was involved (caller identity, agent identity), and when it happened (timestamps with microsecond precision).

The audit trail is append-only and tamper-evident (cryptographic hash chain). No component may modify or delete audit records. Retention periods are configurable per bank and per jurisdiction.

### G4. Authentication State Is Explicitly Tracked and Never Assumed

The system maintains an explicit authentication state machine per call session. Authentication level (AUTH_0 through AUTH_5) determines what the AI can disclose and what actions it can request. Authentication is never assumed from caller ID, voice characteristics alone, or prior call history.

Step-up authentication is triggered when the requested action requires a higher auth level than the current session state. The authentication method (OTP, app push, secure link, knowledge-based) is configurable per bank.

### G5. Model Versions Are Pinned and Changes Require Validation

No model (LLM, STT, TTS, or any classification model) may change version in production without passing through the validation pipeline. The Model Gateway enforces version pinning. Provider-side model updates are blocked until VocalIQ re-validates against the test suite.

This prevents the scenario where a provider silently updates a model and VocalIQ's behavior changes without review. It also supports rollback: if a new model version degrades performance, the previous version can be restored within minutes.

### G6. Conversation Graphs Are Deterministic at the Control Flow Level

The conversation state machine owns the flow. LLM nodes propose language, extract slots, and summarize, but they do not decide which graph node to execute next. Branching logic is deterministic and defined in the graph specification. The LLM assists within nodes; it does not navigate between them.

This means conversation flows are predictable, testable, and auditable. A bank compliance team can read a graph and understand every possible path a call can take, every decision point, and every action that may be triggered.

### G7. Prohibited Actions Cannot Be Unlocked Through Conversation

Actions classified as A6 (prohibited) in the autonomy framework are enforced at three layers: the Graph Compiler rejects graphs that include prohibited action nodes, the Policy Engine denies prohibited action requests at runtime, and the Tool Gateway refuses to execute prohibited tool calls. No conversational technique, prompt injection, or social engineering can override these hard-coded prohibitions because they are not implemented through prompts or model instructions.

---

## Tier 3: Engineering Principles (Best Practices, Justified Exceptions Allowed)

These principles guide implementation decisions. They may be relaxed with documented justification, reviewed and approved by the technical lead.

### E1. Design for Latency Transparency

Every component publishes its latency contribution. The end-to-end latency budget (target: under 2000ms for 90th percentile, single turn) is decomposed across stages. If a component exceeds its budget, the system can identify the bottleneck, switch to a faster fallback, or degrade gracefully.

### E2. Design for Observability from Day One

Every component emits: distributed trace spans (with call ID as the trace root), structured JSON logs, Prometheus-compatible metrics, and health check endpoints. Observability is not bolted on after the fact. It is part of the component interface contract.

### E3. Prefer Explicit Over Implicit

Configuration is explicit, not convention-based. Dependencies are declared, not discovered. Failure modes are enumerated, not assumed. Error messages include the component name, error code, and suggested remediation. When in doubt, be verbose in internal logging and precise in external error reporting.

### E4. Design for Multi-Tenancy from Day One

Every data structure, every API call, and every audit event includes a tenant identifier. Tenant isolation is enforced at the data layer, not just the application layer. Cross-tenant data leakage is treated as a security incident, not a bug.

### E5. Test at the Policy Boundary, Not Just the Code Boundary

Unit tests validate code correctness. Integration tests validate component interactions. But the most important tests validate policy enforcement: can a caller bypass authentication? Can the AI disclose data it shouldn't? Can a prohibited action be triggered? Policy boundary tests are the release gate, and they run against the full pipeline, not against individual components in isolation.

### E6. Build for Swapability, Not for Abstraction Elegance

Provider abstraction interfaces exist to let banks swap providers, not to demonstrate software architecture patterns. If an abstraction makes it harder to understand what's happening (e.g., five layers of indirection for a simple API call), simplify it. The test is: can a bank's integration engineer understand in 30 minutes how to swap a provider?

### E7. Document Decisions, Not Just Designs

Every design document includes: what was decided, what alternatives were considered, why the chosen approach won, what risks remain, and what would trigger revisiting the decision. Architecture decision records are not overhead; they are the institutional memory that prevents the team from re-litigating settled questions.

---

## Principle Application

### How Principles Are Referenced

Each component specification, API contract, and design decision document must include a "Principles Referenced" section that lists which principles informed the design. This creates traceability from high-level principles to specific implementation choices.

### Conflict Resolution

When principles conflict (e.g., E1 Latency Transparency vs. G3 Audit completeness), the tier determines priority: Safety > Governance > Engineering. Within the same tier, the conflict is escalated to the CTO for resolution, and the decision is recorded as an architecture decision record.

### Principle Evolution

Principles are versioned. Changes to Safety-tier principles require CTO and compliance approval. Changes to Governance-tier principles require CTO approval. Changes to Engineering-tier principles require technical lead approval. All changes are documented in the version history with rationale.
