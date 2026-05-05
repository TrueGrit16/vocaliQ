# Banking Use-Case Taxonomy: Voice AI Workflows by Autonomy and Risk

**Document ID:** DOC_WORKFLOW_TAX_001  
**Last Updated:** 2026-05-03  
**Owner:** Chief Product Officer

**Version History:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-03 | Initial taxonomy covering 30+ banking voice workflows |

**Purpose:** Classify banking contact center workflows by autonomy level, risk category, authentication requirements, and regulatory complexity. This taxonomy drives architecture decisions (which components need to exist), policy engine design (what rules enforce which constraints), graph designer scope (which node types and validation rules matter), and MVP scoping (which workflows to build first).

**Scope:** Covers inbound retail and SME banking contact center workflows. Excludes wealth management advisory, institutional banking, and treasury operations. Excludes outbound campaigns (collections outbound, sales outbound, survey outbound) from first release per handoff guidance, though collections inbound is included. Geographic scope assumes Singapore as primary jurisdiction with EU, UK, and US as secondary (per provisional defaults in context summary).

**Assumptions:** Authentication levels map to the handoff's AUTH_0 through AUTH_5 scale. Autonomy levels map to the handoff's A0 through A6 scale. Workflow risk assessments are based on banking operational experience, not specific bank policies (which vary by institution). "First wave" selection prioritizes high volume, low-to-moderate risk, clear procedural scripts, and measurable operational value per Section 7.2. All workflows assume inbound servicing only in first release.

**Decisions Made:** Taxonomy organized by autonomy level (A0 through A6) rather than by banking product line (cards, accounts, loans) because autonomy level directly determines architecture requirements. Within each level, workflows are ordered by recommended implementation priority. Risk classification uses a three-tier scale (Low, Medium, High) reflecting operational, regulatory, and fraud exposure. Each workflow references the specific VocalIQ components it exercises and the integration points it requires.

**Alternatives Considered:** Product-line organization (all card workflows together, all account workflows together) was considered and rejected because the same autonomy level imposes the same architectural constraints regardless of product line. A simpler "allow / defer / prohibit" classification was considered but replaced by the handoff's more granular A0-A6 scale, which provides finer control over which workflows require which controls.

**Risks:** Workflow taxonomy may not match specific bank operating models, which vary by institution, geography, and product mix. Risk classifications are generalized and may be overridden by individual bank risk appetite. New regulatory requirements (e.g., EU AI Act enforcement actions) may reclassify some workflows to higher risk or prohibited status.

**Open Questions:** Should vulnerability detection (identifying financially or emotionally vulnerable callers) be its own workflow or a cross-cutting control embedded in every workflow? How should multi-intent calls be handled (e.g., caller starts with balance inquiry but transitions to a complaint)? Should bereavement handling be classified as A3 (draft action) or A5 (human-approved) given the sensitivity involved?

**Source Links:** Handoff Section 7 (Banking Use-Case Taxonomy), Section 7.5 (Use-Case Approval Template), Section 8 (Banking-Specific Practical Issues), context summary Section 2 (autonomy levels).

---

## 1. Autonomy Level Framework

The handoff defines seven autonomy levels that govern what the AI agent is permitted to do. Each level imposes progressively stricter architectural requirements.

| Level | Name | What AI Can Do | Architecture Requirements |
|-------|------|---------------|--------------------------|
| A0 | Informational only | Provide public, non-account-specific information from approved knowledge bases | RAG Service with approved-content-only knowledge base. No authentication required. No bank system integration. Policy engine validates responses against approved content. |
| A1 | Triage and routing | Classify caller intent and route to appropriate queue or workflow | Intent classifier in Conversation Runtime. Routing rules in Policy Engine. No bank system reads. No customer data disclosed. |
| A2 | Authenticated read-only | Share account-specific information after successful authentication | Full authentication flow (AUTH_2+). Bank system read-only API calls via Tool Gateway. Disclosure policy enforcement. PCI redaction for card data. Audit logging of every data point disclosed. |
| A3 | Draft action | Collect data, classify issues, create cases or drafts for human review | Authentication required. Tool Gateway creates records but flags them for human review. No customer-impacting action executed autonomously. Case management integration. |
| A4 | Controlled execution | Execute low/medium-risk actions after policy checks and customer confirmation | Full authentication with step-up for sensitive actions. Policy Engine validates action against risk rules. Customer confirmation required before execution. Tool Gateway executes with scoped permissions. Full audit trail. Rollback capability where applicable. |
| A5 | Human-approved execution | AI prepares the action, gathers approvals, but a human must authorize execution | Same as A4 plus Human Control Center integration. Action queued for human supervisor approval. AI provides recommendation with supporting data. Timeout handling if human doesn't respond. |
| A6 | Prohibited autonomy | AI must not execute under any circumstances | Graph compiler rejects any graph that routes to execution for these workflows. Policy Engine blocks at runtime as defense-in-depth. Human transfer is mandatory. |

