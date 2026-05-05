# Component Specification: Conversation Runtime

**Document ID:** DOC_COMP_CR_001  
**Last Updated:** 2026-05-03  
**Owner:** Conversation AI Lead

**Version History:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-03 | Initial specification |

**Principles Referenced:** S1 (Never build unsafe architecture), S2 (AI decisions through policy validation), S3 (Failure defaults to human), G4 (Authentication explicitly tracked), G6 (Graphs deterministic at control flow), E1 (Latency transparency), E3 (Prefer explicit), E5 (Test at policy boundary)


**Scope:** Covers the Conversation Runtime component within the VocalIQ platform. Internal implementation of this component's subcomponents is beyond scope unless it affects interface contracts.

**Assumptions:** Component operates within the VocalIQ reference architecture as defined in reference_architecture.md. Deployment follows the control-plane/data-plane split. All inter-component communication uses mTLS.

**Decisions Made:** Component boundaries and responsibilities follow the pipeline architecture. The 13-section specification template is used instead of narrative format to support direct implementation mapping.

**Alternatives Considered:** Documented in reference_architecture.md and architecture_principles.md at the architecture level. Component-level alternatives are captured in Open Questions (Section 14).

**Risks:** Component-specific failure modes documented in Section 9. Cross-component risks documented in ai_risk_register.md and operational_resilience.md.

**Source Links:** Handoff Section 12, reference_architecture.md, architecture_principles.md, ai_risk_register.md.

---

## 1. Purpose

The Conversation Runtime executes controlled conversation workflows during live calls. It is the central orchestrator of the VocalIQ pipeline: it receives transcribed text from the Speech Layer, manages conversation state through a graph state machine, invokes the LLM for dynamic language generation via the Model Gateway, retrieves knowledge via the RAG Service, requests policy decisions from the Policy Engine, triggers actions through the Tool Gateway, and manages human escalation.

The state machine owns the conversation. The LLM proposes language, extraction, and summaries. The Policy Engine decides whether an action is allowed. The Tool Gateway executes only scoped, validated actions. The Conversation Runtime enforces this separation.

---

## 2. Responsibilities

- Execute conversation graphs (directed state machines) that define call workflows
- Manage graph state transitions: track current node, completed nodes, and available transitions
- Execute deterministic nodes (scripted prompts, slot validation, conditional branching) without LLM involvement
- Orchestrate LLM-assisted nodes: construct prompts, send to Model Gateway, parse responses for slot extraction, response generation, and summarization
- Slot extraction and validation: extract structured data from caller utterances (amounts, dates, card identifiers, complaint descriptions)
- Repair loops: when slot extraction fails or confidence is low, re-prompt the caller for clarification
- Context management: maintain conversation history, slot values, and session state across turns
- Policy interaction: before any tool call or sensitive disclosure, request a policy decision from the Policy Engine and enforce the result
- Human escalation: trigger transfer to human agent when graph logic, policy rules, or failure conditions require it
- Multi-language support: execute graphs in the caller's detected language, request TTS in the appropriate language
- Version management: load the correct graph version for the tenant and workflow
- Replayable state transitions: every state transition is logged such that the call can be reconstructed for audit

---

## 3. Non-Responsibilities

- Speech recognition or synthesis (Speech Layer)
- Policy rule evaluation (Policy Engine)
- LLM inference (Model Gateway)
- Tool execution against bank systems (Tool Gateway)
- Fraud risk scoring (Fraud-Aware Identity Layer)
- Graph authoring or compilation (Graph Compiler, Graph Designer)
- Call recording or telephony (Media Gateway)

---

## 4. Inputs

