# Regulatory Research Source Index

**Last Updated:** 2026-05-03  
**Owner:** Chief Product Officer  
**Purpose:** Catalog all regulatory, compliance, and risk framework sources used in VocalIQ research, with metadata per Section 10.2 of the handoff.  
**Scope:** Covers regulations and standards relevant to deploying AI voice agents in banking contact centers across Singapore, EU, UK, and US (primary jurisdictions). Australia, India, and UAE are deferred to Step 5. Covers data protection, AI governance, operational resilience, fraud/financial crime, consumer protection, payment data security, and outbound call consent. Does not provide legal conclusions; all entries identify requirements and flag legal review needs.  
**Assumptions:** VocalIQ will be classified as an ICT third-party service provider to banks under most regulatory frameworks. AI voice interactions will be subject to call recording consent requirements. Any credit-related workflow would trigger EU AI Act high-risk classification. PCI scope can be minimized by design (secure DTMF isolation, redaction before model calls).  
**Decisions Made:** Prioritized Singapore, EU, UK, US per handoff Section 9.2. Used official regulator sources as primary; industry commentary as secondary interpretation only. Each entry now distinguishes "Legal Obligations" from "Product Best Practices" per Section 10.3 requirement.  
**Alternatives Considered:** A jurisdiction-first organization (one file per country) was considered; rejected in favor of a single index for cross-referencing, with jurisdiction-specific deep-dive files to be created in Step 5.  
**Risks:** Regulatory landscape is fast-moving (EU AI Act implementation, MAS AIRG consultation). Source staleness risk is high. Legal interpretation of voice AI under existing regulations is still evolving in most jurisdictions. Regulatory guidance may not explicitly address AI voice agent scenarios, requiring analogical interpretation.  
**Open Questions:** Should VocalIQ's RAG service fall under "automated decision-making" provisions of GDPR Article 22? How will PCI DSS scope be assessed for AI voice agents that never handle card data directly but exist in the same call flow? Will MAS AIRG final guidelines differ materially from the consultation draft?  
**Legal Review Required:** Yes, for all product compliance claims derived from these sources.

**Note on Requirement Classification:** Each regulatory entry below separates product implications into "Legal Obligations" (mandatory compliance requirements) and "Product Best Practices" (design choices that exceed the legal minimum but improve bank confidence and sales positioning). This follows Section 10.3 of the handoff.

---

## REG-001: EU AI Act - Annex III High-Risk AI Systems

- **Source URL:** https://artificialintelligenceact.eu/annex/3/
- **Source Type:** Regulator official (EU legislation)
- **Retrieved Date:** 2026-05-03
- **Jurisdiction:** EU
- **Risk Domains:** AI governance, model risk, consumer protection
- **Summary:** Annex III designates specific financial use cases as high-risk: credit scoring and creditworthiness assessment of natural persons, and insurance pricing/risk assessment for life and health insurance. Classification is use-case-based, not model-architecture-based. A simple logistic regression for credit scoring is high-risk. Fraud detection AI is explicitly exempted from the creditworthiness classification. Compliance deadline: August 2026 (the EU Digital Omnibus package proposed postponement to December 2027, but this is not confirmed).
- **Legal Obligations:** If VocalIQ deploys any AI use case falling under Annex III (e.g., credit scoring, creditworthiness assessment), it must meet EU AI Act high-risk requirements: risk management system, data governance, technical documentation, record-keeping, transparency to users, human oversight measures, accuracy/robustness/cybersecurity standards. Compliance deadline: August 2026 (potentially December 2027 if Digital Omnibus passes).
- **Product Best Practices:** Classify all VocalIQ AI use cases against Annex III proactively, even if current scope (contact center servicing) likely falls below high-risk. Build the model registry and evaluation lab to produce EU AI Act-compatible evidence from day one, even for non-high-risk use cases. This positions VocalIQ for future credit-adjacent workflows and strengthens the bank sales pitch.
- **Confidence:** High (primary legislation)
- **Counterpoint:** The Digital Omnibus may extend deadlines. The exact scope of "creditworthiness assessment" in a contact center context (vs. lending origination) is subject to interpretation. Legal review required.
- **Legal Review Required:** Yes

---

## REG-002: DORA - Digital Operational Resilience Act

