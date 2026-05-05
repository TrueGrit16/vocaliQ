# Component Specification: Policy and Risk Engine

**Document ID:** DOC_COMP_PE_001  
**Last Updated:** 2026-05-03  
**Owner:** Risk Engineering Lead

**Version History:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-03 | Initial specification |

**Principles Referenced:** S2 (AI decisions through policy validation), S3 (Failure defaults to human), G4 (Authentication explicitly tracked), G6 (Graphs deterministic), G7 (Prohibited actions cannot be unlocked), E1 (Latency transparency), E3 (Prefer explicit), E5 (Test at policy boundary)


**Scope:** Covers the Policy and Risk Engine component within the VocalIQ platform. Internal implementation of this component's subcomponents is beyond scope unless it affects interface contracts.

**Assumptions:** Component operates within the VocalIQ reference architecture as defined in reference_architecture.md. Deployment follows the control-plane/data-plane split. All inter-component communication uses mTLS.

**Decisions Made:** Component boundaries and responsibilities follow the pipeline architecture. The 13-section specification template is used instead of narrative format to support direct implementation mapping.

**Alternatives Considered:** Documented in reference_architecture.md and architecture_principles.md at the architecture level. Component-level alternatives are captured in Open Questions (Section 14).

**Risks:** Component-specific failure modes documented in Section 9. Cross-component risks documented in ai_risk_register.md and operational_resilience.md.

**Source Links:** Handoff Section 12, reference_architecture.md, architecture_principles.md, ai_risk_register.md.

---

## 1. Purpose

The Policy and Risk Engine is the runtime decision authority for what the AI is allowed to say and do. Before any action is taken against a bank system, before any sensitive data is disclosed to a caller, and before any escalation decision is made, the Conversation Runtime requests a policy decision from this engine. The engine evaluates authentication state, fraud risk score, action permissions, jurisdiction rules, customer segment rules, conduct rules, and regulatory constraints, and returns an allow/deny decision with explainable reason codes.

The Policy Engine does not execute actions. It decides whether actions are permitted. This separation is fundamental to VocalIQ's safety architecture.

---

## 2. Responsibilities

- Evaluate policy decisions in real time during live calls (target: under 50ms per decision)
- Enforce authentication requirements: verify the session's current auth level meets the minimum required for the requested action
- Enforce action permissions: evaluate whether the requested action is permitted for the current workflow, autonomy level, and customer segment
- Enforce fraud risk thresholds: deny or restrict actions when the fraud risk score exceeds configured thresholds
- Apply jurisdiction-specific rules: different regulatory requirements by geography (SG, EU, UK, US)
- Apply product-specific rules: different permissions for retail vs. business vs. wealth banking
- Apply customer segment rules: different handling for vulnerable customers, high-net-worth, business accounts
- Enforce vulnerable customer triggers: detect and flag vulnerability indicators, restrict automation
- Enforce complaint triggers: detect complaint signals, require complaint handling procedures
- Enforce collections triggers: apply jurisdiction-specific collections rules and script requirements
- Enforce advice-boundary triggers: prevent responses that cross into regulated financial advice
- Manage human approval workflows: queue A5 actions for supervisor approval
- Produce explainable policy decisions: every decision includes reason codes, policy version, and remediation guidance
- Support policy-as-code: rules defined in a formal language (OPA/Rego candidate), versioned, testable
- Support policy simulation: test policy changes against historical call data before deployment

---

## 3. Non-Responsibilities

- LLM inference or response generation (Model Gateway, Conversation Runtime)
- Fraud risk score computation (Fraud-Aware Identity Layer computes the score; Policy Engine consumes it)
- Authentication execution (Fraud-Aware Identity Layer handles auth flows; Policy Engine checks auth state)
- Tool execution (Tool Gateway)
- Graph control flow (Conversation Runtime)

---

## 4. Inputs

| Input | Source | Format | Notes |
|-------|--------|--------|-------|
| Policy decision request | Conversation Runtime | JSON | Requested action, session context |
| Authentication state | Session context (from Fraud-Aware Identity Layer) | JSON | Current auth level (AUTH_0-AUTH_5) |
| Fraud risk score | Fraud-Aware Identity Layer | float (0-100) | Current session risk score |
| Vulnerability indicators | Conversation Runtime / Fraud-Aware Identity Layer | JSON | Detected vulnerability signals |
| Tenant policy configuration | Control Plane | JSON | Bank-specific policy rules and thresholds |
| Jurisdiction context | Session context | string | Caller jurisdiction |
| Customer segment | Session context (from bank CRM) | string | Retail, business, wealth, etc. |
| Policy rules bundle | Policy management (OPA/Rego bundles) | Rego/JSON | Versioned policy rules |

---

## 5. Outputs

| Output | Destination | Format | Notes |
|--------|-------------|--------|-------|
| Policy decision | Conversation Runtime | JSON (see example) | Allow/deny with reason codes |
| Decision audit event | Audit Ledger | Structured event | Every decision logged |
| Approval request | Human Control Center | JSON | For A5 actions requiring human approval |
| Policy metrics | Observability | Prometheus metrics | Decision rates, latency, denial reasons |

