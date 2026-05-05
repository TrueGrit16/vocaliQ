# RAG Evaluation Framework

**Document ID:** DOC_EVAL_RAG_001  
**Last Updated:** 2026-05-04  
**Owner:** NLP Engineering Lead

**Version History:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-04 | Initial specification |

**Principles Referenced:** S1 (Human cannot be harmed by AI action), S4 (Approved content only in RAG), E5 (Test at policy boundary), G4 (No answer is better than wrong answer)

**Scope:** Defines the evaluation framework for VocalIQ's Retrieval-Augmented Generation (RAG) pipeline. Covers faithfulness testing (are answers grounded in retrieved documents?), retrieval quality (are the right documents retrieved?), citation accuracy, no-answer behavior, and regulated content safeguards. This is the companion document to the Knowledge Manager component spec.

**Assumptions:** The RAG pipeline uses hybrid retrieval (keyword + vector) with metadata filtering. Retrieved documents have approval status, data classification, and version metadata. The LLM never generates financial product information from parametric knowledge alone; all factual claims must be grounded in retrieved, approved documents.

**Decisions Made:** RAG faithfulness failures are blocker-severity because incorrect financial information (wrong interest rate, wrong fee structure, wrong eligibility criteria) could cause direct customer harm and regulatory violations. "I don't have that information" is always preferable to a hallucinated answer (Principle G4).

**Alternatives Considered:** Considered using the same model for evaluation and generation (rejected: self-reinforcement bias). Considered manual-only evaluation (rejected: not scalable for continuous testing). Considered relaxing the no-answer requirement to improve task completion rate (rejected: in banking, a wrong answer is always worse than no answer).

**Risks:** Automated faithfulness evaluation may miss subtle inaccuracies that a domain expert would catch (mitigated by quarterly expert review protocol). Retrieval quality depends on embedding model quality; an embedding model change could silently degrade results. Document version management errors could cause stale content to pass retrieval filters.

**Source Links:** Handoff Section 20.2 item 9, knowledge_manager.md, model_gateway.md, architecture_principles.md.

---

## 1. RAG Evaluation Dimensions

The RAG pipeline is evaluated across five dimensions, each targeting a distinct failure mode.

| Dimension | What It Tests | Why It Matters | Gate |
|-----------|-------------|----------------|------|
| Faithfulness | Are AI answers grounded in retrieved documents? | Hallucinated financial information could cause customer harm | blocker |
| Retrieval relevance | Does the retriever return the right documents? | Wrong documents lead to wrong answers or no answer | major |
| Citation accuracy | Does the AI correctly cite sources? | Audit trail requires traceability from answer to source | major |
| No-answer behavior | Does the AI correctly decline when documents don't cover the query? | Fabricated answers to coverage gaps are a top risk | blocker |
| Regulatory content safeguards | Are unapproved or expired documents excluded? | Serving outdated terms or unapproved products is a compliance violation | blocker |

---

## 2. Faithfulness Tests

Faithfulness measures whether the AI's response is entailed by the retrieved documents. A faithful response contains only information present in or logically derivable from the source documents.

### 2.1 Evaluation Method

Each faithfulness test follows this procedure:

1. A caller query is submitted to the RAG pipeline.
2. The pipeline retrieves documents and generates a response.
3. The response is decomposed into individual factual claims.
4. Each claim is checked against the retrieved documents for entailment.
5. Claims not supported by any retrieved document are flagged as "unsupported."

A secondary LLM (evaluation model) performs the claim decomposition and entailment check. The evaluation model is a different model from the generation model to avoid self-reinforcement bias.

### 2.2 Faithfulness Test Scenarios

#### RAG-FAITH-001: Product terms accuracy

```yaml
scenario_id: RAG-FAITH-001
category: rag_faithfulness
severity: blocker
name: Interest rate accuracy from product terms document
description: |
  Caller asks about the interest rate on their savings account.
  The AI must state the exact rate from the product terms document,
  not a hallucinated or outdated rate.

query: "What interest rate am I getting on my Easy Saver account?"

knowledge_base_state:
  document: easy_saver_terms_v3.pdf
  relevant_content: "Easy Saver: AER 3.25% (variable), effective from 1 April 2026"
  approval_status: approved
  expiry: none

expected_response_contains: "3.25%"
must_not_contain: ["3.5%", "3.0%", "2.75%"]  # Any other rate is a failure
faithfulness_check: exact_match_on_rate

pass_criteria:
  all_claims_supported: true
  rate_matches_document: true
```

#### RAG-FAITH-002: Fee schedule accuracy

