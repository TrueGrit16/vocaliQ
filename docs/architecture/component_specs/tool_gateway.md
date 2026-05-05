# Component Specification: Tool Execution Gateway

**Document ID:** DOC_COMP_TG_001  
**Last Updated:** 2026-05-03  
**Owner:** Integration Engineering Lead

**Version History:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-03 | Initial specification |

**Principles Referenced:** S1 (Never build unsafe architecture), S2 (AI decisions through policy), S3 (Failure defaults to human), S4 (PCI never reaches LLM), G7 (Prohibited actions cannot be unlocked), E3 (Prefer explicit), E4 (Multi-tenancy), E5 (Test at policy boundary)


**Scope:** Covers the Tool Execution Gateway component within the VocalIQ platform. Internal implementation of this component's subcomponents is beyond scope unless it affects interface contracts.

**Assumptions:** Component operates within the VocalIQ reference architecture as defined in reference_architecture.md. Deployment follows the control-plane/data-plane split. All inter-component communication uses mTLS.

**Decisions Made:** Component boundaries and responsibilities follow the pipeline architecture. The 13-section specification template is used instead of narrative format to support direct implementation mapping.

**Alternatives Considered:** Documented in reference_architecture.md and architecture_principles.md at the architecture level. Component-level alternatives are captured in Open Questions (Section 14).

**Risks:** Component-specific failure modes documented in Section 9. Cross-component risks documented in ai_risk_register.md and operational_resilience.md.

**Source Links:** Handoff Section 12, reference_architecture.md, architecture_principles.md, ai_risk_register.md.

---

## 1. Purpose

The Tool Execution Gateway is the only component authorized to execute actions against bank systems (CRM, core banking, card processor, fraud platform, identity services, complaint management, collections, knowledge base). It enforces scoped tool permissions, schema validation, two-phase confirmation for sensitive actions, idempotency, rate limiting, and replay protection. No bank system action is executed without passing through this gateway.

The Tool Gateway is the last enforcement layer before bank systems. Even if all other safety controls fail (prompt injection bypasses the Conversation Runtime, a bug in the Policy Engine allows an unauthorized action), the Tool Gateway independently validates every request against its own tool manifest, permission model, and schema validation before executing anything.

---

## 2. Responsibilities

- Maintain the tool registry: a catalog of all available bank system actions with their risk levels, auth requirements, input schemas, and permission models
- Validate tool call requests: schema validation of inputs, forbidden input detection (e.g., no full PAN in card.block request), required field checks
- Enforce scoped permissions: verify the requesting session has the correct autonomy level, auth level, and tenant permissions to invoke the tool
- Enforce two-phase confirmation: for sensitive actions (A4, A5), require explicit customer confirmation before execution
- Enforce human approval gates: for A5 actions, verify supervisor approval before execution
- Generate and validate idempotency keys: prevent duplicate execution of the same action
- Enforce rate limiting: per-tenant, per-tool, per-session rate limits
- Implement replay protection: prevent replay attacks where a previously authorized tool call is re-submitted
- Validate tool results: check that bank system responses match expected schemas
- Manage bank system connectors: abstraction layer for different bank API formats
- Provide sandbox connectors: mock bank systems for testing and evaluation
- Emit detailed audit events for every tool call (request, validation, execution, result)

---

## 3. Non-Responsibilities

- Deciding whether the action is permitted (Policy Engine makes that decision; Tool Gateway enforces basic permission checks as defense-in-depth)
- Conversation logic (Conversation Runtime)
- Constructing the tool call parameters from caller speech (Conversation Runtime with LLM assistance)
- Fraud scoring (Fraud-Aware Identity Layer)
- Authentication (Fraud-Aware Identity Layer manages auth; Tool Gateway checks auth level)

---

## 4. Inputs

| Input | Source | Format | Notes |
|-------|--------|--------|-------|
| Tool call request | Conversation Runtime (after Policy Engine approval) | JSON | Tool ID, parameters, policy decision reference |
| Policy decision reference | Conversation Runtime | JSON | Proof that Policy Engine approved this action |
| Customer confirmation | Conversation Runtime | JSON | Customer said yes (for two-phase confirmation) |
| Human approval | Human Control Center | JSON | Supervisor approved (for A5 actions) |
| Tool registry | Control Plane | YAML/JSON | Tool manifests |
| Bank system credentials | Secrets manager | Encrypted | Per-tenant bank API credentials |

---

## 5. Outputs

| Output | Destination | Format | Notes |
|--------|-------------|--------|-------|
| Tool execution result | Conversation Runtime | JSON | Success/failure with result data |
| Tool audit events | Audit Ledger | Structured events | Full execution trail |
| Execution metrics | Observability | Prometheus metrics | Latency, success rates, error rates |

---

## 6. APIs

### 6.1 Tool Execution API

