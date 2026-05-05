# Component Specification: Audit / Event Ledger

**Document ID:** DOC_COMP_AL_001  
**Last Updated:** 2026-05-03  
**Owner:** Compliance Engineering Lead

**Version History:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-03 | Initial specification |

**Principles Referenced:** G3 (Audit is a sidecar, not afterthought), S4 (PCI data never reaches LLM), E2 (Observability), E3 (Prefer explicit), E4 (Multi-tenancy)


**Scope:** Covers the Audit / Event Ledger component within the VocalIQ platform. Internal implementation of this component's subcomponents is beyond scope unless it affects interface contracts.

**Assumptions:** Component operates within the VocalIQ reference architecture as defined in reference_architecture.md. Deployment follows the control-plane/data-plane split. All inter-component communication uses mTLS.

**Decisions Made:** Component boundaries and responsibilities follow the pipeline architecture. The 13-section specification template is used instead of narrative format to support direct implementation mapping.

**Alternatives Considered:** Documented in reference_architecture.md and architecture_principles.md at the architecture level. Component-level alternatives are captured in Open Questions (Section 14).

**Risks:** Component-specific failure modes documented in Section 9. Cross-component risks documented in ai_risk_register.md and operational_resilience.md.

**Source Links:** Handoff Section 12, reference_architecture.md, architecture_principles.md, ai_risk_register.md.

---

## 1. Purpose

The Audit/Event Ledger is the append-only, tamper-evident record of everything that happens during every call processed by VocalIQ. It captures turn-level events from every component in the pipeline: call lifecycle (Media Gateway), transcription and redaction (Speech Layer), state transitions and decisions (Conversation Runtime), policy decisions (Policy Engine), tool executions (Tool Gateway), fraud signals and authentication (Fraud-Aware Identity Layer), human interventions (Human Control Center), and model calls (Model Gateway).

The ledger proves what happened in every call. This proof is essential for regulatory compliance (MAS recordkeeping, DORA audit trails, FCA complaint reconstruction, GDPR data subject access), internal audit, dispute resolution, and continuous quality improvement.

---

## 2. Responsibilities

- Accept structured events from all VocalIQ components via a standardized event schema
- Store events in an append-only log (no modification, no deletion except by retention policy)
- Maintain tamper evidence via cryptographic hash chain (each event hashes the previous event, creating a verifiable chain)
- Enforce retention policies: per-tenant, per-jurisdiction, configurable retention periods
- Support legal hold: override retention policy for specific calls or tenants when litigation or investigation requires preservation
- Enforce redaction: events must not contain PCI data, and PII is handled per configured redaction rules
- Provide event query and export capabilities for audit, compliance, and investigation
- Support call replay: provide the complete event timeline for a call to enable reconstruction of the AI's decision-making process
- Support regulatory export: generate audit data in formats required by regulators (MAS, FCA, DORA, OCC)
- Maintain referential integrity: events include call_id, turn_id, tenant_id, and component_id for full traceability

---

## 3. Non-Responsibilities

- Real-time monitoring or alerting (Observability/monitoring systems consume events but that is their responsibility)
- Call recording storage (Media Gateway and recording service manage audio; the ledger stores references, not audio)
- Business analytics or dashboards (Analytics services consume ledger events but that is their responsibility)
- Active decision-making (the ledger records what happened, it does not influence what happens)

---

## 4. Inputs

| Input | Source | Format | Notes |
|-------|--------|--------|-------|
| Call lifecycle events | Media Gateway | AuditEvent JSON | Call start, end, transfer, failover |
| Speech events | Speech Layer | AuditEvent JSON | Transcription, redaction, provider switch |
| Session events | Conversation Runtime | AuditEvent JSON | Node transitions, slot fills, LLM calls |
| Policy events | Policy Engine | AuditEvent JSON | Policy decisions (allow/deny) |
| Tool events | Tool Gateway | AuditEvent JSON | Tool executions, validations, results |
| Identity events | Fraud-Aware Identity Layer | AuditEvent JSON | Auth changes, risk score updates, fraud alerts |
| Supervisor events | Human Control Center | AuditEvent JSON | Whisper, takeover, approvals |
| Model events | Model Gateway | AuditEvent JSON | Inference requests, safety filters |

---

## 5. Outputs

| Output | Destination | Format | Notes |
|--------|-------------|--------|-------|
| Event query results | Internal tools (Control Center, Analytics, Evaluation Lab) | JSON | Filtered and paginated event data |
| Call timeline | Human Control Center (replay), Evaluation Lab | JSON | Ordered events for a specific call |
| Regulatory export | Bank compliance teams | CSV, JSON, or regulatory-specific format | Configurable per jurisdiction |
| Data subject export | Privacy/GDPR compliance | JSON | All events related to a specific data subject |
| Retention policy reports | Compliance | JSON | What data is retained, when it expires |
| Integrity verification | Audit | Boolean + chain report | Hash chain verification result |

---

## 6. APIs

### 6.1 Event Ingestion API