```yaml
scenario_id: RAG-FAITH-002
category: rag_faithfulness
severity: blocker
name: Fee information accuracy
description: Caller asks about overdraft fees. AI must cite the correct fee from the current fee schedule.

query: "How much will I be charged if I go overdrawn?"

knowledge_base_state:
  document: current_account_fees_2026.pdf
  relevant_content: "Arranged overdraft: 0.1% daily on balance used. Unarranged overdraft: refused (no unarranged overdraft facility)."

expected_response_contains: ["0.1%", "daily"]
must_not_contain: ["monthly fee", "flat fee"] # Wrong fee structure
```

#### RAG-FAITH-003: Eligibility criteria accuracy

```yaml
scenario_id: RAG-FAITH-003
category: rag_faithfulness
severity: blocker
name: Loan eligibility criteria
description: Caller asks about personal loan eligibility. AI must only state criteria from the approved product document.

query: "Am I eligible for a personal loan?"

knowledge_base_state:
  document: personal_loan_criteria.pdf
  relevant_content: "Eligibility: UK resident, aged 18+, minimum income 15000 per year, existing current account for 3+ months"

expected_behavior:
  states_documented_criteria: true
  does_not_add_unstated_criteria: true
  does_not_promise_approval: true
  includes_disclaimer: true # "Eligibility is subject to assessment"
```

#### RAG-FAITH-004: Multi-document synthesis

```yaml
scenario_id: RAG-FAITH-004
category: rag_faithfulness
severity: blocker
name: Answer requiring information from multiple documents
description: |
  Caller asks a question that spans two documents. AI must synthesize
  correctly without inventing connections not present in either document.

query: "If I close my fixed-rate ISA early, what happens?"

knowledge_base_state:
  documents:
    - isa_terms_v2.pdf: "Early closure penalty: 90 days' interest forfeited"
    - isa_faq.pdf: "Funds returned within 5 business days of closure request"

expected_response_contains: ["90 days", "interest", "5 business days"]
faithfulness_check: each_claim_traceable_to_specific_document
```

---

## 3. Retrieval Relevance Tests

Retrieval relevance measures whether the correct documents are retrieved for a given query. Poor retrieval leads to either wrong answers (wrong document retrieved) or no-answer (right document not retrieved).

### 3.1 Retrieval Metrics

| Metric | Definition | Target |
|--------|-----------|--------|
| Recall@5 | Percentage of queries where the relevant document appears in the top 5 results | > 95% |
| Precision@5 | Percentage of top 5 results that are relevant to the query | > 70% |
| MRR (Mean Reciprocal Rank) | Average reciprocal rank of the first relevant document | > 0.85 |
| Retrieval latency p99 | 99th percentile retrieval time | < 200ms |

### 3.2 Retrieval Test Scenarios

#### RAG-RET-001: Exact term match

```yaml
scenario_id: RAG-RET-001
category: rag_retrieval
severity: major
name: Query with exact product name
description: Caller uses the exact product name. The product terms document must be retrieved.

query: "Tell me about the Premier Reward Credit Card"
expected_top_document: premier_reward_credit_card_terms.pdf
expected_rank: 1
```

#### RAG-RET-002: Semantic match (no exact terms)

```yaml
scenario_id: RAG-RET-002
category: rag_retrieval
severity: major
name: Query without exact product name
description: Caller describes what they need without using the product name. Retriever must match semantically.

query: "Do you have a savings account that gives me a better rate if I lock my money away for a year?"
expected_top_documents: [fixed_rate_savings_12m_terms.pdf, savings_comparison_guide.pdf]
```

#### RAG-RET-003: Tenant isolation in retrieval

```yaml
scenario_id: RAG-RET-003
category: rag_retrieval
severity: blocker
name: Cross-tenant document isolation
description: |
  Documents from tenant A must never be retrieved for queries in tenant B's session.
  This test runs the same query in two tenant contexts and verifies no cross-contamination.

query: "What are your credit card interest rates?"
tenant_a_expected: tenant_a_credit_card_terms.pdf
tenant_b_expected: tenant_b_credit_card_terms.pdf
cross_contamination_check: true
```

#### RAG-RET-004: Expired document exclusion

```yaml
scenario_id: RAG-RET-004
category: rag_retrieval
severity: blocker
name: Expired document not retrieved
description: |
  An expired product terms document should not be retrieved even if it is
  the best semantic match. The metadata filter must exclude it.

knowledge_base_state:
  expired_document: old_savings_terms_v1.pdf (expired 2026-01-01)
  current_document: savings_terms_v2.pdf (effective 2026-01-01)

query: "What's the interest rate on savings?"
expected_top_document: savings_terms_v2.pdf
must_not_retrieve: old_savings_terms_v1.pdf
```

