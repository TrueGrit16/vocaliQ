# Autonomy Classification Matrix: Authentication, Policy, and Handoff Controls

**Document ID:** DOC_AUTONOMY_MTX_001  
**Last Updated:** 2026-05-03  
**Owner:** Chief Product Officer

**Version History:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-03 | Initial matrix covering A0 through A6 with per-workflow control mapping |

**Purpose:** Map every banking voice workflow to its required authentication level, policy engine controls, and human handoff triggers. This matrix serves as the configuration source for the Policy Engine and Graph Compiler: when a workflow graph is compiled, the compiler validates that the graph's authentication gates, policy checkpoints, and handoff nodes match the controls specified here. If they don't, the graph fails validation and cannot be deployed.

**Scope:** Covers all 17 workflows defined in use_case_taxonomy.md (UC-001 through UC-017), plus the prohibited A6 category. Excludes outbound campaigns and wealth management advisory per taxonomy scope. Geographic defaults: Singapore primary, EU/UK/US secondary.

**Assumptions:** Authentication levels follow the AUTH_0 through AUTH_5 scale from the handoff. Policy controls assume OPA/Rego as a candidate engine per provisional defaults. Handoff triggers assume a Human Control Center with real-time supervisor dashboard. Risk scoring assumes a Fraud-Aware Identity Layer producing numeric risk scores with configurable thresholds.

**Decisions Made:** Matrix organized by autonomy level rather than by individual workflow because the same autonomy level imposes the same baseline control requirements. Per-workflow deviations from the baseline are documented as overrides. This allows the Policy Engine to load a base ruleset per autonomy level and then apply workflow-specific overrides.

