# Data Architecture

**Document ID:** DOC_DATA_001  
**Last Updated:** 2026-05-03  
**Owner:** Data Engineering Lead

**Version History:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-03 | Initial specification |

**Scope:** Covers the database schema, event schemas, data classification, retention policies, tenant isolation strategy, and PCI/PII data handling for the VocalIQ platform. Implementation-specific details (index strategies, partitioning schemes, replication topology) are out of scope and will be addressed during build planning.

**Assumptions:** PostgreSQL is the primary relational store. Append-only event store uses PostgreSQL initially, with a migration path to Kafka/NATS/Pulsar if throughput demands it. Redis is used only for ephemeral real-time state, never as audit source of truth. All data at rest is encrypted (AES-256). All data in transit uses mTLS.

**Decisions Made:** Single-database-per-tenant logical isolation using row-level security (RLS) rather than separate database instances. This balances operational simplicity against the stricter isolation of per-tenant databases. Banks requiring physical isolation can use the dedicated deployment mode (see reference_architecture.md Section 4.4). Data classification is mandatory for every field, event payload, and document. Permissions are modeled as a text array column on the `roles` table rather than a separate `permissions` table, because VocalIQ's RBAC model uses a flat permission scheme (permission strings like `calls.monitor`, `graphs.publish`, `approvals.decide`) evaluated at the API gateway layer. A separate permissions table would add join overhead on every authorization check without providing additional capability, since permissions are not independently versioned or audited beyond their assignment to roles. If a bank requires fine-grained permission auditing or hierarchical permission inheritance, a dedicated `permissions` table can be introduced as a non-breaking schema extension.

**Alternatives Considered:** Per-tenant database instances (rejected for operational overhead at scale, available as deployment option), NoSQL document store for session state (rejected for lack of transactional guarantees on policy decisions), time-series database for audit events (rejected for added operational complexity; PostgreSQL with partitioning handles the expected event volumes).

**Risks:** Row-level security misconfiguration could leak data across tenants. Mitigation: automated RLS policy testing in CI, cross-tenant query detection in query middleware. Audit event volume could exceed PostgreSQL capacity at scale. Mitigation: designed migration path to dedicated event store.

**Open Questions:** See Section 10.

**Source Links:** reference_architecture.md, architecture_principles.md, component specs (all 12), VocalIQ_Bank_Grade_Research_Architecture_Handoff.md Sections 16, 18.

---

## 1. Core Entities

The VocalIQ data model is organized into six domains: platform configuration, conversation state, security and risk, audit and compliance, evaluation, and knowledge management.

### 1.1 Platform Configuration

```sql
-- Tenant and access management
tenants (
  id uuid primary key,
  name text not null,
  display_name text,
  region text not null,
  jurisdiction text not null,
  deployment_mode text not null check (deployment_mode in ('saas_multi', 'saas_dedicated', 'vpc', 'private_cloud', 'on_prem', 'air_gapped')),
  status text not null check (status in ('active', 'suspended', 'onboarding')),
  config jsonb not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  data_classification text not null default 'CONFIDENTIAL_CUSTOMER'
);

users (
  id uuid primary key,
  tenant_id uuid not null references tenants(id),
  email text not null,
  display_name text,
  status text not null check (status in ('active', 'inactive', 'locked')),
  mfa_enabled boolean not null default true,
  last_login_at timestamptz,
  created_at timestamptz not null default now(),
  data_classification text not null default 'CONFIDENTIAL_CUSTOMER'
);

roles (
  id uuid primary key,
  tenant_id uuid not null references tenants(id),
  name text not null,
  description text,
  permissions text[] not null default '{}',
  system_role boolean not null default false,
  created_at timestamptz not null default now(),
  data_classification text not null default 'INTERNAL'
);

user_roles (
  user_id uuid not null references users(id),
  role_id uuid not null references roles(id),
  granted_by uuid references users(id),
  granted_at timestamptz not null default now(),
  data_classification text not null default 'INTERNAL',
  primary key (user_id, role_id)
);

-- Agent configuration
agents (
  id uuid primary key,
  tenant_id uuid not null references tenants(id),
  name text not null,
  description text,
  default_graph_id text,
  default_language text not null default 'en',
  voice_config jsonb,
  status text not null check (status in ('active', 'inactive', 'testing')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

### 1.2 Graph and Policy Configuration

```sql
graphs (
  id text not null,
  tenant_id uuid not null references tenants(id),
  name text not null,
  description text,
  workflow_type text not null,
  tags text[] default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (id, tenant_id)
);

