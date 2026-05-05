# Component Specification: Real-Time Speech Layer

**Document ID:** DOC_COMP_SL_001  
**Last Updated:** 2026-05-03  
**Owner:** Speech Engineering Lead

**Version History:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-03 | Initial specification |

**Principles Referenced:** S4 (PCI data never reaches LLM), S5 (Audio never goes to LLM), G1 (Provider abstraction), G3 (Audit sidecar), G5 (Model version pinning), E1 (Latency transparency), E2 (Observability)


**Scope:** Covers the Real-Time Speech Layer component within the VocalIQ platform. Internal implementation of this component's subcomponents is beyond scope unless it affects interface contracts.

**Assumptions:** Component operates within the VocalIQ reference architecture as defined in reference_architecture.md. Deployment follows the control-plane/data-plane split. All inter-component communication uses mTLS.

**Decisions Made:** Component boundaries and responsibilities follow the pipeline architecture. The 13-section specification template is used instead of narrative format to support direct implementation mapping.

**Alternatives Considered:** Documented in reference_architecture.md and architecture_principles.md at the architecture level. Component-level alternatives are captured in Open Questions (Section 14).

**Risks:** Component-specific failure modes documented in Section 9. Cross-component risks documented in ai_risk_register.md and operational_resilience.md.

**Source Links:** Handoff Section 12, reference_architecture.md, architecture_principles.md, ai_risk_register.md.

---

## 1. Purpose

The Real-Time Speech Layer converts live telephony audio into usable streaming text (ASR) and converts AI-generated text responses into natural, interruptible speech (TTS). It sits between the Media Gateway and the Conversation Runtime and is responsible for voice activity detection, streaming speech recognition, endpointing, barge-in detection, language detection, confidence scoring, and PII/PCI redaction on transcribed text before it reaches any AI component.

This layer propagates uncertainty upward. A low-confidence transcript restricts action autonomy in downstream components. The Speech Layer does not make decisions about what to do with the speech; it provides the highest-quality transcription it can, along with calibrated confidence scores that tell downstream components how much to trust the output.

---

## 2. Responsibilities

- Voice Activity Detection (VAD): detect when the caller is speaking vs. silence, background noise, hold music, or non-speech audio
- Streaming ASR: convert caller audio to text in real time, producing partial hypotheses as speech progresses and final transcripts when the turn is complete
- Endpointing: determine when the caller has finished speaking (semantic turn detection, not just silence-based)
- Barge-in detection: detect when the caller starts speaking while TTS is playing, cancel TTS playback, and switch to ASR mode
- TTS synthesis: convert AI-generated text to natural speech audio, stream to Media Gateway for caller playback
- TTS cancellation: immediately stop TTS playback when barge-in is detected or when the system needs to interrupt
- Language detection: identify the language being spoken (supporting multi-language jurisdictions like Singapore)
- Code-switching handling: manage mid-sentence language switches common in multilingual environments
- Confidence scoring: produce per-word and per-utterance confidence scores, plus audio quality assessment
- PII/PCI redaction: scan transcribed text for sensitive data patterns (card numbers, SSNs, account numbers) and redact before forwarding to the Conversation Runtime
- Noise and telephony degradation handling: maintain reasonable performance on low-quality telephony audio (G.711, packet loss, background noise)

---

## 3. Non-Responsibilities

- Conversation logic or intent classification (Conversation Runtime)
- Policy decisions about what to do with uncertain transcriptions (Policy Engine)
- Call routing or telephony signaling (Media Gateway)
- Model selection decisions (Model Gateway decides which LLM to use; Speech Layer manages its own ASR/TTS provider selection)
- Fraud scoring based on speech patterns (Fraud-Aware Identity Layer, though Speech Layer provides raw signals)

---

## 4. Inputs

