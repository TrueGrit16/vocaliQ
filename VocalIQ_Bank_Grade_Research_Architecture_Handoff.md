# VocalIQ Bank-Grade Voice AI: Research Corpus, Architecture, and Pre-Build Specification Handoff

**Date:** 2026-05-03  
**Audience:** CoWork, product strategy, architecture, engineering, security, compliance, and bank pilot teams  
**Status:** Pre-build research and specification brief  
**Primary instruction:** Do not start implementation work until the research corpus, architecture specification, control model, and build-readiness gates in this document are completed and reviewed.

---

## 0. How to use this file

This Markdown file is designed to be dropped into the project workspace as the master handoff brief for a bank-grade voice AI product. It expands the existing VocalIQ/GetVocal-style research into a banking-specific product strategy and architecture plan.

Use it to drive the next phase of work:

1. Build a research corpus.
2. Produce a detailed competitor and market map.
3. Produce a banking regulatory and operational-risk matrix.
4. Produce architecture specifications and technical design documents.
5. Produce threat models, evaluation plans, and pilot-readiness gates.
6. Only then begin implementation.

This is not a prompt to build a demo. This is a prompt to turn the idea into a credible product that a bank can evaluate, risk-assess, approve, and deploy.

---

## 1. Context from the existing research

The existing research positions VocalIQ as a voice AI platform inspired by products such as GetVocal, ElevenLabs, Retell, Vapi, Bland, Synthflow, Voiceflow, Cognigy, PolyAI, Cresta, and Replicant. It identifies these core components:

- Conversation graph engine.
- Voice agent runtime using VAD, STT, LLM, and TTS.
- Telephony integration.
- Human-AI control center.
- Agent management.
- Knowledge base and RAG.
- CRM and contact-center integrations.
- Analytics and compliance.
- AI-to-AI testing.
- On-premise deployment.
- Multilingual support.

The existing research correctly identifies that a deterministic conversation graph plus controlled generative AI is the right direction for compliance-heavy environments. It also recognizes GetVocal's emphasis on human supervision, real-time intervention, and hybrid human-AI operations.

However, the current research is still too generic for banks. It would support a strong voice-agent prototype, but not yet a bank-grade marketable product. For banks, the hard problem is not realistic TTS or basic call automation. The hard problem is safe, auditable, policy-governed, fraud-aware, compliant execution of regulated customer-service workflows.

This document reframes the product around that reality.

---

## 2. Core product thesis

VocalIQ should not be positioned as an ElevenLabs clone, a generic AI voice-agent builder, or a self-service voice automation toy.

The stronger product thesis is:

> VocalIQ is a governed voice automation layer for regulated banking contact centers, combining deterministic workflow control, real-time human oversight, fraud-aware identity, bank-system-safe action execution, and evidence-grade auditability.

The bank buyer does not primarily buy "human-like voice." The bank buyer buys:

- Lower live-agent cost without higher operational risk.
- Better call containment without trapping customers in a bad bot.
- Safer customer authentication and disclosure control.
- Full auditability of every answer and action.
- Compliance, model-risk, fraud, cyber, and operational-resilience evidence.
- Integration into existing contact-center and bank-system architecture.
- Human control over edge cases.
- The ability to stop, replay, explain, and remediate AI behavior.

The winning product will be the one that a Head of Contact Center, Chief Risk Officer, CISO, Compliance Head, Fraud Operations Lead, Enterprise Architect, and Procurement team can all approve without feeling reckless.

---

## 3. The main gap in the current research

The current research mostly answers:

- How do we build a voice AI platform similar to GetVocal?
- Which STT, TTS, LLM, telephony, and orchestration components should we use?
- How do we build a graph designer and control center?

For banks, the missing questions are:

- What actions should the AI be allowed to perform, under which authentication and risk conditions?
- How do we prove the AI did not disclose sensitive information before authentication?
- How do we handle fraud, deepfakes, social engineering, scams, and caller-ID spoofing?
- How do we support bank regulatory requirements across markets?
- How do we avoid turning generative AI into an uncontrolled core-banking API caller?
- How do we integrate with existing CCaaS, CRM, fraud, identity, card processor, and core-banking systems?
- How do we make every answer, policy decision, model output, tool call, and human intervention replayable?
- How do we evaluate the system before every release?
- How do we package evidence for model risk, vendor risk, cyber risk, compliance, and operational-risk approvals?

This document instructs CoWork to fill those gaps before build.

---

## 4. Product definition

### 4.1 Product name placeholder

Use **VocalIQ** as the working product name until naming is finalized.

### 4.2 Product category

Bank-grade voice AI orchestration and governance platform for contact centers.

### 4.3 Product description

VocalIQ enables banks to deploy AI voice agents into inbound and outbound contact-center workflows while retaining deterministic process control, policy enforcement, fraud-aware customer authentication, secure bank-system integrations, human oversight, and complete auditability.

### 4.4 Primary users

- Contact-center executives.
- Contact-center operations managers.
- Supervisors and team leads.
- Customer-service agents.
- Fraud operations teams.
- Compliance teams.
- Model-risk management teams.
- Cybersecurity teams.
- Enterprise architects.
- Bank product owners.
- Vendor-risk and procurement teams.

### 4.5 Primary buyers

- Head of Contact Center.
- Chief Operating Officer or Head of Operations.
- Chief Digital Officer.
- Chief Information Officer.
- Chief Risk Officer or delegated operational-risk owner.
- Fraud and financial-crime leadership for fraud-sensitive workflows.

### 4.6 Bank-grade positioning

VocalIQ is not a pure automation tool. It is a controlled automation platform. The message should be:

> Automate only what is safe to automate. Escalate what is risky. Prove everything.

---

## 5. Non-goals and early constraints

The product should deliberately avoid several tempting but dangerous directions during the first product phase.

### 5.1 Do not build these first

- Autonomous loan approval or rejection.
- Autonomous credit-limit decisions.
- Autonomous investment or wealth advice.
- Autonomous wire transfers.
- Autonomous new beneficiary setup.
- Autonomous final complaint resolution.
- Autonomous suspicious-activity determinations.
- Open-ended financial advice.
- Bank executive voice cloning.
- Generic outbound sales campaigns without consent and jurisdictional controls.
- A consumer-facing gimmick voice assistant.

### 5.2 Do not optimize for these as primary differentiators

- Voice realism alone.
- Lowest price per minute alone.
- Prompt cleverness.
- Free-form agentic behavior.
- Full autonomy.
- Fastest possible demo.

### 5.3 Optimize for these instead

- Policy-governed autonomy.
- Auditable execution.
- Risk-based escalation.
- Safe bank-system integration.
- Repeatable evaluation.
- Operational resilience.
- Compliance evidence.
- Clear ROI per safely resolved call.

---

## 6. Market research workstream

CoWork must produce a deeper market map before architecture finalization.

### 6.1 Market categories to analyze

Create a structured market map with at least these categories:

1. CCaaS/contact-center incumbents.
2. Conversational AI and virtual-agent platforms.
3. Developer-first voice AI platforms.
4. Voice infrastructure providers.
5. STT providers.
6. TTS providers.
7. Speech-to-speech/realtime model providers.
8. Agent-assist platforms.
9. Fraud, identity, and voice-biometrics providers.
10. BPO/contact-center outsourcing firms.
11. Core-banking and CRM ecosystem vendors.
12. Open-source frameworks.

### 6.2 Competitor categories

#### Category A: CCaaS and contact-center incumbents

Examples to research:

- NICE CXone.
- Genesys Cloud CX.
- Amazon Connect.
- Five9.
- Cisco Webex Contact Center.
- Avaya.
- Talkdesk.
- Twilio Flex.

Why they matter:

- They already own bank contact-center routing, recording, workforce management, QA, agent desktops, supervisor dashboards, analytics, and procurement relationships.
- They can add AI features into existing deployments.
- Banks may prefer extending current contact-center platforms rather than buying a standalone system.

Research tasks:

- Identify AI voice, virtual-agent, agent-assist, and generative-AI features.
- Identify financial-services-specific messaging.
- Identify integration models.
- Identify whether they support BYO LLM, data residency, private cloud, or on-premise.
- Identify pricing and packaging where public.
- Identify their weaknesses for highly regulated workflows.

#### Category B: Conversational AI platforms

Examples:

- Cognigy.
- Kore.ai.
- PolyAI.
- Rasa.
- Amelia.
- Microsoft/Nuance.
- Omilia.
- Boost.ai.
- Avaamo.
- Kasisto.

Why they matter:

- Many already sell into banks.
- They may have banking-trained workflows.
- They may already handle enterprise integration and compliance buying processes.

Research tasks:

- Compare deterministic workflow design versus generative/agentic design.
- Compare governance, audit, human takeover, testing, and deployment options.
- Compare support for banking workflows.
- Identify where VocalIQ can differentiate: risk-aware graph compiler, fraud-aware identity, bank tool gateway, assurance lab, audit ledger.

#### Category C: Developer-first voice AI platforms

Examples:

- Retell.
- Vapi.
- Bland AI.
- Synthflow.
- Voiceflow.
- LiveKit Agents.
- Pipecat.
- Dograh.
- TEN Framework.

Why they matter:

- They move fast and shape developer expectations.
- They demonstrate what can be built quickly.
- They may lack bank-grade governance, but can still compete in pilots.

Research tasks:

- Compare latency claims.
- Compare telephony features.
- Compare human takeover.
- Compare observability.
- Compare tool-calling controls.
- Compare compliance claims.
- Compare self-hosting and on-prem support.
- Compare support for testing and simulation.

#### Category D: Voice and AI infrastructure

Examples:

- ElevenLabs.
- Cartesia.
- Deepgram.
- AssemblyAI.
- Speechmatics.
- OpenAI realtime APIs.
- Google Cloud Speech.
- Azure Speech.
- Amazon Transcribe/Polly.
- Twilio.
- Telnyx.
- Vonage.
- LiveKit.

Why they matter:

- VocalIQ should avoid becoming locked into one STT/TTS/LLM provider.
- Banks may require approved providers or self-hosted options.
- Provider choice affects data residency, latency, cost, accuracy, and compliance.

Research tasks:

- Create provider capability matrix.
- Capture supported languages, regions, data-retention terms, streaming support, telephony support, model versioning, private deployment, and pricing.
- Identify vendor lock-in risks.

#### Category E: Fraud, identity, and voice security

Examples:

- Pindrop.
- Nuance Gatekeeper.
- BioCatch.
- Callsign-like identity vendors.
- NICE Actimize.
- Feedzai.
- Featurespace.
- ThreatMetrix/LexisNexis Risk Solutions.
- Socure-like identity verification.

Why they matter:

- Banking voice AI cannot be separated from fraud and identity.
- Caller ID can be spoofed.
- Synthetic voice, deepfake media, and social engineering attacks are increasing.
- Banks will not allow high-risk actions based only on conversational confidence.

Research tasks:

- Identify fraud signals available during calls.
- Identify voice biometric and liveness capabilities.
- Identify account-takeover and scam-detection approaches.
- Identify integration patterns for real-time risk scoring.
- Identify how to include fraud signals in VocalIQ's policy engine.

### 6.3 Competitor database schema

Create a spreadsheet or structured repository table with these fields:

```text
company_name
category
website
headquarters
founded_year
funding_or_public_status
target_segments
banking_or_financial_services_focus
core_product
voice_agent_capability
human_takeover_capability
conversation_graph_capability
agentic_ai_capability
rag_capability
stt_provider_or_capability
tts_provider_or_capability
telephony_capability
ccaas_integrations
deployment_options
on_prem_or_private_cloud_support
data_residency_support
compliance_claims
security_certifications
model_governance_features
audit_features
evaluation_testing_features
fraud_identity_features
pricing_model
public_reference_customers
strengths
weaknesses
threat_to_vocaliq
partnership_opportunity
source_urls
last_verified_date
confidence_level
notes
```

