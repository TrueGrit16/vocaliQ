# Operational Resilience Framework: VocalIQ Platform

**Document ID:** DOC_OPS_RESIL_001  
**Last Updated:** 2026-05-03  
**Owner:** CTO

**Version History:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-03 | Initial framework covering failover, degraded modes, exit planning, and incident response |

**Purpose:** Define how VocalIQ maintains service continuity under adverse conditions, complies with DORA and PRA operational resilience requirements, and enables banks to meet their own operational resilience obligations when using VocalIQ as a technology provider. This framework covers failover architecture, degraded-mode operation, exit planning, incident response, and third-party dependency management.

**Scope:** Covers VocalIQ platform operational resilience. Includes all 12 architecture components, all third-party dependencies (model providers, telephony, cloud infrastructure), and the interfaces between VocalIQ and bank systems. Does not cover bank-side operational resilience (which is the bank's responsibility) but documents what VocalIQ provides to support the bank's resilience posture.

**Assumptions:** VocalIQ is deployed as a cloud-hosted service consumed by banks. Banks treat VocalIQ as a critical or important ICT third-party provider. The primary deployment target is a single cloud region with failover to a secondary region. Contact center operations are 24/7 with no maintenance windows for complete shutdowns.

**Decisions Made:** Degraded-mode operation prioritizes call handling continuity over feature completeness. If AI capabilities fail, the system falls back to IVR or direct human routing rather than dropping calls. Exit planning assumes banks need data portability and the ability to transition to an alternative provider within 90 days.

**Alternatives Considered:** Active-active multi-region deployment was considered but deferred to Phase 2 due to complexity and cost. Offline-first architecture (process calls locally without cloud dependencies) was considered but rejected because model inference requires cloud infrastructure at current scale.

**Risks:** Degraded-mode operation provides limited functionality and may not meet bank SLAs for service quality. Exit plan relies on data portability, but call recordings and model state may not be directly usable by alternative providers. Third-party dependency failures may cascade in unexpected ways.

**Open Questions:** Should VocalIQ offer an on-premises deployment option for banks that require it? How should SLAs be structured for degraded-mode periods (different SLA tier)? What is the minimum viable degraded mode that still provides value?

**Source Links:** DORA (REG-002), PRA Operational Resilience Framework, handoff Section 11 (architecture), handoff Section 9.5 (requirement translation examples for operational resilience).

---

## 1. Service Architecture for Resilience

### 1.1 Component Dependencies

The VocalIQ platform has the following critical dependency chain:

```
Caller -> Telephony (Twilio) -> Media Gateway -> Real-Time Speech Layer -> 
  -> STT (Deepgram) -> Conversation Runtime -> LLM (Provider) ->
  -> Policy Engine -> Tool Gateway -> Bank APIs ->
  -> TTS (Cartesia) -> Media Gateway -> Caller
```

Failure at any point in this chain disrupts service. The resilience framework addresses each failure point.

### 1.2 Failure Mode Analysis

| Component | Failure Mode | Impact | Likelihood | Detection Time |
|-----------|-------------|--------|------------|----------------|
| Telephony (Twilio) | Provider outage | All calls affected | Low | < 1 minute |
| Media Gateway | Process crash | New calls rejected | Low | < 30 seconds |
| STT (Deepgram) | API timeout/error | Speech not transcribed | Low-Medium | < 10 seconds |
| LLM Provider | API timeout/error | No AI responses | Medium | < 10 seconds |
| TTS (Cartesia) | API timeout/error | No voice synthesis | Low-Medium | < 10 seconds |
| Policy Engine | Process crash | No policy validation | Low | < 30 seconds |
| Tool Gateway | Process crash | No bank system access | Low | < 30 seconds |
| Bank APIs | Timeout/error | Specific operations fail | Medium | < 10 seconds |
| Audit Ledger | Write failure | Audit records lost | Low | < 10 seconds |
| Database | Crash or corruption | State lost | Very Low | < 1 minute |
| Network | Connectivity loss | Varies by affected segment | Low | < 30 seconds |

### 1.3 Single Points of Failure

| SPOF | Mitigation |
|------|-----------|
| Telephony provider | Multi-provider telephony (Twilio primary, Vonage or Telnyx secondary) |
| Cloud region | Cross-region failover (primary + DR region) |
| LLM provider | Model Gateway with primary + fallback LLM provider |
| STT provider | Primary + fallback STT in speech layer |
| TTS provider | Primary + fallback TTS in speech layer |
| Database | Primary + replica with automated failover |
| Media Gateway | Multiple instances with load balancing |

---

## 2. Degraded-Mode Operation

### 2.1 Degradation Levels

VocalIQ operates at four levels of service:

**Level 0: Full Service**
All components operational. Full AI capability. All workflows available.

**Level 1: Reduced AI (single model failure)**
One model provider unavailable, fallback active. Slightly degraded quality (e.g., STT accuracy may be lower on fallback provider). All workflows still available but with potential quality reduction.

Detection: Model Gateway circuit breaker triggers.
Response: Automatic switchover to fallback provider. Alert to operations team.
Customer impact: Minimal. Caller may notice slight difference in voice quality or transcription accuracy.

**Level 2: Limited AI (multiple model failures or LLM unavailable)**
Core AI reasoning unavailable. System operates in "smart IVR" mode: basic intent classification using cached models, simple scripted responses, no dynamic conversation. Authentication and routing still function.

Detection: Multiple circuit breakers trigger, or LLM provider completely unavailable.
Response: Switch to cached intent classification and scripted responses. Complex calls routed directly to human agents. Alert to operations team and bank.
Customer impact: Reduced capability. Callers handled by simple scripts or routed to human agents. No AI-powered conversation.

**Level 3: IVR Fallback (AI pipeline completely unavailable)**
AI pipeline completely non-functional. System operates as a basic IVR with DTMF menu and direct routing to human queues. No speech recognition, no AI responses.

Detection: Media Gateway cannot reach any AI component.
Response: Activate IVR fallback configuration. All calls routed through DTMF menu to human queues. Alert to operations team and bank.
Customer impact: Significant. Traditional IVR experience. Higher wait times due to all calls going to human agents.

**Level 4: Emergency Routing (complete platform failure)**
VocalIQ platform completely unavailable. Calls must route directly to bank's existing contact center infrastructure, bypassing VocalIQ entirely.

Detection: Telephony health checks fail to reach VocalIQ.
Response: Telephony provider routes calls directly to bank's backup routing (pre-configured failover route). Bank operations team notified.
Customer impact: VocalIQ is transparent to callers. Bank's existing IVR/routing handles calls.

### 2.2 Failover Configuration

Each bank deployment is configured with:

- Primary routing: calls flow through VocalIQ AI pipeline
- Level 1-3 fallback: degraded-mode configurations pre-tested and ready to activate
- Level 4 fallback: direct routing to bank infrastructure (pre-configured at telephony provider)
- Failover decision thresholds: what metrics trigger each degradation level
- Failback criteria: conditions under which normal service is restored
- Communication templates: pre-drafted notifications for bank operations at each level

### 2.3 Data Handling During Degraded Mode

During degraded operation:
- Call recordings continue at the telephony/media gateway level (independent of AI pipeline)
- Audit records capture what is available (call metadata, routing decisions) even if AI audit events are unavailable
- Any actions taken during degraded mode are flagged for post-incident review
- State recovery procedures restore any interrupted call data when full service resumes

---

## 3. Incident Response

### 3.1 Incident Severity Levels

| Severity | Definition | Response Time | Resolution Target | Notification |
|----------|-----------|---------------|-------------------|-------------|
| P1 (Critical) | Complete platform outage or data breach | 15 minutes | 4 hours | Bank operations immediately. Bank CISO for security incidents. Regulator within DORA timelines if applicable. |
| P2 (Major) | Significant degradation affecting multiple workflows or banks | 30 minutes | 8 hours | Bank operations within 1 hour. |
| P3 (Moderate) | Single workflow or minor degradation | 2 hours | 24 hours | Bank operations at next scheduled touchpoint. |
| P4 (Minor) | Cosmetic or non-impacting issue | Next business day | 5 business days | Not required. |

### 3.2 Incident Response Procedure

1. **Detection:** Automated monitoring detects anomaly. Alert generated.
2. **Triage:** On-call engineer assesses severity. Escalates if P1/P2.
3. **Communication:** Bank notified per severity-level requirements.
4. **Containment:** If necessary, activate degraded mode to prevent further impact.
5. **Resolution:** Identify root cause and implement fix.
6. **Recovery:** Restore full service. Verify recovery through monitoring.
7. **Post-incident:** Root cause analysis within 48 hours. Post-incident report to bank within 5 business days. Process improvements identified and tracked.

### 3.3 DORA Incident Reporting

For EU-regulated banks, DORA requires incident reporting within specific timelines:

- Initial notification: within 24 hours of detecting a major ICT-related incident
- Intermediate report: within 72 hours
- Final report: within 1 month

VocalIQ supports bank DORA reporting by:
- Providing incident data in DORA-compatible format
- Pre-populating incident report templates with technical details
- Maintaining incident timeline with all relevant events
- Cooperating with bank incident response teams

---

## 4. Exit Planning

### 4.1 Exit Scenarios

**Planned exit:** Bank decides to transition to an alternative provider. 90-day transition period. Orderly migration of configuration, data, and call handling.

**Unplanned exit:** VocalIQ service becomes unavailable or relationship terminates unexpectedly. Emergency transition to bank's backup infrastructure.

**Partial exit:** Bank moves some workflows to alternative provider while keeping others on VocalIQ.

### 4.2 Data Portability

VocalIQ provides data export for:

| Data Type | Format | Export Method | Retention After Exit |
|-----------|--------|---------------|---------------------|
| Call recordings | WAV/MP3 | Bulk export API | 30 days after exit completion |
| Call transcripts | JSON/CSV | Bulk export API | 30 days |
| Conversation graphs | YAML/JSON | Configuration export | 30 days |
| Policy rules | OPA/Rego bundles | Configuration export | 30 days |
| Audit records | JSON/CSV | Bulk export API | Per regulatory retention (years) |
| Model performance data | CSV | Report export | 30 days |
| Knowledge base content | Markdown/JSON | Content export | 30 days |

### 4.3 Transition Support

During a planned exit, VocalIQ provides:
- Technical documentation for the bank's replacement integration
- Data export execution and verification
- Parallel operation period (both VocalIQ and replacement running simultaneously)
- Knowledge transfer sessions on configuration and operational procedures
- Post-exit data deletion confirmation

### 4.4 Contractual Exit Provisions

VocalIQ's standard contract includes:
- Right to exit with 90-day notice
- Data export within 30 days of exit request
- Continued access to audit records per regulatory retention requirements
- No lock-in provisions (conversation graphs, policy rules, and knowledge base content are portable)
- Transition assistance fees defined upfront

---

## 5. Third-Party Dependency Management

### 5.1 Critical Dependencies

| Provider | Service | Criticality | Fallback | SLA |
|----------|---------|-------------|----------|-----|
| Cloud provider | Infrastructure | Critical | Cross-region failover | 99.99% |
| Twilio | Telephony | Critical | Vonage/Telnyx | 99.95% |
| Deepgram | STT | Critical | Google Cloud Speech / Whisper | 99.9% |
| LLM Provider | Conversation AI | Critical | Secondary LLM provider | 99.9% |
| Cartesia | TTS | High | ElevenLabs / Azure Speech | 99.9% |
| Bank APIs | Backend systems | High | Degraded mode (per workflow) | Bank-defined |

### 5.2 Provider Risk Assessment

Each third-party provider is assessed for:

- Financial stability (risk of provider shutdown)
- Security posture (SOC 2, ISO 27001, or equivalent)
- Data handling practices (where is data processed, stored, and for how long)
- Change management practices (how model/API updates are communicated)
- Incident response capability (provider SLAs for incident notification)
- Regulatory compliance (data residency, GDPR, DORA cooperation)
- Concentration risk (how many VocalIQ components depend on this provider)

### 5.3 Subprocessor Management

VocalIQ maintains a subprocessor list that is:
- Updated within 30 days of any change
- Available to bank customers on request
- Includes: provider name, service provided, data processed, geographic location of processing, security certifications
- Change notification sent to banks before new subprocessor engagement (per DORA and GDPR requirements)

---

## 6. Business Continuity

### 6.1 Recovery Objectives

| Metric | Target | Notes |
|--------|--------|-------|
| RTO (Recovery Time Objective) | 4 hours for full service, 30 minutes for degraded mode | Time from incident to restored service |
| RPO (Recovery Point Objective) | 0 for call recordings, 5 minutes for operational data | Maximum acceptable data loss |
| MTTR (Mean Time to Repair) | < 2 hours for P1 incidents | Average time to resolve critical incidents |

### 6.2 DR Testing

Disaster recovery testing schedule:

- **Monthly:** Automated failover testing for individual components (database failover, model provider switchover)
- **Quarterly:** Degraded-mode activation testing (simulate component failures, verify fallback behavior)
- **Annually:** Full DR exercise (simulate regional outage, verify cross-region failover, measure RTO/RPO)
- **On change:** Regression testing after infrastructure changes that affect resilience

### 6.3 Capacity Planning

The platform monitors capacity metrics to prevent capacity-related outages:

- Call volume vs. provisioned capacity (alert at 70%, action at 85%)
- Model inference throughput vs. capacity
- Database storage and connection pool utilization
- Network bandwidth utilization
- Cost monitoring (per-call cost trending, provider pricing changes)

Capacity planning reviews occur monthly, with scaling decisions made before demand reaches 80% of provisioned capacity.
