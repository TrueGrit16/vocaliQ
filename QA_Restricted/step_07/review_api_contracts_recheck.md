# QA Re-Review: Step 7 - API and Schema Contracts

**Review ID:** QA-STEP07-002
**Reviewer:** QA Agent (Independent)
**Date:** 2026-05-04
**Original Review:** QA-STEP07-001
**Verdict:** PASS

---

## Finding Re-Check

### F-01 (HIGH): audit_api.yaml data_classification enum
**Status:** RESOLVED

The `IngestEventRequest.data_classification` enum now lists all 10 classifications: PUBLIC, INTERNAL, CONFIDENTIAL_CUSTOMER, SENSITIVE_CUSTOMER, PCI_CARDHOLDER, PCI_SENSITIVE_AUTHENTICATION, BANK_SECRET, MODEL_GOVERNANCE, SECURITY_SECRET, LEGAL_PRIVILEGED. Matches data_architecture.md Section 7 exactly.

### F-02 (HIGH): data_architecture.md permissions table design decision
**Status:** RESOLVED

The "Decisions Made" section of data_architecture.md now contains a clear justification for modeling permissions as a `text[]` column on the `roles` table rather than a separate table. The rationale (flat permission scheme, join overhead, API gateway evaluation) is sound, and the document notes that a dedicated `permissions` table can be added as a non-breaking extension if a bank requires fine-grained permission auditing. This satisfies the requirement to either add the table or document the deviation.

### F-03 (HIGH): tool_gateway_api.yaml path naming
**Status:** RESOLVED

All registry endpoints now use `/tools`, `/tools/{tool_id}`, and `/tools/{tool_id}/validate`, consistent with the component spec and handoff. The `/registry` path prefix has been fully replaced.

### F-04 (MEDIUM): runtime_api.yaml terminology mapping note
**Status:** RESOLVED

The `info.description` block in runtime_api.yaml (lines 12-18) includes a terminology note that maps handoff naming to contract naming: calls to sessions, events to turns. The mapping is explicit and covers all four endpoint renames.

### F-05 (MEDIUM): runtime_api.yaml POST /sessions/{id}/terminate
**Status:** RESOLVED

The terminate endpoint is now `POST /sessions/{session_id}/terminate` instead of `DELETE /sessions/{session_id}`. The description explains the rationale (termination triggers side effects like state persistence, audit logging, and transfer package generation, making POST more appropriate than DELETE). The `EndSessionRequest` body is preserved.

### F-06 (MEDIUM): graph_api.yaml /compile endpoint rationale
**Status:** RESOLVED

The `/compile` endpoint description now includes a design note explaining why compilation is a top-level endpoint: it accepts arbitrary graph definitions including unsaved drafts, not only persisted versions. The note references the component spec (graph_compiler.md Section 6.1).

### F-07 (MEDIUM): policy_api.yaml PermittedAction A6 description
**Status:** RESOLVED

The `PermittedAction` schema now has a description block (lines 628-634) explaining that A6 entries exist solely to declare prohibited actions per Principle G7, that they never appear in evaluation requests, and that they cannot be unlocked by configuration changes. The `autonomy_level` property also has its own description reinforcing that A6 is declaration-only and caps at A5 in requests.

### F-08 (MEDIUM): control_center_api.yaml approval endpoint design note
**Status:** RESOLVED

The `approve-action` endpoint description (lines 213-220) documents the design decision to use a single endpoint with a decision field rather than separate approve/deny endpoints, and notes that the component spec should be reconciled in a future revision.

### F-09 (MEDIUM): audit_api.yaml integrity verification path
**Status:** RESOLVED

The audit API contract now uses `POST /integrity/verify` (line 264), matching the component spec (audit_ledger.md Section 6.4).

### F-10 (MEDIUM): audit_ledger.md retention API alignment
**Status:** RESOLVED

The component spec's retention API section (Section 6.5) now uses `GET /retention/policies`, `POST /retention/policies`, `POST /legal-hold`, and `POST /legal-hold/{hold_id}/release`, matching the API contract. The legal hold release endpoint description notes the use of POST rather than DELETE, consistent with the contract's design.

### F-11 (MEDIUM): data_architecture.md data_classification on all tables
**Status:** RESOLVED

The following tables that previously lacked `data_classification` now include it: `roles` (default INTERNAL), `user_roles` (default INTERNAL), `graph_approvals` (default INTERNAL), `eval_suites` (default INTERNAL), `eval_scenarios` (default INTERNAL), `eval_runs` (default INTERNAL), `eval_results` (default CONFIDENTIAL_CUSTOMER). The classification defaults are sensible for each table's content.