**Alternatives Considered:** Per-workflow flat listing (rejected because it obscures the pattern that control requirements are primarily driven by autonomy level, not workflow specifics). Spreadsheet format (rejected because the narrative context around why specific controls exist is essential for reviewers who aren't familiar with banking operations).

**Risks:** Bank-specific policy engines may use different rule languages than OPA/Rego. Authentication provider capabilities may not support all AUTH levels described. Handoff trigger thresholds are configurable but initial defaults may need tuning per deployment.

**Open Questions:** Should the Policy Engine support dynamic autonomy reclassification during a call (e.g., an A2 call that detects fraud indicators gets elevated to A5 mid-conversation)? What is the fallback behavior if the Fraud-Aware Identity Layer is unavailable?

**Source Links:** Handoff Section 7 (Banking Use-Case Taxonomy), Section 7.1 (Autonomy Levels), Section 7.5 (Use-Case Approval Template), Section 12 (Policy and Risk Engine), Section 13 (Fraud-Aware Identity Layer), use_case_taxonomy.md.

---

## 1. Authentication Requirements by Autonomy Level

Each autonomy level imposes a minimum authentication floor. Individual workflows may require stricter authentication (step-up) based on the specific actions involved.

### AUTH Scale Reference

| Level | Name | Factors | Example Implementation |
|-------|------|---------|----------------------|
| AUTH_0 | Unknown | No verification | Caller identity not established |
| AUTH_1 | Claimed | Caller states identity, no verification | Caller provides name and date of birth |
| AUTH_2 | Soft verified | Account lookup + knowledge-based questions | Account number + mother's maiden name + recent transaction |
| AUTH_3 | OTP/app verified | Out-of-band challenge | SMS OTP, mobile app push notification, email code |
| AUTH_4 | Strong verified | Multi-factor with biometric or device binding | Voice biometric + OTP, device fingerprint + PIN |
| AUTH_5 | Human-verified high assurance | Human agent confirms identity through extended process | In-person verification, notarized document, video call with agent |

### Autonomy-to-Authentication Mapping

| Autonomy Level | Minimum Auth Floor | Step-Up Triggers | Rationale |
|----------------|-------------------|------------------|-----------|
| A0 | AUTH_0 | None | No account data accessed or disclosed. Public information only. |
| A1 | AUTH_0 | AUTH_1 if routing to authenticated queue | Routing does not require identity, but downstream queues may. |
| A2 | AUTH_2 | AUTH_3 recommended for sensitive accounts; AUTH_4 if fraud risk score is elevated | Account data will be disclosed. Must verify the caller is the account holder. |
| A3 | AUTH_2 | AUTH_3 if case involves financial products | Draft actions don't execute, but the case record contains account details. |
| A4 | AUTH_2 base, AUTH_3 for execution | AUTH_4 if action is high-risk (address change, card replacement with new address) | Actions will be executed. Step-up gates prevent unauthorized changes. |
| A5 | AUTH_3 | AUTH_4 recommended; human approver performs additional verification | Human must approve, but the request itself must be authenticated. |
| A6 | N/A | N/A | AI never executes. Human handles the entire interaction. |

### Per-Workflow Authentication Overrides

These workflows deviate from their autonomy level's default authentication because of specific risk characteristics.

| Workflow | Autonomy | Default Auth | Override Auth | Reason |
|----------|----------|-------------|---------------|--------|
| UC-005: Balance and Transactions | A2 | AUTH_2 | AUTH_3 recommended | Balance disclosure is sensitive PII; spoofing risk justifies stronger verification. |
| UC-008: Lost/Stolen Card | A4 | AUTH_2 + AUTH_3 step-up | AUTH_2 for block (urgency), AUTH_3 for replacement | Card block is consumer-protective and time-sensitive. Replacement requires higher bar because it involves address and new card issuance. |
| UC-009: Card Activation | A4 | AUTH_2 + AUTH_3 step-up | AUTH_3 as baseline | Activation of a card that may have been intercepted requires strong verification from the start, not as a step-up. |
| UC-011: Fraud Alert | A4/A5 | AUTH_3 | AUTH_4 recommended | Fraud confirmation calls are themselves a fraud vector. Caller may be the fraudster confirming "their" transaction. |
| UC-014: Contact Detail Update | A4 | AUTH_2 + AUTH_3 step-up | AUTH_4 as baseline | Contact detail changes are the primary account takeover vector. Strong authentication is non-negotiable. |

---

## 2. Policy Engine Controls by Autonomy Level

The Policy Engine enforces rules at runtime. Rules are evaluated at specific checkpoints in the conversation graph. The following table defines which control categories are active at each autonomy level.

### Control Categories

| Category | Description |
|----------|-------------|
| Content Boundary | Controls what information the AI can and cannot share |
| Disclosure Control | Rules about what account data can be disclosed and under what conditions |
| Action Permission | Rules about what actions the AI can execute |
| Risk Threshold | Configurable thresholds that trigger escalation or blocking |
| Temporal Control | Time-based rules (cooldown periods, business hours, rate limits) |
| Fairness Monitor | Rules that detect potentially discriminatory patterns in AI decisions |

### Autonomy-to-Policy Control Mapping

**A0 (Informational)**

Active controls: Content Boundary only.

Policy rules enforce:
- Responses must come from approved knowledge base only (no web scraping, no hallucination)
- Advice boundary detection: block responses that cross from factual information into personalized recommendations
- Content freshness validation: flag if knowledge base content is older than configured threshold
- No account data in responses regardless of what caller says

**A1 (Triage and Routing)**

Active controls: Content Boundary, Risk Threshold.

Adds to A0:
- Routing rules mapped to intent classifications
- Vulnerability detection rules (must trigger appropriate routing for vulnerable callers)
- Escalation rules for unrecognized intents (max retry count before human transfer)
- Emergency detection (threat, fraud in progress, medical emergency) triggers immediate human transfer

**A2 (Authenticated Read-Only)**

Active controls: Content Boundary, Disclosure Control, Risk Threshold.

Adds to A1:
- Disclosure rules per data type (balance: permitted after AUTH_2; full account number: never disclosed; transaction details: permitted with restrictions)
- PCI redaction rules (card numbers must be masked before reaching Model Gateway or logs)
- Joint account disclosure rules (which account holders are authorized to receive which information)
- Session disclosure tracking (audit what was disclosed and to whom)
- Rate limiting on disclosure volume (prevent bulk data extraction)

**A3 (Draft Action)**

Active controls: Content Boundary, Disclosure Control, Risk Threshold, Temporal Control.

Adds to A2:
- Case creation rules (required fields, classification validation)
- Draft action permissions (what record types the AI can create)
- Case routing rules (how cases are assigned to human reviewers)
- Temporal controls on case creation rate (prevent spam or abuse)
- Complaint-specific rules (if workflow is complaint intake): regulatory timeline tracking initiation, vulnerability flagging

**A4 (Controlled Execution)**

Active controls: All categories except Fairness Monitor (unless fee-related).

Adds to A3:
- Action permission rules per action type (block card: permitted; change address: permitted with AUTH_4; initiate transfer: prohibited)
- Customer confirmation rules (which actions require explicit verbal confirmation before execution)
- Rollback capability flags (mark which actions can be undone)
- Step-up authentication triggers per action
- Execution rate limits (prevent rapid-fire actions that could indicate compromised session)
- Post-action notification rules (which actions trigger SMS/email confirmation to customer)

**A5 (Human-Approved Execution)**

Active controls: All categories.

Adds to A4:
- Human approval workflow rules (which actions queue for approval, which supervisor role can approve)
- Timeout rules for human approval (what happens if no supervisor responds within threshold)
- AI recommendation rules (what supporting data the AI must assemble for the supervisor)
- Approval audit rules (supervisor action must be logged with reason)
- Fairness monitor active for fee waiver decisions (detect patterns that might indicate discriminatory approval/denial)

**A6 (Prohibited)**

Active controls: Action Permission (block all), Risk Threshold (maximum).

Single rule: Block all execution. Any graph path that reaches an execution node for a prohibited workflow must fail compilation. At runtime, the Policy Engine blocks as defense-in-depth. Mandatory human transfer.

### Per-Workflow Policy Overrides

| Workflow | Autonomy | Override | Reason |
|----------|----------|----------|--------|
| UC-002: Product FAQ | A0 | Advice boundary detection set to strict mode | Product information can easily cross into personalized advice. False positives are acceptable (better to transfer to human than risk advice violation). |
| UC-007: Complaint Intake | A3 | Vulnerability detection set to mandatory active | Complaint callers are more likely to be vulnerable. FCA Consumer Duty requires proactive vulnerability detection. |
| UC-008: Lost/Stolen Card | A4 | Block action permitted before full step-up authentication | Consumer protection urgency. Blocking prevents further fraud losses. Replacement requires full step-up. |
| UC-011: Fraud Alert | A4/A5 | APP scam detection rules active | Authorized push payment scams involve callers confirming transactions under duress. Policy Engine must detect duress indicators. |
| UC-015: Collections | A2/A4 | Jurisdictional script controls mandatory; vulnerability detection mandatory | Collections regulations vary by jurisdiction. All collections callers are treated as potentially vulnerable by default. |

---

## 3. Human Handoff Triggers by Autonomy Level

The Human Control Center receives handoff requests when specific triggers fire. Triggers fall into categories that apply at different autonomy levels.

### Trigger Categories

| Category | Description | Active From |
|----------|-------------|-------------|
| Safety | Threat to life, medical emergency, caller in danger | All levels |
| Authentication | Failed verification, suspected identity fraud | A2+ |
| Fraud | Fraud indicators, suspicious patterns, social engineering | A2+ |
| Vulnerability | Caller distress, financial difficulty, confusion, age-related | All levels |
| Operational | Tool errors, system failures, workflow not found | All levels |
| Preference | Caller requests human agent | All levels |
| Complexity | Multi-intent, ambiguous situation, edge case | A1+ |
| Regulatory | Compliance boundary crossed, prohibited action requested | A0+ |
| Quality | Low confidence in AI response, repeated misunderstanding | All levels |

### Per-Workflow Handoff Trigger Details

**UC-001 through UC-003 (A0 workflows)**

Handoff triggers are minimal. Transfer on: caller requests human, accessibility needs, question outside knowledge base scope, vulnerability indicators, safety concerns.

Handoff type: Warm transfer with context summary to general queue.

**UC-004 (A1 Routing)**

Handoff triggers: Unrecognized intent after two clarification attempts, caller frustration (detected via speech analysis), caller requesting specific person, emergency detection, vulnerability indicators.

Handoff type: Routing to appropriate specialist queue. Context includes classified intent (if any) and caller interaction summary.

**UC-005 and UC-006 (A2 Read-Only)**

Handoff triggers: Authentication failure (max 3 attempts), elevated fraud risk score, caller disputes a transaction (route to dispute workflow), suspicious inquiry pattern (multiple account lookups), caller distress about account state.

Handoff type: Warm transfer with authentication status and query summary. If fraud is suspected, route to fraud team with risk score.

**UC-007 (A3 Complaint Intake)**

Handoff triggers: Caller distress or anger exceeding threshold, complaint involves potential regulatory breach, complaint about the AI system itself, caller requests supervisor, vulnerability indicators (mandatory active detection), complaint classification uncertain.

Handoff type: Warm transfer with complaint draft case attached. Supervisor sees complaint narrative, classification, caller sentiment assessment.

**UC-008 through UC-010 (A4 Execution)**

Handoff triggers: Suspected account takeover, tool execution failure, action outside permitted scope, customer revokes consent during execution, caller disputes an action taken, post-action anomaly detected.

Handoff type: Urgent transfer for fraud/takeover, standard transfer for operational issues. Transfer includes action audit trail, authentication status, and any pending actions.

**UC-011 (A4/A5 Fraud Alert)**

Handoff triggers: Caller denies transaction (confirmed fraud), multiple flagged transactions, high-value transaction above threshold, authentication failure, suspected social engineering, APP scam indicators, caller distress.

Handoff type: Immediate transfer to fraud team. Full call context including risk scores, flagged transaction details, and authentication events.

**UC-012 through UC-017 (Later Wave)**

Handoff triggers are defined per workflow in use_case_taxonomy.md. These workflows require additional trigger tuning during Phase 2 implementation based on pilot data from first-wave deployments.

### Handoff Protocol

Regardless of trigger, every handoff follows this protocol:

1. AI informs caller they are being connected to a specialist
2. AI transmits structured context to the receiving agent or supervisor (call summary, authentication status, actions taken, reason for handoff)
3. AI remains available for the receiving human to consult (providing call transcript, policy lookups, or system data)
4. Handoff event is logged in the Audit Ledger with trigger type, timestamp, and destination
5. If the handoff fails (no human available within timeout), the AI informs the caller of expected wait time and offers callback

---

## 4. Integration Requirements by Workflow

Each workflow requires connections to specific bank backend systems through the Tool Gateway. The Tool Gateway mediates all API calls with scoped permissions, audit logging, and circuit breaker patterns.

| Workflow | Backend Systems | Access Type | Circuit Breaker Behavior |
|----------|----------------|-------------|------------------------|
| UC-001 | Branch/ATM location DB | Read | Serve cached data if DB unavailable |
| UC-002 | Product content repository | Read | Serve cached content with freshness warning |
| UC-003 | Branch hours DB, booking system | Read + Write | Read: cached fallback. Write: inform caller booking is temporarily unavailable |
| UC-004 | ACD/routing, queue mgmt, WFM | Read + Route | Route to default queue if ACD unavailable |
| UC-005 | Core banking, transaction history, auth service, fraud scoring | Read | Transfer to human if core banking unavailable |
| UC-006 | Application processing, CRM | Read | Transfer to human if application system unavailable |
| UC-007 | Complaint mgmt, CRM, case routing | Read + Write (draft) | Capture complaint in local buffer; queue for submission when system recovers |
| UC-008 | Card processor, CRM, fraud case, notification | Read + Write (execute) | Card block must succeed; if processor unavailable, immediate human transfer |
| UC-009 | Card processor, auth service, CRM | Read + Write (execute) | If processor unavailable, inform caller and offer callback |
| UC-010 | Statement system, fulfillment, CRM | Read + Write (execute) | If system unavailable, queue request and confirm fulfillment timeline |
| UC-011 | Fraud detection, card processor, case mgmt, fraud queue | Read + Write (execute) + Route | If fraud system unavailable, immediate transfer to fraud team |
| UC-012-017 | Various (see use_case_taxonomy.md) | Variable | Defined during Phase 2 implementation |

---

## 5. Evaluation Scenarios by Autonomy Level

Each autonomy level requires specific evaluation scenarios to validate that controls work correctly. These scenarios feed into the Evaluation and Assurance Lab design.

Note: This section defines evaluation focus areas by autonomy level (what categories of testing each level requires). Per-workflow evaluation scenarios (specific test case descriptions for each individual workflow) are documented in use_case_taxonomy.md within each UC entry and in the workflow_catalog.csv evaluation_scenarios column. When building the Evaluation Lab, combine the level-based focus areas below with the per-workflow scenarios from those companion documents.

### A0 Evaluation Focus

- Knowledge boundary testing: Can the AI be tricked into generating information not in the approved knowledge base?
- Advice boundary testing: Does the AI correctly refuse personalized recommendations?
- Hallucination testing: Does the AI fabricate branch locations, product details, or other information?

### A1 Evaluation Focus

- Intent classification accuracy across accents, languages, and noise levels
- Emergency detection reliability (false positives and false negatives)
- Vulnerability detection sensitivity
- Multi-intent resolution accuracy

### A2 Evaluation Focus

- Authentication bypass attempts (social engineering, caller impersonation, synthetic voice)
- Disclosure policy adherence (does the AI ever disclose data it shouldn't?)
- PCI redaction completeness (no card numbers in logs, transcripts, or Model Gateway inputs)
- Joint account authorization accuracy

### A3 Evaluation Focus

- Case creation completeness and classification accuracy
- Draft action boundary (does the AI ever execute instead of draft?)
- Complaint narrative capture quality
- Regulatory timeline initiation accuracy

### A4 Evaluation Focus

- Action authorization (does the AI execute actions without proper auth and confirmation?)
- Step-up authentication enforcement
- Customer confirmation capture (verbal "yes" correctly detected, duress indicators caught)
- Rollback capability testing
- Post-action notification delivery

### A5 Evaluation Focus

- Human approval workflow end-to-end (action queued, supervisor notified, approval logged)
- Timeout handling (what happens when supervisor doesn't respond?)
- AI recommendation quality (does the supporting data help the supervisor decide?)
- Fairness monitoring accuracy

### A6 Evaluation Focus

- Graph compiler rejection testing (any graph containing execution nodes for A6 workflows must fail compilation)
- Runtime policy engine block testing (defense-in-depth: even if a graph slipped past the compiler, the policy engine blocks)
- Prompt injection resistance (adversarial inputs attempting to make the AI execute prohibited actions)
- Jailbreak resistance for prohibited categories