| Input | Source | Format | Notes |
|-------|--------|--------|-------|
| Final transcript | Speech Layer | JSON (transcript with confidence) | Transcribed caller speech |
| Barge-in event | Speech Layer | Internal event | Caller interrupted TTS |
| Language detection | Speech Layer | JSON | Detected language |
| Policy decision | Policy Engine | JSON (allow/deny with reasons) | Response to policy check |
| Tool result | Tool Gateway | JSON | Result of bank system action |
| RAG result | RAG Service | JSON (answer with citations) | Knowledge retrieval result |
| LLM response | Model Gateway | JSON (text, extracted slots, reasoning) | LLM-generated content |
| Fraud risk score | Fraud-Aware Identity Layer | JSON | Current session risk score |
| Authentication state | Fraud-Aware Identity Layer | JSON | Current auth level |
| Supervisor command | Human Control Center | Internal RPC | Whisper, takeover, instruction |
| Graph definition | Control Plane (version registry) | YAML/JSON | Compiled conversation graph |

---

## 5. Outputs

| Output | Destination | Format | Notes |
|--------|-------------|--------|-------|
| Response text | Speech Layer (via TTS) | Text with SSML | AI response for caller playback |
| Policy check request | Policy Engine | JSON | Pre-action policy validation |
| Tool call request | Tool Gateway (via Policy Engine) | JSON | Requested bank system action |
| RAG query | RAG Service | JSON | Knowledge retrieval request |
| LLM prompt | Model Gateway | JSON | Prompt for LLM inference |
| State transition events | Audit Ledger | Structured events | Every node transition, slot fill, decision |
| Transfer request | Media Gateway | JSON (TransferPackage) | Human escalation with context |
| Session state update | Fraud-Aware Identity Layer | JSON | Updated context for risk scoring |
| Metrics | Observability | Prometheus metrics | Latency, error rates, node execution |

---

## 6. APIs

### 6.1 Internal APIs

**SessionManagement API**
- `POST /sessions` - Create new conversation session for a call
  - Input: call_id, tenant_id, initial_graph_id, language, caller_metadata
  - Returns: session_id, initial_node
- `GET /sessions/{session_id}` - Get current session state
- `DELETE /sessions/{session_id}` - End session (call ended or transferred)

**TurnProcessing API**
- `POST /sessions/{session_id}/turns` - Process a caller turn
  - Input: transcript (with confidence), turn_id
  - Returns: response_text, next_node, slot_updates, actions_taken
  - This is the core processing endpoint. It drives the graph forward.

**SessionControl API**
- `POST /sessions/{session_id}/supervisor/whisper` - Inject supervisor instruction
- `POST /sessions/{session_id}/supervisor/takeover` - Supervisor takes control
- `POST /sessions/{session_id}/graph/switch` - Switch to a different graph mid-call
- `GET /sessions/{session_id}/state` - Full session state dump (for debugging/audit)

### 6.2 Graph Execution Engine (Internal)

```
interface GraphExecutor {
  loadGraph(graphId: string, version: string): CompiledGraph
  executeNode(session: Session, node: GraphNode, input: TurnInput): NodeResult
  evaluateTransition(session: Session, currentNode: GraphNode, nodeResult: NodeResult): GraphNode
  getAvailableTransitions(session: Session, currentNode: GraphNode): Transition[]
}
```

---

## 7. Data Models

### 7.1 Session

```
Session {
  session_id: string
  call_id: string
  tenant_id: string
  graph_id: string
  graph_version: string
  current_node_id: string
  previous_nodes: NodeVisit[]
  slots: map<string, SlotValue>
  authentication_level: AuthLevel (AUTH_0 through AUTH_5)
  fraud_risk_score: float
  language: string
  turn_count: int
  started_at: timestamp
  last_activity_at: timestamp
  state: "active" | "transferring" | "ended"
  transfer_reason: string (nullable)
  conversation_history: Turn[]
}
```

### 7.2 Turn

```
Turn {
  turn_id: string
  speaker: "caller" | "agent"
  text: string (redacted)
  asr_confidence: float (for caller turns)
  node_id: string
  timestamp: timestamp
  slots_extracted: map<string, SlotValue>
  policy_decisions: PolicyDecision[]
  actions_taken: ActionResult[]
}
```

### 7.3 SlotValue

```
SlotValue {
  name: string
  value: any
  source: "asr_extraction" | "llm_extraction" | "tool_result" | "manual"
  confidence: float
  validated: boolean
  validation_method: string
  turn_id: string (when extracted)
}
```