- **Source URL:** https://www.esma.europa.eu/esmas-activities/digital-finance-and-innovation/digital-operational-resilience-act-dora
- **Source Type:** Regulator official (EU regulation via ESMA)
- **Retrieved Date:** 2026-05-03
- **Jurisdiction:** EU
- **Risk Domains:** Operational resilience, ICT third-party risk, incident reporting, cybersecurity
- **Summary:** DORA entered application on January 17, 2025 with no transitional regime. It requires financial entities to maintain ICT risk management frameworks, report major disruptions within 24 hours, maintain a Register of Information (RoI) for ICT third-party providers, and conduct regular resilience testing including threat-led penetration testing for high-impact organizations. Penalties can reach 2% of annual worldwide turnover.
- **Legal Obligations:** As an ICT third-party provider, VocalIQ must enable banks to comply with DORA. This means: providing subprocessor lists and ICT dependency documentation for the bank's Register of Information (RoI), supporting incident reporting within 24-hour timelines, cooperating with resilience testing (including TLPT for designated institutions), maintaining exit plans, and documenting business continuity and disaster recovery capabilities. These are mandatory for EU bank deployments.
- **Product Best Practices:** Build operational resilience features beyond the legal minimum: automated provider outage detection and failover, degraded-mode operation (e.g., fallback to IVR if AI pipeline fails), real-time ICT dependency health dashboards, and pre-built DORA evidence export templates. These accelerate bank procurement and reduce the burden on the bank's own DORA compliance team.
- **Confidence:** High (regulation in force)
- **Counterpoint:** DORA's third-party oversight regime is still being operationalized across the EU. Enforcement maturity varies by member state.
- **Legal Review Required:** Yes

---

## REG-003: MAS AI Risk Management Guidelines (AIRG)

- **Source URL:** https://www.mas.gov.sg/news/media-releases/2025/mas-guidelines-for-artificial-intelligence-risk-management
- **Source Type:** Regulator official (Singapore MAS)
- **Retrieved Date:** 2026-05-03
- **Jurisdiction:** Singapore
- **Risk Domains:** AI governance, model risk, fairness, transparency, human oversight, third-party AI management
- **Summary:** MAS issued a consultation paper in November 2025 proposing principles-based, risk-proportionate guidelines for AI risk management in financial institutions. Scope covers all AI technologies including generative AI and agentic systems. Key requirements: board-level AI oversight, three lines of defense model, comprehensive AI inventory, proportionate controls across the AI life cycle (data management, fairness, transparency/explainability, human oversight), and third-party AI management. Consultation closes January 31, 2026. Proposed 12-month transition period from issuance.
- **Legal Obligations:** Once finalized (expected H1 2026 + 12-month transition), Singapore-regulated FIs must maintain AI inventories, implement proportionate life-cycle controls (data management, fairness, transparency, human oversight), and manage third-party AI providers. VocalIQ must enable banks to meet these obligations: model inventory support, explainability outputs, human oversight capabilities, and third-party AI documentation.
- **Product Best Practices:** Pre-build MAS AIRG-compatible evidence templates (model cards, AI inventory exports, human oversight audit trails) before the guidelines are finalized. This positions VocalIQ as compliance-ready for Singapore banks during the transition period and creates a first-mover advantage.
- **Confidence:** High (official MAS consultation paper)
- **Counterpoint:** Guidelines are in consultation; final version may differ. The 12-month transition period means enforcement likely starts H2 2027 at earliest.
- **Legal Review Required:** Yes

---

## REG-004: MAS Technology Risk Management Guidelines

- **Source URL:** https://www.mas.gov.sg/regulation/guidelines/technology-risk-management-guidelines
- **Source Type:** Regulator official (Singapore MAS)
- **Retrieved Date:** 2026-05-03
- **Jurisdiction:** Singapore
- **Risk Domains:** Cybersecurity, technology risk, outsourcing, data protection
- **Summary:** The TRM Guidelines set out risk management principles and best practices for technology risk management in financial institutions in Singapore. They cover IT governance, technology risk management framework, IT project management, software application development and management, IT service management, cybersecurity management, online financial services, and technology innovations.
- **Product Implications:** VocalIQ's development process, deployment architecture, and operational procedures must align with TRM Guidelines. This includes secure software development practices, change management, incident response, access controls, encryption standards, and cybersecurity monitoring. The platform must enable banks to demonstrate TRM compliance for their VocalIQ deployment.
- **Confidence:** High (established guidelines in force)
- **Counterpoint:** TRM Guidelines are broad technology risk management standards, not AI-specific. The newer AIRG guidelines (REG-003) provide AI-specific supplements.
- **Legal Review Required:** Yes