### 6.4 Market research deliverables

Before build, create these documents:

```text
docs/research/market_map.md
docs/research/competitor_matrix.csv
docs/research/competitor_deep_dives/
docs/research/banking_buyer_personas.md
docs/research/banking_contact_center_workflows.md
docs/research/vendor_landscape_decision_memo.md
docs/research/positioning_and_wedge_strategy.md
```

### 6.5 Market claims quality bar

Every market claim must include:

- Source URL.
- Access date.
- Whether the source is official vendor material, analyst content, press, customer case study, or secondary commentary.
- Confidence rating.
- Counterpoint or limitation.

Unsupported claims must be marked as assumptions.

---

## 7. Banking use-case taxonomy

CoWork must classify banking workflows by risk and autonomy level before designing the runtime.

### 7.1 Autonomy levels

Use this scale:

| Level | Name | Description | Example |
|---|---|---|---|
| A0 | Informational only | Gives public, non-account-specific information. | Branch hours. |
| A1 | Triage and routing | Classifies intent and routes customer. | Card dispute queue. |
| A2 | Authenticated read-only | Shares account-specific information after authentication. | Application status. |
| A3 | Draft action | Collects data and creates a draft/case for human review. | Complaint intake. |
| A4 | Controlled execution | Executes low/medium-risk action after policy checks and customer confirmation. | Lost card block. |
| A5 | Human-approved execution | AI prepares action but human must approve. | Fee waiver beyond threshold. |
| A6 | Prohibited autonomy | AI must not execute. | Credit approval, wire transfer, investment advice. |

### 7.2 Recommended first-wave use cases

Prioritize workflows with high volume, low-to-moderate risk, clear scripts, and measurable operational value.

| Use case | Autonomy | Notes |
|---|---|---|
| Branch and ATM locator | A0 | Low risk, easy starting point. |
| Opening hours and appointment booking | A0/A4 | Good for early pilots. |
| Product FAQ from approved knowledge | A0 | RAG must be approved-content-only. |
| Intelligent routing | A1 | Better IVR replacement. |
| Application status | A2 | Requires authentication and backend lookup. |
| Lost or stolen card intake | A4 | Strong wedge: urgent customer value and deterministic process. |
| Card activation | A4 | Requires step-up authentication. |
| Statement request | A4 | Requires authentication and delivery preference controls. |
| Balance and recent transactions | A2 | Requires strong authentication and disclosure policy. |
| Complaint intake | A3 | AI should capture, classify, and create case, not resolve initially. |
| Fraud-alert confirmation | A4/A5 | Valuable but requires strong fraud-safe design. |

### 7.3 Medium-risk later-wave use cases

| Use case | Required controls |
|---|---|
| Transaction dispute intake | Evidence capture, policy scripting, case creation, human review for outcome. |
| Fee waiver request | Deterministic policy thresholds, explainability, human approval above limit. |
| Contact detail update | Step-up authentication, notification, risk hold where needed. |
| Collections reminder | Jurisdictional script controls, vulnerability detection, call-window rules. |
| Travel notification | Authenticated action, fraud policy integration. |
| Card replacement | Address verification, fee disclosure, fulfillment integration. |

### 7.4 Avoid in first release

| Use case | Reason |
|---|---|
| Loan approval or decline | Creditworthiness and fairness/model-risk exposure. |
| Credit score or affordability determination | High regulatory risk in many jurisdictions. |
| Investment advice | Suitability, disclosure, mis-selling, recordkeeping risk. |
| Wire transfer initiation | High fraud and scam risk. |
| New beneficiary creation | Account takeover and authorized push payment scam risk. |
| Final complaint resolution | Regulatory complaint-handling obligations. |
| Fraud investigation conclusion | Requires fraud specialist controls. |
| Vulnerable customer management without human fallback | Conduct and customer-harm risk. |

### 7.5 Use-case approval template

Each use case must be documented before implementation:

```yaml
use_case_id: UC_CARD_LOST_001
name: Lost or stolen card intake
business_owner: Contact Center Operations
risk_owner: Fraud Operations
compliance_owner: Retail Banking Compliance
customer_segment: Retail banking
jurisdictions: [SG, EU, UK, US]
autonomy_level: A4
permitted_actions:
  - collect_cardholder_confirmation
  - block_card
  - create_replacement_request
  - create_case_note
prohibited_actions:
  - disclose_full_card_number
  - change_customer_address
  - initiate_money_movement
required_authentication:
  base: account_lookup_soft_auth
  step_up: app_push_or_otp
required_disclosures:
  - recording_notice
  - replacement_fee_disclosure_if_applicable
fraud_controls:
  - caller_risk_score
  - account_risk_score
  - step_up_on_high_risk
  - human_transfer_on_critical_risk
human_handoff_triggers:
  - customer_distress
  - failed_authentication
  - suspected_fraud
  - tool_error
backend_systems:
  - card_processor
  - crm
  - fraud_case_system
audit_required: true
retention_policy: bank_policy_call_recordings
success_metrics:
  - containment_rate
  - unauthorized_action_rate
  - average_handle_time
  - customer_repeat_call_rate
  - fraud_escape_rate_in_simulation
pre_release_tests:
  - golden_calls
  - adversarial_prompt_injection
  - noisy_audio
  - accent_suite
  - fraud_simulation
  - policy_violation_tests
```

---

## 8. Banking-specific practical issues to research

### 8.1 Contact-center reality

Banks usually do not have a clean greenfield contact center. They often have:

- Legacy IVR trees.
- Multiple CCaaS or on-prem contact-center platforms after mergers.
- BPO partner operations.
- Workforce management tools.
- Quality assurance and call-recording platforms.
- Separate fraud, complaints, collections, and servicing queues.
- Agent desktop systems with custom CRM integrations.
- Regional routing rules.
- Strict change-control windows.
- Long vendor onboarding and security review cycles.

Research and design must assume integration into this environment.

### 8.2 Customer-channel reality

Bank customers may call from:

- Mobile app click-to-call.
- Public phone lines.
- Branch phones.
- Relationship manager callbacks.
- International phone numbers.
- Elderly or vulnerable-customer support lines.
- Fraud hotlines.
- Collections campaigns.

Each channel has different authentication, consent, risk, and routing requirements.

### 8.3 Audio reality

Production phone calls are messy:

- Narrowband 8 kHz audio.
- Accents and code-switching.
- Background noise.
- Speakerphone echo.
- Hold music.
- DTMF tones.
- Interruptions and barge-in.
- Long silence.
- Emotional or distressed callers.
- Multiple people speaking.
- Customers reading numbers incorrectly.
- Network jitter and packet loss.

The architecture must include test suites that replicate these conditions.

### 8.4 Banking workflow reality

A single customer sentence can trigger multiple regulated paths:

- "You charged me unfairly" may be a complaint.
- "I cannot pay" may be collections, hardship, or vulnerable-customer handling.
- "Someone told me to move my money" may be an active scam.
- "I lost my card" may require card block, fraud triage, transaction dispute, and replacement.
- "My father passed away" may require bereavement handling, not generic account service.
- "I want a better rate" may be product servicing, complaint, retention, or advice boundary.

The AI must classify not just intent but regulated context.

### 8.5 Bank procurement reality

A bank will likely require:

- Security questionnaire.
- Architecture diagrams.
- Data-flow diagrams.
- Data-residency statement.
- Subprocessor list.
- SOC 2 or ISO 27001 evidence, or roadmap.
- Penetration-test reports.
- Threat model.
- Incident-response policy.
- Business continuity and disaster recovery evidence.
- Model-risk assessment.
- AI governance pack.
- Legal terms covering liability, data protection, audit rights, exit, and subcontractors.
- Support and SLA commitments.
- Pilot success criteria and rollback plan.

These materials are product requirements, not afterthoughts.

---

## 9. Regulatory, compliance, and governance research corpus

CoWork must create a regulatory and governance corpus organized by jurisdiction and risk domain. Do not attempt legal conclusions without counsel, but build the product requirement matrix from authoritative sources.

### 9.1 Core regulatory domains

Research at minimum:

1. Data protection and privacy.
2. Call recording and consent.
3. Electronic marketing and outbound calls.
4. Payment/card data security.
5. Operational resilience.
6. Outsourcing and third-party risk.
7. Model risk management.
8. AI governance.
9. Consumer protection and conduct risk.
10. Complaints handling.
11. Collections and vulnerable-customer treatment.
12. Fraud and financial crime.
13. Recordkeeping and audit.
14. Accessibility and language support.
15. Cybersecurity.

### 9.2 Jurisdictions to cover first

Minimum first-pass jurisdictions:

- Singapore.
- European Union.
- United Kingdom.
- United States.
- Australia.
- India.
- United Arab Emirates or Saudi Arabia if Middle East is a target.

Prioritize Singapore, EU, UK, and US unless a specific launch market is selected.

### 9.3 Regulatory source starter list

Use official or primary sources where possible.

#### European Union

- Digital Operational Resilience Act (DORA): https://www.esma.europa.eu/esmas-activities/digital-finance-and-innovation/digital-operational-resilience-act-dora
- EU AI Act Annex III high-risk use cases: https://ai-act-service-desk.ec.europa.eu/en/ai-act/annex-3
- European Banking Authority outsourcing and ICT risk materials: https://www.eba.europa.eu/
- European Data Protection Board GDPR guidance: https://www.edpb.europa.eu/

#### Singapore

- MAS Technology Risk Management Guidelines: https://www.mas.gov.sg/regulation/guidelines/technology-risk-management-guidelines
- MAS AI model risk management information paper: https://www.mas.gov.sg/-/media/mas-media-library/regulation/circulars/id/id18_24/id18_24.pdf
- Singapore PDPA: https://sso.agc.gov.sg/Act/PDPA2012
- MAS FEAT principles and Veritas materials: https://www.mas.gov.sg/

#### United States

- Federal Reserve supervisory and regulatory letters: https://www.federalreserve.gov/supervisionreg/srletters/srletters.htm
- OCC bulletins and model-risk materials: https://www.occ.gov/news-issuances/bulletins/index-bulletins.html
- FDIC technology and model-risk materials: https://www.fdic.gov/
- CFPB consumer complaint and UDAAP materials: https://www.consumerfinance.gov/
- FinCEN deepfake alert: https://www.fincen.gov/sites/default/files/shared/FinCEN-Alert-DeepFakes-Alert508FINAL.pdf
- FCC AI-generated voice and TCPA ruling: https://www.fcc.gov/document/fcc-confirms-tcpa-applies-ai-technologies-generate-human-voices
- GLBA Safeguards Rule materials: https://www.ftc.gov/

#### United Kingdom

- FCA Consumer Duty: https://www.fca.org.uk/firms/consumer-duty
- FCA vulnerable customers guidance: https://www.fca.org.uk/publications/finalised-guidance/guidance-firms-fair-treatment-vulnerable-customers
- PRA outsourcing and third-party risk materials: https://www.bankofengland.co.uk/prudential-regulation
- ICO data protection guidance: https://ico.org.uk/

#### Global and cross-framework