graph_versions (
  id uuid primary key,
  graph_id text not null,
  tenant_id uuid not null references tenants(id),
  version_label text not null,
  status text not null check (status in ('draft', 'compiled', 'approved', 'published', 'rolled_back')),
  definition jsonb not null,
  compilation_id uuid,
  compilation_result text check (compilation_result in ('pass', 'fail')),
  node_count int,
  transition_count int,
  complexity_score int,
  created_by uuid references users(id),
  created_at timestamptz not null default now(),
  published_at timestamptz,
  published_by uuid references users(id)
);

graph_approvals (
  id uuid primary key,
  graph_version_id uuid not null references graph_versions(id),
  approver_id uuid not null references users(id),
  decision text not null check (decision in ('approved', 'rejected')),
  notes text,
  decided_at timestamptz not null default now(),
  data_classification text not null default 'INTERNAL'
);

policy_sets (
  id text not null,
  tenant_id uuid not null references tenants(id),
  name text not null,
  description text,
  base_policy_set_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (id, tenant_id)
);

policy_versions (
  id uuid primary key,
  policy_set_id text not null,
  tenant_id uuid not null references tenants(id),
  status text not null check (status in ('draft', 'testing', 'approved', 'published', 'archived')),
  rules_snapshot jsonb not null,
  rules_count int not null,
  change_notes text,
  created_by uuid references users(id),
  created_at timestamptz not null default now(),
  published_at timestamptz,
  published_by uuid references users(id)
);
```

### 1.3 Model and Prompt Management

```sql
model_registry (
  id text not null,
  tenant_id uuid not null references tenants(id),
  provider text not null,
  model_name text not null,
  model_version text not null,
  purpose text not null check (purpose in ('conversation', 'extraction', 'classification', 'summarization', 'embedding', 'reranking', 'liveness', 'social_engineering')),
  config jsonb not null,
  status text not null check (status in ('active', 'deprecated', 'testing', 'disabled')),
  approved_by uuid references users(id),
  approved_at timestamptz,
  created_at timestamptz not null default now(),
  primary key (id, tenant_id),
  data_classification text not null default 'MODEL_GOVERNANCE'
);

prompt_templates (
  id uuid primary key,
  tenant_id uuid not null references tenants(id),
  name text not null,
  description text,
  template_text text not null,
  variables text[] not null default '{}',
  model_id text,
  purpose text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  data_classification text not null default 'MODEL_GOVERNANCE'
);

prompt_versions (
  id uuid primary key,
  prompt_template_id uuid not null references prompt_templates(id),
  version_label text not null,
  template_text text not null,
  status text not null check (status in ('draft', 'testing', 'approved', 'published', 'archived')),
  approved_by uuid references users(id),
  approved_at timestamptz,
  created_at timestamptz not null default now()
);
```

### 1.4 Knowledge Management

```sql
knowledge_collections (
  id uuid primary key,
  tenant_id uuid not null references tenants(id),
  name text not null,
  description text,
  jurisdiction text,
  access_control jsonb not null default '{}',
  status text not null check (status in ('active', 'archived')),
  created_at timestamptz not null default now()
);

knowledge_documents (
  id uuid primary key,
  collection_id uuid not null references knowledge_collections(id),
  tenant_id uuid not null references tenants(id),
  title text not null,
  source_type text not null,
  source_url text,
  content_hash text not null,
  status text not null check (status in ('pending_review', 'approved', 'rejected', 'expired', 'archived')),
  effective_from timestamptz,
  effective_until timestamptz,
  jurisdiction text,
  product_applicability text[],
  approved_by uuid references users(id),
  approved_at timestamptz,
  created_at timestamptz not null default now(),
  data_classification text not null default 'CONFIDENTIAL_CUSTOMER'
);

