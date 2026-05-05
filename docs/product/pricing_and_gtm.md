# Pricing and Go-to-Market Strategy

**Document ID:** DOC_PROD_GTM_001  
**Last Updated:** 2026-05-04  
**Owner:** Chief Product Officer

**Version History:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-04 | Initial specification |

**Principles Referenced:** S1 (Human cannot be harmed by AI action), E7 (Document decisions), G7 (Prohibited actions cannot be unlocked)

**Scope:** Defines VocalIQ's commercial packaging, pricing model, go-to-market strategy, target segments, sales evidence requirements, and design partner pitch structure. This document bridges the product and commercial worlds: it translates the technical architecture into a buying proposition that resonates with bank decision-makers.

**Assumptions:** The initial market is English-speaking jurisdictions (UK, Singapore, potentially US). The initial sales motion is direct, relationship-driven selling to design partners, not self-serve or PLG. Pricing is informed by competitor benchmarks but differentiated by VocalIQ's governance and audit capabilities.

**Decisions Made:** Pricing is based on "safely resolved interactions" rather than per-minute billing. This aligns VocalIQ's incentives with the bank's: we get paid when calls are resolved safely, not when calls are long. The design partner model is used for the first 2-3 deployments to build the evidence base before scaling sales.

**Alternatives Considered:** Considered per-minute pricing (rejected: rewards long, inefficient calls and misaligns incentives with safe resolution). Considered free tier or freemium (rejected: banking deployments require enterprise-grade support and the buyer has budget). Considered per-seat pricing (rejected: doesn't reflect value delivered and is hard to define for AI agents). Considered pure platform licensing without usage component (rejected: banks want variable cost alignment with call volume).

**Risks:** Pricing too high delays design partner acquisition. Pricing too low undervalues the governance and compliance capabilities that differentiate VocalIQ. The design partner model creates dependency on a small number of early customers. Competitor pricing pressure from platforms that don't invest in banking-grade governance may force uncomfortable pricing decisions.

**Source Links:** Handoff Sections 23-24, market_map.md, competitor_matrix.csv, mvp_scope.md, pilot_plan.md.

---

## 1. Positioning

### 1.1 Core Positioning Statement

VocalIQ safely automates selected banking calls with deterministic workflows, fraud-aware controls, human oversight, and full audit evidence.

### 1.2 What We Are

A governed voice automation layer for regulated banking contact centers. We sit between the bank's telephony infrastructure and their agents, handling the calls that can be safely automated while keeping humans in control of everything else.

### 1.3 What We Are Not

We are not a general-purpose voice AI platform. We are not a chatbot vendor. We are not trying to "replace the call center with human-like AI." Banks don't want human-like; they want safe, auditable, and compliant.

### 1.4 Differentiation

| Dimension | VocalIQ | Typical Voice AI Vendor |
|-----------|---------|------------------------|
| Conversation control | Declarative graph with compiled safety rules | Prompt-based with guardrails bolted on |
| Policy enforcement | Three-layer enforcement (Graph, Policy Engine, Tool Gateway) | Single-layer prompt instructions |
| Audit trail | Append-only ledger with integrity verification, every event logged | Basic call logs |
| Fraud detection | Integrated fraud signal detection, APP scam warnings, ATO prevention | Not included; separate system |
| Human oversight | Real-time supervisor monitoring, whisper, takeover, approval workflows | Post-call review |
| Compliance evidence | Structured evidence pack for risk committee | Marketing-level compliance claims |
| Testing rigor | 14 evaluation suites, adversarial testing, fraud simulation | Basic regression tests |
| Prohibited actions | A6 actions architecturally impossible (Principle G7) | Prompt-based "don't do this" |

---

## 2. Target Segments

### 2.1 Priority Segments (Year 1)

| Segment | Why | Typical Size | Estimated Deal |
|---------|-----|-------------|---------------|
| Digital banks | Cloud-native, fast decision cycles, API-first infrastructure, strong appetite for automation | 50-500 agents | $150K-$400K annual |
| Tier-2 and regional banks | Large enough to have meaningful call volume, small enough to move quickly, often looking for competitive advantage | 200-1,000 agents | $250K-$600K annual |
| Credit unions and building societies | Cost-sensitive, high member call volume, limited technology teams, need turnkey solutions | 50-300 agents | $100K-$300K annual |
| Card issuers | High volume of procedural calls (lost/stolen, activation, balance), clear ROI | 100-500 agents | $200K-$500K annual |
| Bank BPO providers | Manage contact centers for multiple banks, multiplier effect on deployment | 500-5,000 agents | $400K-$1.5M annual |
| Fintechs with regulated servicing | Neobanks and fintech lenders with customer servicing obligations (e.g., lending-as-a-service, BNPL providers with complaints handling). Typically cloud-native with fast adoption cycles. | 20-200 agents | $80K-$250K annual |

### 2.2 Segments to Avoid Initially

| Segment | Why |
|---------|-----|
| Top-tier global banks | 12-18 month sales cycles, complex procurement, extensive security reviews. Pursue only with warm introduction or design partnership. |
| Wealth management firms | High-risk advisory conversations, fiduciary obligations, VocalIQ not designed for A6 workflows. |
| Insurance companies | Different regulatory framework, different workflow patterns. May be a Year 2 expansion. |

### 2.3 Buyer Map

A typical bank buying decision involves 5-7 stakeholders. Each has different concerns.

| Buyer | Title | Primary Concern | VocalIQ Value Proposition |
|-------|-------|----------------|--------------------------|
| Economic buyer | COO / Head of Operations | Cost reduction, efficiency, service quality | Measurable cost-per-call reduction with maintained or improved safety |
| Technical buyer | CTO / Head of IT | Architecture fit, integration complexity, vendor lock-in | Open standards, documented APIs, bank-owned data |
| Risk gatekeeper | CRO / Head of Risk | Operational risk, model risk, fraud risk | Evidence pack, evaluation framework, three-layer enforcement |
| Security gatekeeper | CISO | Data security, threat model, access controls | Threat model, pen test results, encryption, tenant isolation |
| Compliance gatekeeper | Head of Compliance | Regulatory adherence, audit trail, disclosure requirements | Compliance scripts, audit ledger, evidence pack |
| Contact center leader | VP Customer Service | Agent impact, training, customer experience | Human oversight model, gradual automation, no agent displacement narrative |
| Procurement | Procurement / Vendor Management | Cost, contract terms, SLA | Clear pricing, measurable SLAs, exit provisions |

---

## 3. Pricing Model

### 3.1 Pricing Structure

VocalIQ's pricing has four components:

| Component | Description | Pricing Basis |
|-----------|------------|---------------|
| Platform fee | Access to the VocalIQ platform, Control Center, Evaluation Lab, and Audit Ledger | Annual subscription, tiered by deployment size |
| Usage fee | Cost of AI-handled calls | Per safely resolved interaction |
| Integration package | Bank connector development, telephony integration, knowledge base setup | One-time implementation fee |
| Support and compliance package | SLA, priority support, evidence pack generation, compliance reporting | Annual subscription |

### 3.2 Platform Fee Tiers

| Tier | Description | Target Segment | Indicative Range |
|------|------------|---------------|-----------------|
| Starter | Up to 3 workflows, 50K calls/month, single-tenant cloud | Digital banks, credit unions | $8K-$15K / month |
| Professional | Up to 8 workflows, 200K calls/month, dedicated infrastructure | Regional banks, card issuers | $15K-$30K / month |
| Enterprise | Unlimited workflows, unlimited volume, private cloud / VPC option | Tier-2 banks, BPOs | $30K-$60K / month |

### 3.3 Usage Fee

The usage fee is based on "safely resolved interactions," defined as calls where:
- The caller's intent was resolved without human escalation
- No policy violations occurred
- No unauthorized disclosures occurred
- The audit trail is complete

| Volume Tier | Per Safely Resolved Interaction |
|------------|-------------------------------|
| First 10,000 / month | $0.30 - $0.45 |
| 10,001 - 50,000 / month | $0.20 - $0.35 |
| 50,001+ / month | $0.15 - $0.25 |

Calls that transfer to human agents are not charged as "safely resolved" but do incur a nominal per-call platform fee ($0.05 - $0.10) to cover ASR, routing, and audit costs.

### 3.4 Integration Package

| Package | Scope | Indicative Range |
|---------|-------|-----------------|
| Standard | Single core banking system, standard telephony, up to 3 workflows | $50K - $100K |
| Advanced | Multiple backend systems, custom telephony, up to 8 workflows | $100K - $200K |
| Enterprise | Complex multi-system integration, custom connectors, private deployment | $200K - $400K |

### 3.5 Pricing Rationale

The "safely resolved interaction" model is VocalIQ's pricing innovation. It works because:

1. It aligns VocalIQ's revenue with the bank's value: we earn more when we resolve more calls safely.
2. It penalizes VocalIQ for poor performance: calls that fail safety checks or transfer to humans generate less revenue.
3. It creates a natural incentive for VocalIQ to invest in quality: better graphs, better RAG, better fraud detection all drive revenue.
4. It gives banks predictable, volume-correlated costs rather than fixed costs that don't scale.

### 3.6 Competitor Pricing Context

| Competitor | Pricing Model | Indicative Range | VocalIQ Comparison |
|-----------|--------------|-----------------|-------------------|
| Retell AI | Per minute | $0.07-$0.20 / min | VocalIQ is higher per-call but includes governance, audit, and fraud detection that Retell doesn't offer |
| PolyAI | Annual license + usage | $200K-$1M+ annual | Comparable range for enterprise deals; VocalIQ differentiates on transparency and evidence |
| Cognigy | Platform license + usage | Similar structure | VocalIQ's usage pricing based on safe resolution is unique |
| Replicant | Per resolved call | $0.50-$1.50 / call | VocalIQ targets the lower end; Replicant doesn't specialize in banking governance |
| GetVocal | Not publicly disclosed | Estimated $300K-$800K annual | VocalIQ matches range but offers banking-specific safety controls |

---

## 4. Design Partner Program

### 4.1 Program Structure

The first 2-3 bank deployments use the design partner model. Design partners receive preferential pricing and direct product influence in exchange for being early adopters and providing references.

| Benefit for Bank | Benefit for VocalIQ |
|-----------------|-------------------|
| 40-50% discount on platform and integration fees | Real-world deployment evidence |
| Direct product roadmap influence | Production performance data |
| Priority support with named engineering team | Reference customer for future sales |
| First access to new workflows and features | Feedback loop for product-market fit |
| Co-developed evidence pack for their risk committee | Reusable evidence pack template |

### 4.2 Design Partner Selection Criteria

| Criterion | Why |
|-----------|-----|
| Cloud-native or cloud-friendly infrastructure | Reduces integration timeline and complexity |
| API-accessible core banking system | Required for bank connector integration |
| Internal champion at VP level or above | Needed to navigate internal approvals |
| Risk team willing to engage early | Pre-pilot risk review is critical |
| Call volume > 50,000/month on target workflows | Sufficient volume for statistically meaningful pilot |
| Not in active vendor procurement process | Design partnership is collaborative, not competitive |

### 4.3 Design Partner Pitch

The pitch to a potential design partner follows this structure:

1. **Problem:** Banking contact centers handle millions of repetitive, procedural calls per year. These calls are expensive (average $5-$8 per call fully loaded), have long wait times, and are prone to human error. Existing AI solutions lack the governance and audit controls that banks require.

2. **Solution:** VocalIQ automates selected banking calls with the same safety controls a bank applies to its human agents: identity verification, authorized actions only, real-time human oversight, and a complete audit trail.

3. **Proof:** Walk through the architecture, show the three-layer enforcement, demonstrate the Control Center, show the evaluation framework, present the evidence pack.

4. **Pilot scope:** 1-3 workflows, limited customer segment, limited call volume, human fallback always available. Pilot runs for 8-12 weeks. If safety metrics are not met, we roll back automatically.

5. **Ask:** API access to core banking sandbox, SIP trunk integration, internal champion to navigate risk committee, 3-month commitment to the design partnership.

6. **Economics:** At the design partner discount, the pilot costs approximately $50K-$100K including integration, with usage fees waived for the pilot period. The projected annual ROI at full deployment is 3-5x the platform cost.

---

## 5. Sales Evidence

### 5.1 Sales Collateral Requirements

Every sales conversation with a bank involves scrutiny from risk, compliance, security, and architecture teams. VocalIQ's sales materials must include technical depth that competitors typically avoid.

| Material | Audience | Content |
|----------|----------|---------|
| Solution overview | All | 2-page positioning, architecture diagram, key differentiators |
| Architecture deep dive | CTO, Enterprise Architecture | Reference architecture, component model, deployment options, integration model |
| Security controls brief | CISO, Security | Threat model summary, encryption, access controls, pen test results |
| Compliance mapping | Head of Compliance | Regulatory requirements mapped to VocalIQ controls, by jurisdiction |
| Evaluation framework brief | CRO, Model Risk | 14 evaluation suites, gate criteria, evidence pack structure |
| Fraud controls brief | Fraud Operations | Fraud detection capabilities, ATO/APP coverage, fraud signal matrix |
| ROI model | COO, Finance | Cost-per-call analysis, containment rate impact, agent time savings, TCO comparison |
| Handoff demo | Contact Center Leader | Live demo of human oversight: monitoring, whisper, takeover |
| Audit replay demo | Compliance, Risk | Demo of complete audit trail for a single call |

### 5.2 Demo Environment

VocalIQ maintains a demo environment with:

| Component | Configuration |
|-----------|--------------|
| Mock bank | Synthetic accounts, transactions, cards with realistic data patterns |
| Workflows | Lost/stolen card, balance inquiry, payment, complaint intake |
| Control Center | Full supervisor view with live call monitoring |
| Adversarial demo | Show prompt injection being blocked in real time |
| Audit replay | Show complete event trail for a completed call |
| Evidence pack | Sample evidence pack from evaluation run |

---

## 6. Go-to-Market Timeline

| Period | Activity | Goal |
|--------|----------|------|
| Months 1-2 | Design partner outreach | Identify and engage 5-10 candidates |
| Months 2-3 | Design partner selection | Sign 1-2 design partners |
| Months 3-5 | Pilot preparation | Integration, training, pre-pilot review |
| Months 5-8 | Pilot operation | Live deployment, evidence collection |
| Months 8-9 | Evidence pack and case study | Produce reference material |
| Months 9-12 | First commercial sales | Use design partner evidence to close 2-3 additional banks |
| Year 2 | Scale | Connector marketplace, self-service onboarding, channel partnerships |

### 6.1 Channel Strategy (Year 2+)

After proving the product with direct sales, VocalIQ explores channel partnerships:

| Channel | Target |
|---------|--------|
| CCaaS platform partnerships | Genesys, NICE, Amazon Connect marketplace listings |
| System integrator partnerships | Accenture, Deloitte, Infosys for bank transformation projects |
| Core banking vendor partnerships | Co-sell with Temenos, Thought Machine, Mambu |
| Bank BPO partnerships | White-label or co-branded for BPO providers |

---

## 7. Competitive Response Playbook

### 7.1 Against General-Purpose Voice AI (Retell, Bland, Vapi)

"These platforms are built for speed-to-deploy across industries. They work well for appointment reminders, order status, and lead qualification. But they don't have the governance layer that banking requires. Ask them to show you a three-layer policy enforcement architecture, a fraud detection signal matrix, an adversarial test suite against prompt injection, or an evidence pack for your risk committee. If they can't produce those, they're not banking-grade."

### 7.2 Against Enterprise Conversational AI (Cognigy, PolyAI, Replicant)

"These are strong platforms with enterprise track records. The difference is in depth of banking governance. We built VocalIQ specifically for regulated financial services: our policy engine enforces autonomy levels at the architecture layer (not the prompt layer), our audit ledger produces tamper-evident event trails, and our evaluation framework includes fraud simulation and adversarial testing as release gates. Ask to see their A6 prohibition mechanism. If it's a prompt instruction, it can be overridden."

### 7.3 Against GetVocal

"GetVocal pioneered the hybrid human-AI model and they've done strong work in telco and delivery. They're EU-focused and haven't publicly demonstrated banking-specific controls: fraud signal detection, APP scam prevention, regulatory evidence packs, or adversarial testing. We respect their contribution to the category and we've built on similar design principles with deeper banking governance."

### 7.4 Against Build-It-Yourself (Pipecat/LiveKit + Internal Team)

"You can absolutely build a voice pipeline with open-source tools. We use them ourselves. The pipeline is maybe 20% of the problem. The other 80% is governance: policy enforcement, fraud detection, audit trails, evaluation frameworks, release gates, and the evidence pack your risk committee needs. Building that from scratch takes 12-18 months of specialized engineering. We've done it."

---

## 8. Open Questions

1. Should VocalIQ offer a free proof-of-concept (sandbox environment with mock bank) for prospects to evaluate before committing to a pilot? This could shorten sales cycles but requires investment in self-service tooling.

2. What is the right discount for design partners? 40-50% is significant. If the product is strong, 20-30% may be sufficient and better protects future pricing power.

3. Should VocalIQ pursue SOC 2 Type II before first sales, or after the design partner pilot? Banks increasingly require it, but the certification process takes 6-12 months and costs $50K-$150K.

4. How should VocalIQ handle banks that want to bring their own LLM provider? The architecture supports it (Model Gateway abstraction), but testing and evaluation need to cover the bank's chosen model, which adds scope.

5. Should the pricing model include a "governance premium" line item that makes the compliance and audit value explicit, or should it be bundled into the platform fee?
