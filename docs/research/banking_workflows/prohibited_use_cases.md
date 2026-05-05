# Prohibited Use Cases (A6): Workflows That Must Never Be Autonomous

**Document ID:** DOC_PROHIBITED_UC_001  
**Last Updated:** 2026-05-03  
**Owner:** Chief Product Officer

**Version History:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-03 | Initial prohibited use case catalog with regulatory justification |

**Purpose:** Define the workflows that VocalIQ's AI agent must never execute autonomously. These are classified as A6 (Prohibited Autonomy) in the autonomy framework. This document provides the regulatory justification for each prohibition, the technical enforcement mechanisms, and the allowed AI role (if any) in supporting human agents who handle these workflows. The Graph Compiler and Policy Engine both use this document as a reference to enforce prohibitions at compilation time and runtime respectively.

**Scope:** Covers all A6-classified workflows identified in the handoff (Section 7.4) and additional workflows identified through regulatory analysis. Applies across all target jurisdictions (Singapore, EU, UK, US). Does not cover workflows that are merely deferred to later phases (UC-012 through UC-017); those are documented in use_case_taxonomy.md with their deferred reasons.

**Assumptions:** "Prohibited" means the AI may not make the decision or execute the action. The AI may still assist a human agent handling these workflows (e.g., by pulling up relevant data, summarizing policy, or drafting a recommendation that the human reviews). The prohibition is on autonomous decision-making and execution, not on information retrieval or draft preparation that a human will act on.

**Decisions Made:** Prohibition is based on a combination of regulatory requirements, operational risk, and reputational risk. Where a workflow is prohibited in some jurisdictions but potentially allowed in others, we apply the strictest standard across all target jurisdictions. This conservative approach simplifies the Graph Compiler's validation logic and avoids jurisdiction-detection errors creating regulatory exposure.

**Alternatives Considered:** Jurisdiction-specific prohibition (allow loan approval in jurisdictions where it might be legally permissible) was considered and rejected. The risk of a jurisdiction-detection error allowing a prohibited action is unacceptable. Per-bank opt-in for certain prohibited categories was considered but rejected for initial release; banks that want to allow autonomous action in these categories can request a classification review after deployment data demonstrates safety.

**Risks:** Overly broad prohibition may reduce VocalIQ's competitive positioning against vendors who allow more autonomous action. Prohibition list may need updating as regulations evolve. The distinction between "prohibited autonomous execution" and "permitted AI-assisted human execution" requires clear communication to deployment teams.

**Open Questions:** Should there be a formal review process for reclassifying A6 workflows to A5 (human-approved) after sufficient deployment data? How should VocalIQ handle banks that insist on autonomous execution of prohibited workflows (contractual limitation vs. technical enforcement)?

**Source Links:** Handoff Section 7.4 (Avoid in First Release), Section 7.1 (Autonomy Levels), Section 12 (Policy and Risk Engine), Section 14 (Graph Compiler validation rules), EU AI Act (Regulation 2024/1689), MAS Technology Risk Management Guidelines, FCA Consumer Duty, US ECOA/Regulation B, FINRA suitability rules.

---

## 1. Prohibited Workflow Catalog

### P-001: Loan Approval or Decline

**Prohibition:** The AI must not approve, decline, or make any creditworthiness determination for any lending product (personal loans, mortgages, business loans, credit cards, overdraft facilities, lines of credit).

**Regulatory Justification:**

Credit decisions in all target jurisdictions carry specific regulatory obligations that AI cannot currently satisfy:

In the US, the Equal Credit Opportunity Act (ECOA) and Regulation B require that adverse action notices explain the specific reasons for denial. These explanations must be factually accurate and specific to the applicant's circumstances. Current LLM architectures cannot provide the deterministic, auditable reasoning chain that regulators expect. The CFPB has issued guidance indicating that "the algorithm decided" is not an acceptable adverse action reason.

