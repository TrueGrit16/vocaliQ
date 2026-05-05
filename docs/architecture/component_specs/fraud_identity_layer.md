# Component Specification: Fraud-Aware Identity Layer

**Document ID:** DOC_COMP_FIL_001  
**Last Updated:** 2026-05-03  
**Owner:** Fraud Engineering Lead

**Version History:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-03 | Initial specification |

**Principles Referenced:** S2 (AI decisions through policy), S3 (Failure defaults to human), G4 (Authentication explicitly tracked), E1 (Latency transparency), E2 (Observability), E4 (Multi-tenancy)


**Scope:** Covers the Fraud-Aware Identity Layer component within the VocalIQ platform. Internal implementation of this component's subcomponents is beyond scope unless it affects interface contracts.

**Assumptions:** Component operates within the VocalIQ reference architecture as defined in reference_architecture.md. Deployment follows the control-plane/data-plane split. All inter-component communication uses mTLS.

**Decisions Made:** Component boundaries and responsibilities follow the pipeline architecture. The 13-section specification template is used instead of narrative format to support direct implementation mapping.

**Alternatives Considered:** Documented in reference_architecture.md and architecture_principles.md at the architecture level. Component-level alternatives are captured in Open Questions (Section 14).

**Risks:** Component-specific failure modes documented in Section 9. Cross-component risks documented in ai_risk_register.md and operational_resilience.md.

**Source Links:** Handoff Section 12, reference_architecture.md, architecture_principles.md, ai_risk_register.md.

---

## 1. Purpose

The Fraud-Aware Identity Layer determines what the AI is allowed to say and do based on caller identity, authentication strength, and fraud risk. It tracks authentication state per session, orchestrates step-up authentication, ingests risk signals from multiple sources (caller ID, device, channel, account history, behavioral patterns, voice biometrics where available, synthetic voice detection), and produces a composite fraud risk score that the Policy Engine uses to gate actions.

Voice biometrics and deepfake detection are risk signals, not absolute identity decisions. They contribute to the risk score but never serve as sole authentication factors.

---

## 2. Responsibilities

- Track authentication state per call session: maintain explicit auth level (AUTH_0 through AUTH_5) and manage transitions
- Orchestrate step-up authentication: when higher auth is required, coordinate with bank IAM for OTP, app push, secure link, or knowledge-based verification
- Ingest and correlate risk signals: caller ID, carrier metadata, device reputation, channel characteristics, account activity history, behavioral anomalies, voice biometric scores, synthetic voice detection scores
- Compute composite fraud risk score: weighted combination of all signal categories (caller identity 30%, behavioral 25%, session 20%, transaction 25%)
- Update risk score dynamically during the call as new signals arrive
- Enforce risk score floor: the score never decreases below the floor set by pre-call signals (prevents "trust-earning" social engineering)
- Multi-session correlation: track caller patterns across sessions to detect distributed attacks (multiple calls, gradual escalation)
- Scam/coercion detection: analyze speech patterns for coaching indicators, unusual pauses, scripted responses, whispered instructions
- Voice liveness detection: detect artifacts of synthetic voice (unnatural spectral patterns, missing micro-pauses, latency artifacts)
- Safe callback protocol: when high fraud risk is detected, recommend call termination and callback to the customer's registered number
- Account takeover detection: identify patterns consistent with ATO (contact detail changes, rapid escalation, concurrent sessions)

---

## 3. Non-Responsibilities

