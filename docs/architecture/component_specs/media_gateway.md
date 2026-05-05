# Component Specification: Media Gateway

**Document ID:** DOC_COMP_MG_001  
**Last Updated:** 2026-05-03  
**Owner:** Platform Engineering Lead

**Version History:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-03 | Initial specification |

**Principles Referenced:** S1 (Never build unsafe architecture), S4 (PCI data never reaches LLM), S5 (Audio never goes directly to LLM), G1 (Provider abstraction), G2 (Data plane independence), G3 (Audit sidecar), E1 (Latency transparency), E4 (Multi-tenancy)


**Scope:** Covers the Media Gateway component within the VocalIQ platform. Internal implementation of this component's subcomponents is beyond scope unless it affects interface contracts.

**Assumptions:** Component operates within the VocalIQ reference architecture as defined in reference_architecture.md. Deployment follows the control-plane/data-plane split. All inter-component communication uses mTLS.

**Decisions Made:** Component boundaries and responsibilities follow the pipeline architecture. The 13-section specification template is used instead of narrative format to support direct implementation mapping.

**Alternatives Considered:** Documented in reference_architecture.md and architecture_principles.md at the architecture level. Component-level alternatives are captured in Open Questions (Section 14).

**Risks:** Component-specific failure modes documented in Section 9. Cross-component risks documented in ai_risk_register.md and operational_resilience.md.

**Source Links:** Handoff Section 12, reference_architecture.md, architecture_principles.md, ai_risk_register.md.

---

## 1. Purpose

The Media Gateway is the telephony boundary of the VocalIQ platform. It terminates inbound and outbound voice connections from SIP trunks, WebRTC clients, mobile apps, and cloud telephony providers (Twilio, Telnyx, Vonage), and routes audio streams into the VocalIQ processing pipeline. It also provides the isolated DTMF capture path for PCI-scoped data, enforces call recording consent policy by jurisdiction, and manages call lifecycle events (hold, mute, transfer, conference, disconnect).

The Media Gateway is the first and last component a caller interacts with. It is the boundary between the telephony world and the AI world.

---

## 2. Responsibilities

- Terminate SIP, WebRTC, and provider-specific telephony connections
- Assign call IDs and map them across telephony provider, CCaaS, and VocalIQ identifiers
- Route inbound audio to the Real-Time Speech Layer for ASR processing
- Route TTS audio from the Speech Layer back to the caller
- Enforce call recording consent policy per jurisdiction (single-party, two-party, opt-in, opt-out)
- Play jurisdiction-appropriate recording consent prompts before AI conversation begins
- Provide secure DTMF capture path that bypasses the AI pipeline entirely, delivering sensitive keypad input directly to bank card processors
- Duplicate audio streams for parallel delivery to: ASR, call recording storage, and supervisor monitoring (when active)
- Manage hold, mute, transfer (cold and warm), and conference operations
- Execute warm transfer to human agent queues, passing call context (call ID, transcript summary, authentication state, risk score)
- Activate IVR fallback when the AI pipeline is unavailable (degraded mode Level 3-4)
- Enforce region-aware routing (e.g., Singapore callers to Singapore-region infrastructure)
- Detect and propagate DTMF tones for menu navigation during IVR fallback
- Emit audit events for all call lifecycle transitions

---

## 3. Non-Responsibilities

- Speech recognition (that is the Real-Time Speech Layer)
- Conversation logic (that is the Conversation Runtime)
- Policy decisions (that is the Policy Engine)
- Fraud scoring (that is the Fraud-Aware Identity Layer; the Media Gateway provides call metadata as input signals)
- Audio content analysis (the Media Gateway routes audio, it does not interpret it)
- Call recording storage management (the Media Gateway streams to a recording service; retention and access control are separate concerns)

---

## 4. Inputs