In the EU, the AI Act classifies AI systems used in creditworthiness assessment as high-risk (Annex III, 5(b)). High-risk AI systems must meet transparency, explainability, human oversight, and data quality requirements that are not achievable with general-purpose language models as the decision-maker.

In the UK, the FCA expects firms to be able to explain credit decisions to consumers and to the regulator. The Consumer Duty requires firms to act to deliver good outcomes for retail customers, which includes ensuring credit decisions are fair and explainable.

In Singapore, MAS Technology Risk Management Guidelines require that AI models used in credit decisions undergo independent model validation, ongoing monitoring, and have clear accountability chains.

Model risk is significant: a faulty credit decision can result in lending to customers who cannot repay (credit losses) or wrongly denying creditworthy customers (fair lending violations, reputational damage). Both outcomes have material financial and regulatory consequences.

**Fairness risk:** LLMs trained on internet data may encode historical lending biases. Even with careful prompting, the risk of disparate impact in credit decisions is not manageable with current explainability tools.

**Technical Enforcement:**
- Graph Compiler: Reject any graph containing a CreditDecisionNode or LoanApprovalNode for workflows tagged A6
- Policy Engine: Block any tool call to credit decision APIs where the request originates from the AI agent (not a human user)
- Tool Gateway: Credit decision APIs require human_operator_id in the request header; AI agent IDs are rejected

**Permitted AI Role:**
- Retrieve application data for human reviewer
- Summarize applicant financial profile from available data
- Draft a recommendation memo (clearly labeled as AI-generated, not a decision)
- Pre-populate decision forms with factual data
- Flag potential compliance issues in the application for human attention

---

### P-002: Credit Score or Affordability Determination

**Prohibition:** The AI must not compute, disclose, or interpret a customer's credit score, creditworthiness assessment, or affordability determination.

**Regulatory Justification:**

Credit score disclosure and interpretation are regulated activities. In the US, the Fair Credit Reporting Act (FCRA) governs who can access credit reports and for what purposes. Disclosing a credit score to a caller requires verification that the disclosure is to the correct consumer and that the score comes from an authorized source.

Affordability determinations (assessing whether a customer can afford a financial product) constitute a regulated activity under FCA rules in the UK, MAS guidelines in Singapore, and various consumer protection frameworks in the EU. These assessments require consideration of the customer's total financial situation, not just the data points available in a single call.

The AI cannot access the full picture of a customer's financial situation. It cannot verify external debts, employment stability, or other factors that a proper affordability assessment requires.

**Technical Enforcement:**
- Graph Compiler: Reject graphs that route to credit score retrieval APIs in A6-tagged workflows
- Policy Engine: Block disclosure of credit-score-related fields even if they appear in retrieved account data
- Content Boundary: Prevent AI from making statements about a customer's creditworthiness, even qualitatively ("you seem to have a good credit history")

**Permitted AI Role:**
- Transfer caller to credit specialist
- Provide factual information about how to obtain their own credit report (without accessing it)
- Explain in general terms what factors affect credit scores (from approved knowledge base, without personalization)

---

### P-003: Investment Advice

**Prohibition:** The AI must not provide personalized investment advice, recommend specific financial products based on a customer's circumstances, assess investment suitability, or make any statement that could reasonably be interpreted as investment guidance.

**Regulatory Justification:**

Investment advice is among the most heavily regulated financial activities across all target jurisdictions.

In the US, FINRA suitability rules and the SEC's Regulation Best Interest require that investment recommendations be suitable for the specific customer's investment profile, risk tolerance, financial situation, and investment objectives. The recommender must have a reasonable basis for the recommendation, know the customer, and ensure the recommendation is suitable. These requirements demand holistic customer understanding and professional judgment that an AI agent cannot provide.

In the EU, MiFID II imposes suitability and appropriateness requirements for investment advice. Investment firms must obtain information about the client's knowledge, experience, financial situation, and investment objectives. MiFID II also imposes specific disclosure requirements about costs, risks, and conflicts of interest.

