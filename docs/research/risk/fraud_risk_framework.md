# Fraud Risk Framework: Voice AI in Banking

**Document ID:** DOC_FRAUD_RISK_001  
**Last Updated:** 2026-05-03  
**Owner:** Fraud Operations Lead

**Version History:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-03 | Initial framework covering voice AI fraud vectors, detection, and controls |

**Purpose:** Define the fraud risk landscape specific to AI voice agents in banking contact centers, identify attack vectors unique to the voice AI channel, specify detection and prevention controls, and establish the fraud risk management framework that governs how VocalIQ's Fraud-Aware Identity Layer, Policy Engine, and Human Control Center work together to prevent, detect, and respond to fraud.

**Scope:** Covers fraud risks created or amplified by deploying AI voice agents: synthetic voice attacks, social engineering against AI, authorized push payment scams through AI channels, identity fraud, and internal fraud risks. Does not cover general banking fraud risks unrelated to the voice AI channel.

**Assumptions:** Fraud attacks against AI voice agents will be more systematic and scalable than attacks against human agents. Attackers will reverse-engineer AI behavior through repeated interactions. Voice synthesis technology will continue improving and becoming more accessible. The Fraud-Aware Identity Layer operates in real-time during every call.

**Decisions Made:** Framework organized by attack vector rather than by regulatory requirement, because fraud prevention must be designed around how attackers actually behave, not just what regulations require. Controls are mapped to VocalIQ architecture components to ensure every control has a clear implementation path.

**Alternatives Considered:** Regulation-first organization (one section per fraud regulation) was rejected because it would fragment the response to a single attack vector across multiple sections. Product-line organization (card fraud, account fraud, payment fraud) was rejected because the same attack vector (e.g., synthetic voice) spans all product lines.

**Risks:** Fraud techniques evolve faster than defense frameworks. This document captures the known threat landscape as of 2026. New attack vectors will emerge. The framework must be treated as a living document with regular updates.

**Open Questions:** Should VocalIQ offer fraud detection as a service (voice biometric analysis, deepfake detection) independent of the contact center workflow? How should VocalIQ handle regulatory divergence on fraud liability (e.g., UK mandatory reimbursement vs. US comparative negligence)?

**Source Links:** FinCEN Deepfake Alert (REG-008), PSR APP Scam Reimbursement, OWASP LLM Top 10, Pindrop 2025 Voice Intelligence Report, handoff Section 8 (banking-specific issues), ai_risk_register.md (RISK-006, RISK-007).

---

## 1. Voice AI Fraud Attack Taxonomy

### 1.1 Synthetic Voice and Deepfake Attacks

**Threat:** Attackers use voice synthesis technology to impersonate legitimate customers, bypassing voice biometric verification or knowledge-based authentication where the caller sounds convincingly like the genuine customer.

**Current landscape:** FinCEN issued a formal alert in 2024 documenting increasing deepfake fraud against financial institutions. Pindrop's 2025 Voice Intelligence Report documented a 1,300% surge in deepfake fraud attempts against contact centers. Voice cloning technology now requires as little as 3 seconds of reference audio to produce a convincing clone.

**Attack progression:**
1. Attacker obtains reference voice audio (social media, recorded calls, voicemail)
2. Attacker generates synthetic voice matching the target customer
3. Attacker calls the contact center using synthetic voice
4. If voice biometrics are used, the synthetic voice may pass verification
5. Attacker passes knowledge-based questions (data obtained through social engineering or data breaches)
6. Attacker executes account takeover actions

**Detection controls:**
- Voice liveness detection (detecting artifacts of voice synthesis: unnatural spectral patterns, missing micro-pauses, inconsistent breathing patterns, latency in real-time synthesis)
- Behavioral biometrics (speaking cadence, hesitation patterns, response timing that differs from genuine customer profile)
- Device and network analysis (call origin metadata, SIP header analysis, carrier pattern)
- Challenge-response that exploits synthetic voice limitations (unexpected questions that require natural improvisation)
- Multi-factor authentication (OTP/app push) that doesn't rely on voice characteristics