**IngestEvent**
- `POST /events` - Write a single event to the ledger
  - Input: AuditEvent (see schema below)
  - Returns: event_id, hash_current
  - Guarantees: append-only, no modification of existing events

**IngestBatch**
- `POST /events/batch` - Write multiple events (for high-throughput components)
  - Input: array of AuditEvents
  - Returns: array of event_ids with hashes

### 6.2 Query API

**QueryEvents**
- `GET /events` - Query events with filters
  - Filters: call_id, tenant_id, event_type, component, time_range, severity
  - Pagination: cursor-based
  - Returns: paginated event list

**GetCallTimeline**
- `GET /calls/{call_id}/timeline` - Get complete event timeline for a call
  - Returns: ordered list of all events for the call, across all components
  - Includes: hash chain verification status

### 6.3 Export API

**ExportEvents**
- `POST /export` - Generate an export of events
  - Input: export_criteria (time_range, tenant_id, event_types), export_format (csv, json, regulatory_format)
  - Returns: export_id, download_url (or async completion webhook)

**DataSubjectExport**
- `POST /export/data-subject` - Generate GDPR data subject access report
  - Input: subject_identifier (caller ID hash, account reference), tenant_id
  - Returns: all events related to the data subject, with appropriate redaction

### 6.4 Integrity API

**VerifyChain**
- `POST /integrity/verify` - Verify the hash chain for a call or time range
  - Input: call_id or time_range
  - Returns: verification_result (valid/invalid), broken_links (if any)

### 6.5 Retention API

**RetentionPolicy**
- `GET /retention/policies` - List retention policies (filterable by tenant_id)
- `POST /retention/policies` - Create a retention policy (requires compliance approval)
  - Input: tenant_id, name, data_category, retention_days, auto_delete, requires_compliance_approval

**LegalHold**
- `POST /legal-hold` - Apply legal hold to specific calls or tenants
  - Input: tenant_id, scope (call_ids or query), hold_reason, hold_authorized_by, expires_at (optional)
  - Legal holds suspend retention policy deletion for affected records
- `POST /legal-hold/{hold_id}/release` - Release legal hold (requires compliance approval)
  - Uses POST rather than DELETE because release is a state transition with audit side effects, not a resource deletion

---

## 7. Data Models

### 7.1 AuditEvent

```
AuditEvent {
  event_id: string (generated by ledger)
  event_type: string (component.category.action, e.g., "policy.decision.allow")
  tenant_id: string
  call_id: string
  turn_id: string (nullable, for turn-level events)
  session_id: string (nullable)
  timestamp: timestamp (microsecond precision)
  component: string (media_gateway, speech_layer, conversation_runtime, etc.)
  actor_type: "system" | "caller" | "supervisor" | "model"
  actor_id: string (nullable, e.g., supervisor_id)
  severity: "info" | "warning" | "error" | "critical"
  payload: map<string, any> (event-specific data, must not contain PCI)
  metadata: EventMetadata
  hash_prev: string (hash of previous event in chain)
  hash_current: string (hash of this event including hash_prev)
}
```

### 7.2 EventMetadata

```
EventMetadata {
  graph_version: string (nullable)
  policy_version: string (nullable)
  model_version: string (nullable)
  prompt_version: string (nullable)
  jurisdiction: string
  redaction_applied: boolean
  data_classification: string
}
```

### 7.3 RetentionPolicy

```
RetentionPolicy {
  tenant_id: string
  default_retention_days: int
  jurisdiction_overrides: map<string, int> (e.g., "EU": 2555 for 7 years)
  event_type_overrides: map<string, int> (e.g., complaint events may have longer retention)
  legal_holds: LegalHold[]
  last_updated: timestamp
  updated_by: string
}
```

### 7.4 LegalHold

```
LegalHold {
  hold_id: string
  scope: "call" | "tenant" | "date_range"
  scope_identifier: string (call_id, tenant_id, or date range)
  reason: string
  authorized_by: string
  created_at: timestamp
  released_at: timestamp (nullable)
  released_by: string (nullable)
}
```

---

## 8. Dependencies

| Dependency | Type | Criticality | Fallback |
|-----------|------|-------------|----------|
| Event store (database) | Data store | Critical | Write-ahead log on local disk. Events replayed to database when available. |
| All VocalIQ components | Event producers | N/A | Ledger passively receives events. Component failure means events stop arriving, not ledger failure. |
| Export storage | Object storage (for export files) | Medium | Retry export when storage available |

---

## 9. Failure Modes

| Failure | Detection | Response | Recovery |
|---------|-----------|----------|----------|
| Event store unavailable | Write failure, connection error | Components buffer events locally (configurable buffer size). Critical events (policy decisions, tool executions) are retried with backoff. | When store recovers, components flush buffered events. Verify hash chain integrity after recovery. |
| Hash chain broken | Integrity verification detects gap | Flag the gap in the chain. Alert compliance. Events before and after the gap remain valid; the gap itself is marked. | Investigate cause. Seal the gap with a chain-repair event documenting the incident. |
| Event ingestion overload | Queue depth exceeds threshold | Backpressure on event producers. Components may drop low-severity (info) events. High-severity events always accepted. | Scale event ingestion capacity. |
| Retention policy execution failure | Scheduled deletion fails | Events over-retained (safe from a compliance perspective). Alert operations. | Retry retention execution. |
| Legal hold conflict with retention | Retention would delete events under legal hold | Legal hold always wins. Events preserved regardless of retention policy. | Hold release triggers deferred retention processing. |
| Export generation failure | Export process crashes | Retry export. Partial export available for resumption. | Restart export from last checkpoint. |