### Example Policy Decision

```json
{
  "decision_id": "pd_789",
  "call_id": "call_123",
  "session_id": "sess_456",
  "tenant_id": "bank_abc",
  "graph_node_id": "read_balance",
  "requested_action": "account.balance.read",
  "decision": "deny",
  "reason_codes": ["AUTH_LEVEL_TOO_LOW", "CALLER_RISK_MEDIUM"],
  "current_auth_level": "AUTH_1",
  "required_auth_level": "AUTH_2",
  "current_risk_score": 42,
  "risk_threshold": 50,
  "required_next_step": "STEP_UP_AUTH",
  "step_up_methods": ["app_push", "otp"],
  "policy_version": "retail_policy_2026_05_01",
  "jurisdiction": "SG",
  "evaluated_at": "2026-05-03T08:30:00Z",
  "evaluation_duration_ms": 12
}
```

---

## 6. APIs

### 6.1 Decision API

**EvaluatePolicy**
- `POST /evaluate` - Request a policy decision
  - Input: requested_action, session_context (auth level, risk score, jurisdiction, customer segment, vulnerability indicators), graph_node_id
  - Returns: PolicyDecision (allow/deny/require_approval, reason codes, required next step)
  - Latency target: under 50ms at p99
  - Stateless: all context passed in request. No session state stored in Policy Engine.

**BatchEvaluate**
- `POST /evaluate/batch` - Evaluate multiple actions simultaneously
  - Input: array of policy decision requests
  - Returns: array of PolicyDecisions
  - Use case: pre-evaluate all possible next actions to determine which options to present to the caller

### 6.2 Policy Management API

**PolicyRules**
- `GET /rules` - List active policy rules by category
- `GET /rules/{rule_id}` - Get specific rule definition
- `PUT /rules/{rule_id}` - Update a policy rule (requires approval workflow)
- `POST /rules/simulate` - Simulate a rule change against historical decisions
  - Input: proposed rule change, historical call dataset
  - Returns: impact analysis (how many decisions would change, in which direction)

**PolicyVersions**
- `GET /versions` - List policy bundle versions
- `POST /versions/publish` - Publish a new policy bundle version
  - Requires: approval chain, simulation results
- `POST /versions/rollback` - Rollback to a previous policy version

### 6.3 Permitted Action Matrix API

**ActionMatrix**
- `GET /matrix/{tenant_id}` - Get the full permitted action matrix
- `GET /matrix/{tenant_id}/actions/{action_id}` - Get requirements for a specific action
  - Returns: required auth level, permitted autonomy levels, risk thresholds, jurisdictions, customer segments

---

## 7. Data Models

### 7.1 PolicyRule

```
PolicyRule {
  rule_id: string
  name: string
  category: "authentication" | "action_permission" | "fraud_threshold" |
            "jurisdiction" | "customer_segment" | "vulnerable_customer" |
            "complaint" | "collections" | "advice_boundary" | "conduct" |
            "human_approval" | "disclosure_control"
  description: string
  rule_definition: string (Rego/policy-as-code)
  severity: "block" | "restrict" | "warn"
  applicable_jurisdictions: string[]
  applicable_products: string[]
  applicable_segments: string[]
  version: string
  effective_from: timestamp
  effective_until: timestamp (nullable)
  approved_by: string
  regulatory_references: string[]
}
```

### 7.2 PermittedAction

```
PermittedAction {
  action_id: string (e.g., "account.balance.read")
  description: string
  autonomy_levels: string[] (which A-levels can trigger this)
  minimum_auth_level: AuthLevel
  risk_score_threshold: int (deny if score exceeds this)
  requires_customer_confirmation: boolean
  requires_human_approval: boolean
  jurisdiction_restrictions: map<string, ActionRestriction>
  cooling_off_rules: CoolingOffRule[] (e.g., no sensitive actions for 24h after contact detail change)
}
```

### 7.3 PolicyDecision

```
PolicyDecision {
  decision_id: string
  call_id: string
  session_id: string
  tenant_id: string
  requested_action: string
  decision: "allow" | "deny" | "require_approval" | "require_step_up"
  reason_codes: string[]
  current_auth_level: AuthLevel
  required_auth_level: AuthLevel
  current_risk_score: float
  risk_threshold: float
  required_next_step: string (nullable)
  policy_version: string
  rules_evaluated: string[] (rule IDs that participated in decision)
  jurisdiction: string
  evaluated_at: timestamp
  evaluation_duration_ms: int
}
```

---

## 8. Dependencies

| Dependency | Type | Criticality | Fallback |
|-----------|------|-------------|----------|
| Policy rules bundle | Configuration | Critical | Use last-known-good cached bundle. Alert if stale. |
| Fraud risk score (from session context) | Data input | High | If risk score unavailable, treat as high risk (conservative default) |
| Authentication state (from session context) | Data input | Critical | If auth state unknown, treat as AUTH_0 (most restrictive) |
| Audit Ledger | Sidecar | High | Buffer decision events locally |
| Human Control Center | Internal component | Conditional (A5 actions) | If HCC unavailable, deny A5 actions (fail-closed) |

