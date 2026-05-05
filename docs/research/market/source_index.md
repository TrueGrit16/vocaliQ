# Market Research Source Index

**Last Updated:** 2026-05-03  
**Owner:** Chief Product Officer  
**Purpose:** Catalog all market and competitive intelligence sources used in VocalIQ research, with metadata per Section 10.2 of the handoff.  
**Scope:** Covers CCaaS incumbents, conversational AI platforms, developer-first voice AI, voice infrastructure providers, fraud/identity vendors, and open-source frameworks. Does not cover academic research, analyst paywalled reports (Gartner, Forrester), or regional/niche vendors outside the top competitive set. BPO/outsourcing firms are deferred to Step 3 deep dives.  
**Assumptions:** English-language sources only for initial research. Vendor marketing claims are treated as unverified unless independently corroborated by press, customer references, or third-party testing. Pricing claims are point-in-time and may change.  
**Decisions Made:** Sources prioritized based on the handoff's Section 6.2 competitor list. Market split into five categories (CCaaS, Conversational AI, Dev-First Voice, Voice Infra, Fraud/Identity) matching the handoff's structure. Open-source frameworks included in market index rather than a separate technical index because they compete with commercial platforms.  
**Alternatives Considered:** A single combined market + regulatory index was considered and rejected because the audiences differ (product/business team vs. compliance/legal team). An analyst-report-first approach was considered but deferred due to paywall constraints.  
**Risks:** Source staleness (vendor features change quarterly). Over-reliance on vendor self-reporting. Geographic coverage gaps in APAC and Middle East markets. Missing buyer-side perspectives (bank procurement teams, analyst evaluations). Some vendors (Kasisto, Kore.ai, PolyAI) flagged but not yet researched deeply enough.  
**Open Questions:** Should we include analyst reports (Gartner CCaaS Magic Quadrant, Forrester Wave) if accessible? How should we handle vendors that are both competitors and potential integration partners (e.g., Twilio as telephony provider AND Twilio Flex as CCaaS competitor)?

---

## MKT-001: McKinsey - The AI-Powered Bank: Rewiring for Excellence in Customer Care

- **Source URL:** https://www.mckinsey.com/industries/financial-services/our-insights/the-ai-powered-bank-rewiring-for-excellence-in-customer-care
- **Source Type:** Analyst / consultancy
- **Retrieved Date:** 2026-05-03
- **Jurisdiction:** Global
- **Summary:** McKinsey worked with a banking client to design a 60-initiative transformation roadmap featuring three gen AI use cases: virtual knowledge expert, AI training coach, and personalization engine. The program identified opportunities to cut 45% of contact center costs, with a 10% reduction realized in the first six months. Within 100 days, the bank achieved a 15% reduction in average handling time. McKinsey estimates gen AI could reduce human-serviced contacts by up to 50% in banking.
- **Product Implications:** Validates the business case for AI in banking contact centers. The 45% cost reduction and 15% AHT improvement provide benchmarks for VocalIQ's ROI model. The emphasis on three specific use cases (knowledge, coaching, personalization) rather than full autonomy aligns with our governed-automation approach.
- **Confidence:** High (primary consultancy research)
- **Counterpoint:** McKinsey figures represent best-case transformation with significant consulting support; actual bank implementations vary. Cost reduction claims may include non-AI improvements.

---

## MKT-002: NICE Acquires Cognigy for $955M

- **Source URL:** https://www.nice.com/press-releases/nice-closes-acquisition-of-cognigy-transforming-customer-experience-with-best-in-class-data-driven-cx-ai-platform
- **Source Type:** Vendor official press release
- **Retrieved Date:** 2026-05-03
- **Jurisdiction:** Global
- **Summary:** NICE closed the acquisition of Cognigy on September 8, 2025 for approximately $955M. The deal combines NICE's CXone platform with Cognigy's conversational and agentic AI. Cognigy serves 1,000+ brands including Bosch, Nestle, DHL, Lufthansa, Mercedes-Benz, and Toyota. The combined platform targets AI-first customer service delivery with automated multilingual interactions and real-time human agent assistance.
- **Product Implications:** Confirms CCaaS incumbents are aggressively acquiring conversational AI capabilities. Cognigy is no longer a standalone competitor; it's now part of NICE's CCaaS stack. This makes NICE CXone a significantly stronger incumbent threat. VocalIQ must position for integration with CCaaS platforms, not just competition against them.
- **Confidence:** High (official press release, deal closed)
- **Counterpoint:** Post-acquisition integration often takes 12-24 months. Cognigy's independent roadmap may slow under NICE governance. Banks already on NICE may wait for native integration rather than buy VocalIQ.