---

## 10. Security Controls

- Append-only storage: no UPDATE or DELETE operations at the database level (retention is implemented as a separate, audited process)
- Cryptographic hash chain: each event includes hash_prev (previous event's hash) and hash_current, creating a chain that detects tampering
- Encryption at rest: all events encrypted with tenant-specific keys (AES-256)
- Access control: query and export APIs require authenticated access with role-based permissions (compliance role for exports, operations role for monitoring)
- PCI exclusion: event ingestion validates that no PCI data appears in event payloads
- PII handling: events may contain PII (caller identifiers, transcript summaries) but are subject to redaction policies and GDPR export/deletion requirements
- Tenant isolation: queries are scoped by tenant_id. No cross-tenant event access.
- Immutable audit trail for the audit trail: changes to retention policies and legal holds are themselves audited

---

## 11. Audit Events

The Audit Ledger logs meta-events about its own operations:

| Event Type | Trigger | Payload |
|-----------|---------|---------|
| ledger.export.requested | Export initiated | export_id, requester, criteria, format |
| ledger.export.completed | Export delivered | export_id, event_count, file_size |
| ledger.retention.executed | Retention policy processed | tenant_id, events_deleted_count, oldest_remaining |
| ledger.legal_hold.applied | Legal hold created | hold_id, scope, authorized_by |
| ledger.legal_hold.released | Legal hold released | hold_id, released_by |
| ledger.integrity.verified | Hash chain verified | scope, result, events_checked, breaks_found |
| ledger.integrity.breach | Hash chain break detected | call_id, expected_hash, actual_hash |

---

## 12. Metrics

| Metric | Type | Description |
|--------|------|-------------|
| al_events_ingested_total | Counter | Total events ingested by component and event_type |
| al_events_ingested_rate | Gauge | Events per second |
| al_ingestion_latency_ms | Histogram | Time from event submission to durable write |
| al_events_buffered | Gauge | Events currently buffered locally (indicates store issues) |
| al_storage_utilization_bytes | Gauge | Total storage used per tenant |
| al_retention_events_deleted | Counter | Events deleted by retention policy |
| al_legal_holds_active | Gauge | Active legal holds |
| al_integrity_checks_total | Counter | Hash chain verifications by result |
| al_export_duration_ms | Histogram | Export generation time |
| al_query_latency_ms | Histogram | Event query response time |

---

## 13. Test Cases

### Ingestion Tests

- Events from all 8 source components are ingested and queryable
- Events are stored in chronological order with microsecond precision
- Hash chain: each event's hash_current is correctly computed from the event data + hash_prev
- Batch ingestion correctly processes multiple events and maintains chain integrity
- PCI data in event payload is rejected at ingestion (validation)

### Integrity Tests

- Hash chain verification passes for an uncorrupted event sequence
- Hash chain verification detects a single modified event in a sequence of 10,000
- Hash chain verification detects a deleted event in a sequence
- Hash chain repair event correctly seals a documented gap

### Retention Tests

- Events past retention period are deleted in the scheduled retention run
- Events under legal hold are preserved past retention period
- Legal hold release triggers deferred retention processing
- Jurisdiction-specific retention overrides are applied correctly (SG vs. EU vs. UK retention periods)

### Export Tests

- Call timeline export returns all events for a call in correct chronological order
- GDPR data subject export returns all events related to a specific caller
- Regulatory export generates data in the configured format
- Export with 1 million events completes within configurable timeout

### Failover Tests

- Event store unavailable: verify components buffer locally, events replayed on recovery
- Hash chain continuity maintained across store recovery
- High-volume ingestion (10,000 events/second) handles backpressure gracefully

### Performance Tests

- Event ingestion latency under 20ms at p95
- Call timeline query under 500ms for a 100-turn call
- Support 5,000 events per second sustained ingestion rate
- Hash chain verification for 100,000 events under 10 seconds

---

## 14. Open Questions

- Should the ledger support event enrichment (adding context to events after the fact, e.g., annotating a call with post-call fraud investigation results) or should enrichment be a separate layer?
- How should the ledger handle GDPR right-to-erasure requests given the append-only, hash-chain integrity requirement? (Options: crypto-shredding, selective redaction, or treating compliance events as exempt from erasure.)
- Should the ledger provide real-time streaming to external systems (SIEM, bank analytics) or should that be a separate integration layer?
- What is the appropriate hash chain granularity: per-call chain (independent chains per call) or global chain (one chain across all events)? Per-call is simpler but global provides stronger integrity guarantees.
- How should the ledger handle clock skew between components when ordering events?