**ExecuteTool**
- `POST /execute` - Execute a tool call
  - Input: tool_id, parameters, call_id, session_id, tenant_id, policy_decision_id, idempotency_key, customer_confirmation (for two-phase), human_approval_id (for A5)
  - Returns: ToolResult (success/failure, result data, execution_id)
  - Validations performed: schema validation, permission check, idempotency check, rate limit check, replay protection

**GetToolStatus**
- `GET /executions/{execution_id}` - Check status of a tool execution (for async tools)
  - Returns: execution status, result (if complete), error (if failed)

### 6.2 Tool Registry API

**Tools**
- `GET /tools` - List all registered tools
- `GET /tools/{tool_id}` - Get tool manifest
- `POST /tools` - Register a new tool
- `PUT /tools/{tool_id}` - Update tool manifest
- `POST /tools/{tool_id}/validate` - Validate a tool request without executing

### 6.3 Connector Management API

**Connectors**
- `GET /connectors` - List bank system connectors
- `GET /connectors/{connector_id}/health` - Check connector health
- `POST /connectors/{connector_id}/test` - Test connector with sandbox request

### 6.4 Tool Manifest Schema

```yaml
tool_id: card.block
version: 1.0.0
description: Block a lost or stolen card.
risk_level: high
allowed_autonomy_levels: [A4, A5]
required_authentication: step_up
requires_customer_confirmation: true
requires_human_approval: false
input_schema:
  type: object
  required: [customer_id, card_id, reason]
  properties:
    customer_id:
      type: string
    card_id:
      type: string
    reason:
      enum: [lost, stolen, suspected_fraud]
forbidden_inputs:
  - full_pan
  - cvv
  - pin
output_schema:
  type: object
  properties:
    block_status:
      enum: [blocked, already_blocked, failed]
    blocked_at:
      type: string
      format: date-time
idempotency_required: true
rate_limit:
  per_session: 3
  per_tenant_per_minute: 100
timeout_ms: 5000
retry_policy:
  max_retries: 1
  backoff_ms: 1000
failure_behavior: transfer_to_card_services
connector_id: bank_card_processor
audit_required: true
sandbox_available: true
```

---

## 7. Data Models

### 7.1 ToolExecution

```
ToolExecution {
  execution_id: string
  tool_id: string
  tool_version: string
  call_id: string
  session_id: string
  tenant_id: string
  idempotency_key: string
  parameters: map<string, any> (validated against schema)
  policy_decision_id: string
  customer_confirmed: boolean
  human_approval_id: string (nullable)
  status: "pending" | "executing" | "succeeded" | "failed" | "timed_out"
  result: any (nullable, matches output_schema)
  error: ToolError (nullable)
  requested_at: timestamp
  executed_at: timestamp (nullable)
  completed_at: timestamp (nullable)
  latency_ms: int
  retry_count: int
}
```

### 7.2 ToolError

```
ToolError {
  error_code: string
  error_message: string
  bank_error_code: string (nullable, from bank system)
  retryable: boolean
  failure_behavior: string (from tool manifest)
}
```

---

## 8. Dependencies

| Dependency | Type | Criticality | Fallback |
|-----------|------|-------------|----------|
| Bank APIs (CRM, core banking, card processor, etc.) | External bank systems | High | Per-tool failure_behavior (transfer to human, retry, degrade) |
| Policy Engine | Internal component (decision reference) | High | Tool Gateway performs basic permission check, but full policy decision must be pre-approved |
| Secrets manager | Infrastructure | Critical | Cached credentials (short-lived) |
| Audit Ledger | Sidecar | High | Buffer execution events locally |

---

## 9. Failure Modes

| Failure | Detection | Response | Recovery |
|---------|-----------|----------|----------|
| Bank API timeout | Configurable timeout per tool | Follow tool manifest failure_behavior (transfer to human, retry, partial result) | Alert operations. Monitor bank API health. |
| Bank API error | HTTP error or application error | Log error. Follow failure_behavior. Do not retry if action may have partially executed (check idempotency). | Contact bank integration team. |
| Schema validation failure | Input doesn't match tool_id input_schema | Reject immediately. Return validation error to Conversation Runtime. | Conversation Runtime re-prompts caller or transfers to human. |
| Forbidden input detected | Input contains forbidden field (e.g., full PAN) | Reject immediately. Log security event. | Investigate how forbidden data reached Tool Gateway. |
| Idempotency violation | Duplicate idempotency_key for same tool | Return cached result from first execution. Do not re-execute. | Normal behavior. |
| Rate limit exceeded | Per-session or per-tenant limit hit | Reject with rate_limit_exceeded error. | Wait and retry, or transfer to human. |
| Replay attack detected | Request with expired or reused nonce | Reject. Log security event. | Investigate potential attack vector. |
| Connector unavailable | Health check failure | Tool calls for affected connector return unavailable error. Follow failure_behavior. | Monitor connector, retry when healthy. |
| Tool Gateway crash | Health monitoring | Active executions may be in indeterminate state. Conversation Runtime treats as failed, follows failure_behavior. | Restart. Check idempotency to avoid duplicate execution. |