- NIST AI Risk Management Framework: https://www.nist.gov/itl/ai-risk-management-framework
- NIST Generative AI Profile: https://www.nist.gov/itl/ai-risk-management-framework
- OWASP Top 10 for LLM Applications 2025: https://owasp.org/www-project-top-10-for-large-language-model-applications/assets/PDF/OWASP-Top-10-for-LLMs-v2025.pdf
- OWASP GenAI Security: https://genai.owasp.org/
- PCI DSS v4.x resource hub: https://blog.pcisecuritystandards.org/pci-dss-v4-0-resource-hub
- PCI DSS future-dated requirements: https://blog.pcisecuritystandards.org/now-is-the-time-for-organizations-to-adopt-the-future-dated-requirements-of-pci-dss-v4-x
- ISO/IEC 27001 and 27002 references.
- ISO/IEC 42001 AI management system references.
- SOC 2 Trust Services Criteria references.

### 9.4 Regulatory matrix schema

Create a structured matrix:

```text
jurisdiction
regulation_or_guidance
source_url
risk_domain
requirement_summary
applies_to_vocaliq
applicability_rationale
product_requirement
technical_control
operational_control
evidence_required
owner
priority
implementation_phase
legal_review_required
last_verified_date
```

### 9.5 Examples of requirement translation

| Regulatory or risk concept | Product requirement |
|---|---|
| Data minimization | Redact unnecessary PII before model calls and retrieval. |
| Recordkeeping | Store call transcript, audio pointer, graph state, model version, tool calls, and policy decisions. |
| Human oversight | Allow supervisor intervention, approval gates, and post-call review. |
| Model risk management | Maintain model inventory, eval results, release approvals, and drift monitoring. |
| Operational resilience | Support failover, degraded mode, incident runbook, exit plan, and third-party dependency mapping. |
| Payment data security | Do not expose PAN, CVV, or sensitive authentication data to LLM prompts. Use PCI-compliant secure capture. |
| Consumer protection | Detect complaint, vulnerability, hardship, and advice-boundary triggers. |
| Outbound call consent | Enforce campaign consent, opt-out, DNC lists, calling windows, and required disclosures. |

---

## 10. Research corpus build plan

The research corpus is the foundation for product decisions, architecture, prompts, policies, and evaluation. CoWork must build it before implementation.

### 10.1 Corpus folder structure

Create this structure:

```text
docs/
  00_master_brief.md
  research/
    market/
      market_map.md
      competitor_matrix.csv
      competitor_deep_dives/
      pricing_benchmarks.md
      buyer_personas.md
      bank_contact_center_stack_map.md
    banking_workflows/
      use_case_taxonomy.md
      workflow_catalog.csv
      workflow_deep_dives/
      autonomy_matrix.md
      prohibited_use_cases.md
    regulatory/
      regulatory_matrix.csv
      source_index.md
      singapore.md
      eu.md
      uk.md
      us.md
      australia.md
      india.md
      cross_frameworks.md
    risk/
      ai_risk_register.md
      model_risk_framework.md
      fraud_risk_framework.md
      operational_resilience.md
      privacy_dpia_template.md
      threat_model.md
    architecture/
      architecture_principles.md
      reference_architecture.md
      component_specs/
      data_architecture.md
      deployment_architecture.md
      integration_architecture.md
      api_contracts/
    product/
      product_requirements.md
      mvp_scope.md
      roadmap.md
      pricing_and_gtm.md
      pilot_plan.md
    evaluation/
      eval_strategy.md
      golden_call_suite.md
      adversarial_tests.md
      fraud_simulations.md
      rag_evaluation.md
      release_gates.md
    operations/
      control_center_ops.md
      incident_response.md
      support_model.md
      sla_model.md
      bank_onboarding_checklist.md
```

### 10.2 Corpus document metadata

Every source document in the corpus should have metadata:

```yaml
doc_id: REG_EU_DORA_001
title: Digital Operational Resilience Act overview
source_type: regulator_official
source_url: https://www.esma.europa.eu/esmas-activities/digital-finance-and-innovation/digital-operational-resilience-act-dora
jurisdiction: EU
risk_domains: [operational_resilience, ict_third_party_risk]
retrieved_date: 2026-05-03
owner: research
summary: DORA applies from 2025-01-17 and harmonizes digital operational resilience requirements for financial entities.
product_implications:
  - map ICT dependencies
  - maintain incident reporting and resilience evidence
  - support exit plans and third-party dependency documentation
confidence: high
legal_review_required: true
```

### 10.3 Corpus quality requirements

- Prefer official regulator, standards body, vendor documentation, and primary sources.
- Use secondary sources only to interpret market movement, not to define compliance requirements.
- Maintain source freshness and access dates.
- Tag assumptions clearly.
- Separate "legal requirement" from "product best practice."
- Capture contradictions and unresolved points.
- Do not overfit to one vendor's marketing claims.

### 10.4 Corpus outputs required before build

CoWork must produce:

1. `market_map.md` with competitor categories and implications.
2. `competitor_matrix.csv` with verified source links.
3. `banking_workflow_catalog.csv` with risk and autonomy levels.
4. `regulatory_matrix.csv` with product-control mapping.
5. `ai_risk_register.md` with ranked risks and mitigations.
6. `reference_architecture.md` with diagrams.
7. `component_specs/` for every major system component.
8. `api_contracts/` for runtime, graph, policy, tool, audit, and control-center APIs.
9. `data_architecture.md` with database and event schemas.
10. `evaluation/eval_strategy.md` with release gates.
11. `security/threat_model.md` or `risk/threat_model.md` with LLM, voice, telephony, and banking threats.
12. `pilot_plan.md` with pilot scope, success criteria, rollback, and bank evidence pack.

---

## 11. Target reference architecture

### 11.1 Architecture principle

The bank-safe architecture is:

```text
Customer speech
  -> media gateway
  -> streaming speech layer
  -> conversation state machine
  -> policy and risk engine
  -> scoped tool gateway
  -> bank systems
  -> audit ledger
  -> human control center
```

The unsafe architecture is:

```text
Customer speech -> LLM -> core banking API
```

Never build the unsafe architecture.

### 11.2 High-level architecture

```text
+-------------------------------+
| Telephony / SIP / WebRTC      |
| CCaaS / IVR / Mobile App      |
+---------------+---------------+
                |
                v
+---------------+---------------+
| Media Gateway                 |
| - SIP/WebRTC/Twilio/Telnyx    |
| - call recording policy       |
| - DTMF secure input           |
| - audio stream routing        |
| - region pinning              |
+---------------+---------------+
                |
                v
+---------------+---------------+
| Real-Time Speech Layer        |
| - VAD                         |
| - streaming ASR               |
| - endpointing                 |
| - barge-in                    |
| - TTS streaming               |
| - language detection          |
+---------------+---------------+
                |
                v
+---------------+---------------+
| Conversation Runtime          |
| - graph state machine         |
| - deterministic nodes         |
| - LLM-assisted nodes          |
| - slot extraction             |
| - repair loops                |
| - handoff logic               |
+-------+---------------+-------+
        |               |
        v               v
+-------+-------+   +---+----------------+
| Policy & Risk |   | Knowledge/RAG      |
| Engine        |   | Service            |
| - auth rules  |   | - approved docs    |
| - action ACLs |   | - metadata filters |
| - fraud rules |   | - citations        |
| - conduct     |   | - answer bounds    |
| - escalation  |   | - versioning       |
+-------+-------+   +---+----------------+
        |
        v
+-------+-------------------------------+
| Tool Execution Gateway                |
| - scoped tools                        |
| - schema validation                   |
| - idempotency                         |
| - two-phase confirmation              |
| - rate limits                         |
| - replay protection                   |
| - tool audit                          |
+-------+-------------------------------+
        |
        v
+-------+-------------------------------+
| Bank Systems                          |
| - CRM                                 |
| - core banking                        |
| - card processor                      |
| - fraud platform                      |
| - identity/MFA                        |
| - complaint/case management           |
| - collections                         |
| - knowledge base                      |
+---------------------------------------+

Sidecars:
- Audit/Event Ledger
- Observability and Tracing
- PII/PCI Redaction
- Model Gateway and Model Registry
- Prompt/Policy/Graph Version Registry
- Evaluation and Simulation Lab
- Human Control Center
- Admin/RBAC
- Data Retention and Legal Hold
- Security Monitoring
```

### 11.3 Control-plane/data-plane split

Design for bank deployment flexibility.

```text
Control Plane:
- tenant management
- graph designer
- version management
- policy management UI
- analytics dashboards
- evaluation management
- admin/RBAC

Data Plane:
- live call processing
- ASR/TTS streams
- LLM/model calls
- policy evaluation
- tool execution
- bank-system connectors
- audit events
```

Banks may require data plane inside bank VPC/private cloud/on-prem while the control plane is SaaS, or they may require both to be self-hosted.

### 11.4 Deployment modes

Support these target modes over time:

| Mode | Description | Target buyer |
|---|---|---|
| SaaS multi-tenant | Fastest deployment, shared control plane and data plane. | Smaller pilots, non-sensitive workflows. |
| Single-tenant SaaS | Dedicated tenant and data isolation. | Mid-market regulated customers. |
| Customer VPC/private cloud | Data plane in customer's cloud account. | Banks with stronger data controls. |
| Hybrid | Control plane SaaS, data plane customer-hosted. | Enterprise banks. |
| Full on-prem | Full stack in bank infrastructure. | Highly regulated or sovereign deployments. |
| Air-gapped limited mode | No external model calls; self-hosted models only. | Rare, high-security deployments. |

### 11.5 Provider abstraction

Every external AI or voice provider must sit behind a provider interface.

```text
ASRProvider
TTSProvider
LLMProvider
RealtimeModelProvider
TelephonyProvider
VectorStoreProvider
FraudSignalProvider
IdentityProvider
```

The bank must be able to:

- Use its approved LLM gateway.
- Disable external model calls.
- Route model calls by region.
- Use self-hosted ASR/TTS/LLM where needed.
- Review and approve provider configuration.
- See exactly what data was sent to each provider.

---

## 12. Component specifications to create before build

CoWork must produce a technical design document for each component below.

### 12.1 Media Gateway

Purpose:

- Connect telephony, SIP, WebRTC, mobile app audio, browser voice, and CCaaS systems into the VocalIQ runtime.

Required capabilities:

- Inbound calls.
- Outbound calls, with consent and campaign controls.
- SIP trunking.
- WebRTC.
- Twilio/Telnyx integration.
- DTMF detection.
- Secure DTMF capture path.
- Call recording policy enforcement.
- Region-aware routing.
- Audio stream duplication for ASR, recording, and supervisor monitoring.
- Hold, mute, transfer, and conference control.
- Warm transfer to human queue.
- Failover to IVR or human queue.

Design questions:

- How are call IDs mapped across telephony provider, CCaaS, and VocalIQ?
- How are recording consent prompts handled by jurisdiction?
- How is audio redaction handled?
- How is PCI capture isolated from AI runtime?
- How is barge-in handled at the media layer?
- What happens if the TTS stream fails mid-call?

Deliverables:

- Sequence diagrams for inbound call, outbound call, warm transfer, DTMF capture, and failover.
- Telephony provider abstraction interface.
- Error model.
- Latency budget.
- Security and data-flow diagram.

### 12.2 Real-Time Speech Layer

Purpose:

- Convert messy live audio into usable streaming text and convert responses into interruptible speech.

Required capabilities:

- Voice activity detection.
- Streaming ASR with partial hypotheses.
- Endpointing and semantic turn detection.
- Barge-in detection.
- TTS streaming.
- TTS cancellation.
- Language detection.
- Code-switching handling.
- Confidence scores and uncertainty propagation.
- Noise and telephony degradation handling.

Key design principle:

The speech layer must propagate uncertainty upward. A low-confidence transcript should restrict action autonomy.

Example output:

```json
{
  "turn_id": "turn_123",
  "asr_text": "I lost my card and there are charges I don't recognize",
  "language": "en-SG",
  "asr_confidence": 0.86,
  "word_confidences": [
    {"word": "lost", "confidence": 0.94},
    {"word": "card", "confidence": 0.96},
    {"word": "charges", "confidence": 0.78}
  ],
  "audio_quality": {
    "snr": "medium",
    "codec": "g711_ulaw",
    "packet_loss_estimate": 0.01
  },
  "risk_flags": ["possible_fraud_dispute"]
}
```

Deliverables:

- ASR provider comparison.
- TTS provider comparison.
- Confidence-handling design.
- Latency budget by stage.
- Audio test corpus requirements.
- Fallback strategy.

### 12.3 Conversation Runtime

Purpose:

- Execute controlled conversation workflows.

Required capabilities:

- Graph state machine.
- Deterministic nodes.
- LLM-assisted response nodes.
- Intent detection.
- Slot filling.
- Repair loops.
- Context management.
- Policy and risk checks before tool calls.
- Human escalation.
- Multilingual flow support.
- Versioned graph execution.
- Replayable state transitions.

Key design principle:

The state machine owns the conversation. The LLM proposes language, extraction, or summaries. The policy engine decides whether an action is allowed. The tool gateway executes only scoped, validated actions.

Deliverables:

- Graph DSL specification.
- Runtime state model.
- Node lifecycle.
- Error and fallback semantics.
- Versioning model.
- Graph validation and compilation rules.
- Runtime API contract.

### 12.4 Risk-Aware Graph Compiler

Purpose:

- Prevent unsafe flows from being published.

The graph compiler should validate:

- No high-risk tool call without required authentication.
- No account-specific disclosure before authentication.
- No PCI data sent to LLM nodes.
- No complaint signal without complaint handling path.
- No collections workflow without jurisdiction tag and script controls.
- No fraud signal without escalation/risk path.
- No regulated disclosure node without audit event.
- No tool node without idempotency and failure handler.
- No LLM node that can choose arbitrary tools.
- No graph with dead-end customer states.
- No graph without human fallback.

Example compiler error:

```json
{
  "graph_version": "card_lost_v3",
  "severity": "blocker",
  "node_id": "block_card_tool_call",
  "rule_id": "AUTH_REQUIRED_FOR_CARD_BLOCK",
  "message": "Card block action requires step-up authentication before execution.",
  "required_fix": "Add AuthenticateNode with method app_push_or_otp before ToolNode."
}
```

Deliverables:

- Compiler rules catalog.
- Severity levels.
- Approval workflow.
- Graph diff and rollback design.
- Policy interaction design.

### 12.5 Policy and Risk Engine

Purpose:

- Enforce business, regulatory, fraud, authentication, conduct, and action-permission rules.

Required capabilities:

- Policy-as-code.
- Rule versioning.
- Jurisdiction rules.
- Product rules.
- Customer segment rules.
- Authentication requirements.
- Fraud risk thresholds.
- Vulnerable-customer triggers.
- Complaint triggers.
- Collections triggers.
- Advice-boundary triggers.
- Permitted-action matrix.
- Human approval rules.
- Explainable policy decision output.

Example policy decision:

```json
{
  "decision_id": "pd_789",
  "call_id": "call_123",
  "graph_node_id": "read_balance",
  "requested_action": "account.balance.read",
  "decision": "deny",
  "reason_codes": ["AUTH_LEVEL_TOO_LOW", "CALLER_RISK_MEDIUM"],
  "required_next_step": "STEP_UP_AUTH",
  "policy_version": "retail_policy_2026_05_01",
  "evaluated_at": "2026-05-03T08:30:00Z"
}
```

Deliverables:

- Policy DSL decision memo: OPA/Rego, Cedar, custom DSL, or rules engine.
- Policy model.
- Risk scoring model.
- Rule versioning and approval workflow.
- Policy test suite design.
- Explanation schema.

### 12.6 Model Gateway

Purpose:

- Centralize all LLM/realtime-model calls and enforce model governance.

Required capabilities:

- Approved model registry.
- Provider routing.
- Region routing.
- Prompt templates and prompt versioning.
- Redaction before model calls.
- Token and cost tracking.
- Input/output logging with sensitive-data controls.
- Safety filters.
- Model fallback.
- Model comparison.
- Bank-owned model gateway integration.
- No training on customer data unless explicitly approved.

Deliverables:

- LLM provider abstraction.
- Prompt registry schema.
- Model registry schema.
- Redaction pipeline.
- Logging and retention policy.
- Error and fallback strategy.
- Model-evaluation integration.

### 12.7 Knowledge/RAG Service

Purpose:

- Provide approved, citation-backed answers from bank-controlled knowledge.

Required capabilities:

- Document ingestion.
- Approval workflow.
- Versioning.
- Effective dates.
- Jurisdiction metadata.
- Product metadata.
- Customer segment metadata.
- ACLs.
- Hybrid search: keyword plus vector.
- Reranking.
- Citation validation.
- Conflict detection.
- No-answer behavior.
- RAG evaluation.

Do not build naive vector search over all bank documents.

Correct design:

```text
customer question
  -> query normalization
  -> jurisdiction/product/customer filters
  -> keyword + vector retrieval
  -> reranking
  -> permission filter
  -> conflict detection
  -> answer drafting
  -> citation validation
  -> policy/safety check
  -> response
```

Deliverables:

- Document metadata schema.
- Ingestion workflow.
- Retrieval architecture.
- RAG prompt templates.
- Citation validation method.
- No-answer policy.
- Evaluation methodology.

### 12.8 Tool Execution Gateway

Purpose:

- Safely execute bank-system actions.

Required capabilities:

- Tool registry.
- Scoped tool permissions.
- Auth-level requirements.
- Schema validation.
- Deterministic preconditions.
- Idempotency keys.
- Two-phase confirmation for sensitive actions.
- Human approval gates.
- Rate limits.
- Replay protection.
- Tool result validation.
- Tool audit events.
- Sandbox connectors.

Example tool manifest:

```yaml
tool_id: card.block
version: 1.0.0
description: Block a lost or stolen card.
risk_level: high
allowed_autonomy_levels: [A4, A5]
required_authentication: step_up
requires_customer_confirmation: true
requires_human_approval: false
input_schema:
  type: object
  required: [customer_id, card_id, reason]
  properties:
    customer_id:
      type: string
    card_id:
      type: string
    reason:
      enum: [lost, stolen, suspected_fraud]
forbidden_inputs:
  - full_pan
  - cvv
idempotency_required: true
audit_required: true
failure_behavior: transfer_to_card_services
```

Deliverables:

- Tool registry schema.
- Tool permission model.
- Tool execution state machine.
- Idempotency strategy.
- Connector framework.
- Mock bank-system simulator.
- Tool audit schema.

### 12.9 Fraud-Aware Identity Layer

Purpose:

- Decide what the AI is allowed to say or do based on caller identity, authentication strength, and fraud risk.

Required capabilities:

- Authentication status tracking.
- Step-up authentication orchestration.
- App push, OTP, secure link, or bank IAM integration.
- Caller-ID risk signal ingestion.
- Device/channel risk signal ingestion.
- Account-risk signal ingestion.
- Behavioral anomaly signal ingestion.
- Voice biometric signal integration where available.
- Synthetic voice/deepfake risk signal integration where available.
- Scam/coercion phrase detection.
- Safe callback protocol.
- Risk-based action restrictions.

Important:

Voice biometrics or deepfake detection must not be treated as absolute truth. They are risk signals, not final identity decisions.

Example risk calculation:

```text
call_risk_score =
  caller_id_risk
+ channel_risk
+ device_reputation_risk
+ account_takeover_risk
+ authentication_gap
+ requested_action_risk
+ asr_uncertainty
+ model_uncertainty
+ scam_language_signal
+ vulnerable_customer_signal
```

Example risk-to-action mapping:

```text
low risk:
  allow informational and authenticated read-only flows
medium risk:
  require step-up auth before sensitive disclosure
high risk:
  restrict sensitive disclosure and route to trained human
critical risk:
  block action path, create fraud event, use safe callback protocol
```

Deliverables:

- Authentication state model.
- Risk signal interface.
- Risk scoring design.
- Scam and coercion detection taxonomy.
- Safe callback protocol.
- Fraud escalation design.
- False-positive handling strategy.

### 12.10 Human Control Center

Purpose:

- Give humans exception-driven oversight and intervention capability.

Required capabilities:

- Live call monitoring.
- Transcript stream.
- AI state view.
- Current graph node.
- Risk flags.
- Authentication status.
- Tool call history.
- Supervisor alerts.
- Human approval queue.
- Whisper/instruction to AI.
- One-click takeover.
- Warm transfer.
- Post-call QA.
- Replay.

Do not design around supervisors watching every call. Design around exception alerts and risk thresholds.

Escalation triggers:

- Low confidence.
- Failed authentication.
- Fraud signal.
- Vulnerable customer signal.
- Complaint signal.
- Collections/hardship signal.
- Advice-boundary signal.
- High-value customer.
- Tool failure.
- Repeated repair loops.
- Customer anger or distress.

Deliverables:

- Control-center user journeys.
- Supervisor alert taxonomy.
- Takeover sequence diagram.
- Handoff package schema.
- Human approval workflow.
- QA review design.

### 12.11 Audit/Event Ledger

Purpose:

- Prove what happened in every call.

Required capabilities:

- Append-only event log.
- Turn-level trace.
- Audio reference.
- Transcript versions.
- ASR confidence.
- Model input/output reference.
- Prompt version.
- Model version.
- Retrieved document references.
- Graph state transitions.
- Policy decisions.
- Tool calls.
- Human interventions.
- Redaction events.
- Retention and legal hold.
- Export for audit and investigations.

Example event:

```json
{
  "event_id": "evt_001",
  "event_type": "policy_decision",
  "tenant_id": "bank_abc",
  "call_id": "call_123",
  "turn_id": "turn_004",
  "timestamp": "2026-05-03T08:30:00Z",
  "actor_type": "system",
  "graph_version": "lost_card_v3",
  "node_id": "block_card_policy_check",
  "payload": {
    "requested_action": "card.block",
    "decision": "allow",
    "reason_codes": ["STEP_UP_AUTH_PASSED", "CALL_RISK_LOW"],
    "policy_version": "retail_policy_2026_05_01"
  },
  "hash_prev": "...",
  "hash_current": "..."
}
```

Deliverables:

- Event taxonomy.
- Event schema.
- Retention model.
- Redaction model.
- Replay design.
- Audit export format.
- Integrity/tamper-evidence design.

### 12.12 Evaluation and Assurance Lab

Purpose:

- Test every agent, graph, model, prompt, policy, and tool before release.

Required capabilities:

- Golden call regression tests.
- AI customer simulation.
- Prompt-injection tests.
- Fraud simulations.
- Deepfake/synthetic audio tests where feasible.
- Accent/noise tests.
- RAG faithfulness tests.
- Compliance script tests.
- Tool-call authorization tests.
- Human handoff tests.
- Load and chaos tests.
- Release gate reporting.

Deliverables:

- Evaluation strategy.
- Test data strategy.
- Simulator architecture.
- Metrics definitions.
- Release gate thresholds.
- Eval report template.

---

## 13. Conversation graph DSL draft

CoWork must formalize the graph DSL. This draft shows the expected direction.

### 13.1 Graph object