knowledge_document_versions (
  id uuid primary key,
  document_id uuid not null references knowledge_documents(id),
  version_label text not null,
  content_hash text not null,
  chunk_count int,
  status text not null check (status in ('processing', 'indexed', 'failed')),
  created_at timestamptz not null default now()
);
```

### 1.5 Tool and Connector Configuration

```sql
tool_registry (
  id text not null,
  tenant_id uuid not null references tenants(id),
  name text not null,
  description text,
  connector_id text not null,
  manifest jsonb not null,
  risk_level text not null check (risk_level in ('low', 'medium', 'high', 'critical')),
  required_authentication text not null,
  status text not null check (status in ('active', 'inactive', 'deprecated')),
  version text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (id, tenant_id)
);

tool_versions (
  id uuid primary key,
  tool_id text not null,
  tenant_id uuid not null references tenants(id),
  version_label text not null,
  manifest jsonb not null,
  change_notes text,
  created_at timestamptz not null default now()
);

connectors (
  id text not null,
  tenant_id uuid not null references tenants(id),
  name text not null,
  type text not null check (type in ('rest_api', 'soap', 'grpc', 'database', 'message_queue')),
  endpoint_url text,
  auth_type text not null check (auth_type in ('mtls', 'oauth2', 'api_key', 'certificate')),
  credential_ref text not null,
  config jsonb not null default '{}',
  status text not null check (status in ('active', 'inactive', 'error')),
  created_at timestamptz not null default now(),
  primary key (id, tenant_id),
  data_classification text not null default 'SECURITY_SECRET'
);
```

---

## 2. Conversation State

These tables capture the real-time and historical state of call sessions and turns.

```sql
call_sessions (
  id uuid primary key,
  tenant_id uuid not null references tenants(id),
  external_call_id text,
  direction text not null check (direction in ('inbound', 'outbound')),
  channel text not null check (channel in ('pstn', 'sip', 'webrtc')),
  telephony_provider text,
  agent_id uuid references agents(id),
  graph_version_id uuid references graph_versions(id),
  customer_ref text,
  authentication_level text not null default 'AUTH_0' check (authentication_level in ('AUTH_0', 'AUTH_1', 'AUTH_2', 'AUTH_3', 'AUTH_4', 'AUTH_5')),
  risk_band text check (risk_band in ('low', 'elevated', 'high', 'very_high', 'critical')),
  risk_score numeric(5,2),
  status text not null check (status in ('active', 'transferring', 'ended', 'dropped')),
  outcome text check (outcome in ('completed', 'transferred', 'dropped', 'error')),
  language text,
  turn_count int not null default 0,
  started_at timestamptz not null,
  ended_at timestamptz,
  recording_artifact_id uuid,
  transcript_artifact_id uuid,
  region text not null,
  jurisdiction text not null,
  transfer_reason text,
  transfer_target_queue text,
  containment_result boolean,
  created_at timestamptz not null default now(),
  data_classification text not null default 'CONFIDENTIAL_CUSTOMER'
);

-- Partitioned by tenant_id and started_at for query performance
create index idx_call_sessions_tenant_status on call_sessions(tenant_id, status);
create index idx_call_sessions_started on call_sessions(started_at);
create index idx_call_sessions_customer on call_sessions(customer_ref) where customer_ref is not null;

call_turns (
  id uuid primary key,
  call_session_id uuid not null references call_sessions(id),
  tenant_id uuid not null,
  turn_index int not null,
  speaker text not null check (speaker in ('customer', 'ai', 'human_agent', 'system')),
  text_redacted text,
  text_raw_ref uuid,
  language text,
  asr_confidence numeric(4,3),
  intent_json jsonb,
  slot_json jsonb,
  graph_node_id text,
  graph_node_type text,
  policy_decisions jsonb,
  actions_taken jsonb,
  llm_model_version text,
  llm_prompt_version_id uuid,
  llm_latency_ms int,
  started_at timestamptz not null,
  ended_at timestamptz,
  created_at timestamptz not null default now(),
  data_classification text not null default 'CONFIDENTIAL_CUSTOMER'
);