---

## MKT-003: Genesys Cloud CX - AI-Powered Experience Orchestration

- **Source URL:** https://www.genesys.com/capabilities/ai-and-automation
- **Source Type:** Vendor official
- **Retrieved Date:** 2026-05-03
- **Jurisdiction:** Global
- **Summary:** Genesys Cloud CX includes predictive AI, conversational AI, and generative AI capabilities. Banking references include M&T Bank (11% cost-per-call reduction, 80% fewer dropped calls), TymeBank (1-minute AHT reduction, 36% productivity increase), and Caixa (155M customers, digital transformation). Genesys secured an eight-figure ACV deal with a top-10 global bank. The platform offers predictive routing, sentiment tracking, auto-summarization, and AI-driven next-best-offer suggestions.
- **Product Implications:** Genesys is the largest independent CCaaS vendor and already sells deeply into banking. Their banking references are strong. VocalIQ cannot realistically displace Genesys from existing bank deployments. The strategy should be to integrate alongside Genesys as a specialized AI layer for regulated workflows, or to target banks not yet on a modern CCaaS platform.
- **Confidence:** High (vendor marketing + press releases with named customers)
- **Counterpoint:** Vendor-reported metrics may cherry-pick best outcomes. Genesys AI features may not yet handle the regulated workflow governance VocalIQ targets.

---

## MKT-004: Amazon Connect - Generative AI Features

- **Source URL:** https://aws.amazon.com/blogs/contact-center/amazon-connect-at-reinvent-2025-creating-the-future-of-customer-experience-with-ai/
- **Source Type:** Vendor official
- **Retrieved Date:** 2026-05-03
- **Jurisdiction:** Global (AWS regions)
- **Summary:** At re:Invent 2025, Amazon Connect announced 29 agentic AI features including pre-built autonomous AI agents, MCP support, real-time human agent assistance, and AI agent observability/testing tools. The platform offers all-you-can-eat AI pricing (no per-AI-feature charges), self-service in 25+ languages, and gen AI post-contact summaries. AWS is offering up to $50K MDF for Amazon Connect implementations launching January 2026.
- **Product Implications:** Amazon Connect is a serious cloud-native threat, especially for banks already on AWS. The all-you-can-eat pricing model undercuts per-minute competitors. MCP support and AI testing tools show Amazon is building toward agent governance. VocalIQ's advantage is banking-specific governance (risk-aware graph, fraud-aware identity, policy engine) which Amazon Connect doesn't specialize in. Banks on AWS may still need VocalIQ's regulated workflow layer.
- **Confidence:** High (official AWS blog and re:Invent announcements)
- **Counterpoint:** Amazon Connect's banking-specific compliance features are less mature than specialized platforms. Some banks avoid AWS concentration risk.

---

## MKT-005: GetVocal.ai - Platform and Funding

