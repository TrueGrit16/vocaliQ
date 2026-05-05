# Component Specification: Human Control Center

**Document ID:** DOC_COMP_HCC_001  
**Last Updated:** 2026-05-03  
**Owner:** Operations Engineering Lead

**Version History:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-03 | Initial specification |

**Principles Referenced:** S3 (Failure defaults to human), G3 (Audit sidecar), G4 (Authentication tracked), E2 (Observability), E3 (Prefer explicit)


**Scope:** Covers the Human Control Center component within the VocalIQ platform. Internal implementation of this component's subcomponents is beyond scope unless it affects interface contracts.

**Assumptions:** Component operates within the VocalIQ reference architecture as defined in reference_architecture.md. Deployment follows the control-plane/data-plane split. All inter-component communication uses mTLS.

**Decisions Made:** Component boundaries and responsibilities follow the pipeline architecture. The 13-section specification template is used instead of narrative format to support direct implementation mapping.

**Alternatives Considered:** Documented in reference_architecture.md and architecture_principles.md at the architecture level. Component-level alternatives are captured in Open Questions (Section 14).

**Risks:** Component-specific failure modes documented in Section 9. Cross-component risks documented in ai_risk_register.md and operational_resilience.md.

**Source Links:** Handoff Section 12, reference_architecture.md, architecture_principles.md, ai_risk_register.md.

---

## 1. Purpose

The Human Control Center provides supervisors with exception-driven oversight and real-time intervention capability over AI-handled calls. It is not designed for supervisors to watch every call. It is designed around exception alerts, risk thresholds, and approval workflows so that human attention is focused where it matters: high-risk calls, fraud alerts, vulnerable customers, failed automation, and actions requiring human judgment (A5 approval).

The Human Control Center is the bridge between autonomous AI operation and human oversight. It ensures that the AI never operates without the ability for humans to see what it's doing and intervene when needed.

---

## 2. Responsibilities

- Live call monitoring: provide real-time transcript stream, AI state, current graph node, risk flags, authentication status, and tool call history for any active call
- Supervisor alert management: receive, prioritize, and route escalation alerts based on configurable thresholds
- Human approval workflows: present A5 action requests to supervisors for approve/deny decisions
- Whisper capability: allow supervisors to inject instructions into the AI during a live call without the caller hearing
- One-click takeover: allow supervisors to take immediate control of a call, transitioning from AI to human agent
- Warm transfer coordination: manage the handoff between AI and human agent, ensuring the human receives full context
- Post-call QA: support call review, scoring, and feedback on AI performance
- Call replay: allow supervisors to replay call recordings with synchronized transcript, AI decisions, and policy events
- Queue management: integrate with the bank's existing queue management and workforce systems
- Supervisor dashboard: aggregate metrics across active calls, alerts, approval queues, and team performance

---

## 3. Non-Responsibilities