**VocalIQ components involved:** Fraud-Aware Identity Layer (primary), Media Gateway (call metadata), Policy Engine (risk threshold enforcement), Human Control Center (escalation for high-risk scores)

### 1.2 Social Engineering Against AI Agents

**Threat:** Callers manipulate the AI agent through conversational techniques that exploit the AI's instruction-following nature, lack of intuition, or inability to detect subtle manipulation.

**AI-specific vulnerabilities:**
- AI agents are more predictable than human agents (attackers can map behavior through repeated calls)
- AI agents may be more susceptible to authority claims ("I'm calling from the fraud department")
- AI agents lack the gut feeling that experienced human agents use to detect social engineering
- AI agents may be vulnerable to gradual escalation across multiple calls (each call pushes boundaries slightly further)
- AI agents process instructions literally, which sophisticated social engineers can exploit

**Attack patterns:**
- Authority impersonation: Caller claims to be a bank employee, regulator, or law enforcement
- Urgency creation: Caller creates artificial urgency to bypass normal verification procedures
- Information extraction: Caller uses indirect questions to extract account information piece by piece
- Emotional manipulation: Caller uses distress, anger, or sympathy to push the AI toward unauthorized actions
- Multi-call pattern: Attacker makes multiple calls, each extracting small pieces of information, combining them for account takeover

