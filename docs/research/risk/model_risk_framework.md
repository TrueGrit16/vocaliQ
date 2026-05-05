# Model Risk Management Framework: VocalIQ AI Models

**Document ID:** DOC_MODEL_RISK_001  
**Last Updated:** 2026-05-03  
**Owner:** Model Risk Owner

**Version History:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-03 | Initial framework covering model inventory, validation, monitoring, and governance |

**Purpose:** Define the model risk management framework for all AI/ML models used in VocalIQ's voice AI platform. This framework ensures compliance with bank regulatory expectations (OCC 2011-12 / SR 11-7, MAS AIRG, EU AI Act model documentation requirements) and establishes the processes for model inventory, validation, deployment, monitoring, and retirement.

**Scope:** Covers all models in the VocalIQ platform: large language models (LLM), speech-to-text (STT), text-to-speech (TTS), intent classification, sentiment analysis, vulnerability detection, fraud risk scoring, voice liveness detection, and any future model additions. Covers both third-party hosted models and any models trained or fine-tuned by VocalIQ.

**Assumptions:** Most models in the initial architecture are third-party hosted (Deepgram for STT, Cartesia for TTS, commercial LLM provider for conversation runtime per provisional defaults). VocalIQ does not train foundation models but may fine-tune classification models. Third-party model providers may update their models without notice, creating version management challenges.

**Decisions Made:** Framework structured around the SR 11-7 lifecycle (development, validation, deployment, monitoring, retirement) because US banking regulators set the most prescriptive model risk requirements and other jurisdictions' requirements are generally compatible with this structure. Model risk tier classification (Critical, High, Medium, Low) determines the depth of validation and monitoring required.

