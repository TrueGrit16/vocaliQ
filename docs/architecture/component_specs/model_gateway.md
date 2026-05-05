# Component Specification: Model Gateway

**Document ID:** DOC_COMP_MGW_001  
**Last Updated:** 2026-05-03  
**Owner:** ML Platform Lead

**Version History:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-03 | Initial specification |

**Principles Referenced:** S4 (PCI never reaches LLM), S5 (Audio never goes to LLM), G1 (Provider abstraction), G5 (Model version pinning), G3 (Audit sidecar), E1 (Latency transparency), E4 (Multi-tenancy)


**Scope:** Covers the Model Gateway component within the VocalIQ platform. Internal implementation of this component's subcomponents is beyond scope unless it affects interface contracts.

**Assumptions:** Component operates within the VocalIQ reference architecture as defined in reference_architecture.md. Deployment follows the control-plane/data-plane split. All inter-component communication uses mTLS.

**Decisions Made:** Component boundaries and responsibilities follow the pipeline architecture. The 13-section specification template is used instead of narrative format to support direct implementation mapping.

**Alternatives Considered:** Documented in reference_architecture.md and architecture_principles.md at the architecture level. Component-level alternatives are captured in Open Questions (Section 14).

**Risks:** Component-specific failure modes documented in Section 9. Cross-component risks documented in ai_risk_register.md and operational_resilience.md.

**Source Links:** Handoff Section 12, reference_architecture.md, architecture_principles.md, ai_risk_register.md.

---

## 1. Purpose

The Model Gateway centralizes all LLM and classification model calls in the VocalIQ platform and enforces model governance. It acts as a controlled proxy between the Conversation Runtime (and other consuming components) and model providers (commercial LLM APIs, self-hosted models, bank-owned model gateways). It provides version pinning, prompt template management, input redaction, output logging, safety filtering, provider fallback, token/cost tracking, and the model registry that tracks every model deployed in the platform.

No VocalIQ component calls an LLM directly. All model calls go through the Model Gateway.

---

## 2. Responsibilities

- Maintain the approved model registry (every model, version, provider, risk tier, validation status)
- Route model calls to the correct provider based on tenant configuration, region, and model type
- Enforce version pinning: prevent automatic model updates by providers
- Manage prompt templates and prompt versioning (prompts are code, not freeform text)
- Redact PII/PCI from model inputs (defense-in-depth, in addition to Speech Layer redaction)
- Filter model outputs for safety violations (toxic content, advice boundary violations, hallucination indicators)
- Track token usage and cost per call, per tenant, per model
- Log model inputs and outputs with configurable retention (sensitive data controls apply)
- Implement provider fallback: if primary provider fails, route to secondary
- Support model comparison (A/B testing) for evaluating model alternatives
- Support bank-owned model gateway integration (banks that require all LLM calls through their own proxy)
- Enforce no-training guarantees: ensure model providers do not train on customer data

---

## 3. Non-Responsibilities

- Conversation logic or prompt composition (Conversation Runtime composes prompts; Model Gateway manages templates)
- Policy decisions (Policy Engine)
- Speech-to-text or text-to-speech (Speech Layer manages ASR/TTS providers)
- Model training or fine-tuning (separate ML pipeline, not part of the real-time call path)
- Model validation (Model Validation Team conducts validation; Model Gateway enforces that only validated models are deployed)

---

## 4. Inputs

| Input | Source | Format | Notes |
|-------|--------|--------|-------|
| Model inference request | Conversation Runtime (primarily) | JSON | Prompt, model ID, parameters |
| Classification request | Various components | JSON | Input text, classifier model ID |
| Prompt template | Prompt registry (Control Plane) | Template with variables | Versioned prompt templates |
| Model configuration | Control Plane | JSON | Provider routing, version pins, fallback config |
| Tenant model policy | Control Plane | JSON | Allowed models, region restrictions, cost limits |
| Redaction rules | Control Plane | JSON | Additional redaction patterns for model inputs |

---

## 5. Outputs

| Output | Destination | Format | Notes |
|--------|-------------|--------|-------|
| Model response | Requesting component | JSON | Generated text, token counts, model metadata |
| Classification result | Requesting component | JSON | Labels, scores, confidence |
| Token/cost tracking events | Observability, billing | Metrics/events | Per-call cost tracking |
| Model call audit event | Audit Ledger | Structured event | Input hash, output hash, model version, latency |
| Safety filter events | Audit Ledger | Structured event | When output is filtered or flagged |

---

## 6. APIs

### 6.1 Inference API

**GenerateResponse**
- `POST /inference/generate` - Generate text from an LLM
  - Input: prompt (or prompt_template_id + variables), model_id, parameters (temperature, max_tokens, stop_sequences), call_id, tenant_id
  - Returns: generated_text, token_counts (prompt, completion), model_version, provider, latency_ms, safety_flags
  - Supports streaming: `POST /inference/generate/stream` returns server-sent events with partial tokens