**Detection controls:**
- Social engineering pattern library in conversation runtime
- Multi-call correlation in Fraud-Aware Identity Layer (track caller across sessions)
- Authority claim detection (flag calls where caller claims to be bank staff or official)
- Urgency pattern detection (flag uncharacteristic urgency in caller requests)
- Information extraction monitoring (alert when caller's questions appear designed to probe system boundaries)
- Hard-coded action boundaries (prohibited actions cannot be unlocked through conversation)

**VocalIQ components involved:** Conversation Runtime (pattern detection), Fraud-Aware Identity Layer (multi-call correlation), Policy Engine (action boundary enforcement), Human Control Center (escalation)

### 1.3 Authorized Push Payment (APP) Scams

**Threat:** The genuine customer is manipulated by a third-party scammer into authorizing a payment to the scammer's account. The customer calls the bank (or is coached through the call by the scammer) to add a new beneficiary and transfer funds. The AI agent sees a properly authenticated customer making a voluntary request.

**Why AI increases APP risk:**
- AI agents may be less able to detect duress indicators (caller being coached, uncharacteristic behavior)
- AI agents process the request at face value if authentication passes
- AI agents may not ask the probing questions that experienced human agents use to detect APP scams
- The scammer may have coached the victim on how to interact with the AI specifically

**Detection controls:**
- Duress detection model (speech pattern analysis for coaching indicators, unusual pauses, whispered instruction, scripted responses)
- Beneficiary creation prohibited for AI (A6 classification in prohibited_use_cases.md)
- Wire transfer prohibited for AI (A6 classification)
- New payee addition prohibited for AI
- Proactive scam warning delivery if suspicious patterns detected
- Safe callback protocol (bank initiates call to registered number for high-value requests)

**VocalIQ components involved:** Conversation Runtime (duress detection), Policy Engine (prohibition enforcement), Graph Compiler (rejection of beneficiary/transfer nodes), Human Control Center (mandatory human handling)

### 1.4 Account Takeover via Contact Center

**Threat:** Attacker uses the contact center channel to take control of a customer's account. Common ATO progression: change contact details (address, phone, email) then request new card, reset password, or transfer funds.

**Contact detail change as the gateway:** The handoff correctly identifies contact detail changes as the number one account takeover vector. Changing the phone number allows the attacker to receive OTPs. Changing the address allows the attacker to receive replacement cards. Changing the email allows the attacker to reset online banking credentials.

**Detection controls:**
- Contact detail update requires AUTH_4 (strong multi-factor, not just knowledge-based)
- Cooling-off period after contact detail changes (no sensitive actions for configurable period)
- Notification to old contact method when changes are made
- Fraud risk scoring elevated for any session involving contact detail changes
- Human review required for flagged accounts (recent activity anomalies, high-risk indicators)
- Multi-session correlation (detect when the same caller identifier makes a series of escalating changes)

**VocalIQ components involved:** Fraud-Aware Identity Layer (risk scoring, multi-session tracking), Policy Engine (AUTH_4 enforcement, cooling-off rules), Human Control Center (review queue for flagged changes), Audit Ledger (change tracking)

### 1.5 Prompt Injection for Fraud

**Threat:** Attacker uses prompt injection techniques to manipulate the AI into performing unauthorized actions or disclosing information that facilitates fraud. This differs from general prompt injection (RISK-001) because the specific goal is financial fraud rather than general mischief.

**Banking-specific prompt injection scenarios:**
- Injecting instructions to skip authentication steps
- Injecting instructions to disclose account information before verification
- Injecting instructions to execute actions above the workflow's permitted scope
- Using adversarial speech patterns that cause STT to produce injection-like text

**Detection controls:**
- Authentication enforcement is architectural, not prompt-based (Graph Compiler ensures auth nodes precede data access nodes)
- Action execution requires Policy Engine validation independent of LLM reasoning
- Tool Gateway enforces scoped permissions regardless of what the LLM generates
- Output validation: any action or disclosure must pass Policy Engine checks after LLM generation but before execution
- Adversarial prompt injection test suite in evaluation lab

**VocalIQ components involved:** All components (defense-in-depth)

---

## 2. Fraud Risk Scoring Model

### 2.1 Scoring Architecture

The Fraud-Aware Identity Layer produces a composite fraud risk score for every call, updated in real-time as the call progresses. The score combines multiple signal categories:

**Caller identity signals (weight: 30%)**
- Authentication confidence (higher auth level = lower risk contribution)
- Voice biometric match score (if available)
- Voice liveness score (synthetic voice probability)
- Caller history (known customer vs. first-time caller)

**Behavioral signals (weight: 25%)**
- Speech pattern anomalies (unusual pauses, coached responses, scripted speech)
- Response timing (too fast or too slow for natural conversation)
- Information-seeking patterns (probing questions, unusual information requests)
- Emotional patterns (unusual distress, artificial urgency)

**Session signals (weight: 20%)**
- Call origin metadata (known vs. unknown carrier, VoIP indicators, geographic anomalies)
- Time of call (unusual hours for the customer's profile)
- Recent account activity (recent password resets, failed login attempts, recent changes)
- Multi-session patterns (frequency, escalation pattern, geographic shifts)

**Transaction signals (weight: 25%)**
- Action requested vs. customer profile (unusual request pattern)
- Transaction amount relative to customer's normal activity
- Beneficiary analysis (for payment-related workflows)
- Account risk flags (bank-side fraud alerts, watch list matches)

### 2.2 Risk Score Thresholds

| Score Range | Risk Level | System Response |
|-------------|-----------|-----------------|
| 0-30 | Low | Standard processing. No additional friction. |
| 31-50 | Elevated | Step-up authentication triggered. Additional verification questions. |
| 51-70 | High | Step-up to AUTH_3/AUTH_4 required. Supervisor monitoring activated. |
| 71-85 | Very High | Mandatory human transfer. AI continues only in read-only assist mode. |
| 86-100 | Critical | Immediate call termination and fraud alert. Account temporarily restricted. Fraud team notified. |

Thresholds are configurable per bank deployment. Banks with higher fraud tolerance may adjust upward; banks in high-fraud markets may adjust downward.

### 2.3 Score Evolution During Call

The risk score is not static. It updates as the call progresses:

- Initial score set from pre-call signals (caller ID, time, account flags)
- Score adjusts based on authentication outcome (successful auth reduces score; failed auth increases score)
- Behavioral signals continuously update the score throughout the call
- Specific events can cause score jumps (e.g., caller asks to change address right after activating a card = significant score increase)
- Score never decreases below a floor set by pre-call signals (prevents social engineering that aims to "earn trust" then exploit it)

---

## 3. Fraud Prevention Controls by Workflow

| Workflow | Primary Fraud Risk | Key Controls |
|----------|-------------------|--------------|
| UC-001-003 (A0) | Reconnaissance (information gathering for social engineering) | Content boundary, no account data |
| UC-004 (A1 Routing) | Routing manipulation, emergency false claims | Emergency validation, routing rule integrity |
| UC-005 (A2 Balance) | Identity fraud for information extraction | AUTH_2+, disclosure policy, session tracking |
| UC-006 (A2 Application) | Identity fraud, application fraud | AUTH_2+, decision rationale prohibition |
| UC-007 (A3 Complaint) | False complaints for compensation extraction | Authentication, complaint pattern analysis |
| UC-008 (A4 Card Block) | Social engineering (blocking legitimate card), ATO (blocking to get replacement) | AUTH_2 for block, AUTH_3 for replacement, social engineering detection |
| UC-009 (A4 Activation) | Intercepted card activation | AUTH_3 mandatory, activation of unrequested card detection |
| UC-010 (A4 Statement) | Address manipulation for statement redirect | AUTH_3 for non-default delivery, address verification |
| UC-011 (A4/A5 Fraud Alert) | Fraudster confirming "their" transaction, APP scams | AUTH_3+, duress detection, APP scam indicators |
| UC-014 (A4 Contact Update) | Account takeover gateway | AUTH_4 mandatory, cooling-off, old-method notification |

---

## 4. Fraud Response Procedures

### 4.1 Real-Time Response (During Call)

When fraud indicators are detected during a call:

1. Risk score updated in real-time
2. If score crosses threshold, Policy Engine triggers appropriate response (step-up, monitoring, transfer, or termination)
3. Human Control Center receives fraud alert with call context
4. If call is transferred, human agent receives risk score, triggering signals, and call transcript
5. If call is terminated, account is flagged for fraud team review
6. Audit Ledger records all fraud detection events with timestamps

### 4.2 Post-Call Response

After a call with elevated fraud indicators:

1. Fraud-Aware Identity Layer updates caller profile with session data
2. If actions were executed during the call, post-action verification runs (e.g., verify card block was on the correct card)
3. Fraud team reviews flagged calls within SLA
4. If fraud is confirmed, remediation procedures are triggered (reverse actions if possible, notify customer through verified channel, file SAR if required)

### 4.3 Pattern Analysis

The Fraud-Aware Identity Layer maintains a pattern database:

- Multi-call patterns from the same caller or caller profile
- Account-level patterns (multiple callers attempting the same account)
- Technique patterns (new social engineering approaches detected across calls)
- Geographic patterns (fraud clusters by region, carrier, or time zone)

Pattern analysis feeds back into risk scoring model calibration and generates fraud intelligence reports for bank fraud teams.

---

## 5. Fraud Control Testing

The Evaluation and Assurance Lab must include dedicated fraud testing:

**Adversarial test categories:**
- Synthetic voice attacks (deepfake samples at various quality levels)
- Social engineering scenarios (authority impersonation, urgency, emotional manipulation, gradual escalation)
- APP scam simulations (coached caller scenarios)
- Account takeover sequences (multi-step, multi-call ATO attempts)
- Prompt injection for fraud (attempts to bypass auth, extract data, execute unauthorized actions)
- Multi-caller attacks on single account (coordinated ATO attempts)

**Testing frequency:**
- Full adversarial suite: before every major release
- Synthetic voice samples: updated quarterly (as voice synthesis technology advances)
- Social engineering scenarios: updated monthly (as new techniques are observed)
- Regression testing: after every model update or policy change

**Success criteria:**
- Zero successful unauthorized actions in adversarial testing
- Synthetic voice detection rate above 95% against current-generation synthesis tools
- Social engineering detection rate above 85% for known patterns
- False positive rate below 5% (genuine callers incorrectly flagged)