**Alternatives Considered:** EU AI Act risk classification as the primary framework (rejected because AI Act categories don't map directly to individual model validation requirements). Simplified two-tier model classification (rejected because the range of models in VocalIQ spans from critical decision-making to cosmetic quality, requiring more granularity).

**Risks:** Third-party model providers may not support the level of documentation and transparency that bank model risk teams expect. Model validation for LLMs is a developing practice without established industry standards. Model monitoring may generate false drift alerts due to normal variation in caller demographics.

**Open Questions:** How should VocalIQ handle model risk for models embedded in third-party services (e.g., fraud scoring models within the bank's existing fraud platform)? Should VocalIQ maintain a shadow model for comparison testing against the primary LLM provider?

**Source Links:** OCC 2011-12 (Model Risk Management), SR 11-7, MAS AIRG, EU AI Act, NIST AI RMF, handoff Section 11 (architecture), ai_risk_register.md.

---

## 1. Model Inventory

Every model deployed in VocalIQ must be registered in the Model Registry. The registry is the authoritative source for what models are running, their versions, their risk tier, and their validation status.

### 1.1 Model Catalog

| Model ID | Model Type | Purpose | Provider | Risk Tier | Deployment |
|----------|-----------|---------|----------|-----------|------------|
| MOD-001 | Large Language Model | Conversation runtime: intent understanding, response generation, action planning | Commercial LLM provider (via Model Gateway) | Critical | Hosted API |
| MOD-002 | Speech-to-Text | Real-time speech recognition | Deepgram Nova-3 (provisional) | Critical | Hosted API |
| MOD-003 | Text-to-Speech | Voice response synthesis | Cartesia Sonic-3 (provisional) | High | Hosted API |
| MOD-004 | Intent Classifier | First-pass intent classification for routing | VocalIQ fine-tuned (on Model Gateway) | High | Self-hosted |
| MOD-005 | Sentiment/Emotion | Caller sentiment and emotion detection | VocalIQ or third-party | Medium | Self-hosted or API |
| MOD-006 | Vulnerability Detection | Detect vulnerability indicators in speech | VocalIQ fine-tuned | High | Self-hosted |
| MOD-007 | Fraud Risk Scoring | Composite fraud risk score per call | VocalIQ (Fraud-Aware Identity Layer) | Critical | Self-hosted |
| MOD-008 | Voice Liveness | Detect synthetic/deepfake voice | VocalIQ or third-party | Critical | Self-hosted |
| MOD-009 | Advice Boundary Detection | Detect when responses cross into financial advice | VocalIQ fine-tuned or rule-based | High | Self-hosted |
| MOD-010 | Complaint Classification | Classify complaint type and severity | VocalIQ fine-tuned | Medium | Self-hosted |
| MOD-011 | Social Engineering Detection | Detect social engineering patterns in conversation | VocalIQ | High | Self-hosted |
| MOD-012 | VAD (Voice Activity Detection) | Detect speech vs. silence for turn management | Open-source (Silero VAD or similar) | Low | Self-hosted |

### 1.2 Model Risk Tiers

| Tier | Criteria | Validation Depth | Monitoring Frequency |
|------|----------|-----------------|---------------------|
| Critical | Model failure could cause direct customer harm, financial loss, or regulatory violation. Model makes or directly influences decisions about customer accounts. | Full independent validation. Adversarial testing. Annual re-validation. | Continuous (real-time monitoring with daily performance reports) |
| High | Model failure degrades service quality or creates compliance risk. Model influences routing, escalation, or information presentation. | Independent validation. Scenario testing. Annual re-validation. | Daily performance metrics, weekly trend analysis |
| Medium | Model failure affects user experience but doesn't create direct harm or compliance risk. | Internal validation. Standard testing. Biannual re-validation. | Weekly performance metrics, monthly trend analysis |
| Low | Model failure causes minor quality degradation with easy fallback. | Internal testing. Annual re-validation. | Monthly performance metrics |

---

## 2. Model Documentation Requirements

Every model must have a model card that contains:

### 2.1 Model Card Template

**Identity:** Model ID, name, version, provider, deployment date, last validation date, next validation due date, risk tier, owner.

**Purpose:** What the model does, why it exists, what decisions it influences, which workflows depend on it.

**Architecture:** Model type (transformer, classifier, rule-based hybrid), size (parameters if applicable), training data description (for VocalIQ-trained models), fine-tuning data description.

**Performance:** Key performance metrics with current values and acceptable thresholds. For each metric: what it measures, how it's calculated, current value, threshold for alert, threshold for action.

**Limitations:** Known limitations, failure modes, edge cases, populations where performance may degrade.

**Fairness:** Demographic performance breakdown (where measurable). Known biases. Mitigation approaches. Monitoring plan.

**Dependencies:** What the model depends on (input data sources, feature pipelines, other models). What depends on the model (downstream systems, decisions).

**Monitoring:** What is monitored, at what frequency, what triggers alerts, what triggers re-validation.

**Fallback:** What happens if the model fails or is unavailable. Degraded-mode behavior. Rollback procedure.

### 2.2 Documentation by Risk Tier

| Documentation Element | Critical | High | Medium | Low |
|----------------------|----------|------|--------|-----|
| Full model card | Required | Required | Required (simplified) | Internal doc |
| Performance metrics | Comprehensive | Standard | Key metrics only | Basic |
| Fairness assessment | Required | Required | If applicable | Not required |
| Adversarial testing | Required | Recommended | Not required | Not required |
| Independent validation | Required | Required | Internal | Internal |
| Regulatory mapping | Required | Required | If applicable | Not required |

---

## 3. Model Validation

### 3.1 Validation Process

**Pre-deployment validation (all tiers):**
1. Model card completed and reviewed
2. Performance benchmarked on standard test set
3. Edge case testing (accent diversity for STT, adversarial prompts for LLM, etc.)
4. Integration testing (model works correctly within VocalIQ pipeline)
5. Regression testing (new model doesn't degrade performance of existing workflows)

**Additional for Critical/High tiers:**
6. Independent validation (reviewer who did not develop or select the model)
7. Adversarial testing (prompt injection, social engineering, deepfake samples)
8. Fairness testing (performance across demographic proxies)
9. Stress testing (performance under load, with degraded inputs, with missing data)
10. Regulatory compliance check (does the model's documentation meet SR 11-7, MAS AIRG, EU AI Act requirements?)

### 3.2 Validation for Third-Party Models

Third-party hosted models (LLM, STT, TTS) present unique validation challenges:

**What we can validate:**
- End-to-end performance on VocalIQ test suites
- Behavior consistency across versions (regression testing when provider updates)
- Integration behavior (latency, error handling, fallback)
- Output quality and safety (adversarial testing of integrated system)

**What we cannot validate:**
- Training data composition and quality
- Internal model architecture and weights
- Provider-side deployment and infrastructure security
- Provider-side monitoring and incident response

**Mitigation for validation gaps:**
- Contractual requirements for model change notification
- Provider security assessments (SOC 2, ISO 27001 or equivalent)
- Comprehensive black-box testing on VocalIQ test suites
- Model Gateway abstraction allowing provider switch if validation concerns arise
- Version pinning to prevent unannounced model changes

### 3.3 Validation Triggers

Re-validation is required when:
- Model version changes (provider update or VocalIQ model retrain)
- Performance monitoring detects drift beyond threshold
- New workflow is added that depends on the model
- Regulatory requirements change
- Security vulnerability discovered in the model or model provider
- Scheduled periodic re-validation (per risk tier frequency)

---

## 4. Model Deployment

### 4.1 Deployment Process

1. Validation complete and approved
2. Model card updated with deployment details
3. Canary deployment (small percentage of traffic)
4. Performance comparison against baseline (A/B testing where feasible)
5. Gradual rollout if canary succeeds
6. Full deployment with monitoring activation
7. Post-deployment validation check (first 24/48/72 hours)

### 4.2 Version Management

The Model Gateway maintains version tracking for all models:

- Every model call is logged with model ID and version
- Version pinning prevents automatic updates
- Rollback to previous version within minutes
- A/B testing capability for model comparison
- Audit trail of all version changes with approval chain

### 4.3 Multi-Provider Strategy

For critical models, VocalIQ maintains primary and fallback providers:

| Model Type | Primary Provider | Fallback Provider | Switchover Trigger |
|-----------|-----------------|-------------------|-------------------|
| LLM | Provider A (TBD) | Provider B (TBD) | Latency > threshold, error rate > threshold, provider outage |
| STT | Deepgram Nova-3 | Google Cloud Speech or Whisper | Same triggers |
| TTS | Cartesia Sonic-3 | ElevenLabs or Azure Speech | Same triggers |

Fallback providers are validated against the same test suites as primary providers. Performance differences are documented and acceptable degradation is defined.

---

## 5. Model Monitoring

### 5.1 Monitoring Metrics by Model Type

**LLM (MOD-001):**
- Hallucination rate (percentage of responses not grounded in retrieved data or approved content)
- Policy violation rate (responses flagged by Policy Engine)
- Advice boundary violation rate
- Response relevance score (automated evaluation)
- Latency (time to first token, total response time)
- Prompt injection detection rate (adversarial inputs correctly identified)

**STT (MOD-002):**
- Word error rate (WER) overall and by segment (accent, noise level, language)
- Critical data accuracy (card numbers, amounts, dates, names)
- Latency (time to transcription)
- Confidence distribution (are scores well-calibrated?)

**TTS (MOD-003):**
- Naturalness score (automated MOS estimation)
- Intelligibility (are callers asking for repeats?)
- Latency (time to first audio)
- Caller satisfaction proxy (call completion rate, repeat call rate)

**Fraud models (MOD-007, MOD-008, MOD-011):**
- Detection rate (true positives / total positives)
- False positive rate (genuine callers incorrectly flagged)
- False negative rate (fraud not detected)
- Score calibration (are risk scores predictive of actual fraud?)

**Classification models (MOD-004, MOD-005, MOD-006, MOD-009, MOD-010):**
- Accuracy, precision, recall, F1
- Confusion matrix analysis
- Confidence calibration
- Drift detection (distribution shift in predictions)

### 5.2 Alert Thresholds

| Metric | Warning Threshold | Action Threshold | Response |
|--------|------------------|------------------|----------|
| LLM hallucination rate | > 2% | > 5% | Warning: investigate. Action: reduce autonomy, increase human review. |
| STT WER | > 8% | > 12% | Warning: investigate. Action: switch to fallback provider. |
| Fraud false positive rate | > 5% | > 10% | Warning: retune thresholds. Action: adjust scoring model. |
| Fraud false negative rate | > 1% | > 3% | Warning: investigate. Action: lower detection thresholds (accepting more false positives). |
| Policy violation rate | > 0.5% | > 1% | Warning: investigate. Action: add policy rules, restrict model output. |
| Latency (any model) | > 2x baseline | > 3x baseline | Warning: investigate. Action: switch to fallback provider. |

### 5.3 Drift Detection

The monitoring system tracks distribution shifts in:
- Model input distributions (are callers saying different things?)
- Model output distributions (is the model responding differently?)
- Performance metric trends (are error rates increasing?)
- Demographic performance gaps (is accuracy diverging across populations?)

Drift is detected using statistical tests (KS test, PSI) comparing current windows against baseline. Detected drift triggers investigation and potential re-validation.

---

## 6. Model Governance

### 6.1 Governance Structure

| Role | Responsibility |
|------|---------------|
| Model Risk Owner | Overall accountability for model risk framework. Approves Critical-tier model deployments. Reports to risk committee. |
| Model Validation Team | Conducts independent validation for Critical/High-tier models. Reviews model cards. |
| Model Development Team | Builds, trains, fine-tunes VocalIQ models. Produces model documentation. |
| Platform Engineering | Operates Model Gateway, monitoring infrastructure, deployment pipeline. |
| Compliance | Ensures regulatory alignment of model documentation and processes. |

### 6.2 Approval Requirements

| Action | Critical Tier | High Tier | Medium Tier | Low Tier |
|--------|-------------|-----------|-------------|---------|
| New model deployment | Model Risk Owner + Compliance | Model Risk Owner | Development Lead | Development Lead |
| Model version update | Model Risk Owner | Model Risk Owner | Development Lead | Automated with monitoring |
| Provider change | Model Risk Owner + CTO | Model Risk Owner | Development Lead | Development Lead |
| Threshold change | Model Risk Owner | Development Lead | Development Lead | Automated |
| Model retirement | Model Risk Owner + CTO | Model Risk Owner | Development Lead | Development Lead |

### 6.3 Regulatory Reporting

The model risk framework supports regulatory reporting requirements:

- **MAS AIRG:** AI inventory exports, model risk assessments, human oversight documentation
- **SR 11-7 / OCC 2011-12:** Model inventory, validation reports, ongoing monitoring reports, model change logs
- **EU AI Act:** Technical documentation for high-risk AI systems, model performance metrics, human oversight records
- **Bank internal audit:** Model risk assessment reports, validation coverage, exception tracking

Reports are generated from the Model Registry and monitoring infrastructure. Export formats are configurable per bank requirements.
