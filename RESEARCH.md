# VocalIQ - Voice AI Platform Research & Build Plan

**Date:** May 3, 2026  
**Objective:** Build a platform with capabilities matching GetVocal.ai and the best of the voice AI agent market

---

## 1. What GetVocal.ai Actually Does

GetVocal (Paris, founded 2023, $30M raised, 60-person team) builds **hybrid human-AI voice agents for enterprise customer experience**. Their core thesis: full automation isn't trustworthy enough for enterprise CX, so they pair AI agents with human operators who can supervise, intervene, and coach the AI in real time.

### Core Product Components

**Agent Blueprints (Conversation Graph Engine)**
- A proprietary graph-based conversation designer that transforms business processes, documents, and logic into a structured conversation flow
- Procedural steps are fully deterministic (no LLM hallucination risk), while generative AI is reserved only for natural language moments that actually need it
- This hybrid deterministic + generative approach is their key differentiator for compliance-heavy industries

**Control Center (launched March 2026)**
- Real-time human-AI operations dashboard
- Supervisors can monitor live conversations, intervene instantly, shadow AI agents, and manage escalations
- AI agents can proactively request human validation for sensitive actions, seek guidance on edge cases, or escalate high-value moments while maintaining full conversation context

**Hybrid Workforce Platform**
- Unified management of human and AI agents in a single pane
- Workforce planning across both agent types
- Performance analytics comparing human vs. AI resolution rates

### Key Metrics They Publish
- 31% fewer live escalations vs. existing enterprise solutions
- 45% more self-service resolutions
- 70% deflection rate within 3 months of launch
- One customer: 5x uptime increase, 35% deflection jump in weeks
- Another: 1,000+ production calls, 42% self-service completion

### Target Market
- Mid-market and enterprise B2B
- Focus sectors: SaaS, finance, insurance, telecom
- Customers include Vodafone, Glovo, Movistar, Deutsche Telekom pilot
- Europe-first, GDPR/EU AI Act compliance as a selling point

### Deployment Options
- Full on-premise (customer infrastructure)
- Private cloud (customer-owned)
- EU-sovereign deployment
- Hybrid cloud + on-prem

### Compliance
- GDPR, SOC 2, HIPAA out of the box
- EU AI Act alignment built into the architecture
- Full audit trails on every conversation

---

## 2. Competitive Landscape

### Direct Competitors (Enterprise Hybrid Voice AI)

| Platform | Focus | Pricing | Key Strength |
|----------|-------|---------|-------------|
| **GetVocal** | Hybrid human-AI, EU-first | Enterprise (sales-led) | Graph-based deterministic + LLM, compliance |
| **Retell AI** | Full-stack voice agents | $0.07/min | Low latency (600ms), self-service HIPAA BAA |
| **Vapi** | Developer-first modular | $0.15-0.33/min | 4,200+ config points, BYO model support |
| **Bland AI** | High-volume outbound | Enterprise | Scale, compliance, logging |
| **Synthflow** | No-code voice agents | $0.225/min (Pro) | Fastest to deploy, non-technical teams |
| **Voiceflow** | Conversation design | Freemium | Best prototyping and team collaboration |
| **Cognigy** | Enterprise CCaaS | Enterprise | 2,500+ agent deployments, complex integrations |
| **PolyAI** | Enterprise contact center | Enterprise | Deep domain models, branded voices |
| **Cresta** | Real-time agent assist | Enterprise | Live coaching, not full automation |
| **Replicant** | Contact center automation | Enterprise | Tier 1 call resolution, backend integrations |

### Infrastructure / API Layer

| Platform | What It Does | Why It Matters |
|----------|-------------|---------------|
| **ElevenLabs** | Best-in-class TTS, agent templates | Expressive multilingual voices |
| **Deepgram** | Fast STT (Nova-3) | Industry standard for real-time transcription |
| **Cartesia** | Ultra-low latency TTS (Sonic-3) | Fastest voice synthesis API |
| **LiveKit** | WebRTC infrastructure + agent framework | Open source, telephony built in |
| **Telnyx** | Carrier-grade voice API | SIP trunking, HD voice, region pinning |

### Open Source Frameworks (GitHub)

| Project | Stars | Language | Key Feature |
|---------|-------|----------|-------------|
| **Pipecat** (by Daily.co) | High | Python | Frame-based pipeline, multi-transport, Twilio/SIP |
| **LiveKit Agents** | High | Python/Go | WebRTC-native, telephony, semantic turn detection, MCP support |
| **TEN Framework** | Growing | Multi | Real-time multimodal, ultra-low latency |
| **Dograh** | Growing | TypeScript | Visual workflow builder, self-hosted, Twilio/Vonage, "n8n of voice AI" |

### Product Hunt Landscape
- ElevenLabs Agent Templates leading for ready-made voice agents
- Growing category with "AI Voice Agents" and "AI Voice Agent Infrastructure" as distinct categories
- Trend toward real-time reasoning, multilingual support, and faster LLM context handling

---

## 3. The Voice AI Tech Stack in 2026

### Architecture Decision: Pipeline vs. Speech-to-Speech