---

## 2. First-Wave Workflows (MVP Candidates)

These workflows are recommended for VocalIQ's initial release. They share characteristics: high call volume in banking contact centers, well-defined procedural scripts, low-to-moderate operational risk, and clear measurable value (containment rate, AHT reduction, cost savings).

### 2.1 A0: Informational Workflows

**UC-001: Branch and ATM Locator**

| Field | Value |
|-------|-------|
| Autonomy Level | A0 |
| Risk | Low |
| Authentication | None (AUTH_0) |
| Description | Caller asks for nearest branch or ATM location based on address, suburb, or postal code. AI responds with location details, operating hours, and available services. |
| Permitted Actions | Search location database, return branch/ATM details, offer to send SMS with directions |
| Prohibited Actions | Disclose any account information, access customer records |
| Required Components | RAG Service (location database), Conversation Runtime, basic Policy Engine |
| Integration Points | Branch/ATM location database (read-only) |
| Human Handoff Triggers | Request for services not available at suggested branch, accessibility requirements |
| Evaluation Scenarios | Ambiguous location queries, locations near branch coverage gaps, after-hours queries, multilingual location names |
| Regulatory Considerations | Accessibility requirements (alternative formats for visually impaired callers). Minimal regulatory exposure. |
| Priority | P1 - Day 1 pilot workflow |

**UC-002: Product FAQ from Approved Knowledge**

| Field | Value |
|-------|-------|
| Autonomy Level | A0 |
| Risk | Low-Medium |
| Authentication | None (AUTH_0) |
| Description | Caller asks about banking products (savings accounts, credit cards, loans, mortgages). AI responds from approved knowledge base only. No personalized recommendations. No suitability assessment. |
| Permitted Actions | Search approved product knowledge base, provide factual product information, offer to connect to product specialist |
| Prohibited Actions | Recommend specific products, provide personalized rates or pricing, assess suitability, compare products in ways that constitute advice, disclose any account information |
| Required Components | RAG Service (approved-content-only knowledge base with citation tracking), Conversation Runtime, Policy Engine (advice boundary detection) |
| Integration Points | Approved product content repository (read-only). Content must go through bank approval workflow before entering knowledge base. |
| Human Handoff Triggers | Questions that cross into advice territory, questions about product suitability, questions about specific rates or personalized pricing, caller expressing financial difficulty |
| Evaluation Scenarios | Questions that subtly cross from information to advice ("which card is best for me?"), outdated product information, questions about competitor products, questions about terms and conditions nuances |
| Regulatory Considerations | Financial advice boundary is jurisdictionally sensitive. In Singapore (MAS), in the EU (MiFID II), in the UK (FCA), and in the US (FINRA), personalized product recommendations may constitute regulated advice. The Policy Engine must detect and block advice-boundary crossings. RAG must return only bank-approved content, never web-scraped or hallucinated product details. |
| Priority | P1 - Day 1 pilot workflow |

**UC-003: Opening Hours and Appointment Booking**

| Field | Value |
|-------|-------|
| Autonomy Level | A0 (hours) / A4 (booking) |
| Risk | Low |
| Authentication | None for hours (AUTH_0), AUTH_2 for booking if linked to account |
| Description | Caller asks about branch/department hours. If booking is available, AI can schedule an appointment. |
| Permitted Actions | Provide hours, check appointment availability, book appointment slots |
| Prohibited Actions | Access account information, change account settings |
| Required Components | RAG Service (hours/calendar), Tool Gateway (booking system write for A4 portion), Conversation Runtime |
| Integration Points | Branch hours database, appointment booking system |
| Human Handoff Triggers | Complex booking requirements, accessibility needs, branch not found |
| Evaluation Scenarios | Holiday schedules, temporary closures, booking conflicts, time zone handling |
| Regulatory Considerations | Minimal. Call recording consent applies as for all calls. |
| Priority | P2 |