---

## REG-005: Singapore PDPA

- **Source URL:** https://sso.agc.gov.sg/Act/PDPA2012
- **Source Type:** Regulator official (Singapore legislation)
- **Retrieved Date:** 2026-05-03
- **Jurisdiction:** Singapore
- **Risk Domains:** Data protection, privacy, consent, cross-border transfers
- **Summary:** The Personal Data Protection Act 2012 governs the collection, use, disclosure, and care of personal data in Singapore. Relevant provisions include consent requirements for data collection, purpose limitation, data minimization, access and correction rights, data breach notification, and cross-border transfer restrictions.
- **Legal Obligations:** Consent for collection and processing of personal data (including voice recordings and transcripts). Purpose limitation on how customer data is used. Cross-border data transfer controls if processing occurs outside Singapore. Data breach notification. Customer access and correction rights. Retention and deletion obligations.
- **Product Best Practices:** Implement consent management UI in the graph designer (recording-notice nodes). Build redaction pipeline to minimize personal data exposure to model providers beyond what PDPA strictly requires. Provide data residency controls as a configurable deployment option. Support customer data deletion requests through audit-safe processes.
- **Confidence:** High (primary legislation)
- **Counterpoint:** PDPA interpretation in the context of AI-processed voice data is still evolving.
- **Legal Review Required:** Yes

---

## REG-006: NIST AI Risk Management Framework

- **Source URL:** https://www.nist.gov/itl/ai-risk-management-framework
- **Source Type:** Standards body (US NIST)
- **Retrieved Date:** 2026-05-03
- **Jurisdiction:** US / Global reference
- **Risk Domains:** AI governance, risk management, trustworthiness
- **Summary:** The NIST AI RMF provides a voluntary framework for managing AI risks. Organized around four core functions: Govern, Map, Measure, Manage. The framework emphasizes trustworthiness characteristics including validity, reliability, safety, security, accountability, transparency, explainability, privacy, and fairness. The Generative AI Profile (NIST AI 600-1) extends the framework to address generative AI-specific risks including confabulation, data privacy, environmental impact, and information integrity.
- **Product Implications:** NIST AI RMF serves as a cross-jurisdictional reference framework for VocalIQ's AI governance model. The four-function structure (Govern, Map, Measure, Manage) can organize VocalIQ's model risk management approach. The Generative AI Profile provides specific risk categories relevant to LLM use in the conversation runtime and RAG service. Banks using NIST as their AI governance reference will expect VocalIQ to map controls to NIST functions.
- **Confidence:** High (authoritative standards body)
- **Counterpoint:** NIST AI RMF is voluntary, not regulatory. Some banks may use different governance frameworks.
- **Legal Review Required:** No (framework, not regulation)

---

## REG-007: OWASP Top 10 for LLM Applications 2025

- **Source URL:** https://owasp.org/www-project-top-10-for-large-language-model-applications/assets/PDF/OWASP-Top-10-for-LLMs-v2025.pdf
- **Source Type:** Industry standards body
- **Retrieved Date:** 2026-05-03
- **Jurisdiction:** Global
- **Risk Domains:** LLM security, prompt injection, information disclosure, model supply chain
- **Summary:** The OWASP Top 10 for LLM Applications identifies the most critical security risks for applications using large language models. Key risks include prompt injection, sensitive information disclosure, supply chain vulnerabilities, data and model poisoning, improper output handling, excessive agency, system prompt leakage, vector and embedding weaknesses, misinformation, and unbounded consumption.
- **Product Implications:** Every risk in the OWASP LLM Top 10 is directly relevant to VocalIQ. Prompt injection (from caller speech) maps to the handoff's threat model. Sensitive information disclosure maps to the pre-auth disclosure controls. Excessive agency maps to the "least agency" principle and tool gateway design. Supply chain vulnerabilities map to the model gateway and provider abstraction. The OWASP Top 10 should be used as a checklist for the threat model (Step 5) and adversarial test suite (Step 8).
- **Confidence:** High (widely adopted industry standard)
- **Counterpoint:** LLM Top 10 is generic, not banking-specific. Banking-specific threats (deepfake fraud, authorized push payment scams, regulatory disclosure violations) must be added.
- **Legal Review Required:** No (industry standard, not regulation)