| Input | Source | Format | Notes |
|-------|--------|--------|-------|
| Inbound SIP INVITE | Telephony provider / SIP trunk | SIP/SDP | Call setup with codec negotiation |
| WebRTC offer | Browser/mobile client | SDP over WebSocket | WebRTC signaling |
| Provider webhook | Twilio/Telnyx/Vonage | HTTPS POST (JSON) | Call event notifications |
| TTS audio stream | Real-Time Speech Layer | RTP / audio frames | AI-generated speech for playback to caller |
| Transfer command | Conversation Runtime | Internal RPC | Request to transfer call to human queue |
| Hold/mute command | Conversation Runtime or Human Control Center | Internal RPC | Call state changes |
| Recording policy config | Control Plane (tenant config) | JSON | Per-jurisdiction consent rules |
| Failover trigger | Health monitoring | Internal event | AI pipeline unavailability signal |
| DTMF input | Caller keypad | In-band (RFC 2833) or SIP INFO | Secure capture or IVR navigation |

---

## 5. Outputs

| Output | Destination | Format | Notes |
|--------|-------------|--------|-------|
| Caller audio stream | Real-Time Speech Layer | RTP / audio frames | Continuous during call |
| Audio recording stream | Recording service | Audio stream (configurable codec) | Per recording policy |
| Supervisor audio feed | Human Control Center | Audio stream | When supervisor monitoring is active |
| DTMF digits (secure path) | Bank card processor | Encrypted payload via bank API | PCI-scoped data, bypasses AI pipeline |
| Call lifecycle events | Audit Ledger | Structured events | Call start, end, transfer, hold, etc. |
| Call metadata | Fraud-Aware Identity Layer | JSON | Caller ID, carrier, geographic origin, SIP headers |
| Transfer package | Human agent queue / CCaaS | JSON + audio context | Call ID, transcript, auth state, risk score |
| Failover routing | IVR system / bank backup routing | SIP redirect or provider API | When AI pipeline is unavailable |

---

## 6. APIs

### 6.1 Internal APIs (consumed by other VocalIQ components)

**CallControl API**
- `POST /calls/{call_id}/hold` - Place call on hold with hold music
- `POST /calls/{call_id}/resume` - Resume from hold
- `POST /calls/{call_id}/mute` - Mute caller audio (stop sending to ASR)
- `POST /calls/{call_id}/transfer` - Transfer to target (human queue, extension, external number)
- `POST /calls/{call_id}/conference` - Add party to call
- `POST /calls/{call_id}/disconnect` - End call
- `GET /calls/{call_id}/status` - Current call state and metadata
- `POST /calls/{call_id}/dtmf-capture/start` - Begin secure DTMF capture session
- `POST /calls/{call_id}/dtmf-capture/stop` - End secure DTMF capture session
- `POST /calls/{call_id}/play` - Play audio file or TTS stream to caller

**CallEvents Stream**
- WebSocket endpoint streaming call lifecycle events in real time
- Events: call.started, call.ringing, call.answered, call.hold, call.resume, call.transfer.initiated, call.transfer.completed, call.ended, call.failed, dtmf.received (non-secure only), recording.started, recording.stopped

### 6.2 Provider-Facing APIs (Telephony Provider Abstraction)

```
interface TelephonyProvider {
  acceptInboundCall(callEvent: InboundCallEvent): CallSession
  initiateOutboundCall(target: DialTarget, campaign: CampaignConfig): CallSession
  transferCall(callId: string, target: TransferTarget): TransferResult
  endCall(callId: string, reason: DisconnectReason): void
  playAudio(callId: string, audioStream: AudioStream): void
  startRecording(callId: string, config: RecordingConfig): void
  stopRecording(callId: string): RecordingReference
  sendDTMF(callId: string, digits: string): void
  getCallStatus(callId: string): CallStatus
}
```

Implementations: TwilioProvider, TelnyxProvider, VonageProvider, SIPDirectProvider

---

## 7. Data Models

### 7.1 CallSession