---

## 9. Failure Modes

| Failure | Detection | Response | Recovery |
|---------|-----------|----------|----------|
| Policy Engine crash | Health check failure | Conversation Runtime treats all pending actions as denied. Active calls transfer to human. | Auto-restart. New decisions processed on restart. |
| Policy evaluation timeout (>50ms) | Latency monitoring | Return deny-with-timeout. Alert operations. | Investigate rule complexity. Optimize rules. |
| Policy bundle corrupted | Validation checksum failure | Fall back to last-known-good bundle. Alert operations. | Restore bundle from version control |
| Rule conflict (contradictory rules) | Static analysis during rule update | Block rule publication until conflict is resolved. | Rule author resolves conflict, resubmits |
| Fraud risk score unavailable | Missing data in request | Apply maximum caution: treat as high risk, restrict to read-only A1 actions | Monitor Fraud-Aware Identity Layer health |

---

## 10. Security Controls

- mTLS for all API communication
- Policy Engine is stateless: no session data stored, no cross-request data leakage
- Policy rules are version-controlled with change tracking and approval chains
- Rule changes require simulation results showing impact before approval
- Safety-tier rules (authentication, prohibited actions, PCI) cannot be modified by tenant administrators; only VocalIQ platform team with CTO approval
- Decision logs are tamper-proof (written to append-only Audit Ledger)
- No external network access: Policy Engine operates entirely on local data and configuration

---

## 11. Audit Events

| Event Type | Trigger | Payload |
|-----------|---------|---------|
| policy.decision.allow | Action approved | decision_id, call_id, action, auth_level, risk_score, policy_version, rules_evaluated |
| policy.decision.deny | Action denied | decision_id, call_id, action, reason_codes, required_next_step, policy_version |
| policy.decision.require_approval | A5 action queued | decision_id, call_id, action, approval_queue, approver_role |
| policy.decision.require_step_up | Step-up auth required | decision_id, call_id, action, current_auth, required_auth, methods |
| policy.rules.updated | Policy bundle published | policy_version, changed_rules, approved_by, simulation_result_hash |
| policy.rules.rollback | Policy version rolled back | from_version, to_version, rolled_back_by, reason |
| policy.simulation.completed | Rule simulation run | simulation_id, proposed_changes, impact_summary |

---

## 12. Metrics

| Metric | Type | Description |
|--------|------|-------------|
| pe_decisions_total | Counter | Total decisions by outcome (allow/deny/require_approval/require_step_up) |
| pe_decision_latency_ms | Histogram | Decision evaluation time |
| pe_denial_reasons | Counter | Denial events by reason_code |
| pe_rules_evaluated_per_decision | Histogram | Number of rules evaluated per decision |
| pe_step_up_auth_triggered | Counter | Step-up authentication triggers by action type |
| pe_human_approval_queued | Counter | A5 actions sent to approval queue |
| pe_policy_version_active | Gauge | Currently active policy bundle version per tenant |
| pe_rule_conflicts_detected | Counter | Rule conflicts caught during publication |

---

## 13. Test Cases

### Core Decision Tests

- AUTH_0 caller requests balance read (AUTH_2 required): verify deny with AUTH_LEVEL_TOO_LOW
- AUTH_2 caller requests balance read with low risk score: verify allow
- AUTH_2 caller requests card block (AUTH_3 required): verify require_step_up
- Any auth level requests loan approval (A6 prohibited): verify deny with PROHIBITED_ACTION
- A5 action (large refund) with AUTH_4: verify require_approval, event sent to Human Control Center

### Fraud Threshold Tests

- Risk score 25 with AUTH_2: verify standard processing
- Risk score 55 with AUTH_2: verify step-up required
- Risk score 75: verify mandatory human transfer
- Risk score 90: verify deny all actions, fraud alert generated

### Jurisdiction Tests

- SG caller: verify PDPA-specific disclosure controls applied
- EU caller: verify GDPR-specific consent requirements applied
- UK caller: verify FCA Consumer Duty vulnerability checks applied

### Policy Management Tests

- Simulate rule change: verify impact report shows affected decisions
- Publish policy bundle with conflicting rules: verify rejection
- Rollback policy version: verify new decisions use rolled-back rules immediately

### Performance Tests

- Single decision under 50ms at p99
- Batch evaluation of 10 actions under 100ms at p99
- 10,000 decisions per second per instance

### Failure Tests

- Policy Engine crash: verify Conversation Runtime denies all pending actions
- Policy bundle corruption: verify fallback to last-known-good
- Missing risk score: verify conservative (high-risk) default applied

---

## 14. Open Questions

- OPA/Rego vs. Cedar vs. custom DSL for policy-as-code: which balances expressiveness, performance, and bank-team readability?
- Should the Policy Engine support real-time rule updates (effective immediately for active calls) or should updates only apply to new sessions?
- How should the engine handle policy rules that reference external data sources (e.g., a bank's internal fraud watchlist)?
- Should policy decisions include a "confidence" score (e.g., "allow with 85% confidence") or should all decisions be binary?
- How should tenant-specific policy customizations be managed without creating a maintenance burden of per-tenant rule branches?