---

## 10. Security Controls

- mTLS for all internal communication
- Bank API credentials stored in secrets manager, never in Tool Gateway memory beyond the execution lifetime
- Forbidden input validation: tool manifests define inputs that must never be accepted (PCI data, raw credentials)
- Idempotency keys prevent duplicate execution
- Replay protection via nonce-based request authentication with time-bound validity
- Rate limiting prevents abuse (both from compromised internal components and from excessive caller requests)
- Connector isolation: each bank connector runs in its own execution context, preventing cross-connector data leakage
- Tool manifests are version-controlled and changes require approval
- Sandbox mode: test connectors respond with mock data, clearly flagged in audit events
- No tool call without a valid policy_decision_id (defense-in-depth check)

---

## 11. Audit Events

| Event Type | Trigger | Payload |
|-----------|---------|---------|
| tool.request.received | Tool call request received | execution_id, tool_id, call_id, session_id, tenant_id, policy_decision_id, parameters_hash |
| tool.validation.passed | Schema and permission validation passed | execution_id, tool_id |
| tool.validation.failed | Schema or permission validation failed | execution_id, tool_id, failure_reason, rejected_fields |
| tool.confirmation.received | Customer confirmation for two-phase | execution_id, tool_id, confirmation_method |
| tool.approval.received | Human approval for A5 action | execution_id, tool_id, approver_id, approval_timestamp |
| tool.execution.started | Tool execution begins | execution_id, tool_id, connector_id |
| tool.execution.succeeded | Tool execution successful | execution_id, tool_id, result_hash, latency_ms |
| tool.execution.failed | Tool execution failed | execution_id, tool_id, error_code, failure_behavior_triggered |
| tool.idempotency.hit | Duplicate request returned cached result | execution_id, original_execution_id, tool_id |
| tool.ratelimit.exceeded | Rate limit triggered | tool_id, session_id, tenant_id, limit_type |
| tool.security.forbidden_input | Forbidden input detected | execution_id, tool_id, forbidden_field (no value) |
| tool.security.replay_detected | Replay attack detected | tool_id, session_id, nonce |

---

## 12. Metrics

| Metric | Type | Description |
|--------|------|-------------|
| tg_executions_total | Counter | Tool executions by tool_id and outcome |
| tg_execution_latency_ms | Histogram | Per-tool execution latency |
| tg_validation_failures_total | Counter | Validation failures by tool_id and reason |
| tg_bank_api_error_rate | Gauge | Error rate per bank system connector |
| tg_bank_api_latency_ms | Histogram | Bank API response time per connector |
| tg_idempotency_hits_total | Counter | Idempotency cache hits |
| tg_rate_limit_rejections_total | Counter | Rate limit rejections by tool_id |
| tg_two_phase_confirmations_total | Counter | Two-phase confirmations by tool_id |
| tg_human_approvals_total | Counter | Human approval requests by tool_id |
| tg_security_events_total | Counter | Security events (forbidden input, replay) |

---

## 13. Test Cases

### Functional Tests

- Execute card.block with valid parameters and policy decision: verify successful execution and audit trail
- Two-phase confirmation: submit tool call, verify system waits for customer confirmation before executing
- Human approval gate: submit A5 action, verify system waits for supervisor approval
- Idempotency: submit same tool call twice with same idempotency key, verify single execution and cached result on second call
- Forbidden input rejection: include full PAN in card.block request, verify immediate rejection

### Security Tests

- Replay protection: re-submit an authorized tool call with expired nonce, verify rejection
- Rate limiting: exceed per-session rate limit, verify rejection
- No policy decision reference: submit tool call without policy_decision_id, verify rejection
- Cross-tenant isolation: verify connector cannot access another tenant's bank credentials
- Sandbox mode: verify sandbox connector responses are flagged as test data

### Bank Integration Tests

- Test each bank system connector with sandbox: CRM read, core banking balance read, card block, card activation, complaint creation
- Connector failure handling: simulate bank API timeout, verify failure_behavior executes correctly
- Connector health check: verify health monitoring detects and reports connector status

### Performance Tests

- Tool execution overhead (excluding bank API time) under 50ms at p95
- Support 200 concurrent tool executions per instance
- Schema validation under 5ms per request
- Idempotency lookup under 2ms

---

## 14. Open Questions

- Should the Tool Gateway support asynchronous tool calls (where the bank system acknowledges receipt but the result comes later via callback)?
- How should the gateway handle tool calls that partially succeed (e.g., card blocked but notification failed)?
- Should the sandbox connectors simulate realistic latency and error rates, or should they respond instantly for faster testing?
- How should tool manifest versioning interact with graph versioning (if a graph references card.block v1.0 but the latest is v1.1)?
- Should the Tool Gateway maintain a transaction log that supports compensating actions (undo) for certain tool calls?