---

## REG-008: FinCEN Deepfake Media Fraud Alert

- **Source URL:** https://www.fincen.gov/sites/default/files/shared/FinCEN-Alert-DeepFakes-Alert508FINAL.pdf
- **Source Type:** Regulator official (US FinCEN)
- **Retrieved Date:** 2026-05-03
- **Jurisdiction:** US
- **Risk Domains:** Fraud, financial crime, deepfake detection, identity
- **Summary:** FinCEN issued an alert to financial institutions about the increasing use of deepfake media in fraud schemes targeting financial institutions. The alert describes red flags for identifying deepfake-related fraud including synthetic identity creation, account takeover using synthetic voice, and manipulation of identification documents.
- **Product Implications:** VocalIQ's fraud-aware identity layer must account for deepfake voice attacks. The FinCEN red flags should inform the scam/coercion detection taxonomy and the fraud escalation triggers in the Policy Engine. Banks using VocalIQ will expect alignment with FinCEN guidance for suspicious activity monitoring. The evaluation lab must include deepfake/synthetic voice test scenarios.
- **Confidence:** High (official US regulator alert)
- **Counterpoint:** FinCEN guidance is US-specific. Other jurisdictions may have different deepfake-related guidance.
- **Legal Review Required:** Yes (for BSA/AML implications)

---

## REG-009: FCC - TCPA Applies to AI-Generated Voices

- **Source URL:** https://www.fcc.gov/document/fcc-confirms-tcpa-applies-ai-technologies-generate-human-voices
- **Source Type:** Regulator official (US FCC)
- **Retrieved Date:** 2026-05-03
- **Jurisdiction:** US
- **Risk Domains:** Outbound calls, consent, AI-generated voice, telemarketing
- **Summary:** The FCC confirmed that the Telephone Consumer Protection Act (TCPA) applies to AI technologies that generate human voices. AI-generated voice calls are considered "artificial" under the TCPA, meaning they require prior express consent for outbound calls and are subject to the same restrictions as robocalls.
- **Product Implications:** Any outbound calling feature in VocalIQ must comply with TCPA requirements: prior express consent, opt-out mechanisms, DNC list compliance, and calling window restrictions. The platform must enforce consent verification before outbound AI voice calls. This is a strong reason to start with inbound-only in the MVP (as the handoff recommends).
- **Confidence:** High (official FCC ruling)
- **Counterpoint:** TCPA enforcement landscape is complex with ongoing litigation. State-level laws may add requirements.
- **Legal Review Required:** Yes

---

## REG-010: PCI DSS v4.x

- **Source URL:** https://blog.pcisecuritystandards.org/pci-dss-v4-0-resource-hub
- **Source Type:** Industry standards body (PCI SSC)
- **Retrieved Date:** 2026-05-03
- **Jurisdiction:** Global (card brand requirement)
- **Risk Domains:** Payment card data security, cardholder data protection
- **Summary:** PCI DSS v4.0 and subsequent v4.x updates set security standards for organizations that store, process, or transmit cardholder data. Future-dated requirements became mandatory in 2025. Key areas: encrypted transmission of cardholder data, access controls, logging and monitoring, vulnerability management, network segmentation, and strong cryptography.
- **Legal Obligations:** If VocalIQ processes, stores, or transmits cardholder data, PCI DSS v4.x compliance is mandatory. Encrypted transmission, access controls, logging, vulnerability management, and network segmentation requirements apply. Future-dated requirements are now mandatory (as of 2025).
- **Product Best Practices:** Design the architecture to minimize PCI scope entirely. The AI runtime should never receive PAN, CVV, or sensitive authentication data. The media gateway should route secure DTMF capture through an isolated path that bypasses the AI pipeline. The redaction pipeline should strip any cardholder data before model calls as a defense-in-depth measure. Produce a PCI scope statement documenting that VocalIQ's AI components are out of PCI scope by design. This dramatically simplifies bank procurement.
- **Confidence:** High (mandatory industry standard)
- **Counterpoint:** PCI scope for voice AI is a developing area. Self-assessment vs. third-party assessment depends on transaction volume and bank requirements.
- **Legal Review Required:** Yes (for scope determination)