```
CallSession {
  call_id: string (VocalIQ internal ID)
  provider_call_id: string (telephony provider's call ID)
  ccaas_call_id: string (optional, CCaaS system call ID)
  tenant_id: string
  direction: "inbound" | "outbound"
  caller_number: string (E.164)
  called_number: string (E.164)
  provider: string (twilio, telnyx, vonage, sip_direct)
  region: string (sg, eu, uk, us)
  codec: string (g711_ulaw, g711_alaw, opus)
  state: "ringing" | "active" | "hold" | "transferring" | "ended"
  recording_active: boolean
  recording_consent_obtained: boolean
  recording_consent_method: string
  secure_dtmf_active: boolean
  started_at: timestamp
  ended_at: timestamp (nullable)
  disconnect_reason: string (nullable)
  sip_headers: map<string, string> (carrier metadata)
}
```

### 7.2 TransferPackage

```
TransferPackage {
  call_id: string
  tenant_id: string
  target_queue: string
  transfer_type: "warm" | "cold"
  transcript_summary: string
  authentication_state: AuthState
  fraud_risk_score: float
  fraud_signals: string[]
  current_graph_node: string
  slot_values: map<string, any>
  caller_sentiment: string
  vulnerability_flags: string[]
  call_duration_seconds: int
  actions_taken: ActionSummary[]
}
```

---

## 8. Dependencies

| Dependency | Type | Criticality | Fallback |
|-----------|------|-------------|----------|
| Telephony provider (Twilio primary) | External service | Critical | Telnyx or Vonage secondary provider |
| Real-Time Speech Layer | Internal component | Critical | IVR fallback (Level 3) |
| Recording storage service | Internal/external | High | Buffer recordings locally, retry upload |
| Bank card processor (for secure DTMF) | External bank system | High | Transfer to human agent for card data |
| Human agent queue / CCaaS | External bank system | High | Direct SIP transfer to bank routing |
| Audit Ledger | Internal component | High | Buffer events locally, replay when available |

---

## 9. Failure Modes

| Failure | Detection | Response | Recovery |
|---------|-----------|----------|----------|
| Telephony provider outage | Health check failure, connection errors | Switch to secondary telephony provider. New calls route through secondary. Active calls on primary may drop. | Monitor primary, failback when healthy |
| Media Gateway process crash | Health check, watchdog | Orchestrator restarts process. New calls accepted on other instances. Active calls on crashed instance are lost. | Auto-restart, load balancer reroutes |
| Speech Layer unavailable | Connection failure to Speech Layer | Activate IVR fallback (Level 3). Play DTMF menu. Route to human queues. | Monitor Speech Layer, deactivate IVR fallback when healthy |
| Recording service failure | Write errors, timeouts | Buffer audio locally (up to configurable limit). Alert operations. | Flush buffer when recording service recovers |
| Secure DTMF path failure | Bank processor connection error | Transfer caller to human agent for card data capture | Retry connection, alert operations |
| Audio quality degradation | Packet loss monitoring, codec errors | Log quality metrics. Alert if sustained. Consider codec renegotiation. | Automatic codec adjustment where supported |
| Region routing failure | DNS failure, regional infrastructure outage | Route to nearest available region (with latency penalty) | Monitor, restore region routing when available |

---

## 10. Security Controls

- TLS 1.3 for all SIP signaling (SIP over TLS / SRTP for media)
- mTLS for all internal communication with Speech Layer and other components
- Secure DTMF path: DTMF digits captured in isolated memory, encrypted immediately, transmitted to bank processor via dedicated encrypted channel. Digits are never logged, never written to disk, never passed to any AI component.
- Call recording encryption: recordings encrypted at rest (AES-256) with tenant-specific keys
- Caller ID validation: basic ANI verification through telephony provider (note: ANI is not cryptographically secure and is not used as an authentication factor)
- Rate limiting: per-tenant concurrent call limits, per-source-number call frequency limits
- SIP security: SIP message validation, prevention of SIP injection attacks
- Network segmentation: Media Gateway runs in a DMZ with restricted access to internal components
- DDoS protection: telephony-layer rate limiting and provider-level DDoS mitigation

---

## 11. Audit Events