- Conversation logic or graph execution (Conversation Runtime)
- Fraud risk scoring (Fraud-Aware Identity Layer)
- Policy evaluation (Policy Engine)
- Call recording (Media Gateway)
- Agent desktop for human agents (bank's existing CCaaS/CRM; the Control Center is for supervisors overseeing AI agents)

---

## 4. Inputs

| Input | Source | Format | Notes |
|-------|--------|--------|-------|
| Real-time call state | Conversation Runtime | WebSocket stream | Transcript, current node, slot values, AI state |
| Risk score updates | Fraud-Aware Identity Layer | WebSocket stream | Score changes, indicator alerts |
| Escalation alerts | Conversation Runtime, Fraud-Aware Identity Layer, Policy Engine | JSON | Alert events with priority and context |
| Approval requests | Policy Engine (A5 actions) | JSON | Action details requiring supervisor approval |
| Audio stream | Media Gateway | Audio stream | Supervisor listen-in (when activated) |
| QA feedback | Supervisor | JSON | Post-call review scores and notes |

---

## 5. Outputs

| Output | Destination | Format | Notes |
|--------|-------------|--------|-------|
| Whisper instruction | Conversation Runtime | JSON | Supervisor guidance to AI |
| Takeover command | Conversation Runtime + Media Gateway | JSON | Supervisor assumes call control |
| Approval decision | Policy Engine (via Tool Gateway) | JSON | Approve/deny A5 action |
| Transfer context | Human agent (via bank CCaaS) | TransferPackage | Full call context for agent handoff |
| QA scores | Evaluation Lab, Analytics | JSON | Post-call quality assessment |
| Supervisor actions | Audit Ledger | Structured events | All supervisor interventions logged |

---

## 6. APIs

### 6.1 Monitoring API

**LiveCalls**
- `GET /calls/active` - List all active AI-handled calls with summary metrics
  - Returns: call_id, duration, current_node, risk_level, alert_count, auth_level
  - Supports filtering by risk level, alert status, tenant
- `GET /calls/{call_id}/stream` - WebSocket for real-time call state
  - Streams: transcript turns, node transitions, risk score updates, alerts
- `GET /calls/{call_id}/state` - Snapshot of current call state

### 6.2 Intervention API

**SupervisorActions**
- `POST /calls/{call_id}/whisper` - Send instruction to AI
  - Input: instruction_text, supervisor_id
  - The instruction is injected into the Conversation Runtime's context but not spoken to the caller
- `POST /calls/{call_id}/takeover` - Take control of call
  - Input: supervisor_id, takeover_reason
  - Transfers audio to supervisor's phone/softphone. AI disengages.
- `POST /calls/{call_id}/transfer` - Transfer to human queue
  - Input: target_queue, supervisor_id, priority, notes
  - Generates TransferPackage with full call context

### 6.3 Approval API

**Approvals**
- `GET /approvals/pending` - List pending A5 approval requests
  - Returns: approval_id, call_id, action_requested, context_summary, requested_at
- `POST /approvals/{approval_id}/approve` - Approve an A5 action
  - Input: supervisor_id, notes
- `POST /approvals/{approval_id}/deny` - Deny an A5 action
  - Input: supervisor_id, denial_reason, alternative_action

### 6.4 QA/Review API

**CallReview**
- `GET /calls/{call_id}/replay` - Get call replay data (recording, transcript, events timeline)
- `POST /calls/{call_id}/review` - Submit post-call QA review
  - Input: scores (accuracy, compliance, customer_experience), notes, flags
- `GET /reviews/summary` - Aggregate QA scores and trends

---

## 7. Data Models

### 7.1 SupervisorAlert

```
SupervisorAlert {
  alert_id: string
  call_id: string
  tenant_id: string
  alert_type: "fraud" | "vulnerability" | "complaint" | "low_confidence" |
              "auth_failure" | "tool_failure" | "repair_loop" | "customer_distress" |
              "advice_boundary" | "high_value" | "collections_hardship" | "approval_required"
  priority: "critical" | "high" | "medium" | "low"
  message: string
  context: AlertContext
  created_at: timestamp
  acknowledged_at: timestamp (nullable)
  acknowledged_by: string (nullable)
  resolved_at: timestamp (nullable)
  resolution: string (nullable)
}
```

### 7.2 AlertContext

```
AlertContext {
  current_graph_node: string
  risk_score: float
  risk_level: string
  auth_level: AuthLevel
  turn_count: int
  call_duration_seconds: int
  last_3_turns_summary: string
  active_fraud_indicators: string[]
  vulnerability_flags: string[]
  actions_pending: string[]
}
```

### 7.3 TransferPackage (shared with Media Gateway)

```
TransferPackage {
  call_id: string
  tenant_id: string
  target_queue: string
  transfer_type: "warm" | "cold"
  priority: "normal" | "urgent"
  transcript_summary: string
  full_transcript_available: boolean
  authentication_state: AuthState
  fraud_risk_score: float
  fraud_indicators: string[]
  vulnerability_flags: string[]
  current_graph_node: string
  slot_values: map<string, any> (non-sensitive)
  caller_sentiment: string
  actions_taken: ActionSummary[]
  actions_pending: string[]
  supervisor_notes: string
  call_duration_seconds: int
}
```

---

## 8. Dependencies

| Dependency | Type | Criticality | Fallback |
|-----------|------|-------------|----------|
| Conversation Runtime | Data source | Critical for monitoring | If Runtime unavailable, no active call monitoring. Alerts stop. Historical data still accessible. |
| Media Gateway | Audio source (listen-in) | High | Text-only monitoring without audio |
| Fraud-Aware Identity Layer | Risk data source | High | Monitoring continues without live risk updates |
| Bank CCaaS / queue management | Transfer target | High | Direct SIP transfer if CCaaS unavailable |
| Audit Ledger | Event storage | High | Buffer supervisor events locally |

---

## 9. Failure Modes

| Failure | Detection | Response | Recovery |
|---------|-----------|----------|----------|
| Control Center UI unavailable | Health check | AI continues operating autonomously. Alerts queued. Critical alerts (fraud, very high risk) trigger automatic transfer to human without supervisor oversight. | Restart, process queued alerts |
| Real-time stream disconnected | WebSocket connection loss | Reconnect automatically. During gap, supervisor misses real-time updates but can refresh state. | Auto-reconnect with state catch-up |
| Approval queue unavailable | Connection failure | A5 actions denied (fail-closed). Caller informed the action requires manual processing. | Restore queue, process backlog |
| Takeover failure | Audio routing error | Retry takeover. If persistent, initiate cold transfer to human queue instead. | Investigate Media Gateway routing |
| QA review data unavailable | Storage error | QA review deferred. Replay data buffered until storage recovers. | Restore storage, resume reviews |

---

## 10. Security Controls

- Role-based access control: supervisors see only calls for their assigned tenants, teams, and skill groups
- Supervisor authentication: MFA required for Control Center access
- Audit trail: every supervisor action (view, listen, whisper, takeover, approve/deny) is logged with supervisor ID and timestamp
- Audio monitoring consent: supervisor listen-in only activated for calls where recording consent was obtained
- PII handling: transcript display follows the same redaction rules as the pipeline (PCI data redacted before display)
- Session timeout: inactive supervisor sessions are automatically terminated

---

## 11. Audit Events

| Event Type | Trigger | Payload |
|-----------|---------|---------|
| hcc.alert.generated | Escalation alert created | alert_id, call_id, alert_type, priority |
| hcc.alert.acknowledged | Supervisor acknowledges alert | alert_id, supervisor_id, response_time_ms |
| hcc.call.monitored | Supervisor opens live call view | call_id, supervisor_id |
| hcc.call.listen_in | Supervisor activates audio monitoring | call_id, supervisor_id |
| hcc.whisper.sent | Supervisor sends whisper instruction | call_id, supervisor_id, instruction_hash |
| hcc.takeover.initiated | Supervisor takes over call | call_id, supervisor_id, reason |
| hcc.approval.granted | Supervisor approves A5 action | approval_id, call_id, action, supervisor_id |
| hcc.approval.denied | Supervisor denies A5 action | approval_id, call_id, action, supervisor_id, denial_reason |
| hcc.transfer.initiated | Supervisor initiates transfer | call_id, supervisor_id, target_queue |
| hcc.qa.review_submitted | Post-call QA review completed | call_id, reviewer_id, scores |

---

## 12. Metrics

| Metric | Type | Description |
|--------|------|-------------|
| hcc_alerts_active | Gauge | Current unacknowledged alerts by type and priority |
| hcc_alert_response_time_ms | Histogram | Time from alert to supervisor acknowledgment |
| hcc_approval_response_time_ms | Histogram | Time from A5 request to supervisor decision |
| hcc_takeovers_total | Counter | Takeover events by reason |
| hcc_whispers_total | Counter | Whisper instructions sent |
| hcc_transfers_total | Counter | Supervisor-initiated transfers by target queue |
| hcc_calls_monitored | Gauge | Calls currently being actively monitored |
| hcc_qa_scores_avg | Gauge | Average QA scores by category |
| hcc_approval_rate | Gauge | Percentage of A5 requests approved vs. denied |

---

## 13. Test Cases

### Monitoring Tests

- Active call list updates in real time as calls start and end
- Live transcript stream displays turns within 1 second of speech
- Risk score updates display within 2 seconds of score change
- Alert appears within 3 seconds of escalation trigger

### Intervention Tests

- Whisper instruction is received by Conversation Runtime and influences AI response without being spoken to caller
- Takeover transitions audio to supervisor's endpoint within 5 seconds
- Warm transfer delivers complete TransferPackage to receiving agent

### Approval Tests

- A5 action approval: approve in Control Center, verify Tool Gateway executes the action
- A5 action denial: deny in Control Center, verify Tool Gateway does not execute, Conversation Runtime informs caller
- Approval timeout: if supervisor doesn't respond within SLA, action is automatically denied

### QA Tests

- Call replay synchronizes recording, transcript, and event timeline correctly
- QA review scores are stored and contribute to aggregate metrics
- QA feedback can flag calls for further investigation

### Security Tests

- Supervisor can only see calls for assigned tenants
- Inactive session times out after configured period
- All supervisor actions produce audit events

---

## 14. Open Questions

- Should the Control Center support supervisor-to-supervisor handoff (e.g., escalate from team lead to fraud specialist)?
- How should the UI handle high alert volumes during an incident (100+ simultaneous alerts)?
- Should the whisper capability support templated instructions (pre-defined whisper scripts for common scenarios)?
- How should the Control Center integrate with the bank's existing workforce management and scheduling systems?
- Should post-call QA reviews be mandatory for certain call categories (e.g., all calls with fraud alerts, all A5 approvals)?
