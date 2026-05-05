# Component Specification: Risk-Aware Graph Compiler

**Document ID:** DOC_COMP_GC_001  
**Last Updated:** 2026-05-03  
**Owner:** Platform Engineering Lead

**Version History:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-03 | Initial specification |

**Principles Referenced:** S1 (Never build unsafe architecture), S2 (AI decisions through policy), G6 (Graphs deterministic at control flow), G7 (Prohibited actions cannot be unlocked), E3 (Prefer explicit), E5 (Test at policy boundary), E7 (Document decisions)


**Scope:** Covers the Risk-Aware Graph Compiler component within the VocalIQ platform. Internal implementation of this component's subcomponents is beyond scope unless it affects interface contracts.

**Assumptions:** Component operates within the VocalIQ reference architecture as defined in reference_architecture.md. Deployment follows the control-plane/data-plane split. All inter-component communication uses mTLS.

**Decisions Made:** Component boundaries and responsibilities follow the pipeline architecture. The 13-section specification template is used instead of narrative format to support direct implementation mapping.

**Alternatives Considered:** Documented in reference_architecture.md and architecture_principles.md at the architecture level. Component-level alternatives are captured in Open Questions (Section 14).

**Risks:** Component-specific failure modes documented in Section 9. Cross-component risks documented in ai_risk_register.md and operational_resilience.md.

**Source Links:** Handoff Section 12, reference_architecture.md, architecture_principles.md, ai_risk_register.md.

---

## 1. Purpose

The Risk-Aware Graph Compiler validates and compiles conversation graph definitions before they can be deployed to the Conversation Runtime. It is a build-time safety gate that prevents unsafe conversation flows from ever reaching production. The compiler statically analyzes graph definitions against a catalog of safety rules, regulatory constraints, and structural requirements, rejecting any graph that violates these rules.

This is the first enforcement layer in VocalIQ's defense-in-depth approach. The Graph Compiler catches unsafe designs at authoring time. The Policy Engine catches unsafe actions at runtime. The Tool Gateway catches unauthorized tool calls at execution time. No single layer is solely responsible for safety.

---

## 2. Responsibilities

- Parse and validate conversation graph definitions (YAML/JSON)
- Enforce structural integrity: no dead-end nodes, no unreachable nodes, all transitions resolve to valid nodes, every graph has a human fallback path
- Enforce authentication rules: no tool call nodes without preceding authentication nodes at the required level
- Enforce data access rules: no account-specific disclosure nodes before authentication
- Enforce PCI isolation: no nodes that pass PCI data to LLM-assisted nodes
- Enforce complaint handling: complaint signal detection nodes must have complaint handling paths
- Enforce collections/vulnerability rules: collections workflows must have jurisdiction tags and script controls, vulnerability detection must have escalation paths
- Enforce fraud handling: fraud signal nodes must have escalation/risk paths
- Enforce audit requirements: regulated disclosure nodes must emit audit events
- Enforce tool safety: tool nodes must have idempotency keys and failure handlers
- Enforce LLM constraints: LLM nodes cannot choose arbitrary tools (tool selection is graph-defined)
- Enforce prohibited actions: graphs containing A6-classified actions are rejected
- Produce human-readable compilation reports with specific error locations and remediation guidance
- Version compiled graphs and maintain compilation history

---

## 3. Non-Responsibilities

- Graph authoring or visual design (Graph Designer in Control Plane)
- Runtime policy enforcement (Policy Engine)
- Runtime graph execution (Conversation Runtime)
- Tool permission management (Tool Gateway)
- Model selection or inference (Model Gateway)

---

## 4. Inputs

| Input | Source | Format | Notes |
|-------|--------|--------|-------|
| Graph definition | Graph Designer / CI pipeline | YAML or JSON | Raw graph to compile |
| Compiler rules catalog | Platform configuration | YAML | Safety and structural rules |
| Tool registry | Tool Gateway | JSON | Available tools with risk levels and auth requirements |
| Policy rule summary | Policy Engine | JSON | Current policy rules for validation cross-reference |
| Authentication requirements | Fraud-Aware Identity Layer config | JSON | Auth level requirements per action type |
| Prohibited actions list | prohibited_use_cases.md | Config | A6-classified actions |

---

## 5. Outputs

| Output | Destination | Format | Notes |
|--------|-------------|--------|-------|
| Compiled graph | Graph Version Registry | Binary/JSON | Optimized graph ready for Conversation Runtime |
| Compilation report | Graph Designer / CI pipeline | JSON | Pass/fail with detailed findings |
| Compilation events | Audit Ledger | Structured events | Who compiled what, when, with what result |

### Example Compiler Error