| Input | Source | Format | Notes |
|-------|--------|--------|-------|
| Caller audio stream | Media Gateway | RTP / audio frames (G.711, Opus) | Continuous during call |
| Response text | Conversation Runtime | Text string with SSML annotations | Text to synthesize as speech |
| TTS cancel command | Conversation Runtime | Internal RPC | Stop current TTS playback |
| Language hint | Tenant config / call metadata | ISO 639 language code | Expected primary language |
| ASR provider config | Control Plane | JSON | Provider selection, model version, custom vocabulary |
| TTS provider config | Control Plane | JSON | Provider selection, voice ID, speaking rate |
| Redaction rules | Control Plane | JSON | PII/PCI patterns and replacement rules |

---

## 5. Outputs

| Output | Destination | Format | Notes |
|--------|-------------|--------|-------|
| Streaming transcript | Conversation Runtime | JSON (see example below) | Partial and final hypotheses with confidence |
| TTS audio stream | Media Gateway | Audio frames | Synthesized speech for caller playback |
| Redaction events | Audit Ledger | Structured event | What was redacted, pattern matched, position in transcript |
| Audio quality metrics | Observability | Metrics | SNR, codec quality, packet loss, estimated MOS |
| Language detection result | Conversation Runtime | JSON | Detected language with confidence |
| Barge-in event | Conversation Runtime | Internal event | TTS interrupted by caller speech |
| VAD events | Observability | Metrics | Speech/silence transitions, timing |

### Example Transcript Output

```json
{
  "turn_id": "turn_123",
  "call_id": "call_456",
  "transcript_type": "final",
  "asr_text": "I lost my card and there are charges I don't recognize",
  "asr_text_redacted": "I lost my card and there are charges I don't recognize",
  "language": "en-SG",
  "asr_confidence": 0.86,
  "word_confidences": [
    {"word": "lost", "confidence": 0.94, "start_ms": 120, "end_ms": 340},
    {"word": "card", "confidence": 0.96, "start_ms": 360, "end_ms": 520},
    {"word": "charges", "confidence": 0.78, "start_ms": 780, "end_ms": 1020}
  ],
  "audio_quality": {
    "snr_db": 22,
    "codec": "g711_ulaw",
    "packet_loss_pct": 0.01,
    "estimated_mos": 3.8
  },
  "redactions_applied": [],
  "risk_flags": ["possible_fraud_dispute"],
  "asr_provider": "deepgram",
  "asr_model_version": "nova-3-2026-04",
  "processing_latency_ms": 180
}
```

---

## 6. APIs

### 6.1 Internal APIs

**TranscriptionStream API**
- WebSocket endpoint: streaming transcription results per call
- Message types: `partial_transcript`, `final_transcript`, `language_detected`, `barge_in`, `vad_state_change`, `audio_quality_update`

**TTSRequest API**
- `POST /tts/synthesize` - Start TTS synthesis and streaming
  - Input: text (with optional SSML), voice_id, speaking_rate, call_id
  - Returns: stream_id, estimated_duration_ms
- `POST /tts/cancel/{stream_id}` - Cancel active TTS playback
- `GET /tts/voices` - List available TTS voices per language/region

**SpeechLayerControl API**
- `POST /calls/{call_id}/asr/start` - Begin ASR processing for a call
- `POST /calls/{call_id}/asr/stop` - Stop ASR processing
- `PUT /calls/{call_id}/asr/config` - Update ASR configuration mid-call (e.g., switch language model)
- `GET /calls/{call_id}/asr/status` - Current ASR state and metrics

### 6.2 Provider Abstraction Interfaces

```
interface ASRProvider {
  startStream(config: ASRConfig): ASRStream
  processAudio(stream: ASRStream, audioChunk: AudioFrame): void
  getPartialResult(stream: ASRStream): PartialTranscript
  getFinalResult(stream: ASRStream): FinalTranscript
  endStream(stream: ASRStream): void
  getSupportedLanguages(): Language[]
  getModelVersions(): ModelVersion[]
}

interface TTSProvider {
  synthesize(text: string, config: TTSConfig): AudioStream
  cancel(streamId: string): void
  getVoices(language: string): Voice[]
  getModelVersions(): ModelVersion[]
}
```

Implementations: DeepgramASR, GoogleCloudSpeechASR, WhisperASR, AzureSpeechASR, CartesiaTTS, ElevenLabsTTS, AzureTTS

---

## 7. Data Models

### 7.1 ASRConfig