```yaml
graph_id: lost_card_retail_v1
name: Retail lost or stolen card flow
version: 1.0.0
status: draft
jurisdictions: [SG]
customer_segments: [retail]
owner: contact_center_ops
risk_owner: fraud_ops
compliance_owner: retail_compliance
default_language: en-SG
supported_languages: [en-SG, zh-SG, ms-SG, ta-SG]
audit_required: true
human_fallback_required: true
nodes:
  - id: start
    type: speak
    next: collect_intent
  - id: collect_intent
    type: collect
    next: route_intent
```

### 13.2 Node metadata

Every node must include risk metadata.

```yaml
id: read_balance
node_type: tool
business_process: account_servicing
data_classification: confidential_customer_data
autonomy_level_required: A2
required_authentication: step_up
permitted_roles: [retail_voice_agent]
regulated_contexts:
  - privacy
  - account_disclosure
risk_level: medium
human_approval_required: false
audit_required: true
fallback_node: transfer_to_human
```

### 13.3 Node types

Required node types:

```text
SpeakNode
CollectNode
IntentNode
AuthenticateNode
PolicyNode
RiskNode
ToolNode
RAGNode
DisclosureNode
ConfirmNode
HumanApprovalNode
TransferNode
CaseNode
WaitNode
EndNode
FallbackNode
```

### 13.4 Example flow

```yaml
graph_id: lost_card_retail_v1
version: 1.0.0
nodes:
  - id: greeting
    type: SpeakNode
    message_template: greeting_recording_notice_v1
    next: identify_reason

  - id: identify_reason
    type: IntentNode
    allowed_intents:
      - lost_card
      - stolen_card
      - card_fraud
      - other
    low_confidence_next: transfer_to_human
    next_map:
      lost_card: auth_customer
      stolen_card: auth_customer
      card_fraud: fraud_triage
      other: route_general

  - id: auth_customer
    type: AuthenticateNode
    methods: [app_push, otp, secure_link]
    success_next: collect_card_details
    failure_next: transfer_to_human

  - id: collect_card_details
    type: CollectNode
    slots:
      - card_selector
      - loss_context
    validation: card_selector_must_match_customer_cards
    next: risk_check

  - id: risk_check
    type: RiskNode
    risk_model: card_servicing_risk_v1
    next_map:
      low: confirm_block
      medium: confirm_block
      high: transfer_to_fraud_specialist
      critical: fraud_safe_callback

  - id: confirm_block
    type: ConfirmNode
    message_template: confirm_card_block_v1
    next_on_yes: block_card
    next_on_no: transfer_to_human

  - id: block_card
    type: ToolNode
    tool_id: card.block
    required_authentication: step_up
    idempotency_required: true
    success_next: offer_replacement
    failure_next: transfer_to_card_services

  - id: offer_replacement
    type: PolicyNode
    policy: replacement_card_policy_v1
    next_map:
      eligible: confirm_replacement
      not_eligible: create_case_and_transfer

  - id: confirm_replacement
    type: ConfirmNode
    message_template: confirm_replacement_card_v1
    next_on_yes: create_replacement_request
    next_on_no: close_call

  - id: create_replacement_request
    type: ToolNode
    tool_id: card.replacement.create
    required_authentication: step_up
    requires_customer_confirmation: true
    success_next: close_call
    failure_next: transfer_to_card_services

  - id: close_call
    type: SpeakNode
    message_template: lost_card_closing_v1
    next: end

  - id: transfer_to_human
    type: TransferNode
    queue: card_services
    include_handoff_package: true

  - id: transfer_to_fraud_specialist
    type: TransferNode
    queue: fraud_ops
    include_handoff_package: true

  - id: fraud_safe_callback
    type: TransferNode
    queue: fraud_ops_priority
    include_handoff_package: true
    customer_message_template: safe_callback_protocol_v1
```

---

## 14. Policy model draft

### 14.1 Policy dimensions

Policies must account for:

- Jurisdiction.
- Legal entity.
- Product type.
- Customer segment.
- Customer vulnerability status.
- Call direction: inbound or outbound.
- Call channel: PSTN, app click-to-call, branch, relationship manager.
- Authentication level.
- Caller risk score.
- Requested action risk.
- Data classification.
- Human approval requirement.
- Model confidence and ASR confidence.
- Complaint/fraud/collections/advice signals.

### 14.2 Authentication levels

```text
AUTH_0_UNKNOWN
AUTH_1_CALL_CONTEXT_ONLY
AUTH_2_SOFT_AUTH
AUTH_3_KNOWLEDGE_OR_OTP
AUTH_4_APP_PUSH_OR_STRONG_CUSTOMER_AUTH
AUTH_5_HUMAN_VERIFIED_HIGH_ASSURANCE
```

### 14.3 Action classes

```text
PUBLIC_INFO_READ
ACCOUNT_INFO_READ
CUSTOMER_DATA_UPDATE
CARD_BLOCK
CARD_REPLACEMENT
CASE_CREATE
COMPLAINT_CREATE
DISPUTE_CREATE
PAYMENT_INITIATE
BENEFICIARY_CREATE
CREDIT_DECISION
INVESTMENT_ADVICE
FRAUD_CASE_ESCALATE
```

### 14.4 Action permission matrix draft

| Action class | Minimum auth | Risk threshold | Human approval | MVP status |
|---|---|---|---|---|
| PUBLIC_INFO_READ | AUTH_0 | Any | No | Allow |
| INTELLIGENT_ROUTING | AUTH_0 | Any | No | Allow |
| ACCOUNT_INFO_READ | AUTH_4 | Low/Medium | No | Allow carefully |
| CARD_BLOCK | AUTH_4 | Low/Medium | No | Allow carefully |
| CARD_REPLACEMENT | AUTH_4 | Low | Maybe | Later MVP |
| CASE_CREATE | AUTH_2 | Any | No | Allow |
| COMPLAINT_CREATE | AUTH_2 | Any | No | Allow intake only |
| DISPUTE_CREATE | AUTH_4 | Low/Medium | Maybe | Later |
| CUSTOMER_DATA_UPDATE | AUTH_4 | Low | Maybe | Later |
| PAYMENT_INITIATE | AUTH_5 | Low | Yes | Prohibited initially |
| BENEFICIARY_CREATE | AUTH_5 | Low | Yes | Prohibited initially |
| CREDIT_DECISION | N/A | N/A | N/A | Prohibited initially |
| INVESTMENT_ADVICE | N/A | N/A | N/A | Prohibited initially |

### 14.5 Policy output schema

```json
{
  "policy_decision_id": "pd_123",
  "decision": "allow|deny|step_up_required|human_approval_required|transfer_required",
  "reason_codes": ["AUTH_SUFFICIENT", "RISK_LOW"],
  "required_actions": [],
  "forbidden_actions": [],
  "policy_version": "policy_2026_05_01",
  "explanation": "Customer passed app push authentication and call risk is low. Card block is permitted.",
  "audit_required": true
}
```

---

## 15. Algorithmic design requirements

### 15.1 Hybrid controller design

The runtime should use a layered controller:

```text
1. Audio controller
2. ASR and turn controller
3. Intent and slot controller
4. Graph state controller
5. Policy/risk controller
6. LLM language controller
7. Tool execution controller
8. Human escalation controller
9. Audit controller
```

LLM output must never directly mutate graph state or execute tools. It can produce proposed interpretations, responses, or summaries that are validated by deterministic controllers.

### 15.2 Intent detection

Use a hybrid approach:

- Fast classifier for common intents.
- LLM-based classifier for ambiguous intents.
- Regulated-context classifiers for complaint, fraud, hardship, collections, vulnerability, advice boundary, and coercion.
- Confidence calibration.
- Multi-intent support.

Example:

```json
{
  "intents": [
    {"name": "lost_card", "confidence": 0.91},
    {"name": "transaction_dispute", "confidence": 0.73}
  ],
  "regulated_contexts": [
    {"name": "possible_fraud", "confidence": 0.82}
  ],
  "recommended_next_node": "fraud_triage",
  "requires_human_review": false
}
```

### 15.3 Slot extraction

Slot extraction must include:

- Raw utterance.
- Normalized value.
- Confidence.
- Validation status.
- Source span.
- Repair prompt if invalid.

Example:

```json
{
  "slot_name": "transaction_amount",
  "raw_value": "one hundred and twenty dollars",
  "normalized_value": "120.00",
  "currency": "SGD",
  "confidence": 0.89,
  "validation_status": "requires_confirmation",
  "source_turn_id": "turn_008"
}
```

### 15.4 Uncertainty management

The runtime must account for uncertainty from:

- ASR confidence.
- Intent confidence.
- Slot confidence.
- RAG retrieval confidence.
- LLM output confidence or validation status.
- Tool response consistency.
- Fraud risk signals.
- Policy ambiguity.

Uncertainty should reduce autonomy.

Example:

```text
if asr_confidence < 0.75 and requested_action.risk_level in [medium, high]:
  require confirmation or transfer
```

### 15.5 Turn-taking and barge-in

The runtime must support:

- Customer interruption while TTS is playing.
- TTS cancellation.
- Mid-response intent shift.
- Repair after interruption.
- Confirmation after critical information.

Design principle:

For regulated disclosures, interruption handling must ensure the required disclosure was actually completed or logged as incomplete.

### 15.6 Risk scoring

Risk scoring should be transparent and auditable.

Avoid black-box risk-only decisions for critical actions. Combine deterministic thresholds with model-based signals.

Risk components:

```text
identity_risk
channel_risk
account_risk
action_risk
conversation_risk
model_uncertainty_risk
fraud_language_risk
vulnerability_risk
regulatory_context_risk
```

Output:

```json
{
  "risk_score": 72,
  "risk_band": "high",
  "reason_codes": [
    "CALLER_ID_SPOOF_RISK",
    "REQUESTED_ACTION_HIGH_RISK",
    "SCAM_LANGUAGE_DETECTED"
  ],
  "allowed_autonomy": "A1",
  "required_next_step": "TRANSFER_TO_FRAUD_SPECIALIST"
}
```

### 15.7 RAG answer controls

RAG should not answer unless:

- Retrieved sources are approved.
- Sources match jurisdiction/product/customer segment.
- Sources are active on the call date.
- User has permission for the content.
- The answer is supported by sources.
- No policy conflict is detected.

Failure mode:

- Provide a safe no-answer or transfer.

### 15.8 Tool execution controls

Tool execution should use a state machine:

```text
requested
  -> policy_check
  -> auth_check
  -> schema_validation
  -> precondition_validation
  -> customer_confirmation_if_required
  -> human_approval_if_required
  -> execute
  -> result_validation
  -> audit
  -> customer_response
```

### 15.9 Human escalation model

Escalation should be risk-based and exception-driven.

Escalation score can include:

- Low confidence.
- High risk.
- Customer distress.
- Regulated context.
- Repeated repairs.
- Tool failure.
- VIP/customer segment.
- Customer asks for human.

### 15.10 Evaluation algorithms

Evaluation must test:

- Conversation success.
- Policy compliance.
- Tool authorization.
- RAG faithfulness.
- Fraud detection.
- Human handoff correctness.
- Latency and reliability.
- Regression across graph versions.

Each test should produce machine-readable results:

```json
{
  "eval_run_id": "eval_2026_05_03_001",
  "graph_version": "lost_card_v1.0.0",
  "scenario_id": "scam_coercion_003",
  "result": "fail",
  "failure_type": "missed_fraud_signal",
  "expected_behavior": "transfer_to_fraud_specialist",
  "observed_behavior": "continued_card_replacement_flow",
  "severity": "blocker"
}
```

---

## 16. Data architecture draft

### 16.1 Core entities

Minimum database entities:

```text
tenants
users
roles
permissions
agents
graphs
graph_versions
graph_approvals
policy_sets
policy_versions
model_registry
prompt_templates
prompt_versions
knowledge_collections
knowledge_documents
knowledge_document_versions
tool_registry
tool_versions
connectors
call_sessions
call_turns
transcript_segments
audio_artifacts
auth_events
risk_events
policy_decisions
tool_calls
human_interventions
handoff_packages
audit_events
eval_suites
eval_scenarios
eval_runs
eval_results
incidents
retention_policies
legal_holds
```

### 16.2 Call session schema draft

```sql
call_sessions (
  id uuid primary key,
  tenant_id uuid not null,
  external_call_id text,
  direction text check (direction in ('inbound','outbound')),
  channel text,
  telephony_provider text,
  agent_id uuid,
  graph_version_id uuid,
  customer_ref text,
  authentication_level text,
  risk_band text,
  status text,
  started_at timestamptz,
  ended_at timestamptz,
  recording_artifact_id uuid,
  transcript_artifact_id uuid,
  region text,
  jurisdiction text,
  created_at timestamptz default now()
)
```

### 16.3 Turn event schema draft

```sql
call_turns (
  id uuid primary key,
  call_session_id uuid not null,
  turn_index int not null,
  speaker text check (speaker in ('customer','ai','human_agent','system')),
  text_redacted text,
  text_raw_ref uuid,
  language text,
  asr_confidence numeric,
  intent_json jsonb,
  slot_json jsonb,
  graph_node_id text,
  started_at timestamptz,
  ended_at timestamptz,
  created_at timestamptz default now()
)
```

### 16.4 Audit event schema draft

```sql
audit_events (
  id uuid primary key,
  tenant_id uuid not null,
  call_session_id uuid,
  event_type text not null,
  actor_type text not null,
  actor_id text,
  graph_version_id uuid,
  policy_version_id uuid,
  model_version_id text,
  prompt_version_id uuid,
  tool_call_id uuid,
  payload_redacted jsonb,
  sensitive_payload_ref uuid,
  hash_prev text,
  hash_current text,
  created_at timestamptz default now()
)
```

### 16.5 Data classification

Define data classes:

```text
PUBLIC
INTERNAL
CONFIDENTIAL_CUSTOMER
SENSITIVE_CUSTOMER
PCI_CARDHOLDER
PCI_SENSITIVE_AUTHENTICATION
BANK_SECRET
MODEL_GOVERNANCE
SECURITY_SECRET
LEGAL_PRIVILEGED
```

Every field, event, prompt, transcript segment, and document should have data classification.

### 16.6 Retention

Retention policies must support:

- Tenant-specific retention.
- Jurisdiction-specific retention.
- Call recording retention.
- Transcript retention.
- Model trace retention.
- Tool-call retention.
- Redaction and deletion.
- Legal hold.
- Complaint/fraud investigation hold.

---

## 17. API surface draft

CoWork must create detailed OpenAPI/AsyncAPI contracts before implementation.

### 17.1 Graph API

```text
POST /graphs
GET /graphs/{graph_id}
POST /graphs/{graph_id}/versions
POST /graphs/{graph_id}/versions/{version_id}/validate
POST /graphs/{graph_id}/versions/{version_id}/submit-approval
POST /graphs/{graph_id}/versions/{version_id}/publish
POST /graphs/{graph_id}/versions/{version_id}/rollback
```

### 17.2 Runtime API

```text
POST /runtime/calls
GET /runtime/calls/{call_id}
POST /runtime/calls/{call_id}/events
POST /runtime/calls/{call_id}/transfer
POST /runtime/calls/{call_id}/terminate
GET /runtime/calls/{call_id}/state
```

### 17.3 Policy API

```text
POST /policy/evaluate
POST /policy/sets
POST /policy/sets/{policy_set_id}/versions
POST /policy/sets/{policy_set_id}/versions/{version_id}/test
POST /policy/sets/{policy_set_id}/versions/{version_id}/publish
```

### 17.4 Tool Gateway API

```text
POST /tools/register
GET /tools/{tool_id}
POST /tools/{tool_id}/validate
POST /tools/{tool_id}/execute
GET /tools/executions/{execution_id}
```

### 17.5 Control Center API

```text
GET /control-center/live-calls
GET /control-center/live-calls/{call_id}
POST /control-center/live-calls/{call_id}/whisper
POST /control-center/live-calls/{call_id}/takeover
POST /control-center/live-calls/{call_id}/approve-action
POST /control-center/live-calls/{call_id}/transfer
```

### 17.6 Audit API

```text
GET /audit/calls/{call_id}/timeline
GET /audit/calls/{call_id}/events
GET /audit/calls/{call_id}/replay
POST /audit/export
POST /audit/legal-hold
POST /audit/redaction-request
```

### 17.7 Evaluation API

```text
POST /eval/suites
POST /eval/scenarios
POST /eval/runs
GET /eval/runs/{run_id}
GET /eval/runs/{run_id}/report
POST /eval/runs/{run_id}/approve-release
```

---

## 18. Security and threat model requirements

### 18.1 Threat categories

CoWork must create a threat model covering:

- Prompt injection by caller.
- Indirect prompt injection through documents or tool outputs.
- Sensitive information disclosure.
- Unauthorized tool execution.
- Model supply-chain risk.
- Model/provider outage.
- Data exfiltration through logs or prompts.
- Caller-ID spoofing.
- Synthetic voice and deepfake attacks.
- Social engineering of AI agent.
- Social engineering of human supervisor through AI handoff.
- Account takeover.
- Authorized push payment scams.
- Telephony fraud.
- DTMF/PSTN attacks.
- Cross-tenant data leakage.
- Insider misuse.
- Misconfigured retention or deletion.
- Incomplete audit logs.
- Insecure connectors to bank systems.
- Over-permissive service accounts.
- API key and secret leakage.
- Denial of service.
- Replay attacks.
- Hallucinated policy or product terms.

### 18.2 Security controls

Minimum controls:

- Tenant isolation.
- RBAC and least privilege.
- SSO/SAML/OIDC.
- MFA for admin users.
- Strong secret management.
- KMS/HSM integration options.
- Encryption in transit and at rest.
- Network allowlisting/private connectivity.
- Service-to-service authentication.
- Scoped connector credentials.
- PII/PCI redaction.
- DLP before model calls.
- Prompt and tool-call logging with sensitive payload references.
- Immutable audit logs.
- Security monitoring.
- Vulnerability management.
- Dependency and model supply-chain review.
- Penetration testing.
- Incident response.

### 18.3 LLM-specific controls

- Prompt templates are versioned and approved.
- System prompts are not the only safety control.
- Tool permissions are enforced outside the LLM.
- Retrieved documents are permission-filtered.
- User speech is untrusted input.
- Tool outputs are untrusted input until validated.
- LLM output is treated as a proposal, not an instruction.
- No model call receives unnecessary sensitive data.
- No raw PCI sensitive authentication data is sent to an LLM.
- Safety filters and output validators run after LLM responses.
- Red-team tests are part of release gates.

---

## 19. Compliance and evidence pack requirements

A bank pilot will require evidence. Build the product and process to produce it.

### 19.1 Evidence pack checklist

Create these artifacts:

```text
architecture_diagram.pdf or .md
data_flow_diagram.md
subprocessor_list.md
data_residency_statement.md
security_controls_matrix.md
ai_governance_model.md
model_inventory.md
model_cards/
prompt_registry_export.md
graph_version_export.md
policy_version_export.md
evaluation_report.md
red_team_report.md
threat_model.md
incident_response_plan.md
business_continuity_plan.md
disaster_recovery_plan.md
exit_plan.md
retention_and_deletion_policy.md
privacy_impact_assessment_template.md
pci_scope_statement.md
access_control_model.md
support_and_sla_model.md
```

### 19.2 Model card template

```yaml
model_id: llm_provider_model_x
provider: provider_name
version: model_version
approved_for:
  - intent_classification
  - response_drafting_from_approved_content
  - summarization
not_approved_for:
  - credit_decisions
  - investment_advice
  - identity_verification_final_decision
  - direct_tool_execution
input_data_classes_allowed:
  - PUBLIC
  - INTERNAL
  - CONFIDENTIAL_CUSTOMER_REDACTED
input_data_classes_forbidden:
  - PCI_SENSITIVE_AUTHENTICATION
  - SECURITY_SECRET
  - RAW_FULL_PAN
regions_allowed:
  - sg
  - eu
retention_terms: no_training_no_retention_if_configured
last_eval_date: 2026-05-03
eval_summary: pending
approval_status: draft
risk_owner: model_risk
```

### 19.3 Prompt card template

```yaml
prompt_id: intent_classifier_retail_v1
version: 1.0.0
purpose: Classify retail banking call intents and regulated contexts.
approved_models:
  - model_x
allowed_data_classes:
  - transcript_redacted
forbidden_data_classes:
  - raw_pan
  - cvv
  - password
safety_requirements:
  - identify_complaint_signal
  - identify_fraud_signal
  - identify_vulnerable_customer_signal
  - do_not_make_policy_decisions
owner: product_ai
approver: compliance
last_eval_run: eval_2026_05_03_001
status: draft
```

### 19.4 Graph approval template

```yaml
graph_id: lost_card_retail_v1
version: 1.0.0
business_owner_approval: pending
risk_owner_approval: pending
compliance_approval: pending
security_approval: pending
model_risk_approval: pending
eval_status: pending
known_limitations:
  - English-only initial pilot.
  - No address change in flow.
  - Fraud dispute outcome not automated.
rollback_version: null
go_live_conditions:
  - all blocker tests pass
  - fraud scenarios pass
  - human handoff tested
  - bank UAT completed
```

---

## 20. Evaluation strategy

### 20.1 Evaluation principle

For banks, evaluation is not optional. Evaluation is a product feature and a sales enabler.

Every release must answer:

- What changed?
- What was tested?
- What failed?
- What risks remain?
- Who approved it?
- How do we roll back?

### 20.2 Evaluation suites

Minimum suites:

1. Golden path tests.
2. Edge-case tests.
3. Adversarial prompt-injection tests.
4. Fraud and scam tests.
5. Deepfake or spoofing signal tests where available.
6. Low-audio-quality tests.
7. Accent and multilingual tests.
8. Compliance script tests.
9. RAG faithfulness tests.
10. Tool-call authorization tests.
11. Human handoff tests.
12. Load and latency tests.
13. Provider outage tests.
14. Regression tests across graph versions.

### 20.3 Evaluation metrics

#### Customer outcome metrics

```text
task_completion_rate
safe_resolution_rate
repeat_call_rate
containment_rate_without_repeat
customer_abandonment_rate
customer_satisfaction_proxy
complaint_rate
```

#### Safety metrics

```text
unauthorized_disclosure_rate
unauthorized_tool_call_rate
policy_violation_rate
hallucinated_answer_rate
rag_unsupported_answer_rate
missed_complaint_signal_rate
missed_fraud_signal_rate
missed_vulnerability_signal_rate
```

#### Voice metrics

```text
word_error_rate_by_language
word_error_rate_by_accent
intent_accuracy
slot_f1
barge_in_success_rate
turn_latency_p50_p95_p99
tts_first_audio_latency
conversation_repair_rate
```

#### Operational metrics

```text
average_handle_time
human_transfer_rate
human_rescue_rate
supervisor_approval_rate
agent_after_call_work_reduction
system_uptime
provider_error_rate
fallback_rate
```

#### Economic metrics

```text
cost_per_call
cost_per_safe_resolution
live_agent_minutes_saved
integration_maintenance_cost
fraud_loss_avoidance_proxy
qa_review_time_saved
```