```json
{
  "graph_id": "card_lost_v3",
  "graph_version": "draft",
  "compilation_result": "failed",
  "errors": [
    {
      "severity": "blocker",
      "rule_id": "AUTH_REQUIRED_FOR_CARD_BLOCK",
      "node_id": "block_card_tool_call",
      "message": "Card block action requires step-up authentication before execution.",
      "required_fix": "Add AuthenticateNode with method app_push_or_otp before ToolNode.",
      "category": "authentication"
    },
    {
      "severity": "blocker",
      "rule_id": "TOOL_NODE_REQUIRES_FAILURE_HANDLER",
      "node_id": "block_card_tool_call",
      "message": "ToolNode must define a failure handler node.",
      "required_fix": "Add failure_next transition to a FallbackNode or TransferNode.",
      "category": "structural"
    }
  ],
  "warnings": [
    {
      "severity": "warning",
      "rule_id": "GRAPH_COMPLEXITY_HIGH",
      "message": "Graph has 47 nodes and 83 transitions. Consider decomposing into sub-graphs for maintainability.",
      "category": "quality"
    }
  ]
}
```

---

## 6. APIs

### 6.1 Compiler API

**CompileGraph**
- `POST /compile` - Compile a graph definition
  - Input: graph definition (YAML/JSON), tenant_id, target_environment
  - Returns: compilation_result (pass/fail), compiled_graph (if pass), errors, warnings
  - Idempotent: same input produces same output

**ValidateGraph**
- `POST /validate` - Validate without full compilation (faster, for interactive editing)
  - Input: graph definition (YAML/JSON), validation_scope (structural, auth, full)
  - Returns: validation_result, errors, warnings

**GetRules**
- `GET /rules` - List all active compiler rules
  - Returns: rules with descriptions, severity levels, categories

**DiffGraphs**
- `POST /diff` - Compare two graph versions
  - Input: graph_v1, graph_v2
  - Returns: added_nodes, removed_nodes, changed_nodes, changed_transitions, new_risks

### 6.2 Deployment API

**PublishGraph**
- `POST /publish` - Publish a compiled graph to the version registry
  - Input: compiled_graph, approval_chain (who approved), deployment_target
  - Requires: compilation_result = pass, required approvals obtained
  - Returns: published_version, effective_at

**RollbackGraph**
- `POST /rollback` - Rollback to a previous graph version
  - Input: graph_id, target_version
  - Returns: rollback_result, active_sessions_affected

---

## 7. Data Models

### 7.1 CompilerRule

```
CompilerRule {
  rule_id: string
  name: string
  description: string
  category: "authentication" | "data_access" | "pci" | "complaint" | 
            "collections" | "fraud" | "audit" | "tool_safety" | 
            "llm_constraints" | "prohibited" | "structural" | "quality"
  severity: "blocker" | "warning" | "info"
  node_types_affected: string[]
  validation_logic: string (reference to rule implementation)
  remediation_guidance: string
  regulatory_references: string[]
  enabled: boolean
  tenant_overridable: boolean (false for safety rules)
}
```

### 7.2 CompilationResult

```
CompilationResult {
  compilation_id: string
  graph_id: string
  graph_version: string
  tenant_id: string
  result: "pass" | "fail"
  errors: CompilerFinding[]
  warnings: CompilerFinding[]
  info: CompilerFinding[]
  compiled_at: timestamp
  compiled_by: string
  compiler_version: string
  rules_version: string
  node_count: int
  transition_count: int
  complexity_score: int
}
```

### 7.3 CompilerRulesCatalog

The following rules are enforced (non-exhaustive):

| Rule ID | Category | Severity | Description |
|---------|----------|----------|-------------|
| NO_DEAD_END | structural | blocker | Every non-EndNode must have at least one outgoing transition |
| NO_UNREACHABLE | structural | blocker | Every node must be reachable from the start node |
| HUMAN_FALLBACK_REQUIRED | structural | blocker | Every graph must have at least one TransferNode or FallbackNode reachable from every path |
| AUTH_REQUIRED_FOR_TOOL | authentication | blocker | ToolNodes require preceding AuthenticateNode at the tool's required auth level |
| AUTH_REQUIRED_FOR_DISCLOSURE | authentication | blocker | DisclosureNodes for account data require preceding AuthenticateNode |
| NO_PCI_TO_LLM | pci | blocker | No data path from DTMF/PCI capture to any LLM-assisted node |
| COMPLAINT_PATH_REQUIRED | complaint | blocker | IntentNodes that detect complaint intent must have a complaint handling path |
| COLLECTIONS_JURISDICTION_TAG | collections | blocker | Collections workflow graphs must specify jurisdiction |
| FRAUD_ESCALATION_REQUIRED | fraud | blocker | RiskNodes detecting high/critical fraud must route to escalation |
| AUDIT_ON_DISCLOSURE | audit | blocker | Regulated DisclosureNodes must emit audit events |
| TOOL_IDEMPOTENCY | tool_safety | blocker | ToolNodes must specify idempotency keys |
| TOOL_FAILURE_HANDLER | tool_safety | blocker | ToolNodes must define failure_next transition |
| LLM_NO_ARBITRARY_TOOLS | llm_constraints | blocker | LLM-assisted nodes cannot dynamically select tools |
| PROHIBITED_ACTION | prohibited | blocker | Graphs containing A6-classified tool calls are rejected |
| VULNERABILITY_ESCALATION | structural | blocker | Vulnerability detection must have human escalation path |
| GRAPH_COMPLEXITY | quality | warning | Graphs exceeding complexity thresholds generate warnings |