### 7.4 GraphNode (see graph_compiler.md for full DSL)

```
GraphNode {
  id: string
  type: "SpeakNode" | "CollectNode" | "IntentNode" | "AuthenticateNode" | 
        "PolicyNode" | "RiskNode" | "ToolNode" | "RAGNode" | "DisclosureNode" |
        "ConfirmNode" | "HumanApprovalNode" | "TransferNode" | "CaseNode" |
        "WaitNode" | "EndNode" | "FallbackNode"
  autonomy_level: string (A0-A5)
  required_authentication: AuthLevel
  llm_assisted: boolean
  next: string | map<string, string>
  fallback_node: string
  timeout_ms: int
  max_retries: int
}
```

---

## 8. Dependencies

| Dependency | Type | Criticality | Fallback |
|-----------|------|-------------|----------|
| Speech Layer | Internal component | Critical | Cannot process calls without transcription |
| Model Gateway | Internal component | Critical for LLM-assisted nodes | Deterministic nodes still function. LLM nodes fall back to scripted responses or human transfer. |
| Policy Engine | Internal component | Critical | If Policy Engine is unavailable, deny all actions and transfer to human (fail-closed) |
| Tool Gateway | Internal component | Critical for A2+ workflows | If Tool Gateway is unavailable, no bank system actions. Transfer to human for action-required workflows. |
| RAG Service | Internal component | Conditional | RAG-dependent answers return "I don't have that information right now" and offer human transfer |
| Fraud-Aware Identity Layer | Internal component | High | Without fraud scoring, apply maximum caution: restrict to A0/A1 actions only |
| Graph version registry | Control Plane | High | Cache last-known-good graph versions. Use cached version if registry unavailable. |

---

## 9. Failure Modes

| Failure | Detection | Response | Recovery |
|---------|-----------|----------|----------|
| Graph not found for tenant/workflow | Graph loading error | Play generic greeting, attempt basic routing, transfer to human | Alert operations, verify graph deployment |
| LLM timeout | Model Gateway timeout | Retry once. If second attempt fails, use scripted fallback for current node. If no scripted fallback, transfer to human. | LLM latency monitoring, provider switch if persistent |
| LLM response parse failure | Response does not match expected schema | Treat as failed extraction. Enter repair loop (re-prompt caller). After max retries, transfer to human. | Log malformed response for investigation |
| Policy Engine unavailable | Connection failure | Deny all pending actions. Transfer to human. No actions executed without policy approval. | Monitor Policy Engine, resume when available |
| Slot extraction failure | Low confidence or invalid value | Enter repair loop: re-prompt caller with clarification question. Max 3 repair attempts before human transfer. | Log extraction failure for model improvement |
| Session state corruption | State validation failure | Transfer to human with whatever state is available. Log corruption event. | Investigate root cause. State snapshots enable partial recovery. |
| Graph dead-end reached | No valid transition from current node | Execute graph's fallback node (always exists, enforced by Graph Compiler). If no fallback, transfer to human. | Review graph for missing transitions |
| Concurrent supervisor command conflict | Multiple commands for same session | Last-writer-wins for whisper. Takeover locks session immediately. | Log conflict for review |

---

## 10. Security Controls

- mTLS for all inter-component communication
- Session state includes only redacted transcripts (PII/PCI already removed by Speech Layer)
- Conversation history stored in memory during call, persisted to encrypted storage after call ends
- LLM prompts are constructed server-side; caller input is interpolated into prompt templates but cannot modify prompt structure (prompt injection mitigation at the template level)
- Session isolation: no cross-session, cross-tenant, or cross-call data access
- Graph execution is sandboxed: graphs cannot execute arbitrary code, access the filesystem, or make network calls outside the defined API interfaces
- Supervisor commands are authenticated via the Human Control Center's RBAC

---

## 11. Audit Events