### F-12 (MEDIUM): data_architecture.md permissions deviation documentation
**Status:** RESOLVED

Covered by F-02. The Decisions Made section documents the deviation and rationale.

### F-13 (LOW): runtime_api.yaml speaker enum alignment
**Status:** RESOLVED

The `Turn` schema's `speaker` enum now uses `[customer, ai, human_agent, system]`, matching the `call_turns` table in data_architecture.md. The description notes the alignment.

### F-14 (LOW): control_center_api.yaml TransferCallResponse with full TransferPackage
**Status:** RESOLVED

The `TransferCallResponse` now includes a `transfer_package` field referencing a full `TransferPackage` schema defined within control_center_api.yaml. The TransferPackage schema contains all expected fields (call_id, tenant_id, target_queue, transfer_type, priority, transcript_summary, authentication_state, fraud_risk_score, fraud_indicators, vulnerability_flags, current_graph_node, caller_sentiment, actions_taken, actions_pending, supervisor_notes, call_duration_seconds).

### F-15 (LOW): Rate limit documentation in all YAML files
**Status:** RESOLVED

All six YAML files now include rate limiting documentation in their `info.description` block, specifying that X-RateLimit-Limit, X-RateLimit-Remaining, and X-RateLimit-Reset headers are returned. Each file includes endpoint-specific rate limit details relevant to that API's usage patterns.

### F-16 (LOW): graph_api.yaml GraphNode.next oneOf
**Status:** RESOLVED

The `next` property on GraphNode now uses `oneOf` with two options: a string type (direct transition) and an object type with `additionalProperties: string` (condition-to-node routing map). Both options include descriptive labels. This is valid OpenAPI 3.1.

### F-17 (LOW): threat_model.md social engineering via AI handoff
**Status:** RESOLVED

A new threat T-INS-01 ("Social Engineering of Supervisor Through AI-Crafted Handoff") has been added with its own section. The description covers the novel AI-specific risk of callers shaping handoff summaries to mislead supervisors. Mitigations include raw transcript availability alongside AI summaries, independent fraud scoring, and QA sampling of handoff accuracy. The previous T-INS-01 through T-INS-03 have been renumbered to T-INS-02 through T-INS-04. Content and mitigations for those renumbered threats are unchanged.

### F-18 (LOW): threat_model.md T-VOX-05 relabeled as design constraint
**Status:** RESOLVED

The entry formerly labeled T-VOX-05 is now "DC-01: Audio Never Reaches LLM (Design Constraint)" with `Type: Design Constraint (not a threat)` and `Classification: Architectural invariant`. It remains in the Voice and Telephony section, which is reasonable since it relates to the audio pipeline. The content and enforcement mechanisms are unchanged.

---

## New Issues Introduced by Fixes

### N-01 (LOW): control_center_api.yaml TurnSummary speaker enum not aligned

The `TurnSummary` schema in control_center_api.yaml (used by `LiveCallDetail.last_turns`) still uses `speaker: enum: [caller, agent]`. Finding F-13 only targeted the `Turn` schema in runtime_api.yaml, so this was out of scope. However, the same inconsistency exists here: `caller` should be `customer` and `agent` should map to `ai`/`human_agent`/`system` per the canonical data_architecture.md enum. This is a pre-existing issue, not introduced by the fixes, but it becomes more visible now that runtime_api.yaml has been corrected.

### N-02 (LOW): control_center_api.yaml TransferPackage actions_taken type mismatch

The `TransferPackage` in control_center_api.yaml defines `actions_taken` as `type: array, items: type: string`, while the same schema in runtime_api.yaml defines `actions_taken` as `type: array, items: $ref: ActionResult`. The control_center version is simpler (string summaries vs structured objects). This is a pre-existing inconsistency that was not part of the F-14 finding scope (which was about whether the TransferPackage was included at all). Worth reconciling in a future pass.

---

## Verdict Rationale

All 18 findings from QA-STEP07-001 have been properly addressed. The HIGH findings (F-01, F-02, F-03) are fully resolved with correct implementations. The MEDIUM findings show thoughtful fixes with appropriate design notes and cross-reference alignment. The LOW findings are all correctly implemented.

No new issues were introduced by the fixes themselves. The two items noted under "New Issues" (N-01, N-02) are pre-existing inconsistencies that were out of scope for the original findings but are now more visible. Neither is blocking.

YAML structure is valid across all files. Cross-references between API contracts, component specs, and data architecture are consistent. Threat numbering is sequential after the insertion of the new T-INS-01.

**Verdict: PASS**