### 2.2 A1: Triage and Routing Workflows

**UC-004: Intelligent Intent Classification and Routing**

| Field | Value |
|-------|-------|
| Autonomy Level | A1 |
| Risk | Low-Medium |
| Authentication | None initially (AUTH_0); may request basic verification for routing to authenticated queues |
| Description | Replaces legacy IVR tree with natural language intent classification. Caller states reason for calling. AI classifies intent, applies routing rules, and transfers to appropriate queue, workflow, or specialist. |
| Permitted Actions | Classify intent, determine routing, provide estimated wait times, offer callback, route call |
| Prohibited Actions | Disclose account data, attempt to resolve issues beyond routing, promise specific outcomes |
| Required Components | Conversation Runtime (intent classification), Policy Engine (routing rules), Human Control Center (queue management integration) |
| Integration Points | ACD/routing system, queue management, workforce management (for wait time estimates) |
| Human Handoff Triggers | Unrecognized intent after two clarification attempts, caller frustration, caller requesting specific person, emergency (threat, fraud in progress) |
| Evaluation Scenarios | Multi-intent calls, ambiguous intent, emotional callers, callers who refuse to state intent, code-switching (multiple languages in one utterance), noisy audio, callers reading from scripts (potential social engineering) |
| Regulatory Considerations | Call recording consent must be established at the start of the routing flow. Vulnerability detection should be active from first utterance to ensure appropriate routing. |
| Priority | P1 - Day 1 pilot workflow (highest volume reduction potential) |

### 2.3 A2: Authenticated Read-Only Workflows

**UC-005: Balance and Recent Transactions**

| Field | Value |
|-------|-------|
| Autonomy Level | A2 |
| Risk | Medium |
| Authentication | AUTH_2 (account lookup + knowledge-based verification) minimum. AUTH_3 (OTP/app push) recommended. |
| Description | Authenticated caller requests account balance and/or recent transaction history. AI retrieves from core banking and reads back. |
| Permitted Actions | Authenticate caller, retrieve balance, retrieve last N transactions, read transaction details |
| Prohibited Actions | Disclose full account numbers, disclose other accounts not explicitly requested, provide financial advice based on balance, disclose to anyone other than verified account holder |
| Required Components | Fraud-Aware Identity Layer (authentication), Tool Gateway (core banking read), Policy Engine (disclosure rules, PCI redaction), Conversation Runtime, Audit Ledger |
| Integration Points | Core banking system (balance API), transaction history API, authentication/identity service, fraud risk scoring |
| Human Handoff Triggers | Authentication failure, suspicious activity on account, caller disputes a transaction (escalate to dispute workflow), caller distress about balance |
| Evaluation Scenarios | Multiple accounts (which to disclose?), joint accounts, overdrawn accounts (sensitivity), recent large/suspicious transactions, callers asking about transactions they don't recognize (potential fraud), PCI-sensitive data in transaction descriptions |
| Regulatory Considerations | Balance disclosure is account-specific PII. Must verify identity before any disclosure. Must not disclose to unauthorized callers (spoofing risk). PCI DSS applies if card numbers appear in transaction data. Audit trail must record what was disclosed, to whom, and when. In some jurisdictions, recording of full card numbers in voice recording is restricted. |
| Priority | P1 |

**UC-006: Application Status Inquiry**

| Field | Value |
|-------|-------|
| Autonomy Level | A2 |
| Risk | Low-Medium |
| Authentication | AUTH_2 minimum |
| Description | Caller checks status of a pending application (credit card, loan, account opening). AI retrieves status from application processing system. |
| Permitted Actions | Authenticate caller, retrieve application status, provide expected timeline, explain next steps |
| Prohibited Actions | Disclose application decision rationale (for credit products), change application details, expedite processing, disclose to non-applicant |
| Required Components | Fraud-Aware Identity Layer, Tool Gateway (application system read), Policy Engine, Conversation Runtime |
| Integration Points | Application processing system (read-only), CRM |
| Human Handoff Triggers | Application rejected (caller may need explanation from human), application stuck/delayed, caller wants to modify application |
| Evaluation Scenarios | Multiple pending applications, joint applications, applications in different stages, callers wanting reasons for delays |
| Regulatory Considerations | Credit decision explanations may trigger adverse action notice requirements (US ECOA/Reg B, UK FCA). AI should not attempt to explain credit decisions. |
| Priority | P2 |