**Classify**
- `POST /inference/classify` - Run a classification model
  - Input: text, classifier_model_id, call_id, tenant_id
  - Returns: labels with scores, model_version, latency_ms

### 6.2 Model Registry API

**Models**
- `GET /models` - List all registered models with status
- `GET /models/{model_id}` - Get model card (version, provider, risk tier, validation status, metrics)
- `POST /models` - Register a new model
- `PUT /models/{model_id}` - Update model registration (version pin, provider, status)
- `POST /models/{model_id}/validate` - Record validation result

### 6.3 Prompt Registry API

**Prompts**
- `GET /prompts` - List prompt templates
- `GET /prompts/{template_id}` - Get specific prompt template with version history
- `POST /prompts` - Register new prompt template
- `PUT /prompts/{template_id}` - Update prompt template (creates new version)
- `POST /prompts/{template_id}/render` - Render a prompt template with variables (for testing)

### 6.4 Provider Abstraction Interface

```
interface LLMProvider {
  generate(prompt: string, config: GenerationConfig): GenerationResult
  generateStream(prompt: string, config: GenerationConfig): AsyncStream<Token>
  getModels(): ModelInfo[]
  getModelVersion(modelId: string): string
  healthCheck(): ProviderHealth
}
```

Implementations: provider-specific adapters, bank-owned gateway adapter, self-hosted model adapter

---

## 7. Data Models

### 7.1 ModelRegistryEntry

```
ModelRegistryEntry {
  model_id: string
  name: string
  model_type: "llm" | "classifier" | "embedding" | "reranker"
  provider: string
  provider_model_id: string
  version: string (pinned)
  risk_tier: "critical" | "high" | "medium" | "low"
  validation_status: "validated" | "pending_validation" | "validation_expired"
  last_validated: timestamp
  next_validation_due: timestamp
  deployment: "hosted_api" | "self_hosted"
  region_restrictions: string[]
  tenants_allowed: string[] (empty = all)
  fallback_model_id: string (nullable)
  cost_per_1k_input_tokens: decimal
  cost_per_1k_output_tokens: decimal
  max_context_window: int
  owner: string
}
```

### 7.2 PromptTemplate

```
PromptTemplate {
  template_id: string
  name: string
  version: string
  purpose: string
  template_text: string (with {{variable}} placeholders)
  required_variables: string[]
  optional_variables: string[]
  model_compatibility: string[] (which models this template works with)
  max_expected_tokens: int
  created_by: string
  approved_by: string
  effective_from: timestamp
  tags: string[]
}
```

### 7.3 InferenceLog

```
InferenceLog {
  request_id: string
  call_id: string
  tenant_id: string
  model_id: string
  model_version: string
  provider: string
  prompt_template_id: string
  prompt_hash: string (hash of rendered prompt, not the prompt itself for PII safety)
  input_token_count: int
  output_token_count: int
  latency_ms: int
  time_to_first_token_ms: int
  safety_flags: string[]
  redactions_applied: int
  cost_usd: decimal
  timestamp: timestamp
}
```

---

## 8. Dependencies

| Dependency | Type | Criticality | Fallback |
|-----------|------|-------------|----------|
| Primary LLM provider | External API | Critical | Secondary LLM provider (automatic failover) |
| Prompt registry | Configuration | High | Cache last-known-good prompt templates |
| Model registry | Configuration | High | Cache current model configurations |
| Audit Ledger | Sidecar | High | Buffer inference logs locally |
| Conversation Runtime | Consumer | Critical | No calls without consumer, but no downstream failure impact |

---

## 9. Failure Modes

| Failure | Detection | Response | Recovery |
|---------|-----------|----------|----------|
| Primary LLM provider outage | API errors, circuit breaker | Switch to secondary LLM provider. Log switch. Accept potential quality difference. | Monitor primary, switchback when healthy |
| LLM latency spike | Latency exceeds 2x baseline | Alert operations. If sustained (>60s), switch to secondary provider. | Investigate with provider. Switchback when resolved. |
| Safety filter triggers | Output contains flagged content | Suppress output. Return safe fallback. Log event. Alert if frequency spikes. | Investigate prompt template or model behavior |
| Token limit exceeded | Prompt + response exceed context window | Truncate conversation history in prompt. Log truncation. | Conversation Runtime should manage context window proactively |
| Provider rate limit hit | HTTP 429 from provider | Queue requests briefly. If sustained, switch to secondary. | Request rate limit increase with provider. Capacity planning. |
| Model version mismatch | Provider returns different version than pinned | Alert immediately. Block requests to that model until version is confirmed. | Contact provider. Pin correct version. Re-validate if needed. |
| Redaction engine failure | Processing error | Block request. Do not send unredacted input to model. Alert. | Restart redaction service |
| Cost threshold exceeded | Per-tenant cost tracking | Alert operations and tenant admin. Optionally rate-limit calls. | Review cost trends. Adjust cost thresholds. |