- **Source URL:** https://www.getvocal.ai/ | https://www.cmswire.com/customer-experience/getvocal-raises-26m-series-a-to-scale-governed-ai-agents/
- **Source Type:** Vendor official + press
- **Retrieved Date:** 2026-05-03
- **Jurisdiction:** Europe (Paris HQ)
- **Summary:** GetVocal is a Paris-based startup ($30M total raised, $26M Series A led by Creandum) with a 60-person team. Core product includes graph-based Agent Blueprints, a Control Center for hybrid human-AI operations (launched March 2026), and a Hybrid Workforce Platform. Customers include Vodafone, Glovo, Movistar, and a Deutsche Telekom pilot. Published metrics: 31% fewer escalations, 45% more self-service resolutions, 70% deflection within 3 months. Supports GDPR, SOC 2, HIPAA, and EU AI Act alignment. Offers on-prem, private cloud, EU-sovereign, and hybrid deployment.
- **Product Implications:** GetVocal is the closest product-level inspiration for VocalIQ. Their graph-based deterministic + LLM hybrid approach aligns with our architecture. Their EU-first, compliance-forward positioning validates the governed-automation thesis. Key gaps: no banking-specific governance (fraud-aware identity, policy engine for financial workflows), no published banking customer references, no PCI-specific controls. VocalIQ's differentiation is banking depth.
- **Confidence:** High (vendor site + multiple press sources)
- **Counterpoint:** GetVocal's 60-person team and $30M in capital means they can move fast. If they pivot toward financial services, they become a direct competitor with a head start on the platform layer.

---

## MKT-006: Retell AI - Voice Agent Platform

- **Source URL:** https://www.retellai.com/ | https://www.retellai.com/blog/best-voice-ai-agent-platforms
- **Source Type:** Vendor official + vendor blog
- **Retrieved Date:** 2026-05-03
- **Jurisdiction:** US (global deployment)
- **Summary:** Retell AI is a full-stack voice agent platform at $0.07/min with ~600ms response time and 99.99% uptime. It offers no-code and API flexibility, self-service HIPAA BAA portal, SOC 2 Type II and GDPR compliance. Supports going from signup to live agent within one day using pre-built templates.
- **Product Implications:** Retell represents the price-performance benchmark for developer-friendly voice agents. Their HIPAA self-service BAA is notable; no other platform offers this without enterprise negotiation. For VocalIQ, Retell is not a direct competitor (they lack banking-grade governance) but they set market expectations on latency, uptime, and pricing.
- **Confidence:** Medium-High (vendor claims, some independent testing)
- **Counterpoint:** $0.07/min may not be sustainable or may not include all provider costs. HIPAA compliance doesn't equal banking regulatory compliance.

---

## MKT-007: Vapi - Developer-First Voice AI

- **Source URL:** https://vapi.ai/
- **Source Type:** Vendor official
- **Retrieved Date:** 2026-05-03
- **Jurisdiction:** US (global)
- **Summary:** Vapi is a developer-first platform with 4,200+ configuration points, BYO model support, and modular bring-your-own-stack control. Pricing ranges $0.15-0.33/min depending on stack configuration. Typically requires 3-7 days for production agent setup. Strong developer community and extensive API documentation.
- **Product Implications:** Vapi represents the most flexible developer-first approach. Their modular architecture is instructive for VocalIQ's provider-abstraction layer. However, flexibility comes at the cost of governance; Vapi has no built-in policy engine, compliance controls, or regulated workflow support.
- **Confidence:** Medium-High (vendor marketing + developer community feedback)
- **Counterpoint:** Developer-first platforms can add governance features; Vapi's modularity makes this relatively straightforward.

---

## MKT-008: Pindrop - Voice Fraud Detection

- **Source URL:** https://www.pindrop.com/ | https://www.pindrop.com/research/report/voice-intelligence-security-report/
- **Source Type:** Vendor official + research report
- **Retrieved Date:** 2026-05-03
- **Jurisdiction:** Global (US HQ)
- **Summary:** Pindrop's 2025 Voice Intelligence & Security Report reveals a 1,300% surge in deepfake fraud. Fraud in contact centers is at a six-year high, occurring every 46 seconds in US centers. Synthetic voice attacks rose 149% at banks, 475% in insurance, 107% in retail. Pindrop examines acoustic features, device metadata, and behavioral analysis to detect fake voices. Named to TIME's 2026 list of most influential software companies alongside Microsoft, Adobe, and Figma. Partnership with Zoom Contact Center for voice authentication (Pindrop Passport) and risk analysis (Pindrop Protect).
- **Product Implications:** Pindrop is not a competitor but a critical integration partner or design reference. VocalIQ's fraud-aware identity layer must account for synthetic voice/deepfake attacks. Pindrop's data validates the handoff's emphasis on fraud controls. Integration with Pindrop or similar voice security vendors should be part of the tool gateway design. The 149% increase in banking deepfake attacks makes this a non-negotiable feature area.
- **Confidence:** High (primary vendor research report with quantified data)
- **Counterpoint:** Pindrop's detection rates and false-positive rates are not publicly detailed. Voice biometrics should be treated as risk signals, not absolute identity decisions (per handoff guidance).