create index idx_call_turns_session on call_turns(call_session_id, turn_index);

transcript_segments (
  id uuid primary key,
  call_session_id uuid not null references call_sessions(id),
  tenant_id uuid not null,
  turn_id uuid references call_turns(id),
  speaker text not null,
  text_redacted text not null,
  text_raw_ref uuid,
  start_ms int not null,
  end_ms int not null,
  confidence numeric(4,3),
  language text,
  created_at timestamptz not null default now(),
  data_classification text not null default 'CONFIDENTIAL_CUSTOMER'
);

audio_artifacts (
  id uuid primary key,
  call_session_id uuid not null references call_sessions(id),
  tenant_id uuid not null,
  artifact_type text not null check (artifact_type in ('full_recording', 'segment', 'dtmf_capture')),
  storage_ref text not null,
  storage_encrypted boolean not null default true,
  encryption_key_ref text,
  duration_ms int,
  format text not null default 'opus',
  sample_rate int not null default 16000,
  consent_obtained boolean not null,
  created_at timestamptz not null default now(),
  expires_at timestamptz,
  data_classification text not null default 'SENSITIVE_CUSTOMER'
);
```

---

## 3. Security and Risk

```sql
auth_events (
  id uuid primary key,
  call_session_id uuid not null references call_sessions(id),
  tenant_id uuid not null,
  from_level text not null,
  to_level text not null,
  method text not null check (method in ('ani', 'kba', 'otp', 'app_push', 'secure_link', 'voice_biometric', 'human_verified')),
  result text not null check (result in ('success', 'failure', 'timeout', 'cancelled')),
  attempt_number int not null default 1,
  created_at timestamptz not null default now(),
  data_classification text not null default 'CONFIDENTIAL_CUSTOMER'
);

risk_events (
  id uuid primary key,
  call_session_id uuid not null references call_sessions(id),
  tenant_id uuid not null,
  previous_score numeric(5,2),
  new_score numeric(5,2) not null,
  trigger_signal text not null,
  signal_category text not null check (signal_category in ('caller_identity', 'behavioral', 'session', 'transaction')),
  risk_level text not null,
  fraud_indicators jsonb,
  created_at timestamptz not null default now(),
  data_classification text not null default 'CONFIDENTIAL_CUSTOMER'
);

policy_decisions (
  id uuid primary key,
  call_session_id uuid not null references call_sessions(id),
  tenant_id uuid not null,
  turn_id uuid references call_turns(id),
  requested_action text not null,
  decision text not null check (decision in ('allow', 'deny', 'step_up', 'human_approval')),
  reason_codes text[] not null default '{}',
  auth_level_at_decision text not null,
  risk_score_at_decision numeric(5,2),
  policy_version_id uuid,
  rules_matched jsonb,
  latency_ms int,
  created_at timestamptz not null default now(),
  data_classification text not null default 'INTERNAL'
);

tool_calls (
  id uuid primary key,
  call_session_id uuid not null references call_sessions(id),
  tenant_id uuid not null,
  turn_id uuid references call_turns(id),
  tool_id text not null,
  connector_id text not null,
  policy_decision_id uuid references policy_decisions(id),
  idempotency_key text not null,
  parameters_redacted jsonb,
  sensitive_params_ref uuid,
  result_status text not null check (result_status in ('success', 'failure', 'denied', 'timeout', 'dry_run', 'sandbox')),
  result_redacted jsonb,
  error_type text,
  error_message text,
  bank_error_code text,
  execution_duration_ms int,
  dry_run boolean not null default false,
  sandbox boolean not null default false,
  created_at timestamptz not null default now(),
  data_classification text not null default 'CONFIDENTIAL_CUSTOMER'
);

create unique index idx_tool_calls_idempotency on tool_calls(tenant_id, idempotency_key);