In the UK, the FCA's Conduct of Business Sourcebook (COBS) requires suitability assessments for personal recommendations. The FCA has taken enforcement action against firms for providing unsuitable advice, and the penalties are severe.

In Singapore, the Financial Advisers Act and MAS Notice on Fair Dealing require that financial advisers have a reasonable basis for making recommendations and conduct needs analysis before advising.

Mis-selling risk is the primary concern: recommending an unsuitable investment product can cause significant financial harm to customers and result in regulatory fines, customer compensation, and reputational damage.

**Technical Enforcement:**
- Graph Compiler: Reject any graph containing investment product recommendation logic
- Policy Engine: Strict advice boundary detection; block any response that includes "I recommend," "you should invest," "this product suits your needs," or similar personalized guidance patterns
- Content Boundary: Allow factual product information from approved knowledge base but block any comparative, evaluative, or personalized framing

**Permitted AI Role:**
- Provide factual, non-personalized product information from approved knowledge base (UC-002 covers this at A0)
- Transfer caller to licensed investment adviser
- Provide general educational content about investment concepts (without personalization)

---

### P-004: Wire Transfer Initiation

**Prohibition:** The AI must not initiate, authorize, or process wire transfers, international payments, SWIFT transfers, or any high-value payment instruction.

**Regulatory Justification:**

Wire transfers are irrevocable once processed. Unlike card transactions, there is no chargeback mechanism for completed wire transfers. This makes wire transfers the highest-value target for social engineering, authorized push payment (APP) scams, and account takeover fraud.

In the UK, the Payment Systems Regulator (PSR) has introduced mandatory reimbursement for APP scam victims (effective October 2024), creating direct financial liability for payment service providers that fail to prevent APP fraud. An AI agent that processes a fraudulent wire transfer instruction creates direct reimbursement liability.

In Singapore, MAS has issued guidance on preventing scam-related fund transfers, including requiring additional verification steps for high-value or unusual transfers.

In the US, Regulation E and the UCC Article 4A govern electronic fund transfers and wire transfers respectively, with different liability frameworks depending on the type of transfer and the authentication used.

The risk profile is asymmetric: a single fraudulent wire transfer can result in losses far exceeding the cumulative value of all legitimate transactions the AI might process. No amount of authentication can fully mitigate the risk that the genuine account holder is being coerced or deceived.

**Technical Enforcement:**
- Graph Compiler: Reject any graph that routes to payment/transfer APIs for A6-tagged workflows
- Policy Engine: Block all tool calls to payment initiation endpoints from AI agent context
- Tool Gateway: Wire transfer APIs require human_operator_id with supervisor_approval flag
- Content Boundary: AI must not confirm wire transfer details or provide recipient account information

**Permitted AI Role:**
- Confirm that a wire transfer request has been received and will be processed by a specialist
- Transfer caller to payments team
- Provide factual information about wire transfer fees, processing times, and required documentation (from approved knowledge base)
- For human agents handling wire transfers, pull up customer verification data and flag risk indicators

---

### P-005: New Beneficiary or Payee Creation

**Prohibition:** The AI must not add new beneficiaries, payees, or payment recipients to a customer's account.

**Regulatory Justification:**

Beneficiary creation is the setup step for authorized push payment fraud. Scammers social-engineer victims into adding the scammer's account as a beneficiary, then instructing a transfer. Once the beneficiary is added, the victim (or the scammed AI) can transfer funds to the fraudster.

The UK's Contingent Reimbursement Model Code and the PSR's mandatory reimbursement rules specifically focus on the beneficiary-addition-then-transfer pattern. Banks are expected to implement friction and verification at the beneficiary creation step, not just at the transfer step.

MAS has similarly emphasized that banks should implement "cooling-off" periods and additional verification for new payee additions.

Even if the genuine account holder is requesting the addition, they may be doing so under duress or deception. The AI cannot reliably detect all duress indicators, making autonomous beneficiary creation an unacceptable risk.