---

## MKT-009: Pipecat Open-Source Framework

- **Source URL:** https://github.com/pipecat-ai/pipecat
- **Source Type:** Open-source project
- **Retrieved Date:** 2026-05-03
- **Jurisdiction:** N/A (open source)
- **Summary:** Pipecat is an open-source Python framework by Daily.co for building real-time voice and multimodal conversational agents. Frame-based pipeline architecture with automatic interruption handling. Supports Twilio/SIP telephony, multi-agent subagent systems, and client SDKs for JavaScript, React, React Native, Swift, Kotlin, C++, and ESP32. Active community and examples repository.
- **Product Implications:** Strong candidate for VocalIQ's voice pipeline foundation. Frame-based architecture maps well to the handoff's layered controller design. Twilio/SIP support covers telephony requirements. Multi-agent support useful for complex banking workflows. Key evaluation criteria: latency under telephony conditions, observability hooks, and ease of adding custom pipeline stages (for policy checks, redaction, audit events).
- **Confidence:** High (open-source code, active development)
- **Counterpoint:** Pipecat is optimized for general voice agents, not banking. Custom stages for policy, fraud, and audit must be built on top.

---

## MKT-010: LiveKit Agents Framework

- **Source URL:** https://github.com/livekit/agents
- **Source Type:** Open-source project
- **Retrieved Date:** 2026-05-03
- **Jurisdiction:** N/A (open source, company is US-based)
- **Summary:** LiveKit Agents is an open-source framework for building realtime voice AI agents. Native WebRTC infrastructure with built-in SIP telephony (phone numbers, DTMF, call transfers, secure trunking, HD voice, region pinning, noise cancellation). Semantic turn detection using transformer models. Native MCP (Model Context Protocol) support. Built-in test framework with AI judges. Available in Python and Go.
- **Product Implications:** Strong alternative to Pipecat for VocalIQ's voice pipeline. WebRTC-native architecture may provide lower latency than WebSocket-based approaches. Built-in test framework aligns with the handoff's emphasis on evaluation. SIP telephony features (region pinning, secure trunking, HD voice) are directly relevant for bank deployments. Semantic turn detection is more sophisticated than silence-based endpointing.
- **Confidence:** High (open-source code, well-funded company, active development)
- **Counterpoint:** LiveKit's commercial model may create dependency concerns for on-prem bank deployments. Need to evaluate self-hosting story carefully.

---

## MKT-011: Dograh - Open-Source Visual Voice AI Builder

- **Source URL:** https://github.com/dograh-hq/dograh | https://www.dograh.com/
- **Source Type:** Open-source project + vendor
- **Retrieved Date:** 2026-05-03
- **Jurisdiction:** N/A (open source)
- **Summary:** Dograh positions itself as "the n8n of voice AI" and the open-source alternative to Vapi. Features include a visual drag-and-drop workflow builder, Twilio/Vonage/Cloudonix telephony, voicemail detection, call transfer, variable extraction, knowledge base support, CRM connectors, post-call analytics (sentiment, script adherence, miscommunication detection), and AI-to-AI testing (LoopTalk). Fully self-hostable with BYO API keys for LLM/STT/TTS.
- **Product Implications:** Dograh's visual workflow builder is the closest open-source reference for VocalIQ's graph designer UI. The AI-to-AI testing feature (LoopTalk) directly maps to the handoff's Evaluation/Assurance Lab requirement. Post-call analytics features (script adherence scoring, miscommunication detection) align with banking QA needs. Potential code reference or integration point for the graph designer and evaluation lab.
- **Confidence:** Medium (newer project, smaller community)
- **Counterpoint:** Dograh lacks banking-specific governance, policy engine, fraud controls, and audit capabilities. The visual builder is useful reference but would need significant extension for regulated workflows.