**Pipeline (STT -> LLM -> TTS)** - the production default for most use cases:
- Full control and debuggability at every stage
- Swap any component without touching the rest
- Better for compliance (you can log every stage)
- More cost-effective (use cheap models where you can)
- Latency target: 300-600ms first syllable

**Speech-to-Speech (S2S)** - better for conversational naturalness:
- Lower latency potential
- More natural interruption handling
- Less control and transparency
- Higher cost per interaction

**Our recommendation: Pipeline architecture** (matches GetVocal's approach and gives us the deterministic control layer they use for compliance)

### Recommended Stack

**Layer 1: Transport**
- WebSocket for most use cases (easier to deploy, debug, monitor)
- WebRTC via LiveKit for ultra-low-latency requirements
- SIP trunking via Twilio or Telnyx for telephony

**Layer 2: Voice Activity Detection (VAD)**
- Silero VAD (open source, fast, reliable)
- Budget: 10-50ms added latency

**Layer 3: Speech-to-Text (STT)**
- Primary: Deepgram Nova-3 (fastest, most accurate for real-time)
- Fallback: OpenAI Whisper (self-hosted for cost or sovereignty)
- On-prem option: Faster-Whisper

**Layer 4: Language Model (LLM)**
- Primary: Claude (Anthropic) or GPT-4o for reasoning
- Fast path: Claude Haiku or GPT-4o-mini for simple routing decisions
- Self-hosted option: Llama 3 or Mistral for on-prem deployments

**Layer 5: Text-to-Speech (TTS)**
- Primary: Cartesia Sonic-3 (lowest latency) or ElevenLabs Flash v2.5 (most expressive)
- Self-hosted: Coqui TTS or XTTS

**Layer 6: Orchestration**
- Pipecat or LiveKit Agents as the core framework
- Custom conversation graph engine on top (this is the key build)

**Layer 7: Telephony**
- Twilio for global coverage
- Telnyx for carrier-grade quality
- SIP trunk integration for enterprise BYOC

**Layer 8: Observability**
- Session-level audio recordings
- Turn-by-turn transcripts with timestamps
- LLM input/output traces with per-stage latency
- Tool call logs
- Error events tied to session moments

---

## 4. What We Need to Build

Based on the research, here are the core components we need to match GetVocal's capabilities:

### P0 - Must Have (MVP)

1. **Conversation Graph Engine**
   - Visual graph-based conversation designer (similar to GetVocal's Agent Blueprints)
   - Deterministic nodes for procedural steps (no LLM involved)
   - Generative nodes for natural language moments
   - Conditional branching, loops, variable extraction
   - Import from business process documents

2. **Voice Agent Runtime**
   - Pipeline architecture: VAD -> STT -> LLM -> TTS
   - Streaming end-to-end (no waiting for full transcription)
   - Interruption handling (barge-in detection)
   - Turn detection (semantic, not just silence-based)
   - Sub-600ms first-syllable latency target

3. **Telephony Integration**
   - Inbound call handling (IVR replacement)
   - Outbound calling (campaigns, follow-ups)
   - SIP trunk support
   - Call recording and transcription
   - DTMF handling
   - Call transfer (warm and cold)

4. **Human-AI Collaboration (Control Center)**
   - Real-time conversation monitoring dashboard
   - One-click human takeover / escalation
   - AI-initiated escalation (knows when to ask for help)
   - Supervisor alerts and intervention tools
   - Conversation context handoff (AI to human, human to AI)

5. **Agent Management**
   - Create, configure, deploy, and version agents
   - Agent templates / blueprints library
   - A/B testing between agent versions
   - Performance analytics per agent

### P1 - Important (Post-MVP)

6. **Multi-channel Support**
   - Voice (phone), chat, email from same conversation graph
   - Channel-specific adaptations of the same logic

7. **Knowledge Base**
   - RAG-powered document ingestion
   - FAQ management
   - Dynamic context injection during conversations

8. **CRM & Integrations**
   - Salesforce, HubSpot, Zendesk connectors
   - Webhook-based custom integrations
   - API for programmatic control

9. **Analytics & Reporting**
   - Call volume, resolution rates, escalation rates
   - Sentiment analysis per call
   - Script adherence scoring
   - Cost per resolution tracking

10. **Compliance & Security**
    - GDPR tooling (data deletion, consent management)
    - Audit trails on every conversation
    - Role-based access control
    - Data residency controls

### P2 - Differentiation

11. **AI-to-AI Testing (like Dograh's LoopTalk)**
    - Simulate calls with AI playing the customer
    - Automated regression testing of conversation flows

12. **On-Premise Deployment**
    - Docker/Kubernetes packaging
    - Self-hosted STT/TTS/LLM options
    - Air-gapped deployment support

13. **Multi-language Support**
    - Real-time language detection
    - Seamless language switching mid-call
    - Localized conversation graphs

---

## 5. Recommended Tech Stack for Our Build

```
Frontend (Dashboard & Graph Designer):
  - Next.js 14+ (React)
  - React Flow (for visual graph editor)
  - Tailwind CSS
  - WebSocket client for real-time monitoring

Backend (API & Orchestration):
  - Python (FastAPI) for voice pipeline and agent runtime
  - Node.js (Express/Fastify) for dashboard API
  - PostgreSQL (primary database)
  - Redis (real-time state, pub/sub for live monitoring)
  - Celery or BullMQ (async job processing)

Voice Pipeline:
  - Pipecat or LiveKit Agents (core framework)
  - Deepgram Nova-3 (STT)
  - Cartesia Sonic-3 or ElevenLabs (TTS)
  - Claude API or OpenAI (LLM)
  - Silero VAD

Telephony:
  - Twilio Voice SDK
  - SIP.js for browser-based SIP
  - WebRTC via LiveKit

Infrastructure:
  - Docker + Kubernetes
  - AWS/GCP (cloud deployment)
  - Terraform (IaC)
  - GitHub Actions (CI/CD)

Observability:
  - OpenTelemetry (tracing)
  - Prometheus + Grafana (metrics)
  - Custom session replay system
```

---

## 6. Open Source Projects to Build On

Rather than building everything from scratch, we should leverage:

| Component | Build vs. Use | Project |
|-----------|--------------|---------|
| Voice pipeline orchestration | Use | Pipecat or LiveKit Agents |
| Visual conversation designer | Build | Custom (React Flow based) |
| Telephony integration | Use | Twilio SDK + Pipecat telephony |
| Human-AI control center | Build | Custom (WebSocket + React) |
| Agent management | Build | Custom |
| Analytics | Partial build | OpenTelemetry + custom dashboards |
| Knowledge base / RAG | Use | LangChain or LlamaIndex |
| Authentication | Use | NextAuth.js or Clerk |

---

## 7. Key Differentiators to Target

GetVocal's weaknesses and market gaps we can exploit:

1. **Europe-only focus** - they're EU-first with 100+ teams across Europe. We can target US/APAC from day one.

2. **Sales-led enterprise only** - no self-serve option, no SMB tier. We can offer a PLG (product-led growth) motion with a free tier.

3. **Closed source** - everything is proprietary. We can offer an open-core model where the conversation engine is open source, with enterprise features (control center, compliance, on-prem) as paid.

4. **No developer API** - their API docs exist but the product is primarily no-code. We can be developer-first with API and SDK, plus a visual builder for non-technical users.

5. **Pricing opacity** - no public pricing. We can be transparent with per-minute pricing.

---

## 8. Suggested Product Names

Since we're building in the VocalIQ workspace, here are name candidates:

| Name | Domain Available? | Notes |
|------|------------------|-------|
| **VocalIQ** | Check .ai/.io | "Vocal Intelligence" - strong, memorable |
| **Voxa** | Check .ai | Short, punchy, voice-related |
| **Talkwise** | Check .ai | Approachable, implies smart conversations |
| **Callflow** | Check .ai | Descriptive, implies conversation design |
| **Speakr** | Check .ai | Modern, consumer-friendly |
| **Convox** | Check .ai | "Conversation + Vox (voice)" |
| **Agentvoice** | Check .ai | Descriptive, SEO-friendly |

---

## 9. Next Steps

1. **Finalize product name** and secure domain
2. **Set up the monorepo** with the recommended stack
3. **Build the voice pipeline MVP** using Pipecat + Deepgram + Cartesia + Claude
4. **Build the conversation graph designer** using React Flow
5. **Integrate Twilio** for telephony (inbound first)
6. **Build the control center** for real-time human monitoring
7. **Deploy alpha** and test with real calls

---

## Sources

- [GetVocal Homepage](https://www.getvocal.ai/)
- [GetVocal Agent Blueprints](https://www.getvocal.ai/agent-blueprint)
- [GetVocal Control Center Launch](https://www.businesswire.com/news/home/20260330718259/en/)
- [GetVocal $26M Series A](https://www.cmswire.com/customer-experience/getvocal-raises-26m-series-a-to-scale-governed-ai-agents/)
- [GetVocal Hybrid Workforce Platform](https://www.getvocal.ai/hybrid-workplace-platform)
- [GetVocal API Documentation](https://api-documentation.getvocal.ai/)
- [Pipecat GitHub](https://github.com/pipecat-ai/pipecat)
- [LiveKit Agents GitHub](https://github.com/livekit/agents)
- [Dograh GitHub](https://github.com/dograh-hq/dograh)
- [TEN Framework GitHub](https://github.com/TEN-framework/ten-framework)
- [Voice AI Stack 2026 - AssemblyAI](https://www.assemblyai.com/blog/the-voice-ai-stack-for-building-agents)
- [Pipeline vs Realtime Architecture](https://www.famulor.io/blog/realtime-vs-pipeline-voice-agent-architecture-guide-2026)
- [Best AI Voice Agents 2026 - Retell](https://www.retellai.com/blog/best-voice-ai-agent-platforms)
- [Product Hunt AI Voice Agents](https://www.producthunt.com/categories/ai-voice-agents)
- [Dograh - Open Source Voice AI Platform](https://www.dograh.com/)