human_interventions (
  id uuid primary key,
  call_session_id uuid not null references call_sessions(id),
  tenant_id uuid not null,
  intervention_type text not null check (intervention_type in ('whisper', 'takeover', 'transfer', 'approval_granted', 'approval_denied', 'alert_acknowledged')),
  supervisor_id uuid not null references users(id),
  reason text,
  notes text,
  alert_id uuid,
  approval_id uuid,
  target_queue text,
  created_at timestamptz not null default now(),
  data_classification text not null default 'INTERNAL'
);

handoff_packages (
  id uuid primary key,
  call_session_id uuid not null references call_sessions(id),
  tenant_id uuid not null,
  target_queue text not null,
  transfer_type text not null check (transfer_type in ('warm', 'cold')),
  priority text not null check (priority in ('normal', 'urgent')),
  transcript_summary text,
  authentication_state text not null,
  fraud_risk_score numeric(5,2),
  fraud_indicators text[],
  vulnerability_flags text[],
  current_graph_node text,
  caller_sentiment text,
  actions_taken jsonb,
  actions_pending text[],
  supervisor_notes text,
  created_at timestamptz not null default now(),
  data_classification text not null default 'CONFIDENTIAL_CUSTOMER'
);
```

---

## 4. Audit Events

The audit_events table is the core of the Audit Ledger. It is append-only with a cryptographic hash chain for tamper evidence.

```sql
audit_events (
  id uuid primary key,
  tenant_id uuid not null,
  call_session_id uuid,
  event_type text not null,
  actor_type text not null check (actor_type in ('system', 'ai_agent', 'human_supervisor', 'human_agent', 'caller', 'admin')),
  actor_id text,
  component text not null,
  graph_version_id uuid,
  policy_version_id uuid,
  model_version_id text,
  prompt_version_id uuid,
  tool_call_id uuid,
  payload_redacted jsonb,
  sensitive_payload_ref uuid,
  data_classification text not null default 'INTERNAL',
  hash_prev text not null,
  hash_current text not null,
  created_at timestamptz not null default now()
);

-- Partitioned by tenant_id and created_at (monthly partitions)
-- hash_prev references the hash_current of the previous event in the tenant's chain
create index idx_audit_events_tenant_time on audit_events(tenant_id, created_at);
create index idx_audit_events_call on audit_events(call_session_id) where call_session_id is not null;
create index idx_audit_events_type on audit_events(event_type);
create index idx_audit_events_hash on audit_events(hash_current);
```

### 4.1 Hash Chain Mechanics

Each audit event's `hash_current` is computed as:

```
hash_current = SHA-256(
  tenant_id || event_type || actor_type || actor_id ||
  component || payload_redacted_canonical || hash_prev || created_at
)
```

The chain is per-tenant. The first event in a tenant's chain uses a well-known genesis hash. Chain verification walks the sequence and recomputes each hash, comparing against the stored value. Any discrepancy indicates tampering or data loss.

---

## 5. Evaluation

```sql
eval_suites (
  id uuid primary key,
  tenant_id uuid,
  name text not null,
  description text,
  category text not null check (category in ('golden_call', 'adversarial', 'compliance', 'performance', 'rag_faithfulness', 'authorization', 'handoff', 'load_chaos', 'accent_noise', 'model_comparison')),
  thresholds jsonb not null,
  required_for_release boolean not null default false,
  owner text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  data_classification text not null default 'INTERNAL'
);

eval_scenarios (
  id uuid primary key,
  suite_id uuid not null references eval_suites(id),
  name text not null,
  description text,
  scenario_type text not null check (scenario_type in ('scripted', 'ai_caller', 'adversarial', 'load')),
  scenario_config jsonb not null,
  expected_outcomes jsonb not null,
  severity text not null check (severity in ('blocker', 'major', 'minor')),
  tags text[] default '{}',
  created_at timestamptz not null default now(),
  data_classification text not null default 'INTERNAL'
);