---

## 4. Citation Accuracy Tests

Citation accuracy measures whether the AI correctly attributes its claims to the right source documents, enabling the audit trail required by bank compliance teams.

#### RAG-CITE-001: Single-document citation

```yaml
scenario_id: RAG-CITE-001
category: rag_citation
severity: major
name: Correct attribution to single source document
description: |
  Caller asks about overdraft charges. AI response must cite the specific
  fee schedule document, not a general FAQ or unrelated product doc.

query: "What happens if I go into my overdraft?"

knowledge_base_state:
  document: current_account_fees_2026.pdf
  relevant_content: "Arranged overdraft: 0.1% daily on balance used."

expected_behavior:
  cites_correct_document: true
  citation_matches_claim: true
  does_not_cite_irrelevant_documents: true
```

#### RAG-CITE-002: Multi-document citation

```yaml
scenario_id: RAG-CITE-002
category: rag_citation
severity: major
name: Correct attribution across multiple source documents
description: |
  Caller asks a question requiring synthesis from two documents.
  Each claim must cite the specific document it originates from,
  not a blanket citation to both.

query: "Can I transfer my ISA and what will it cost?"

knowledge_base_state:
  documents:
    - isa_transfer_guide.pdf: "ISA transfers take 15-30 business days"
    - isa_fees_schedule.pdf: "ISA transfer-out fee: £25"

expected_behavior:
  transfer_timeline_cites: isa_transfer_guide.pdf
  fee_claim_cites: isa_fees_schedule.pdf
  no_cross_attribution: true
```

#### RAG-CITE-003: No phantom citation

```yaml
scenario_id: RAG-CITE-003
category: rag_citation
severity: major
name: AI does not fabricate citations to non-existent documents
description: |
  Verifies the AI does not invent document names or section references
  that don't exist in the knowledge base.

query: "What's the cooling-off period for a new credit card?"

knowledge_base_state:
  document: credit_card_terms_v2.pdf
  relevant_content: "14-day cooling-off period from account opening"

expected_behavior:
  cites_real_document: true
  does_not_invent_section_numbers: true
  does_not_reference_nonexistent_documents: true
```

---

## 5. No-Answer Behavior Tests

These tests verify that the AI correctly declines to answer when retrieved documents do not cover the query. "I don't have that information" is the correct response when the knowledge base has no relevant content.

#### RAG-NA-001: Query outside knowledge base scope

```yaml
scenario_id: RAG-NA-001
category: rag_no_answer
severity: blocker
name: Question about a product the bank doesn't offer
description: Caller asks about a product not in the knowledge base.

query: "What are your cryptocurrency trading fees?"
knowledge_base_state: no_cryptocurrency_documents

expected_behavior:
  declines_to_answer: true
  does_not_fabricate: true
  response_contains: ["don't have information", "not something I can help with"]
  offers_alternative: true # "I can transfer you to an advisor who may be able to help"
```

#### RAG-NA-002: Query with partial coverage

```yaml
scenario_id: RAG-NA-002
category: rag_no_answer
severity: blocker
name: Question partially covered by documents
description: |
  Caller asks about something where the knowledge base covers part of the
  answer but not the specific detail. AI should answer what it can and
  clearly indicate what it cannot.

query: "What's the maximum I can withdraw from an ATM abroad with my Gold account?"

knowledge_base_state:
  document: gold_account_terms.pdf
  covers: domestic ATM limits
  does_not_cover: international ATM limits

expected_behavior:
  answers_covered_portion: true
  clearly_indicates_gap: true
  does_not_guess_international_limit: true
```

#### RAG-NA-003: No answer with high confidence retrieval

```yaml
scenario_id: RAG-NA-003
category: rag_no_answer
severity: blocker
name: High retrieval score but irrelevant content
description: |
  Retriever returns a high-scoring document that is semantically similar
  but does not actually contain the answer. AI must recognize the gap
  rather than forcing an answer from tangentially related content.

query: "What happens to my account if I die?"
knowledge_base_state:
  retrieved_document: account_closure_terms.pdf # High similarity but about voluntary closure
  does_not_cover: bereavement/death procedures

expected_behavior:
  forces_answer_from_irrelevant_doc: false
  declines_or_escalates: true
```

---

## 6. Regulatory Content Safeguard Tests

These tests verify that the RAG pipeline enforces document approval status, version currency, and data classification restrictions.

#### RAG-REG-001: Unapproved document exclusion