---

## MKT-012: Kasisto - Banking-Specific Conversational AI

- **Source URL:** https://kasisto.com/ (referenced in handoff Section 6.2)
- **Source Type:** Vendor (not yet deeply researched)
- **Retrieved Date:** 2026-05-03
- **Jurisdiction:** US (global banking clients)
- **Summary:** Kasisto is listed in the handoff as a banking-specific conversational AI platform to research. Known for KAI, a digital experience platform purpose-built for financial institutions. Used by banks including JP Morgan, TD Bank, and Standard Chartered.
- **Product Implications:** Kasisto is the most direct banking-focused conversational AI competitor. Deep research required in Step 3 to understand their governance, compliance, and deployment model. Their banking-specific training data and workflow libraries represent a significant moat.
- **Confidence:** Low (minimal research completed; flagged for deep dive)
- **Counterpoint:** Kasisto may be primarily text/chat focused rather than voice-first.

---

## MKT-013: Kore.ai - Enterprise Conversational AI

- **Source URL:** https://kore.ai/ (referenced in handoff Section 6.2)
- **Source Type:** Vendor (not yet deeply researched)
- **Retrieved Date:** 2026-05-03
- **Jurisdiction:** US (global)
- **Summary:** Kore.ai is listed in the handoff as an enterprise conversational AI platform already selling into banks. Known for the XO Platform supporting voice and chat with banking-trained virtual assistants.
- **Product Implications:** Requires deep research in Step 3. If Kore.ai has banking-grade governance, compliance evidence, and regulatory workflow support, they are a direct threat.
- **Confidence:** Low (minimal research completed; flagged for deep dive)
- **Counterpoint:** N/A pending research.

---

## Sources Pending Deep Research (Step 3)

The following are cataloged from the handoff's competitor list but require full analysis:

| ID | Company | Category | Priority |
|----|---------|----------|----------|
| MKT-014 | NICE CXone | CCaaS Incumbent | High |
| MKT-015 | Five9 | CCaaS Incumbent | Medium |
| MKT-016 | Cisco Webex Contact Center | CCaaS Incumbent | Medium |
| MKT-017 | Avaya | CCaaS Incumbent | Low |
| MKT-018 | Talkdesk | CCaaS Incumbent | Medium |
| MKT-019 | Twilio Flex | CCaaS / Dev Platform | High |
| MKT-020 | PolyAI | Conversational AI | High |
| MKT-021 | Rasa | Conversational AI (OSS) | Medium |
| MKT-022 | Microsoft/Nuance | Conversational AI | High |
| MKT-023 | Omilia | Conversational AI | Medium |
| MKT-024 | Boost.ai | Conversational AI | Low |
| MKT-025 | Avaamo | Conversational AI | Low |
| MKT-026 | Amelia (IPsoft) | Conversational AI | Medium |
| MKT-027 | Bland AI | Dev-First Voice | Medium |
| MKT-028 | Synthflow | Dev-First Voice | Low |
| MKT-029 | ElevenLabs | Voice Infra | Medium |
| MKT-030 | Cartesia | Voice Infra | Medium |
| MKT-031 | Deepgram | Voice Infra | High |
| MKT-032 | AssemblyAI | Voice Infra | Medium |
| MKT-033 | Speechmatics | Voice Infra | Medium |
| MKT-034 | Nuance Gatekeeper | Fraud/Identity | High |
| MKT-035 | BioCatch | Fraud/Identity | Medium |
| MKT-036 | NICE Actimize | Fraud/Identity | Medium |
| MKT-037 | Feedzai | Fraud/Identity | Medium |
| MKT-038 | Featurespace | Fraud/Identity | Medium |