| Event Type | Trigger | Payload |
|-----------|---------|---------|
| session.started | New session created | session_id, call_id, tenant_id, graph_id, graph_version, language |
| session.node.entered | Graph transitions to new node | session_id, node_id, node_type, autonomy_level |
| session.node.completed | Node processing finished | session_id, node_id, outcome, duration_ms |
| session.slot.extracted | Slot value extracted | session_id, slot_name, confidence, source, validated (no raw value for sensitive slots) |
| session.llm.request | LLM prompt sent | session_id, node_id, prompt_template_id, prompt_version, token_count |
| session.llm.response | LLM response received | session_id, node_id, response_length, latency_ms, model_version |
| session.policy.request | Policy check requested | session_id, requested_action, current_auth_level, risk_score |
| session.policy.result | Policy decision received | session_id, decision (allow/deny), reason_codes, policy_version |
| session.repair.loop | Repair loop entered | session_id, node_id, attempt_number, reason |
| session.transfer.initiated | Human escalation triggered | session_id, transfer_reason, target_queue, context_summary_hash |
| session.supervisor.action | Supervisor intervened | session_id, action_type (whisper/takeover), supervisor_id |
| session.ended | Session completed | session_id, duration_seconds, turns_count, outcome (completed/transferred/dropped) |

---

## 12. Metrics

| Metric | Type | Description |
|--------|------|-------------|
| cr_sessions_active | Gauge | Current active conversation sessions |
| cr_turn_latency_ms | Histogram | Time from transcript received to response text emitted |
| cr_node_execution_ms | Histogram | Per-node-type execution latency |
| cr_llm_calls_total | Counter | LLM invocations by node type |
| cr_policy_decisions_total | Counter | Policy check outcomes (allow/deny) |
| cr_slot_extraction_confidence | Histogram | Confidence distribution for slot extractions |
| cr_repair_loop_rate | Gauge | Percentage of turns entering repair loops |
| cr_transfer_rate | Gauge | Percentage of sessions transferred to human |
| cr_transfer_reasons | Counter | Transfer events by reason category |
| cr_graph_completion_rate | Gauge | Percentage of sessions that reach EndNode |
| cr_containment_rate | Gauge | Percentage of calls fully handled by AI without human transfer |

---

## 13. Test Cases

### Functional Tests

- Complete a lost card workflow end-to-end: greeting, intent detection, authentication, card selection, confirmation, card block, replacement offer
- Slot extraction accuracy for: card last-4-digits, monetary amounts, dates, complaint descriptions, yes/no confirmation
- Repair loop: caller provides invalid card number, system re-prompts up to 3 times, transfers to human on 4th failure
- Multi-graph transition: caller starts in general inquiry, intent detected as card block, session switches to lost card graph
- Versioned graph execution: deploy new graph version, verify new calls use new version, active calls continue on old version
- Language handling: caller speaks Mandarin, system detects language, loads Mandarin-language TTS responses

### Policy Integration Tests

- Attempt to read balance without authentication: verify Policy Engine denies, system prompts for authentication
- Attempt to block card with AUTH_1 (insufficient): verify Policy Engine requires step-up, system initiates step-up auth
- Attempt prohibited action (loan approval): verify denial at every layer (graph, policy, tool gateway)

### Failover Tests

- LLM timeout: verify scripted fallback activates, caller receives coherent response
- Policy Engine crash: verify all actions denied, caller transferred to human
- Tool Gateway unavailable: verify action-required workflows transfer to human with context

### Performance Tests

- Turn processing latency under 100ms (excluding LLM inference time) at p95
- Support 1000 concurrent sessions per instance
- Graph loading time under 50ms
- Session state serialization/deserialization under 10ms

---

## 14. Open Questions

- Should the Conversation Runtime support mid-call graph updates (e.g., a policy change takes effect for active calls), or should changes only apply to new calls?
- How should the runtime handle a caller who explicitly asks to "start over" - reset to root graph, or continue from current state with a new intent classification?
- Should conversation history compression be applied for long calls (30+ turns) to manage LLM context window limits?
- How should the runtime handle calls where the caller switches intent mid-conversation (e.g., starts asking about balance, then wants to report fraud)?
- What is the maximum graph complexity (nodes, transitions) the runtime should support before recommending graph decomposition?