eval_runs (
  id uuid primary key,
  suite_id uuid not null references eval_suites(id),
  release_candidate jsonb not null,
  environment text not null check (environment in ('sandbox', 'staging')),
  status text not null check (status in ('pending', 'running', 'completed', 'failed', 'cancelled')),
  overall_result text check (overall_result in ('pass', 'fail')),
  pass_count int,
  fail_count int,
  error_count int,
  skip_count int,
  metrics_summary jsonb,
  started_at timestamptz,
  completed_at timestamptz,
  duration_ms int,
  created_at timestamptz not null default now(),
  data_classification text not null default 'INTERNAL'
);

eval_results (
  id uuid primary key,
  run_id uuid not null references eval_runs(id),
  scenario_id uuid not null references eval_scenarios(id),
  result text not null check (result in ('pass', 'fail', 'error', 'skipped')),
  actual_outcomes jsonb,
  expected_vs_actual jsonb,
  metrics jsonb,
  duration_ms int,
  error_details text,
  call_transcript jsonb,
  artifacts text[],
  created_at timestamptz not null default now(),
  data_classification text not null default 'CONFIDENTIAL_CUSTOMER'
);
```

---

## 6. Operational

```sql
incidents (
  id uuid primary key,
  tenant_id uuid references tenants(id),
  severity text not null check (severity in ('critical', 'high', 'medium', 'low')),
  title text not null,
  description text,
  component text,
  status text not null check (status in ('open', 'investigating', 'mitigating', 'resolved', 'closed')),
  detected_at timestamptz not null,
  resolved_at timestamptz,
  root_cause text,
  remediation text,
  created_at timestamptz not null default now()
);