**Technical Enforcement:**
- Graph Compiler: Reject graphs with beneficiary/payee creation nodes in A6 workflows
- Policy Engine: Block tool calls to beneficiary management APIs from AI agent context
- Tool Gateway: Beneficiary APIs require human_operator_id

**Permitted AI Role:**
- Inform caller that beneficiary changes require human assistance
- Transfer to appropriate team
- For human agents, pre-populate beneficiary forms with verified data from the caller

---

### P-006: Final Complaint Resolution

**Prohibition:** The AI must not resolve, adjudicate, or close a complaint. The AI may only perform complaint intake (UC-007, A3 - draft action).

**Regulatory Justification:**

Complaint resolution is a regulated activity with specific requirements in all target jurisdictions.

In the UK, the FCA requires that complaints be resolved fairly, considering all relevant circumstances. The Financial Ombudsman Service (FOS) reviews complaint handling decisions and can award compensation to consumers who were treated unfairly. A complaint resolved by AI without proper consideration of the specific circumstances risks unfair outcomes and FOS referrals.

In Singapore, MAS expects complaints to be handled by appropriately qualified staff who can exercise judgment about fair outcomes.

In the US, the CFPB tracks complaint patterns and investigates firms with high complaint volumes or poor resolution outcomes.

Complaint resolution often involves judgment calls about compensation, policy exceptions, and customer relationship considerations that require human discretion. An AI making these calls risks both unfair outcomes and inconsistent treatment across customers.

**Technical Enforcement:**
- Graph Compiler: Complaint workflows must terminate at case creation (A3), not at resolution
- Policy Engine: Block any tool calls that update complaint status to "resolved" or "closed" from AI context
- Content Boundary: AI must not offer compensation, promise specific resolution outcomes, or admit liability

**Permitted AI Role:**
- Complaint intake and classification (UC-007)
- Draft complaint response for human review
- Retrieve relevant policy documents and precedents for human reviewer
- Summarize complaint history for the reviewing officer

---

### P-007: Fraud Investigation Conclusion

**Prohibition:** The AI must not conclude a fraud investigation, determine liability, or make decisions about fraud claim outcomes (approved, denied, or partially approved).

**Regulatory Justification:**

Fraud investigation outcomes have direct financial impact on customers and involve complex judgment calls about evidence, liability, and customer culpability. Regulations require that these decisions be made by qualified fraud investigators with appropriate oversight.

In the UK, the PSR mandatory reimbursement framework requires that banks assess whether the customer met the standard of caution before denying reimbursement. This assessment requires human judgment about the specific circumstances.

In all jurisdictions, wrongly denying a genuine fraud claim causes direct customer harm and regulatory risk. Wrongly approving a fraudulent claim causes financial loss. Both error types require human accountability.

**Technical Enforcement:**
- Graph Compiler: Fraud workflows must terminate at case escalation, not at resolution
- Policy Engine: Block tool calls that update fraud case outcomes from AI context
- Tool Gateway: Fraud resolution APIs require fraud_investigator_id with case_review_complete flag

**Permitted AI Role:**
- Fraud alert confirmation and initial data gathering (UC-011, A4/A5)
- Compile transaction data, timeline, and risk indicators for fraud investigator
- Flag patterns or anomalies for investigator attention
- Draft investigation summary for human review

---

### P-008: Vulnerable Customer Management Without Human Fallback

**Prohibition:** The AI must not be the sole handler for calls where a customer is identified as vulnerable. A human must be available in the loop.

**Regulatory Justification:**

Vulnerable customers require enhanced care that current AI cannot reliably provide. The FCA's Consumer Duty (and its predecessor, Treating Customers Fairly) requires firms to take particular care with vulnerable customers, including adjusting communication styles, providing additional time, and ensuring the customer understands the information being provided.