```
ASRConfig {
  provider: string
  model_version: string (pinned)
  language: string (ISO 639)
  additional_languages: string[] (for code-switching)
  sample_rate: int (8000 for telephony, 16000 for WebRTC)
  encoding: string (linear16, mulaw, alaw, opus)
  enable_word_timestamps: boolean
  enable_word_confidences: boolean
  custom_vocabulary: string[] (bank-specific terms)
  profanity_filter: boolean
  endpointing_config: EndpointingConfig
  vad_config: VADConfig
}
```

### 7.2 EndpointingConfig

```
EndpointingConfig {
  silence_threshold_ms: int (default: 700)
  semantic_endpointing: boolean (default: true)
  max_turn_duration_ms: int (default: 30000)
  interim_results_interval_ms: int (default: 100)
}
```

### 7.3 RedactionRule

```
RedactionRule {
  rule_id: string
  pattern_type: "regex" | "ner" | "luhn"
  pattern: string
  data_classification: "pci" | "pii" | "sensitive"
  replacement: string (e.g., "[REDACTED_CARD]")
  enabled: boolean
  jurisdictions: string[] (where this rule applies)
}
```

---

## 8. Dependencies

| Dependency | Type | Criticality | Fallback |
|-----------|------|-------------|----------|
| Deepgram Nova-3 (primary ASR) | External API | Critical | Google Cloud Speech or Whisper (secondary ASR) |
| Cartesia Sonic-3 (primary TTS) | External API | Critical | ElevenLabs or Azure Speech (secondary TTS) |
| Silero VAD (or equivalent) | Self-hosted model | High | Simple energy-based VAD |
| Media Gateway | Internal component | Critical | None (no audio source without Media Gateway) |
| Conversation Runtime | Internal component | Critical | IVR fallback via Media Gateway |
| Audit Ledger | Internal component | High | Buffer redaction events locally |

---

## 9. Failure Modes

| Failure | Detection | Response | Recovery |
|---------|-----------|----------|----------|
| Primary ASR provider outage | API errors, circuit breaker trips | Switch to secondary ASR provider. Log provider switch. Accept potential quality degradation. | Monitor primary, switchback when healthy |
| Primary TTS provider outage | API errors, circuit breaker trips | Switch to secondary TTS provider. Caller hears different voice. | Monitor primary, switchback when healthy |
| ASR latency spike | Latency monitoring exceeds 2x baseline | Alert operations. If sustained, switch to secondary provider. | Investigate root cause with provider |
| VAD failure | No speech detection on active call with audio | Fall back to energy-based VAD. Log anomaly. | Restart VAD model, investigate |
| Redaction engine failure | Processing error in redaction pipeline | BLOCK transcript from reaching Conversation Runtime. Transfer to human. Never forward unredacted text. | Restart redaction service, resume ASR |
| Language detection failure | Low confidence on language detection | Default to configured primary language. Log uncertainty. | Continue with best guess, allow Conversation Runtime to request language clarification |
| TTS synthesis failure | API error or timeout | Play pre-recorded fallback message ("Please hold"). Transfer to human. | Retry TTS, switch provider if persistent |

---

## 10. Security Controls

- All ASR/TTS provider communication over TLS 1.3
- mTLS between Speech Layer and all internal VocalIQ components
- PII/PCI redaction runs in-process before any transcript leaves the Speech Layer
- Redaction is fail-closed: if the redaction engine fails, transcripts are blocked, not forwarded unredacted
- Audio streams are not persisted by the Speech Layer (recording is a separate path via Media Gateway)
- ASR provider data processing agreements must prohibit training on VocalIQ customer audio
- Custom vocabulary lists are tenant-specific and isolated
- TTS voice cloning protections: VocalIQ uses pre-approved synthetic voices only, no caller voice replication

---

## 11. Audit Events