- Policy decision enforcement (Policy Engine consumes the risk score and makes allow/deny decisions)
- Conversation logic (Conversation Runtime)
- Voice biometric enrollment or management (bank's voice biometric system, if any)
- Fraud investigation or case management (bank's fraud operations team)
- Call recording or transcription (Speech Layer, Media Gateway)

---

## 4. Inputs

| Input | Source | Format | Notes |
|-------|--------|--------|-------|
| Call metadata | Media Gateway | JSON | Caller ID, carrier, SIP headers, geographic origin |
| Authentication events | Bank IAM (via orchestration) | JSON | OTP result, app push result, KBA result |
| Transcript turns | Conversation Runtime | JSON (redacted) | For behavioral analysis and scam detection |
| Account activity | Bank systems (via Tool Gateway) | JSON | Recent transactions, login attempts, changes |
| Voice biometric score | Bank voice biometric system (if available) | float | Voiceprint match confidence |
| Voice liveness score | Internal liveness model (MOD-008) | float | Synthetic voice probability |
| Social engineering indicators | Internal detection model (MOD-011) | JSON | Detected social engineering patterns |
| Behavioral signals | Internal analysis | JSON | Response timing, speech cadence, hesitation patterns |

---

## 5. Outputs

| Output | Destination | Format | Notes |
|--------|-------------|--------|-------|
| Authentication state | Conversation Runtime, Policy Engine | JSON | Current auth level (AUTH_0-AUTH_5) |
| Fraud risk score | Policy Engine, Conversation Runtime | float (0-100) | Composite risk score |
| Risk signal breakdown | Human Control Center | JSON | Contributing signals for supervisor review |
| Step-up auth request | Media Gateway / bank IAM | JSON | Initiate OTP, app push, or secure link |
| Fraud alert | Human Control Center, bank fraud team | JSON | When risk exceeds critical threshold |
| Scam warning | Conversation Runtime | JSON | Trigger proactive scam warning to caller |
| Multi-session correlation events | Audit Ledger | Structured events | Cross-session pattern detection |

---

## 6. APIs

### 6.1 Authentication State API

**AuthState**
- `GET /sessions/{session_id}/auth` - Get current authentication state
  - Returns: auth_level, methods_used, last_auth_timestamp, step_up_available_methods
- `POST /sessions/{session_id}/auth/step-up` - Initiate step-up authentication
  - Input: required_level, preferred_method, call_id
  - Returns: auth_challenge (OTP sent, push notification sent, etc.)
- `POST /sessions/{session_id}/auth/verify` - Verify step-up response
  - Input: verification_data (OTP code, push confirmation, KBA answers)
  - Returns: verification_result, new_auth_level

### 6.2 Risk Score API

**RiskScore**
- `GET /sessions/{session_id}/risk` - Get current risk score and breakdown
  - Returns: composite_score, signal_breakdown, risk_level, recommended_actions
- `POST /sessions/{session_id}/risk/signals` - Submit additional risk signals
  - Input: signal_type, signal_data
  - Returns: updated_score

### 6.3 Fraud Detection API

**FraudDetection**
- `POST /sessions/{session_id}/analyze` - Analyze a turn for fraud indicators
  - Input: transcript (redacted), behavioral_data, session_context
  - Returns: fraud_indicators, updated_risk_score, recommended_actions
- `GET /callers/{caller_id}/history` - Get caller history for multi-session correlation
  - Returns: session_history, pattern_flags, cumulative_risk_indicators

### 6.4 Risk Signal Interface

```
interface FraudSignalProvider {
  getCallerRiskSignals(callerId: string): CallerRiskSignals
  getDeviceRiskSignals(deviceId: string): DeviceRiskSignals
  getAccountRiskSignals(accountId: string): AccountRiskSignals
  submitFraudEvent(event: FraudEvent): void
}
```

---

## 7. Data Models

### 7.1 SessionRiskProfile

```
SessionRiskProfile {
  session_id: string
  call_id: string
  tenant_id: string
  auth_level: AuthLevel (AUTH_0 through AUTH_5)
  auth_methods_used: AuthMethod[]
  composite_risk_score: float (0-100)
  risk_floor: float (minimum score, set from pre-call signals)
  risk_level: "low" | "elevated" | "high" | "very_high" | "critical"
  signal_breakdown: {
    caller_identity: float
    behavioral: float
    session: float
    transaction: float
  }
  active_fraud_indicators: FraudIndicator[]
  scam_probability: float
  voice_liveness_score: float
  multi_session_flags: string[]
  last_updated: timestamp
}
```

### 7.2 FraudIndicator

```
FraudIndicator {
  indicator_id: string
  type: "synthetic_voice" | "social_engineering" | "authority_claim" |
        "urgency_pattern" | "coaching_detected" | "ato_pattern" |
        "multi_session_escalation" | "geographic_anomaly" | "timing_anomaly"
  confidence: float
  detected_at: timestamp
  contributing_signals: string[]
  description: string
}
```

### 7.3 AuthLevel Enumeration

```
AUTH_0: Unknown caller. No identification. Informational (A0) only.
AUTH_1: Caller identified by ANI/caller ID. Low confidence. A1 routing.
AUTH_2: Basic authentication (KBA or single-factor). A2 read-only.
AUTH_3: Step-up authentication (OTP, app push). A3/A4 actions.
AUTH_4: Strong multi-factor authentication. Contact detail changes, high-value actions.
AUTH_5: Human-verified, high assurance. Exceptional cases only.
```

---

## 8. Dependencies

| Dependency | Type | Criticality | Fallback |
|-----------|------|-------------|----------|
| Bank IAM / authentication service | External bank system | Critical for auth | If IAM unavailable, no step-up auth possible. Session stays at current auth level. Policy Engine restricts actions accordingly. |
| Voice liveness model (MOD-008) | Internal model | High | If unavailable, liveness score excluded from risk calculation. Conservative (higher) score applied. |
| Social engineering detection model (MOD-011) | Internal model | High | If unavailable, social engineering indicators not available. Conservative adjustment. |
| Bank fraud platform | External bank system | Medium | If unavailable, external fraud signals excluded. Internal signals still function. |
| Caller history database | Internal data store | High | If unavailable, no multi-session correlation. Each call treated independently. |
| Policy Engine | Consumer of risk score | Critical | If Policy Engine unavailable, risk score still computed but not acted upon (Conversation Runtime handles by transferring to human) |

---

## 9. Failure Modes

| Failure | Detection | Response | Recovery |
|---------|-----------|----------|----------|
| Bank IAM unavailable | Connection failure, timeout | No step-up authentication possible. Session remains at current auth level. Actions requiring higher auth are denied by Policy Engine. | Monitor IAM, retry when available |
| Voice liveness model crash | Model health check | Exclude liveness from risk calculation. Apply conservative adjustment (+10 to risk score). | Restart model, resume when healthy |
| Risk score computation failure | Internal error | Apply maximum risk score (100). Transfer to human. | Investigate, restart, resume |
| Multi-session database unavailable | Connection failure | Each call treated independently. Alert operations. Higher false-negative risk for distributed ATO. | Monitor, reconnect |
| Scam detection model crash | Model health check | Scam detection inactive. Apply conservative adjustment. Alert operations. | Restart model |
| OTP delivery failure | Bank IAM error | Offer alternative step-up method (app push, secure link). If all methods fail, transfer to human. | Retry, escalate to bank IAM support |

---

## 10. Security Controls

- mTLS for all internal and bank IAM communication
- Authentication state is cryptographically bound to the session (cannot be forged or replayed)
- Risk signals from external sources are validated and sanitized before inclusion in risk calculation
- Multi-session correlation data uses hashed caller identifiers (not raw phone numbers) for storage
- Voice biometric data (voiceprints) is never stored by VocalIQ; only scores from the bank's biometric system are consumed
- Voice liveness analysis operates on derived features, not raw audio
- Safe callback protocol uses only the customer's registered phone number (from bank records), never a number provided during the call
- Rate limiting on authentication attempts (prevent brute-force OTP guessing)
- Session-level risk score is not disclosed to the caller (prevents attackers from gaming the scoring)

---

## 11. Audit Events

| Event Type | Trigger | Payload |
|-----------|---------|---------|
| identity.auth.level_changed | Authentication state transition | session_id, from_level, to_level, method_used |
| identity.auth.step_up.initiated | Step-up auth requested | session_id, required_level, method |
| identity.auth.step_up.succeeded | Step-up verification passed | session_id, method, new_level |
| identity.auth.step_up.failed | Step-up verification failed | session_id, method, failure_reason, attempt_count |
| identity.risk.score_updated | Risk score changed | session_id, previous_score, new_score, trigger_signal |
| identity.risk.threshold_crossed | Score crossed risk level boundary | session_id, new_risk_level, triggered_action |
| identity.fraud.indicator_detected | Fraud indicator identified | session_id, indicator_type, confidence |
| identity.fraud.alert_generated | Risk score reached critical | session_id, risk_score, indicators, alert_destination |
| identity.scam.warning_triggered | Scam probability exceeded threshold | session_id, scam_probability, contributing_signals |
| identity.multisession.pattern_detected | Cross-session pattern found | caller_hash, pattern_type, sessions_involved |
| identity.liveness.assessment | Voice liveness check completed | session_id, liveness_score, synthetic_probability |

---

## 12. Metrics

| Metric | Type | Description |
|--------|------|-------------|
| fil_risk_score_distribution | Histogram | Risk score distribution across sessions |
| fil_auth_level_distribution | Gauge | Current sessions by auth level |
| fil_step_up_success_rate | Gauge | Step-up authentication success rate by method |
| fil_step_up_latency_ms | Histogram | Step-up auth completion time |
| fil_fraud_indicators_total | Counter | Fraud indicators by type |
| fil_fraud_alerts_total | Counter | Critical-level fraud alerts generated |
| fil_scam_detection_rate | Gauge | Scam detection trigger rate |
| fil_liveness_score_distribution | Histogram | Voice liveness score distribution |
| fil_multisession_patterns_total | Counter | Multi-session patterns detected |
| fil_false_positive_rate | Gauge | Estimated false positive rate (genuine callers flagged) |

---

## 13. Test Cases

### Authentication Tests

- New call starts at AUTH_0, identify by ANI moves to AUTH_1
- Successful KBA moves from AUTH_1 to AUTH_2
- Successful OTP step-up moves from AUTH_2 to AUTH_3
- Failed OTP attempt: verify attempt counter increments, auth level unchanged
- OTP brute-force protection: verify account lockout after max attempts

### Risk Scoring Tests

- Low-risk call (known customer, normal time, low-risk request): verify score 0-30
- Elevated risk (VoIP call, unusual time): verify score 31-50, step-up triggered
- High risk (synthetic voice detected, coaching patterns): verify score 71-85, human transfer
- Critical risk (confirmed deepfake, ATO pattern): verify score 86-100, call termination and alert
- Risk floor enforcement: verify score cannot decrease below pre-call floor regardless of positive signals

### Fraud Detection Tests

- Synthetic voice sample: verify liveness detection flags the call
- Social engineering script (authority claim, urgency creation): verify pattern detection
- Multi-session ATO attempt (3 calls with escalating requests): verify cross-session correlation detects pattern
- APP scam indicators (coached responses, unusual pauses): verify scam probability elevation
- Genuine caller with legitimate urgency: verify false positive rate is acceptable

### Safe Callback Tests

- High-risk detected: verify safe callback uses registered number only
- Caller provides alternative number for callback: verify system ignores provided number

### Performance Tests

- Risk score update within 20ms of new signal
- Step-up auth orchestration overhead under 500ms (excluding bank IAM response time)
- Multi-session lookup under 50ms
- Support 2000 concurrent session risk profiles

---

## 14. Open Questions

- How should the risk score weighting (30/25/20/25) be calibrated, and should it be adjustable per bank based on their fraud patterns?
- Should the Fraud-Aware Identity Layer support continuous voice biometric verification during the call (not just at authentication), or would this create unacceptable latency?
- How should the system handle legitimate customers who trigger false positives repeatedly (e.g., an elderly customer who sounds coached because they're reading from notes)?
- Should multi-session correlation data be shared across tenants (anonymized) to detect attackers targeting multiple banks?
- How should the system handle the transition from no-voice-biometric to voice-biometric authentication as banks adopt this technology over time?