---

## REG-011: FCA Consumer Duty (UK)

- **Source URL:** https://www.fca.org.uk/firms/consumer-duty
- **Source Type:** Regulator official (UK FCA)
- **Retrieved Date:** 2026-05-03
- **Jurisdiction:** UK
- **Risk Domains:** Consumer protection, conduct risk, vulnerable customers, complaints
- **Summary:** The FCA Consumer Duty requires firms to act to deliver good outcomes for retail customers. It sets higher expectations for consumer protection with an emphasis on good outcomes in four areas: products and services, price and value, consumer understanding, and consumer support. The duty includes specific guidance on fair treatment of vulnerable customers.
- **Product Implications:** VocalIQ's Policy Engine must include consumer protection triggers aligned with FCA Consumer Duty. The conversation runtime must detect vulnerability signals (distress, confusion, bereavement, financial hardship) and route to appropriate handling. Complaint detection must be robust. The AI agent must not provide misleading product information or obscure fees/terms. The evaluation lab must test for consumer outcome compliance.
- **Confidence:** High (regulation in force since July 2023)
- **Counterpoint:** Consumer Duty is UK-specific. Other jurisdictions have comparable but different consumer protection frameworks.
- **Legal Review Required:** Yes

---

## REG-012: FCA Vulnerable Customers Guidance (UK)

- **Source URL:** https://www.fca.org.uk/publications/finalised-guidance/guidance-firms-fair-treatment-vulnerable-customers
- **Source Type:** Regulator official (UK FCA)
- **Retrieved Date:** 2026-05-03
- **Jurisdiction:** UK
- **Risk Domains:** Consumer protection, vulnerable customer treatment, conduct risk
- **Summary:** FCA guidance on the fair treatment of vulnerable customers. Vulnerability drivers include health conditions, life events (bereavement, job loss), resilience (low financial resilience, debt), and capability (low literacy, language barriers). Firms must understand the nature and scale of vulnerability among their customers, ensure skills and capabilities of staff to recognize and respond to vulnerability, respond to customer needs throughout product design and customer service, and monitor and evaluate whether vulnerable customers are receiving good outcomes.
- **Product Implications:** VocalIQ must detect vulnerability signals in voice interactions: emotional distress, confusion, mentions of bereavement or hardship, difficulty understanding information, and language barriers. These signals must trigger appropriate responses (slower pace, simpler language, human handoff, specialist queue routing). The handoff explicitly lists vulnerable-customer detection as an escalation trigger in the Human Control Center. The evaluation lab must include vulnerability detection test scenarios.
- **Confidence:** High (established FCA guidance)
- **Counterpoint:** Vulnerability detection by AI is imperfect. False negatives (missing genuine vulnerability) and false positives (unnecessary escalation) both carry risk. Human fallback is essential.
- **Legal Review Required:** Yes

---

## Sources Pending Deep Research (Step 5)

| ID | Source | Jurisdiction | Priority |
|----|--------|-------------|----------|
| REG-013 | EBA outsourcing and ICT risk materials | EU | High |
| REG-014 | EDPB GDPR guidance (voice data, automated decision-making) | EU | High |
| REG-015 | OCC Model Risk Management (SR 11-7 / OCC 2011-12) | US | High |
| REG-016 | CFPB UDAAP and consumer complaint materials | US | Medium |
| REG-017 | GLBA Safeguards Rule | US | Medium |
| REG-018 | PRA outsourcing and third-party risk | UK | Medium |
| REG-019 | ICO data protection guidance (voice recordings) | UK | Medium |
| REG-020 | ISO/IEC 27001 and 27002 | Global | Medium |
| REG-021 | ISO/IEC 42001 AI management system | Global | Medium |
| REG-022 | SOC 2 Trust Services Criteria | Global | Medium |
| REG-023 | MAS FEAT principles and Veritas | Singapore | Medium |
| REG-024 | Australia APRA CPS 234 / CPS 230 | Australia | Low |
| REG-025 | India RBI IT governance and outsourcing | India | Low |
| REG-026 | UAE CBUAE / ADGM AI frameworks | UAE | Low |