### 20.4 Release gates

A graph/model/prompt/policy release cannot go live if:

- Any blocker policy test fails.
- Any high-risk tool can execute without required authentication.
- RAG provides unsupported regulated answers above threshold.
- Fraud simulations fail for critical scenarios.
- Complaint detection fails for core complaint phrases.
- Human handoff does not preserve context.
- Audit events are incomplete.
- Rollback is not configured.
- Security review is missing for new connectors.

### 20.5 Eval report template

```yaml
eval_report_id: eval_report_lost_card_v1
scope:
  graph_version: lost_card_v1.0.0
  policy_version: retail_policy_2026_05_01
  prompt_versions:
    - intent_classifier_v1
    - response_drafter_v1
summary:
  total_tests: 350
  passed: 342
  failed: 8
  blockers: 0
  high: 1
  medium: 3
  low: 4
recommendation: conditional_approval
conditions:
  - fix medium issue on noisy audio confirmation loop before pilot
known_limitations:
  - no Tamil support in pilot
  - no disputed transaction outcome automation
approvals:
  product: pending
  compliance: pending
  risk: pending
  security: pending
```

---

## 21. MVP scope

### 21.1 MVP objective

Build a bank-grade pilot platform for safe inbound servicing automation, not a broad open-ended voice assistant.

### 21.2 MVP workflows

Include:

1. Greeting and recording notice.
2. Intelligent routing.
3. Public FAQ from approved knowledge.
4. Branch/ATM locator.
5. Appointment booking.
6. Application status after authentication.
7. Lost/stolen card intake.
8. Card block after step-up authentication.
9. Complaint intake and case creation.
10. Warm transfer with context package.
11. Supervisor monitoring and takeover.
12. Full audit/replay.

### 21.3 MVP platform capabilities

| Capability | MVP requirement |
|---|---|
| Voice pipeline | Streaming VAD/STT/LLM/TTS with barge-in. |
| Telephony | Inbound calls, SIP/Twilio/Telnyx path, warm transfer. |
| Graph runtime | Deterministic state machine with controlled LLM nodes. |
| Graph designer | Basic visual builder or declarative graph config with UI viewer. |
| Policy engine | Auth/action/risk checks for MVP workflows. |
| Identity | One step-up method integrated or mocked with production interface. |
| Tool gateway | Mock bank-system simulator plus one real connector path. |
| RAG | Approved documents only, metadata filtering, citations. |
| Human control | Live monitor, alerts, takeover, transfer. |
| Audit | Event ledger with call replay. |
| Evaluation | Golden tests, fraud tests, prompt-injection tests, release gates. |
| Deployment | Containerized, single-tenant capable. |
| Security | RBAC, encryption, secrets, redaction, audit logs. |

### 21.4 MVP exclusions

Exclude:

- Money movement.
- Credit decisioning.
- Investment advice.
- Fully automated collections negotiation.
- Final complaint resolution.
- New beneficiary setup.
- Open-ended general banking assistant.
- Unsupported languages in production.
- Public self-service production deployment for banks.

### 21.5 MVP success criteria

Pilot success must include both business and safety metrics.

Business:

- Reduction in live-agent minutes for selected workflows.
- Improvement in routing accuracy versus IVR baseline.
- Acceptable average handle time.
- Acceptable customer repeat-call rate.
- Supervisor satisfaction with handoff context.

Safety:

- Zero unauthorized high-risk tool execution in tests.
- Zero intentional account disclosure before required authentication in tests.
- Complaint and fraud signals detected above agreed threshold.
- Complete audit trail for pilot calls.
- Human transfer works under failure conditions.
- Rollback tested.

---

## 22. Implementation roadmap after research and specs

Do not begin this roadmap until the pre-build deliverables are complete.

### Phase 0: Research and specification

Duration: complete before coding.

Deliverables:

- Market map.
- Competitor matrix.
- Regulatory matrix.
- Banking use-case taxonomy.
- MVP definition.
- Reference architecture.
- Component specs.
- Data model.
- API contracts.
- Threat model.
- Evaluation plan.
- Pilot plan.

Gate:

- Product, architecture, risk, security, and compliance review complete.

### Phase 1: Technical spike

Goal:

- Prove voice pipeline, telephony, graph runtime, and audit event generation with mock systems.

Build:

- Minimal media gateway.
- Streaming STT/TTS.
- Declarative graph runtime.
- Simple policy engine.
- Mock tool gateway.
- Basic audit event log.
- Basic supervisor view.

Gate:

- Demo works under realistic call conditions.
- No direct LLM-to-tool execution.
- Audit trail complete for demo calls.

### Phase 2: MVP platform

Goal:

- Build pilot-ready bank workflows.

Build:

- Graph designer or graph management UI.
- Control center.
- Policy engine v1.
- Tool gateway v1.
- RAG service v1.
- Identity step-up integration.
- Evaluation harness.
- Deployment packaging.

Gate:

- MVP release gates pass.
- Pilot evidence pack generated.

### Phase 3: Bank pilot

Goal:

- Deploy selected workflows with a design partner bank or bank BPO.

Build:

- Real bank-system connector or controlled integration.
- Pilot dashboards.
- QA review process.
- Bank-specific policies.
- Pilot runbook.

Gate:

- Pilot success criteria met.
- Risk and compliance signoff for broader rollout.

### Phase 4: Enterprise hardening

Goal:

- Support larger bank deployments.

Build:

- Private cloud/customer VPC deployment.
- Multi-region resilience.
- Advanced model registry.
- Advanced fraud signal integration.
- Advanced eval lab.
- Connector marketplace.
- SOC 2/ISO evidence path.

---

## 23. GTM and product packaging

### 23.1 Recommended positioning

Do not pitch:

> Replace your call center with human-like AI.

Pitch:

> Safely automate selected banking calls with deterministic workflows, fraud-aware controls, human oversight, and full audit evidence.

### 23.2 Initial target segments

Prioritize:

- Digital banks.
- Tier-2 and regional banks.
- Credit unions/building societies.
- Card issuers.
- Bank BPO providers.
- Fintechs with regulated servicing operations.

Avoid starting with:

- Top-tier global banks with very long sales cycles unless there is a warm design partnership.
- High-risk wealth/advice workflows.
- High-risk payment initiation workflows.

### 23.3 Commercial packaging

Recommended pricing model:

```text
annual platform fee
+ deployment tier fee
+ usage fee based on safely resolved interactions or automated minutes
+ integration package
+ compliance/assurance package
+ premium support/SLA
```

Avoid pure per-minute pricing as the only model because it can reward long, inefficient calls. Banks care about safe resolution, not talk time.

### 23.4 Design partner pitch

Offer a tightly scoped pilot:

- 1 to 3 workflows.
- Limited customer segment.
- Limited call volume.
- Human fallback always available.
- Full audit and QA review.
- Clear ROI baseline.
- Clear rollback.
- Joint risk review.

### 23.5 Sales evidence

Sales material must include:

- Use-case risk taxonomy.
- Architecture diagram.
- Security controls.
- Compliance mapping.
- Evaluation report.
- Handoff demo.
- Audit replay demo.
- Fraud-safe design explanation.
- ROI model.

---

## 24. Open questions CoWork must resolve

### 24.1 Product and market

1. Which geography is first: Singapore, EU, UK, US, or another market?
2. Which bank segment is first: digital bank, regional bank, credit union, card issuer, or BPO?
3. Which contact-center platforms must be supported first?
4. Is the first wedge inbound, outbound, or both?
5. Which languages are required for the first pilot?
6. Is private deployment required for the first target segment?

### 24.2 Architecture

1. Pipecat or LiveKit Agents for the first runtime foundation?
2. Twilio, Telnyx, SIP BYOC, or CCaaS-native integration first?
3. Which model providers are allowed for prototype and pilot?
4. Should policy engine be OPA/Rego, Cedar, or custom?
5. Should event ledger be Postgres append-only, Kafka/NATS stream, or both?
6. How much graph designer UI is needed before pilot?
7. Should RAG use Postgres pgvector, OpenSearch, Elasticsearch, Vespa, or managed vector DB?
8. How will bank connectors be simulated?
9. What is the minimum viable model registry?
10. How will audit logs be made tamper-evident?

### 24.3 Risk and compliance

1. What exact data will be sent to external model providers?
2. Can bank data be used for model training? Default answer should be no.
3. How will PCI scope be minimized?
4. How will call recording consent be handled by jurisdiction?
5. What retention policies apply to transcripts and audio?
6. What is the incident process for wrong AI answers?
7. What is the exit plan if a bank terminates the service?
8. Who approves prompt, graph, model, and policy changes?

---

## 25. Required pre-build deliverables and acceptance criteria

### 25.1 Deliverable checklist

CoWork must produce these before coding:

| Deliverable | Description | Acceptance criteria |
|---|---|---|
| Market map | Competitor and category analysis. | Covers CCaaS, conversational AI, voice infra, fraud, BPO, open source. |
| Competitor matrix | Structured evidence-backed CSV. | Each claim sourced and dated. |
| Buyer persona brief | Bank buyer and approver map. | Includes contact center, risk, CISO, compliance, fraud, architecture. |
| Use-case taxonomy | Banking workflows by autonomy and risk. | Includes allow/defer/prohibit decisions. |
| Regulatory matrix | Requirements mapped to product controls. | Covers first target jurisdictions. |
| Risk register | AI, fraud, security, operational, compliance risks. | Includes mitigation and owner. |
| Reference architecture | Component architecture and diagrams. | Includes control/data plane and deployment modes. |
| Component specs | TDDs for major components. | Includes APIs, data, failure modes, controls. |
| Graph DSL spec | Graph model and compiler rules. | Includes risk metadata and validation. |
| Policy model | Policy engine design. | Includes auth/action matrix and decision schema. |
| Tool gateway spec | Safe execution model. | Includes idempotency, validation, audit, approval. |
| Data model | DB and event schemas. | Includes retention, classification, audit. |
| Threat model | Security and LLM threat model. | Includes prompt injection, fraud, deepfake, connectors. |
| Eval plan | Test suites and release gates. | Includes golden, adversarial, fraud, RAG, tool, load tests. |
| Pilot plan | Bank pilot scope and success criteria. | Includes rollback and evidence pack. |

### 25.2 Build-readiness gate

Build can begin only when:

```text
[ ] MVP workflows are selected.
[ ] Target jurisdiction is selected.
[ ] Deployment mode assumption is selected.
[ ] CCaaS/telephony integration path is selected.
[ ] Model provider assumptions are selected.
[ ] Use-case autonomy levels are approved.
[ ] Regulatory matrix is complete enough for target pilot.
[ ] Graph DSL and policy model are specified.
[ ] Tool gateway safety model is specified.
[ ] Audit event schema is specified.
[ ] Evaluation release gates are specified.
[ ] Threat model is complete.
[ ] Pilot success metrics are defined.
```

---

## 26. Detailed CoWork instructions

CoWork should proceed in this order.

### Step 1: Ingest and summarize

Read:

- The existing VocalIQ research file.
- This handoff document.
- All source links in the starter source list.

Produce:

```text
docs/00_context_summary.md
```

The summary must include:

- What the existing research already covers.
- What this handoff adds.
- What assumptions remain unresolved.
- What decisions are needed before build.

### Step 2: Build the research corpus

Create the folder structure in Section 10.

For every source:

- Save title.
- Save URL.
- Save access date.
- Save source type.
- Save summary.
- Save product implications.
- Save confidence rating.

Produce:

```text
docs/research/regulatory/source_index.md
docs/research/market/source_index.md
```

### Step 3: Produce the market map

Create:

```text
docs/research/market/market_map.md
docs/research/market/competitor_matrix.csv
```

Include:

- Vendor categories.
- Competitor deep dives.
- Banking relevance.
- Threat level.
- Partnership potential.
- Differentiation opportunities.

### Step 4: Produce banking workflow catalog

Create:

```text
docs/research/banking_workflows/use_case_taxonomy.md
docs/research/banking_workflows/workflow_catalog.csv
docs/research/banking_workflows/autonomy_matrix.md
docs/research/banking_workflows/prohibited_use_cases.md
```

Include:

- Autonomy classification.
- Required auth level.
- Required policy controls.
- Required human handoff triggers.
- Integration requirements.
- Evaluation scenarios.

### Step 5: Produce regulatory and risk matrix

Create:

```text
docs/research/regulatory/regulatory_matrix.csv
docs/research/risk/ai_risk_register.md
docs/research/risk/fraud_risk_framework.md
docs/research/risk/model_risk_framework.md
docs/research/risk/operational_resilience.md
```

Include:

- Requirement.
- Product implication.
- Technical control.
- Operational control.
- Evidence artifact.
- Owner.
- Priority.

### Step 6: Produce architecture specs

Create:

```text
docs/architecture/reference_architecture.md
docs/architecture/architecture_principles.md
docs/architecture/component_specs/media_gateway.md
docs/architecture/component_specs/speech_layer.md
docs/architecture/component_specs/conversation_runtime.md
docs/architecture/component_specs/graph_compiler.md
docs/architecture/component_specs/policy_engine.md
docs/architecture/component_specs/model_gateway.md
docs/architecture/component_specs/rag_service.md
docs/architecture/component_specs/tool_gateway.md
docs/architecture/component_specs/fraud_identity_layer.md
docs/architecture/component_specs/control_center.md
docs/architecture/component_specs/audit_ledger.md
docs/architecture/component_specs/evaluation_lab.md
```

Each component spec must include:

```text
purpose
responsibilities
non-responsibilities
inputs
outputs
APIs
data models
dependencies
failure modes
security controls
audit events
metrics
test cases
open questions
```

### Step 7: Produce API and schema contracts

Create:

```text
docs/architecture/api_contracts/runtime_api.yaml
docs/architecture/api_contracts/graph_api.yaml
docs/architecture/api_contracts/policy_api.yaml
docs/architecture/api_contracts/tool_gateway_api.yaml
docs/architecture/api_contracts/control_center_api.yaml
docs/architecture/api_contracts/audit_api.yaml
docs/architecture/data_architecture.md
```

### Step 8: Produce evaluation plan

Create:

```text
docs/evaluation/eval_strategy.md
docs/evaluation/golden_call_suite.md
docs/evaluation/adversarial_tests.md
docs/evaluation/fraud_simulations.md
docs/evaluation/rag_evaluation.md
docs/evaluation/release_gates.md
```

### Step 9: Produce MVP and pilot plan

Create:

```text
docs/product/mvp_scope.md
docs/product/roadmap.md
docs/product/pilot_plan.md
docs/product/pricing_and_gtm.md
```

### Step 10: Stop and review

After producing the above, stop. Do not code.

Produce:

```text
docs/BUILD_READINESS_REVIEW.md
```

This review must list:

- Completed deliverables.
- Open questions.
- Major risks.
- Recommended MVP scope.
- Recommended technical stack.
- Build plan.
- No-build blockers.

---

## 27. Recommended technical stack assumptions to evaluate

These are not final decisions. CoWork must evaluate them.

### 27.1 Frontend

Candidate:

- Next.js.
- React Flow for graph designer.
- Tailwind or design-system equivalent.
- WebSocket/SSE for live call monitoring.

Need to evaluate:

- Enterprise RBAC.
- Auditability of graph edits.
- Graph diff view.
- Approval workflow UX.
- Real-time supervisor UX.

### 27.2 Backend

Candidate:

- Python FastAPI for voice/runtime services.
- Optional Node.js only if frontend team needs separate BFF.
- PostgreSQL for primary relational state.
- Append-only event store using Postgres initially, Kafka/NATS/Pulsar later if needed.
- Redis only for ephemeral realtime state, not audit source of truth.

Need to evaluate:

- Whether one backend language reduces complexity.
- Workflow engine need: Temporal, Dagster-like, custom, or graph runtime only.
- Event replay and audit requirements.

### 27.3 Voice runtime

Candidates:

- Pipecat.
- LiveKit Agents.
- Custom runtime around provider SDKs.

Evaluate:

- Telephony support.
- SIP/WebRTC support.
- Barge-in support.
- Latency.
- Observability.
- Provider abstraction.
- Self-hosting.
- Community maturity.
- Fit for bank deployments.

### 27.4 STT/TTS/LLM

Candidate approach:

- Provider-agnostic abstraction.
- Cloud provider for prototype.
- Self-hosted options for private deployments.
- Bank-approved model gateway support.

Evaluate:

- Latency.
- Accuracy on phone audio.
- Language support.
- Data retention.
- Region availability.
- Cost.
- Contractual terms.
- Failover.

### 27.5 Policy engine

Candidates:

- OPA/Rego.
- Cedar.
- Custom rule engine.
- Hybrid business rule engine.

Evaluate:

- Explainability.
- Business-user maintainability.
- Versioning.
- Testability.
- Runtime latency.
- Integration with graph compiler.

### 27.6 RAG stack

Candidates:

- Postgres plus pgvector.
- OpenSearch/Elasticsearch hybrid search.
- Vespa.
- Managed vector DB.

Evaluate:

- Metadata filtering.
- ACL filtering.
- Hybrid retrieval.
- Reranking.
- Versioning.
- Tenant isolation.
- On-prem support.

---

## 28. Documentation quality bar

Every document CoWork produces must include:

- Purpose.
- Scope.
- Assumptions.
- Decisions made.
- Alternatives considered.
- Risks.
- Open questions.
- Source links.
- Last updated date.
- Owner.

Use direct language. Avoid vague statements such as "ensure compliance" or "use AI safely" without specifying actual controls.

Bad:

```text
The system should be compliant and secure.
```

Good:

```text
The system must not send full PAN, CVV, passwords, OTPs, or security secrets to LLM providers. The redaction service must run before every model gateway call, log a redaction event, and block the call if forbidden data classes remain.
```

---

## 29. Key product risks

### 29.1 Gimmick risk

Risk:

- Product becomes a nice voice demo without bank approval path.

Mitigation:

- Build around policy, audit, fraud, integration, and evaluation from day one.

### 29.2 Incumbent platform risk

Risk:

- CCaaS incumbents bundle similar AI features.

Mitigation:

- Differentiate on bank-grade governance, risk-aware graph compiler, tool gateway, fraud-aware identity, and assurance lab. Integrate with incumbents rather than only compete against them.

### 29.3 Compliance overclaim risk

Risk:

- Marketing says compliant without evidence.

Mitigation:

- Produce control matrices and evidence artifacts. Avoid legal conclusions without counsel.

### 29.4 Fraud amplification risk

Risk:

- AI agent becomes a new attack surface for account takeover or scams.

Mitigation:

- Build fraud-aware identity, action restrictions, step-up auth, safe callback, and fraud simulations.

### 29.5 LLM autonomy risk

Risk:

- LLM makes decisions or calls tools outside policy.

Mitigation:

- Enforce least agency. LLM proposes, policy decides, tool gateway executes.

### 29.6 RAG hallucination risk

Risk:

- AI gives wrong product, fee, rate, or policy information.

Mitigation:

- Approved-content-only RAG, metadata filters, citation validation, no-answer behavior, RAG evals.

### 29.7 Integration underestimation risk

Risk:

- Bank-system integration consumes most project time.

Mitigation:

- Build connector framework and bank-system simulator early.

### 29.8 Evaluation debt risk

Risk:

- Product works in demo but fails in real calls.

Mitigation:

- Make evaluation lab P0, not P2.

---

## 30. Final product principles

Use these principles to resolve tradeoffs:

1. Determinism over improvisation for regulated workflows.
2. Least agency over agentic freedom.
3. Human escalation over unsafe automation.
4. Evidence over claims.
5. Policy outside prompts.
6. Tool permissions outside LLMs.
7. Approved knowledge over open-ended answers.
8. Fraud-aware identity over voice confidence.
9. Safe resolution over deflection.
10. Integration over standalone demo.
11. Evaluation before release.
12. Bank approval path before feature breadth.

---

## 31. Starter source list

Use this list as the first set of sources for corpus building. Verify freshness and add more sources before making final decisions.

### Existing project source

- `RESEARCH.md` in the workspace: existing VocalIQ/GetVocal-style platform research and build plan.

### Market and contact center

- McKinsey, AI-powered bank customer care: https://www.mckinsey.com/industries/financial-services/our-insights/the-ai-powered-bank-rewiring-for-excellence-in-customer-care
- NICE closes acquisition of Cognigy: https://www.nice.com/press-releases/nice-closes-acquisition-of-cognigy-transforming-customer-experience-with-best-in-class-data-driven-cx-ai-platform
- Genesys AI and automation: https://www.genesys.com/capabilities/ai-and-automation
- Amazon Connect generative AI features: https://aws.amazon.com/blogs/aws/new-generative-ai-features-in-amazon-connect-including-amazon-q-facilitate-improved-contact-center-service/

### Regulatory and risk

- ESMA DORA overview: https://www.esma.europa.eu/esmas-activities/digital-finance-and-innovation/digital-operational-resilience-act-dora
- EU AI Act Annex III: https://ai-act-service-desk.ec.europa.eu/en/ai-act/annex-3
- MAS AI Model Risk Management information paper: https://www.mas.gov.sg/-/media/mas-media-library/regulation/circulars/id/id18_24/id18_24.pdf
- MAS Technology Risk Management Guidelines: https://www.mas.gov.sg/regulation/guidelines/technology-risk-management-guidelines
- Singapore PDPA: https://sso.agc.gov.sg/Act/PDPA2012
- NIST AI Risk Management Framework: https://www.nist.gov/itl/ai-risk-management-framework
- OWASP Top 10 for LLM Applications 2025: https://owasp.org/www-project-top-10-for-large-language-model-applications/assets/PDF/OWASP-Top-10-for-LLMs-v2025.pdf
- FinCEN deepfake media fraud alert: https://www.fincen.gov/sites/default/files/shared/FinCEN-Alert-DeepFakes-Alert508FINAL.pdf
- FCC TCPA and AI-generated voices: https://www.fcc.gov/document/fcc-confirms-tcpa-applies-ai-technologies-generate-human-voices
- PCI DSS v4.x resource hub: https://blog.pcisecuritystandards.org/pci-dss-v4-0-resource-hub
- PCI DSS v4.x future-dated requirements: https://blog.pcisecuritystandards.org/now-is-the-time-for-organizations-to-adopt-the-future-dated-requirements-of-pci-dss-v4-x

### Open source and voice infrastructure

- Pipecat: https://github.com/pipecat-ai/pipecat
- LiveKit Agents: https://github.com/livekit/agents
- TEN Framework: https://github.com/TEN-framework/ten-framework
- Dograh: https://github.com/dograh-hq/dograh
- Twilio Voice: https://www.twilio.com/docs/voice
- Telnyx Voice API: https://developers.telnyx.com/docs/voice

---

## 32. Final instruction to CoWork

Treat this as a regulated financial-services product from the first day of research. The correct next step is not to build a voice demo. The correct next step is to produce a research corpus, risk model, architecture specification, evaluation plan, and pilot-readiness pack detailed enough that a serious bank can review it.

The build should start only after the no-build blockers are cleared.