retention_policies (
  id uuid primary key,
  tenant_id uuid not null references tenants(id),
  name text not null,
  data_category text not null check (data_category in ('call_recordings', 'transcripts', 'audit_events', 'model_traces', 'tool_calls', 'risk_events')),
  retention_days int not null check (retention_days >= 30),
  jurisdiction text,
  auto_delete boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

legal_holds (
  id uuid primary key,
  tenant_id uuid not null references tenants(id),
  name text not null,
  reason text not null,
  scope jsonb not null,
  status text not null check (status in ('active', 'released')),
  created_by uuid not null references users(id),
  created_at timestamptz not null default now(),
  released_at timestamptz,
  released_by uuid references users(id),
  release_reason text
);
```

---

## 7. Data Classification

Every field, event payload, transcript segment, and document in VocalIQ carries a data classification. Classifications determine encryption requirements, access controls, retention rules, and whether data can be sent to external services (LLM providers, analytics).

| Classification | Description | Encryption | LLM Eligible | Retention |
|---------------|-------------|------------|-------------|-----------|
| PUBLIC | Marketing content, public product info | At rest | Yes | No limit |
| INTERNAL | Operational data, metrics, system config | At rest | Yes | Per policy |
| CONFIDENTIAL_CUSTOMER | Customer interaction data, transcripts, session state | At rest + field-level | Redacted only | Per tenant/jurisdiction |
| SENSITIVE_CUSTOMER | Vulnerability flags, complaint details, hardship indicators | At rest + field-level | No | Per tenant/jurisdiction, min 7 years for complaints |
| PCI_CARDHOLDER | Card numbers (masked/tokenized), cardholder name | At rest + field-level + tokenized | Never | PCI DSS requirements |
| PCI_SENSITIVE_AUTHENTICATION | CVV, PIN, full track data, OTP | At rest + field-level | Never | Must not be stored post-authorization |
| BANK_SECRET | Bank system credentials, API keys, certificates | HSM/KMS | Never | Rotated per schedule |
| MODEL_GOVERNANCE | Prompt templates, model configs, evaluation results | At rest | N/A (is the model config) | Per model lifecycle |
| SECURITY_SECRET | Encryption keys, signing keys, service credentials | HSM/KMS | Never | Rotated per schedule |
| LEGAL_PRIVILEGED | Legal advice, investigation notes, regulatory correspondence | At rest + access-restricted | Never | Per legal hold |

### 7.1 Classification Enforcement

Data classification is enforced at three layers:

**Schema layer:** Every table includes a `data_classification` column with a default value. The column is checked at insert time. Tables containing mixed-classification data (e.g., call_turns with redacted text and raw text reference) carry the highest classification among their fields.

**Application layer:** The data access layer checks classification before any read or write. Queries that would return data above the caller's clearance level are rejected. Cross-classification joins are logged and audited.

**Export layer:** Data exports, DSAR responses, and analytics feeds filter based on classification. PCI_SENSITIVE_AUTHENTICATION data is never exported. PCI_CARDHOLDER data is exported only in tokenized form.

---

## 8. Tenant Isolation

### 8.1 Row-Level Security

All tables that contain tenant-scoped data include a `tenant_id` column. PostgreSQL row-level security (RLS) policies ensure that queries from a tenant's connection can only see that tenant's data.

```sql
-- Example RLS policy (applied to every tenant-scoped table)
alter table call_sessions enable row level security;

create policy tenant_isolation on call_sessions
  using (tenant_id = current_setting('app.tenant_id')::uuid);

-- Service accounts bypass RLS for cross-tenant operations (analytics, billing)
-- These accounts are restricted to specific read-only roles
```

### 8.2 Connection Routing

Each API request carries a tenant_id in the JWT or mTLS certificate. The connection middleware sets `app.tenant_id` before any query executes. This approach has no bypass path from application code.

### 8.3 Physical Isolation Options

Banks requiring physical database isolation use the dedicated or VPC deployment modes. In these modes, the tenant gets its own PostgreSQL instance. The application layer is identical; the difference is infrastructure topology.

---

## 9. PCI and PII Handling

### 9.1 PCI Data Flow

PCI cardholder data (card numbers) enters VocalIQ only through two paths:

1. **DTMF capture:** The Media Gateway captures DTMF tones in an isolated PCI-scoped process. The raw digits are tokenized immediately. Only the token leaves the PCI boundary. The Speech Layer, Conversation Runtime, and LLM never see raw card numbers.

2. **Tool Gateway responses:** Bank system queries may return masked card numbers (last 4 digits). These are classified as PCI_CARDHOLDER and displayed to the caller but never sent to the LLM.

PCI_SENSITIVE_AUTHENTICATION data (CVV, PIN, full PAN) is never stored in VocalIQ databases. If a caller speaks a CVV, the Speech Layer's redaction service replaces it with `[REDACTED_CVV]` before the transcript reaches any downstream component.

### 9.2 PII Redaction Pipeline

The Speech Layer applies redaction before transcripts leave the speech boundary:

```
Raw transcript -> Redaction service -> Redacted transcript -> Downstream components
                                    -> Sensitive payload ref -> Encrypted secure storage
```

Redaction is fail-closed: if the redaction service fails, the transcript is not forwarded. The call continues with audio-only state until redaction recovers or the call transfers to a human.

### 9.3 Sensitive Payload References

When sensitive data must be preserved for regulatory or investigation purposes, the redacted version goes into the main data path, and a reference to the encrypted original is stored separately. The `sensitive_payload_ref` UUID points to an encrypted blob in dedicated secure storage with separate access controls and key management.

---

## 10. Open Questions

1. Should audit event partitioning be by tenant_id (simpler queries) or by created_at (better for time-range scans)? Composite partitioning (tenant then time) is possible but adds operational complexity.

2. What is the expected audit event volume per tenant per day, and at what volume should the migration to a dedicated event store (Kafka/Pulsar) be triggered?

3. Should the knowledge_documents table support document-level encryption (separate keys per document) for banks that require it, or is table-level encryption sufficient?

4. How should the schema handle multi-region deployments where a tenant's data must remain in a specific geographic region? Separate database clusters per region, or logical partitioning within a global cluster?

5. Should call_sessions include a denormalized `slot_values_snapshot` column for fast post-call analysis, or should slot state always be reconstructed from call_turns?

6. What is the retention floor for audit events across all jurisdictions? MAS requires 5 years for transaction records. APRA requires 7 years. The schema supports per-tenant/per-jurisdiction policies but the minimum default needs a legal determination.