### 2.4 A3: Draft Action Workflows

**UC-007: Complaint Intake**

| Field | Value |
|-------|-------|
| Autonomy Level | A3 |
| Risk | Medium-High |
| Authentication | AUTH_2 minimum |
| Description | Caller wishes to lodge a complaint. AI captures complaint details, classifies the complaint type, creates a case record, and confirms the complaint reference number. AI does not resolve the complaint. |
| Permitted Actions | Authenticate caller, capture complaint narrative, classify complaint category, create case in complaint management system, provide reference number, set expectations on response timeline |
| Prohibited Actions | Resolve or adjudicate the complaint, offer compensation, admit liability, promise specific outcomes, dismiss the complaint |
| Required Components | Fraud-Aware Identity Layer, Tool Gateway (complaint system write - draft), Policy Engine (complaint classification rules, vulnerability detection), Conversation Runtime, Audit Ledger (complete recording and transcript) |
| Integration Points | Complaint management system, CRM, case routing system |
| Human Handoff Triggers | Caller distress or anger, complaint involves potential regulatory breach, complaint about AI itself, caller requests supervisor, vulnerability indicators |
| Evaluation Scenarios | Emotionally charged callers, multi-issue complaints, complaints about fees (may overlap with fee waiver workflow), complaints involving third parties, complaints where caller is wrong but must still be handled respectfully, complaints that could indicate systemic issues |
| Regulatory Considerations | Complaints handling is heavily regulated in all target jurisdictions. UK FCA requires complaints to be acknowledged, investigated, and resolved within prescribed timeframes. Singapore MAS requires fair and prompt complaints handling. US CFPB tracks complaint patterns. The AI's role is intake and classification only - resolution requires human review. The complaint record must be tamper-evident and fully auditable. Vulnerability detection must be active throughout. |
| Priority | P1 |

### 2.5 A4: Controlled Execution Workflows

**UC-008: Lost or Stolen Card - Block and Replace**

| Field | Value |
|-------|-------|
| Autonomy Level | A4 |
| Risk | Medium |
| Authentication | AUTH_2 (soft auth for urgency) with step-up to AUTH_3 before replacement |
| Description | Caller reports card lost or stolen. AI authenticates, blocks the card immediately (urgent action to prevent fraud), initiates replacement card, and creates case notes. |
| Permitted Actions | Authenticate, block card, initiate replacement, confirm replacement delivery address, disclose replacement timeline, create case note |
| Prohibited Actions | Disclose full card number, change customer address (separate workflow), initiate money movement, process pending transactions |
| Required Components | All core components: Fraud-Aware Identity, Tool Gateway (card processor write), Policy Engine (risk assessment, step-up rules), Conversation Runtime, Audit Ledger |
| Integration Points | Card processor (block API, replacement API), CRM, fraud case system, notification service |
| Human Handoff Triggers | Suspected account takeover (caller may not be genuine), caller reports unauthorized transactions (escalate to fraud), tool error during card block, caller distress |
| Evaluation Scenarios | Social engineering attempts ("I'm calling about my mother's card"), callers who don't know card details, multiple cards on account, joint account cards, international callers, callers who changed address recently, noisy audio during card number verification |
| Regulatory Considerations | Card blocking is consumer-protective (preventing fraud losses), so urgency justifies faster authentication. However, the replacement workflow must verify identity more rigorously because it involves address disclosure and new card issuance. PCI DSS applies to any card data handled. Replacement card fees must be disclosed before processing. |
| Priority | P0 - Recommended wedge use case (highest customer urgency, clearest deterministic process) |

**UC-009: Card Activation**