| Event Type | Trigger | Payload |
|-----------|---------|---------|
| call.started | Call answered | call_id, tenant_id, direction, caller_number (redacted last 4), called_number, provider, region, codec |
| call.recording.consent | Consent obtained or declined | call_id, consent_method, consent_result, jurisdiction, timestamp |
| call.recording.started | Recording begins | call_id, recording_id, storage_location |
| call.hold | Call placed on hold | call_id, initiated_by (ai, supervisor, caller_request) |
| call.transfer.initiated | Transfer started | call_id, transfer_type, target_queue, transfer_package_hash |
| call.transfer.completed | Transfer accepted by target | call_id, target_agent_id, handoff_duration_ms |
| call.dtmf.secure_session | Secure DTMF session started/ended | call_id, session_type (card_number, pin), duration_ms (no digit values logged) |
| call.ended | Call disconnected | call_id, duration_seconds, disconnect_reason, disconnect_initiator |
| call.failover | Failover triggered | call_id, failover_level, trigger_reason, target_routing |
| call.quality.alert | Audio quality below threshold | call_id, metric (packet_loss, jitter, mos), value, threshold |

---

## 12. Metrics

| Metric | Type | Description |
|--------|------|-------------|
| mg_calls_active | Gauge | Current active calls per tenant, per region |
| mg_calls_total | Counter | Total calls (inbound/outbound) per tenant |
| mg_call_setup_duration_ms | Histogram | Time from SIP INVITE to call answered |
| mg_call_duration_seconds | Histogram | Total call duration |
| mg_transfer_duration_ms | Histogram | Time from transfer initiation to handoff completion |
| mg_failover_events_total | Counter | Failover activations by level and reason |
| mg_recording_consent_rate | Gauge | Percentage of calls with recording consent obtained |
| mg_audio_quality_mos | Gauge | Estimated Mean Opinion Score per call |
| mg_provider_error_rate | Gauge | Error rate per telephony provider |
| mg_dtmf_secure_sessions_total | Counter | Secure DTMF capture sessions |
| mg_concurrent_calls_utilization | Gauge | Current calls / provisioned capacity |

---

## 13. Test Cases

### Functional Tests

- Inbound call setup and teardown through each telephony provider
- Outbound call with consent verification and campaign controls
- Warm transfer to human queue with complete transfer package
- Cold transfer with caller notification
- Secure DTMF capture: verify digits never appear in logs, transcripts, or audit event payloads
- Recording consent prompt plays before AI conversation starts (per jurisdiction: SG, EU, UK, US)
- Hold and resume with hold music
- Conference bridge creation and teardown
- Call ID mapping: verify VocalIQ call_id, provider call_id, and CCaaS call_id are all linked in audit trail

### Failover Tests

- Primary telephony provider outage: verify automatic switchover to secondary
- Speech Layer unavailable: verify IVR fallback activation within 30 seconds
- Recording service failure: verify local buffering and subsequent flush
- Region routing failure: verify cross-region fallback with acceptable latency
- Full platform unavailable: verify Level 4 emergency routing through pre-configured telephony failover

### Security Tests

- Verify secure DTMF digits cannot be extracted from any log, audit event, or component memory dump
- SIP injection attack resistance
- Verify recording encryption at rest
- Verify mTLS between Media Gateway and all internal components
- Verify rate limiting prevents call flooding

### Performance Tests

- Call setup latency under 500ms at p95
- Concurrent call capacity at provisioned limit
- Audio stream latency contribution under 50ms
- Transfer completion within 3 seconds
- Failover switchover time under 30 seconds

---

## 14. Open Questions

- How should the Media Gateway handle mid-call codec renegotiation when audio quality degrades?
- Should outbound call campaign management be a separate service or part of the Media Gateway?
- How should call recording be handled when a call spans multiple jurisdictions (e.g., caller in Singapore, agent in UK)?
- What is the maximum local recording buffer size before the system must pause recording or transfer to a human agent?
- Should WebRTC connections be terminated at the Media Gateway or at a separate WebRTC gateway that feeds into the Media Gateway?
- How should the Media Gateway handle simultaneous requests to transfer from both the Conversation Runtime and a Human Control Center supervisor?