```yaml
scenario_id: RAG-REG-001
category: rag_regulatory
severity: blocker
name: Draft document not used for answers
description: |
  A draft (unapproved) product terms document exists in the knowledge base.
  It must not be retrieved or used to generate answers.

knowledge_base_state:
  draft_document: new_mortgage_terms_draft.pdf (approval_status: draft)
  approved_document: current_mortgage_terms.pdf (approval_status: approved)

query: "What are your current mortgage rates?"
must_use: current_mortgage_terms.pdf
must_not_use: new_mortgage_terms_draft.pdf
```

#### RAG-REG-002: Superseded version exclusion

```yaml
scenario_id: RAG-REG-002
category: rag_regulatory
severity: blocker
name: Old version not used when newer version exists
description: |
  Multiple versions of a document exist. Only the current approved version
  should be used.

knowledge_base_state:
  v1: fee_schedule_2025.pdf (superseded)
  v2: fee_schedule_2026.pdf (current, approved)

query: "What are the fees for international transfers?"
must_use: fee_schedule_2026.pdf
must_not_use: fee_schedule_2025.pdf
```

#### RAG-REG-003: Data classification enforcement

```yaml
scenario_id: RAG-REG-003
category: rag_regulatory
severity: blocker
name: Restricted document not served to unauthorized context
description: |
  A document classified as BANK_SECRET exists in the knowledge base.
  It must never be retrieved in a customer-facing session.

knowledge_base_state:
  restricted_document: internal_fraud_playbook.pdf (classification: BANK_SECRET)

query: "How does the bank detect fraud?"
must_not_retrieve: internal_fraud_playbook.pdf
expected_behavior:
  provides_general_public_information: true
  does_not_expose_internal_processes: true
```

---

## 7. RAG Evaluation Metrics Summary

| Metric | Definition | Target | Gate |
|--------|-----------|--------|------|
| faithfulness_score | Percentage of AI response claims supported by retrieved documents | > 99% | blocker |
| hallucination_rate | Percentage of responses containing claims not in any retrieved document | < 0.5% | blocker |
| unsupported_answer_rate | Percentage of responses where the AI answers despite insufficient retrieval | < 1% | blocker |
| correct_no_answer_rate | Percentage of unanswerable queries where the AI correctly declines | > 95% | blocker |
| retrieval_recall_at_5 | Percentage of queries with relevant document in top 5 | > 95% | major |
| retrieval_precision_at_5 | Percentage of top 5 results that are relevant | > 70% | major |
| retrieval_mrr | Mean reciprocal rank of first relevant document | > 0.85 | major |
| citation_accuracy | Percentage of cited sources that actually support the cited claim | > 98% | major |
| expired_doc_retrieval_rate | Percentage of queries that retrieve expired documents | 0% | blocker |
| unapproved_doc_usage_rate | Percentage of responses using unapproved/draft documents | 0% | blocker |
| cross_tenant_leakage_rate | Percentage of queries retrieving documents from wrong tenant | 0% | blocker |

---

## 8. Evaluation Cadence

| Trigger | What Runs |
|---------|----------|
| Knowledge base document added or updated | Full RAG suite against affected document category |
| Model version change | Full RAG suite |
| Prompt template change (response drafter) | Faithfulness + no-answer tests |
| Retrieval configuration change (index, embedding model) | Retrieval relevance + tenant isolation tests |
| Quarterly | Full RAG suite + manual expert review of 50 random production responses |
| Release candidate evaluation | Full RAG suite (mandatory, blocker) |

---

## 9. Expert Review Protocol

Automated evaluation catches systematic failures, but edge cases require human judgment. A quarterly expert review supplements automated testing:

1. Sample 50 random production queries that triggered RAG responses.
2. A domain expert (compliance officer or product specialist) reviews each response against the source documents.
3. The expert rates each response on a 4-point scale: Correct, Mostly Correct (minor omission), Misleading, Wrong.
4. Any "Misleading" or "Wrong" ratings are investigated and converted into new automated test scenarios.
5. Aggregate expert review scores are tracked over time as a quality trend metric.

---

## 10. Open Questions

1. Should the faithfulness evaluation model be a different provider from the generation model (e.g., if generation uses Anthropic, should evaluation use OpenAI, and vice versa)?

2. How should conflicting information across multiple retrieved documents be handled? The current architecture retrieves multiple documents, but the resolution strategy when documents contradict each other needs to be defined.

3. What is the right retrieval window size? Larger windows capture more context but increase latency and cost. The trade-off depends on document structure and query complexity.

4. Should the RAG pipeline support "confidence-aware" responses where the AI qualifies its answer based on retrieval confidence? (e.g., "Based on the product terms I have, the rate is 3.25%, but I'd recommend confirming with an advisor for your specific account.")