| Field | Value |
|-------|-------|
| Autonomy Level | A4 |
| Risk | Medium |
| Authentication | AUTH_3 (step-up required - OTP or app push) |
| Description | Caller received a new or replacement card and wants to activate it. AI verifies identity with step-up authentication, activates the card, and confirms. |
| Permitted Actions | Authenticate with step-up, activate card, confirm activation, set temporary spending limits if applicable |
| Prohibited Actions | Change PIN (separate channel), disclose full card number, modify account settings |
| Required Components | Fraud-Aware Identity, Tool Gateway (card processor activation API), Policy Engine (step-up enforcement), Conversation Runtime, Audit Ledger |
| Integration Points | Card processor (activation API), authentication service (OTP/push), CRM |
| Human Handoff Triggers | Authentication failure, card not found in system, card already activated, suspicious activity |
| Evaluation Scenarios | Caller doesn't have phone for OTP (alternative authentication), caller activating card they didn't request (potential fraud), activation of replacement card while old is still active |
| Regulatory Considerations | Card activation requires strong authentication per PCI DSS and card scheme rules. |
| Priority | P1 |

**UC-010: Statement Request**

| Field | Value |
|-------|-------|
| Autonomy Level | A4 |
| Risk | Low-Medium |
| Authentication | AUTH_2 minimum, AUTH_3 for delivery to non-default address |
| Description | Caller requests a copy of a recent statement. AI authenticates, confirms which statement period, verifies delivery preference (email, post, app), and submits request. |
| Permitted Actions | Authenticate, confirm statement period, verify delivery address/email, submit statement request, provide expected delivery timeline |
| Prohibited Actions | Read out full statement contents over phone (PCI risk for card statements), change delivery address (separate workflow), access statements older than retention period |
| Required Components | Fraud-Aware Identity, Tool Gateway (statement fulfillment API), Policy Engine (delivery controls), Conversation Runtime, Audit Ledger |
| Integration Points | Statement generation system, fulfillment/delivery service, CRM |
| Human Handoff Triggers | Statement period not available, caller wants statement for closed account, caller disputes statement contents |
| Evaluation Scenarios | Multiple account types (which statement?), historical statements beyond standard range, delivery to shared email address (privacy concern), callers who want statements read out loud |
| Regulatory Considerations | Statement delivery to non-registered addresses requires additional verification. Postal delivery must comply with data protection (statement should not disclose account details on envelope). |
| Priority | P2 |

### 2.6 A4/A5: Higher-Risk First-Wave Workflows

**UC-011: Fraud Alert Confirmation**

| Field | Value |
|-------|-------|
| Autonomy Level | A4 (confirm legitimate) / A5 (confirm fraud - human review for investigation) |
| Risk | High |
| Authentication | AUTH_3 minimum, AUTH_4 recommended |
| Description | Bank's fraud system flagged a transaction. Caller contacts bank (or is called back via safe callback protocol) to confirm or deny the transaction. If caller confirms as legitimate, AI clears the alert. If caller reports fraud, AI escalates to fraud investigation. |
| Permitted Actions | Authenticate with step-up, present flagged transaction for confirmation (without disclosing full card number), clear alert if confirmed legitimate, escalate to fraud if denied, block card if fraud confirmed and customer requests |
| Prohibited Actions | Disclose full transaction details before authentication, clear fraud alerts without proper authentication, process refunds, conclude fraud investigation |
| Required Components | All components including Fraud-Aware Identity (critical - must detect if the call itself is fraudulent), Tool Gateway (fraud system APIs), Policy Engine (fraud-specific rules), Human Control Center (fraud team escalation), Audit Ledger |
| Integration Points | Fraud detection system, card processor, case management, fraud investigation queue |
| Human Handoff Triggers | Caller denies transaction (fraud confirmed), multiple flagged transactions, high-value transaction, caller distress, authentication failure, suspected social engineering |
| Evaluation Scenarios | Authorized push payment scams (caller says "yes" under duress), synthetic voice attacks, callers confused about which transaction is flagged, callers who don't remember making the transaction, simultaneous fraud on multiple cards |
| Regulatory Considerations | Fraud handling is heavily regulated. MAS, FCA, and CFPB all have specific requirements for fraud dispute handling. Unauthorized transaction liability rules vary by jurisdiction. The AI must not make liability determinations. Safe callback protocol (bank initiates call to registered number) is required for outbound fraud alerts per handoff guidance. |
| Priority | P1 (high value but requires robust fraud controls before deployment) |

---

## 3. Later-Wave Workflows

These workflows require additional controls, integrations, or regulatory analysis before deployment. They are targeted for Phase 2 or later.

### 3.1 Medium-Risk Deferred Workflows