---

## 10. Security Controls

- All provider communication over TLS 1.3
- mTLS between Model Gateway and all internal components
- PII/PCI redaction applied to all model inputs before transmission (defense-in-depth layer, supplementing Speech Layer redaction)
- Model output logging uses configurable retention: full output for debugging (short retention), hashed output for audit (long retention)
- Provider data processing agreements prohibit training on customer data
- Version pinning prevents unannounced model changes
- Prompt templates are version-controlled and access-restricted (prompt injection via template modification is mitigated through RBAC and change tracking)
- Bank-owned model gateway integration: when configured, all model calls route through the bank's proxy, ensuring the bank controls which models are used and what data leaves their infrastructure
- Region routing: model calls are routed to region-appropriate endpoints (e.g., Singapore data stays in Singapore region)

---

## 11. Audit Events

| Event Type | Trigger | Payload |
|-----------|---------|---------|
| model.inference.request | Model call initiated | request_id, call_id, model_id, model_version, prompt_template_id, input_tokens |
| model.inference.response | Model response received | request_id, output_tokens, latency_ms, time_to_first_token_ms, safety_flags |
| model.inference.error | Model call failed | request_id, error_type, provider, retry_count |
| model.safety.filtered | Output filtered by safety check | request_id, filter_type, action_taken |
| model.redaction.applied | Input redacted before model call | request_id, redaction_count, data_classification |
| model.provider.switched | Failover to secondary provider | from_provider, to_provider, reason |
| model.version.changed | Model version updated in registry | model_id, from_version, to_version, changed_by |
| prompt.version.published | Prompt template version published | template_id, version, published_by |

---

## 12. Metrics

| Metric | Type | Description |
|--------|------|-------------|
| mgw_inference_latency_ms | Histogram | Total inference latency by model and provider |
| mgw_time_to_first_token_ms | Histogram | Streaming: time to first token |
| mgw_token_count_input | Histogram | Input token count per request |
| mgw_token_count_output | Histogram | Output token count per request |
| mgw_cost_usd | Counter | Cumulative cost per tenant, per model |
| mgw_provider_error_rate | Gauge | Error rate per provider |
| mgw_safety_filter_rate | Gauge | Percentage of responses with safety flags |
| mgw_redaction_rate | Gauge | Percentage of requests with redaction applied |
| mgw_provider_switchover_total | Counter | Provider failover events |
| mgw_active_requests | Gauge | Current in-flight inference requests |
| mgw_model_version_active | Gauge | Currently active model version per model_id |

---

## 13. Test Cases

### Functional Tests

- Standard LLM inference: submit prompt, receive response with correct metadata (tokens, latency, version)
- Streaming inference: verify token-by-token streaming with correct final aggregation
- Prompt template rendering: verify variables are correctly interpolated and the rendered prompt matches expectations
- Version pinning: verify that the gateway sends requests to the pinned model version, not the provider's latest
- Redaction: inject PCI data into prompt, verify it is redacted before reaching the provider
- Safety filtering: submit prompt that generates toxic output, verify the output is suppressed

### Failover Tests

- Primary LLM provider outage: verify automatic switchover to secondary within 10 seconds
- Rate limiting: verify graceful degradation when provider returns 429
- Model version mismatch: verify request is blocked and alert is generated

### Cost Tracking Tests

- Verify per-call, per-tenant cost tracking accuracy against provider billing
- Verify cost threshold alerts trigger at configured limits

### Performance Tests

- Inference latency under 1500ms at p90 for standard requests
- Time to first token under 300ms at p90 for streaming
- Support 500 concurrent inference requests per instance
- Redaction overhead under 10ms per request

### Security Tests

- Verify PII/PCI never appears in provider-bound requests (inspect outbound traffic)
- Verify prompt templates cannot be modified without RBAC authorization
- Verify model call logs respect retention policies

---

## 14. Open Questions

- Should the Model Gateway support caching of model responses for identical prompts (semantic caching), or does the regulatory requirement for per-call audit make caching impractical?
- Should the gateway support multiple concurrent LLM calls per turn (e.g., parallel intent classification and response generation)?
- How should the gateway handle bank-owned model gateways that have different API schemas than standard providers?
- Should prompt templates support conditional sections (e.g., include vulnerability-sensitive language only when vulnerability indicators are present)?
- What is the appropriate retention period for full model input/output logs vs. hashed audit records?