Vulnerability takes many forms: financial difficulty, health conditions (including mental health), life events (bereavement, relationship breakdown), and low financial capability. The AI's ability to detect all forms of vulnerability and adapt its communication appropriately is not yet reliable enough for unsupervised handling.

The risk is that a vulnerable customer's needs are missed, leading to poor outcomes that the regulator will scrutinize. Banks have been fined for failures in vulnerable customer handling.

**Technical Enforcement:**
- Policy Engine: When vulnerability detection triggers fire, conversation must route to human or human-supervised mode
- Human Control Center: Vulnerability flag on a call requires supervisor monitoring at minimum
- Graph Compiler: Vulnerability-detected branches must include human escalation or supervision nodes

**Permitted AI Role:**
- Passive vulnerability detection (flagging indicators for human awareness)
- Continuing the conversation under human supervision (human monitoring the call and able to intervene)
- Providing information and capturing details while human supervisor is en route
- Adapting communication style (slower pace, simpler language, confirmation checks) while human backup is in place

---

## 2. Technical Enforcement Architecture

Prohibitions are enforced at three layers, providing defense-in-depth:

### Layer 1: Graph Compiler (Compile Time)

The Risk-Aware Graph Compiler validates every conversation graph before deployment. For A6 workflows:

- The compiler maintains a prohibited_actions registry derived from this document
- Any graph node that references a prohibited action (credit decision, wire transfer, beneficiary creation, complaint resolution, fraud conclusion) is rejected at compilation
- Any graph path that reaches an execution node for a prohibited workflow is rejected
- The compiler produces an explicit error message identifying which prohibition was violated
- No override mechanism exists at compile time; prohibitions cannot be bypassed through graph design

### Layer 2: Policy Engine (Runtime)

The Policy Engine evaluates rules at runtime checkpoints:

- Before every Tool Gateway call, the Policy Engine checks the action against the prohibition list
- If a prohibited action is detected at runtime (defense against any graph that somehow bypassed compilation), the Policy Engine blocks the call and triggers human transfer
- The Policy Engine logs the blocked action as a security event
- Prohibited action detection at runtime is a critical alert that triggers investigation (it means the Graph Compiler failed to catch something)

### Layer 3: Tool Gateway (API Level)

The Tool Gateway enforces API-level access controls:

- Prohibited APIs require human_operator_id in the request header
- The AI agent's identity token is rejected by these APIs
- This provides a final backstop even if both the Graph Compiler and Policy Engine fail
- API-level blocking is logged and triggers critical security alerts

### Defense-in-Depth Verification

The Evaluation and Assurance Lab must periodically test all three layers:

- Attempt to create graphs that execute prohibited actions (should fail at compilation)
- Attempt to bypass the Policy Engine through prompt injection (should be blocked at runtime)
- Attempt to call prohibited APIs with AI agent credentials (should be rejected at API level)
- All three layers must block independently; no layer should depend on another for enforcement

---

## 3. Reclassification Process

A6 classifications are not permanent in principle, but reclassification requires a formal process:

1. **Data requirement:** A minimum of 6 months of deployment data from lower-risk workflows demonstrating that the technical controls (Graph Compiler, Policy Engine, Tool Gateway) work reliably under production conditions.

2. **Regulatory review:** Legal and compliance review confirming that the target jurisdiction's regulatory framework permits AI involvement in the specific workflow category, with documented regulatory citations.

3. **Risk assessment:** Independent risk assessment evaluating the specific failure modes, potential harm, and mitigation effectiveness.

4. **Pilot design:** Controlled pilot plan with human-in-the-loop (A5 classification as an intermediate step), defined success metrics, and kill switch.

5. **Board approval:** Risk committee or equivalent governance body must approve the reclassification.

6. **Reversibility:** Any reclassified workflow must be immediately reversible to A6 if issues emerge during pilot.

No workflow should move directly from A6 to A4 or lower. The intermediate step through A5 (human-approved) allows the system to build a track record under human supervision before full autonomy is considered.