**UC-012: Transaction Dispute Intake**

| Field | Value |
|-------|-------|
| Autonomy Level | A3 |
| Risk | Medium-High |
| Authentication | AUTH_3 |
| Description | Caller disputes a specific transaction. AI captures dispute details, classifies dispute type (unauthorized, goods not received, service not as described), captures evidence, creates dispute case. Resolution is human-handled. |
| Required Controls | Evidence capture, dispute classification against scheme rules (Visa/Mastercard), provisional credit policy decision by human, regulatory timeline tracking |
| Integration Points | Card processor dispute API, case management, scheme portal |
| Deferred Reason | Dispute classification is complex (multiple scheme rules); provisional credit decisions have financial impact; regulatory timelines are strict (Regulation E in US, PSR in UK) |

**UC-013: Fee Waiver Request**

| Field | Value |
|-------|-------|
| Autonomy Level | A4 (below threshold) / A5 (above threshold) |
| Risk | Medium |
| Authentication | AUTH_2 |
| Description | Caller requests waiver of a fee (late payment, overdraft, annual fee). AI checks fee waiver policy, auto-approves below threshold, escalates above threshold to supervisor. |
| Required Controls | Deterministic policy thresholds (amount, customer tenure, recent waiver history), explainability (why approved or denied), human approval above limit, audit of all waivers |
| Integration Points | Fee management system, CRM (customer value/tenure), approval workflow |
| Deferred Reason | Fee waiver policies vary significantly by bank; threshold logic requires bank-specific configuration; fairness monitoring needed to prevent discriminatory waiver patterns |

**UC-014: Contact Detail Update (Address, Email, Phone)**

| Field | Value |
|-------|-------|
| Autonomy Level | A4 |
| Risk | High |
| Authentication | AUTH_4 (strong step-up required - this is a common account takeover vector) |
| Description | Caller wants to update their contact details. AI authenticates with strong step-up, confirms changes, applies with risk hold if applicable. |
| Required Controls | Step-up authentication (AUTH_4), fraud risk scoring (address change is high-risk), notification to old contact method, cooling-off period for high-risk changes, human review for flagged accounts |
| Integration Points | CRM (contact update API), authentication service, fraud risk engine, notification service |
| Deferred Reason | Contact detail changes are the #1 account takeover vector. Requires robust fraud controls and step-up authentication. Risk of social engineering is very high. |

**UC-015: Collections Reminder (Inbound)**

| Field | Value |
|-------|-------|
| Autonomy Level | A2 (information) / A4 (payment arrangement) |
| Risk | High |
| Authentication | AUTH_2 |
| Description | Customer in arrears calls about their account. AI provides current balance, arrears amount, and payment options. Can set up payment arrangements within pre-approved templates. |
| Required Controls | Jurisdictional script controls (collections regulations vary significantly), vulnerability detection (mandatory - financial difficulty is a vulnerability indicator), calling-window rules, hardship assessment triggers, recorded consent for arrangements |
| Integration Points | Collections system, payment arrangement system, hardship referral, vulnerability flagging |
| Deferred Reason | Collections is heavily regulated with jurisdiction-specific requirements. Vulnerability detection is critical (callers in financial difficulty are by definition vulnerable). FCA, CFPB, MAS, and ASIC all have specific collections conduct requirements. |

**UC-016: Travel Notification**

| Field | Value |
|-------|-------|
| Autonomy Level | A4 |
| Risk | Low-Medium |
| Authentication | AUTH_2 |
| Description | Caller notifies bank of upcoming travel to prevent card blocks in foreign countries. |
| Required Controls | Authentication, destination and date capture, fraud policy integration (travel notes must update fraud rules) |
| Integration Points | Card processor (travel notification API), fraud rules engine |
| Deferred Reason | Lower priority; many banks now handle this via mobile app. Simple workflow but requires card processor integration. |

**UC-017: Card Replacement (Non-Lost)**

| Field | Value |
|-------|-------|
| Autonomy Level | A4 |
| Risk | Low-Medium |
| Authentication | AUTH_3 |
| Description | Caller requests replacement card (damaged, expired, name change). Not an emergency (unlike UC-008). |
| Required Controls | Authentication with step-up, address verification, fee disclosure and confirmation, delivery preference |
| Integration Points | Card processor (replacement API), CRM, fee management |
| Deferred Reason | Overlaps with UC-008 (lost card) but with different urgency model. Implement after UC-008 proves stable. |