| Event Type | Trigger | Payload |
|-----------|---------|---------|
| speech.turn.started | VAD detects speech onset | call_id, turn_id, timestamp |
| speech.turn.completed | Endpointing triggers | call_id, turn_id, duration_ms, asr_confidence, language, word_count |
| speech.redaction.applied | PII/PCI pattern detected in transcript | call_id, turn_id, redaction_rule_id, data_classification, position (no original text) |
| speech.redaction.failed | Redaction engine error | call_id, turn_id, error, action_taken (transcript_blocked) |
| speech.tts.started | TTS synthesis begins | call_id, tts_stream_id, text_length_chars, voice_id, provider |
| speech.tts.cancelled | Barge-in or explicit cancel | call_id, tts_stream_id, reason, audio_played_pct |
| speech.provider.switched | ASR or TTS provider failover | call_id, provider_type (asr/tts), from_provider, to_provider, reason |
| speech.language.detected | Language identification | call_id, detected_language, confidence, previous_language |
| speech.quality.degraded | Audio quality below threshold | call_id, metric, value, threshold |

---

## 12. Metrics

| Metric | Type | Description |
|--------|------|-------------|
| sl_asr_latency_ms | Histogram | Time from audio to final transcript per turn |
| sl_tts_latency_ms | Histogram | Time from text to first audio chunk |
| sl_asr_confidence | Histogram | Per-turn ASR confidence distribution |
| sl_word_error_rate | Gauge | Estimated WER (sampled, compared against human transcription) |
| sl_redaction_events_total | Counter | Redaction events by data_classification |
| sl_barge_in_rate | Gauge | Percentage of TTS turns interrupted by barge-in |
| sl_language_detection_accuracy | Gauge | Language detection accuracy (sampled) |
| sl_provider_error_rate | Gauge | Error rate per ASR/TTS provider |
| sl_provider_latency_ms | Histogram | Per-provider latency distribution |
| sl_active_streams | Gauge | Current active ASR streams |
| sl_tts_naturalness_mos | Gauge | Estimated MOS score for TTS output (sampled) |

---

## 13. Test Cases

### Functional Tests

- Streaming ASR produces accurate transcripts for clear English speech (WER < 8%)
- Streaming ASR handles Singapore English, Singlish, code-switching (English/Mandarin, English/Malay)
- PCI redaction: card numbers in speech (spoken digit by digit or as a block) are redacted before transcript reaches Conversation Runtime
- PII redaction: NRIC numbers, phone numbers, addresses are redacted per configured rules
- TTS produces natural speech with configurable voice, rate, and language
- Barge-in: caller interruption stops TTS within 200ms and ASR resumes immediately
- Endpointing: semantic endpointing handles natural pauses (e.g., caller thinking) without premature cutoff
- Language detection: correctly identifies English, Mandarin, Malay, Tamil for Singapore deployment
- Confidence scores are well-calibrated (high-confidence transcripts are more accurate than low-confidence ones)

### Provider Failover Tests

- ASR provider switch: primary Deepgram fails, secondary activates within 5 seconds
- TTS provider switch: primary Cartesia fails, secondary activates within 5 seconds
- Verify call continuity during provider switch (no dropped turns)

### Security Tests

- Redaction fail-closed: when redaction engine crashes, verify transcript is blocked, not forwarded
- Verify no PCI data appears in any log, metric, or audit event payload
- Verify provider data processing agreements are enforced (no training on customer audio)

### Performance Tests

- ASR latency: final transcript within 300ms of speech end at p95
- TTS latency: first audio chunk within 200ms at p95
- VAD latency: speech detection within 200ms at p95
- Concurrent stream capacity at provisioned limit
- Performance under telephony degradation: G.711 with 1% packet loss, 15dB SNR

---

## 14. Open Questions

- Should the Speech Layer support real-time speaker diarization (distinguishing between multiple speakers on the same call, e.g., during a conference)?
- How should code-switching be handled for ASR: single multilingual model, or dynamic model switching?
- Should the Speech Layer provide emotion/sentiment signals from prosody analysis, or should that be a separate model in the pipeline?
- What is the minimum acceptable ASR accuracy for the system to continue in AI mode vs. transferring to a human agent?
- Should TTS support SSML input for fine-grained prosody control, or should a simplified markup be used?
- How should the Speech Layer handle very long caller turns (e.g., a caller describing a complex fraud scenario for 2+ minutes)?