---

## 8. Dependencies

| Dependency | Type | Criticality | Fallback |
|-----------|------|-------------|----------|
| Tool Registry (Tool Gateway) | Configuration dependency | High | Use cached tool registry. Alert if stale. |
| Policy rule summary | Configuration dependency | High | Use cached policy summary. Alert if stale. |
| Graph Version Registry | Storage dependency | High | If registry unavailable, compilation succeeds but publishing is blocked. |
| Audit Ledger | Sidecar | Medium | Buffer compilation events locally |

---

## 9. Failure Modes

| Failure | Detection | Response | Recovery |
|---------|-----------|----------|----------|
| Compiler crash during compilation | Process monitoring | Return compilation error. Graph is not compiled, not published. No unsafe graph enters production. | Restart compiler, retry compilation |
| Tool registry unavailable | Connection failure | Compile with cached registry and warning. Require re-compilation with fresh registry before publishing. | Monitor Tool Gateway, retry with fresh registry |
| Rules catalog corruption | Validation checksum failure | Refuse all compilations until rules are restored. Alert operations. | Restore rules from version control |
| Graph definition parse error | YAML/JSON parser error | Return parse error with line/column number. | Fix graph definition |
| Circular transition detected | Graph traversal analysis | Report cycle with involved nodes. Block compilation. | Fix graph to remove cycle |

---

## 10. Security Controls

- Compiler rules catalog is version-controlled and change-tracked. Changes to blocker-severity rules require CTO approval.
- Compilation results are immutable audit records. A compilation cannot be retroactively changed from "fail" to "pass."
- Publishing requires compilation_result = pass. There is no override mechanism for blocker findings.
- Compilation is deterministic: same input + same rules = same output. No randomness, no external data that could be manipulated.
- Role-based access: only authorized graph designers can submit graphs for compilation. Only authorized approvers can publish compiled graphs.

---

## 11. Audit Events

| Event Type | Trigger | Payload |
|-----------|---------|---------|
| graph.compilation.started | Compilation requested | compilation_id, graph_id, tenant_id, submitted_by |
| graph.compilation.completed | Compilation finished | compilation_id, result (pass/fail), error_count, warning_count, duration_ms |
| graph.compilation.blocker | Blocker-severity finding | compilation_id, rule_id, node_id, message |
| graph.published | Compiled graph published | graph_id, version, published_by, approved_by, effective_at |
| graph.rollback | Graph version rolled back | graph_id, from_version, to_version, rolled_back_by, reason |
| graph.rules.updated | Compiler rules updated | rules_version, changed_rules, updated_by, approval_chain |

---

## 12. Metrics

| Metric | Type | Description |
|--------|------|-------------|
| gc_compilations_total | Counter | Total compilations by result (pass/fail) and tenant |
| gc_compilation_duration_ms | Histogram | Compilation time |
| gc_blocker_findings_total | Counter | Blocker findings by rule_id |
| gc_warning_findings_total | Counter | Warning findings by rule_id |
| gc_graph_complexity_score | Histogram | Complexity scores of compiled graphs |
| gc_graphs_published_total | Counter | Published graphs by tenant |
| gc_rollbacks_total | Counter | Rollback events |
| gc_rules_count | Gauge | Active compiler rules by severity |

---

## 13. Test Cases

### Validation Tests

- Graph with ToolNode but no preceding AuthenticateNode: verify blocker
- Graph with DisclosureNode before auth: verify blocker
- Graph with PCI data flowing to LLM node: verify blocker
- Graph with A6 prohibited action (loan approval tool): verify blocker
- Graph with dead-end node: verify blocker
- Graph with no human fallback path: verify blocker
- Graph with circular transitions: verify blocker
- Graph with ToolNode missing idempotency: verify blocker
- Graph with ToolNode missing failure handler: verify blocker
- Valid graph with all requirements met: verify pass

### Compilation Tests

- Compile a 50-node graph within 5 seconds
- Deterministic compilation: same input produces identical output across runs
- Compilation with cached tool registry produces warning
- Graph diff correctly identifies added, removed, and changed nodes

### Publishing Tests

- Attempt to publish failed compilation: verify rejection
- Publish with valid approval chain: verify success
- Rollback to previous version: verify active sessions continue on old version, new sessions use rolled-back version

### Regression Tests

- After adding a new compiler rule, all previously passing graphs are re-validated
- After modifying a rule, the change is logged with approval chain

---

## 14. Open Questions

- Should the compiler support "draft" mode for graph designers to test partial graphs, or should all compilations enforce the full rule catalog?
- Should the compiler run at deployment time in addition to build time, to catch configuration drift (e.g., tool registry changes that invalidate previously compiled graphs)?
- How should the compiler handle graph inheritance or composition (e.g., a base graph extended by tenant-specific customizations)?
- Should the compiler produce a human-readable compliance report that can be provided to bank audit teams?
- How should the compiler handle rules that conflict with each other (e.g., a jurisdiction requires a disclosure that another rule restricts)?