---

## 4. Decision Framework: Allow, Defer, Prohibit

Each workflow falls into one of three implementation decisions:

### ALLOW (First Wave)

Workflows approved for first release. Must meet all of the following criteria:

- Autonomy level A0 through A4
- Well-defined procedural script with deterministic decision points
- High call volume (measurable containment impact)
- Clear success metrics (containment rate, AHT, error rate)
- Integration requirements limited to 1-2 bank systems
- Regulatory requirements well-understood and implementable
- Evaluation scenarios can be automated (golden calls, adversarial tests)

**Allowed workflows:** UC-001 through UC-011

### DEFER (Later Waves)

Workflows deferred to Phase 2+ due to additional complexity. Must meet at least one of the following:

- Requires bank-specific policy configuration not yet available
- Regulatory requirements are jurisdiction-specific and complex
- Integration requirements span 3+ bank systems
- Fraud risk requires additional controls not yet built
- Evaluation scenarios require banking domain expertise to design

**Deferred workflows:** UC-012 through UC-017

### PROHIBIT (A6 - Never Autonomous)

Workflows the AI must never execute autonomously. See prohibited_use_cases.md for the complete list with regulatory justification.

---

## 5. Workflow-to-Component Mapping

This matrix shows which VocalIQ architecture components are exercised by each workflow category. Components marked as required for a workflow category must be built and tested before that category can be deployed.

| Component | A0 | A1 | A2 | A3 | A4 | A5 |
|-----------|----|----|----|----|----|----|
| Media Gateway | Required | Required | Required | Required | Required | Required |
| Real-Time Speech Layer | Required | Required | Required | Required | Required | Required |
| Conversation Runtime | Required | Required | Required | Required | Required | Required |
| Risk-Aware Graph Compiler | Required | Required | Required | Required | Required | Required |
| Policy Engine | Basic | Routing rules | Disclosure rules | Case creation rules | Action permission rules | Full + human approval rules |
| Model Gateway | Required | Required | Required | Required | Required | Required |
| RAG Service | Required | Optional | Optional | Optional | Optional | Optional |
| Tool Gateway | Not needed | Not needed | Read-only | Write (draft) | Write (execute) | Write (stage for approval) |
| Fraud-Aware Identity | Not needed | Not needed | Required | Required | Required | Required |
| Human Control Center | Monitoring | Queue management | Monitoring + fallback | Case review | Supervisor override | Approval workflow |
| Audit Ledger | Basic | Basic | Full | Full | Full + action audit | Full + approval audit |
| Evaluation Lab | Basic tests | Routing accuracy tests | Disclosure tests | Case quality tests | Action safety tests | Approval flow tests |

This mapping confirms that A0-A1 workflows (UC-001 through UC-004) can be deployed with a subset of the full architecture, making them suitable for early pilots. A2+ workflows require the full component set.

---

## 6. Cross-Cutting Controls

Several controls apply across all workflows regardless of autonomy level:

**Vulnerability Detection:** Every call must include passive vulnerability detection. Indicators include caller distress, confusion, mention of financial difficulty, mention of pressure from third parties, mention of bereavement, age-related communication difficulties. Detection triggers human handoff or enhanced care protocol. Required by FCA Consumer Duty, MAS fair dealing principles, and generally expected by all regulators.

**Call Recording Consent:** Recording notice must be provided at the start of every call per jurisdiction-specific requirements. Some jurisdictions require explicit consent, others allow notice-only. The Media Gateway must handle consent variations per inbound number or jurisdiction routing.

**PCI Redaction:** Any workflow that touches card data (card numbers, CVVs, expiry dates) must run PCI redaction before any data reaches the Model Gateway or is stored in logs. The redaction service must operate in the speech layer, not post-call.

**Fraud Signal Integration:** Every authenticated call should include a fraud risk score from the Fraud-Aware Identity Layer. High-risk scores should trigger step-up authentication or human transfer even if the workflow doesn't normally require it.

**Audit Completeness:** Every call must produce a complete audit record including: call metadata, authentication events, policy decisions, tool calls and responses, data disclosed, actions taken, human interventions, and call outcome. The Audit Ledger must be tamper-evident.
