# Component Specification: RAG / Knowledge Service

**Document ID:** DOC_COMP_RAG_001  
**Last Updated:** 2026-05-03  
**Owner:** Knowledge Engineering Lead

**Version History:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-03 | Initial specification |

**Principles Referenced:** S2 (AI decisions through policy), G3 (Audit sidecar), G6 (Graphs deterministic), E3 (Prefer explicit), E5 (Test at policy boundary), E7 (Document decisions)


**Scope:** Covers the RAG / Knowledge Service component within the VocalIQ platform. Internal implementation of this component's subcomponents is beyond scope unless it affects interface contracts.

**Assumptions:** Component operates within the VocalIQ reference architecture as defined in reference_architecture.md. Deployment follows the control-plane/data-plane split. All inter-component communication uses mTLS.

**Decisions Made:** Component boundaries and responsibilities follow the pipeline architecture. The 13-section specification template is used instead of narrative format to support direct implementation mapping.

**Alternatives Considered:** Documented in reference_architecture.md and architecture_principles.md at the architecture level. Component-level alternatives are captured in Open Questions (Section 14).

**Risks:** Component-specific failure modes documented in Section 9. Cross-component risks documented in ai_risk_register.md and operational_resilience.md.

**Source Links:** Handoff Section 12, reference_architecture.md, architecture_principles.md, ai_risk_register.md.

---

## 1. Purpose

The RAG/Knowledge Service provides approved, citation-backed answers from bank-controlled knowledge bases. When the Conversation Runtime needs factual information to answer a caller's question (product features, interest rates, branch hours, process instructions, eligibility criteria), it queries this service rather than relying on the LLM's training data.

This is not naive vector search over all bank documents. The knowledge service enforces document approval workflows, jurisdiction and product filtering, ACLs, citation validation, conflict detection, and no-answer behavior when the knowledge base cannot provide a reliable answer. Every answer the AI gives about bank products or services must be traceable to an approved, versioned source document.

---

## 2. Responsibilities

- Document ingestion: accept bank documents (PDFs, HTML, markdown, structured content) through an approval workflow
- Document metadata management: track jurisdiction, product line, customer segment, effective dates, expiry dates, and approval status per document
- Version management: maintain document versions and track which version was active at the time of any given answer
- Access control: enforce per-document ACLs (some documents may be restricted to certain customer segments or products)
- Hybrid search: combine keyword search and vector search for retrieval
- Reranking: apply a reranking model to improve retrieval precision
- Query normalization: handle synonyms, abbreviations, and colloquial phrasing
- Jurisdiction/product/segment filtering: apply metadata filters before retrieval to ensure only relevant documents are searched
- Citation validation: verify that the generated answer is actually supported by the retrieved documents
- Conflict detection: identify when retrieved documents contain contradictory information (e.g., two documents state different interest rates)
- No-answer behavior: when the knowledge base cannot provide a reliable answer, return an explicit "no answer" rather than guessing
- Effective date enforcement: only return content from documents that are currently effective (not expired, not future-dated)

---

## 3. Non-Responsibilities

- Answer generation (the Conversation Runtime or Model Gateway generates the answer using retrieved context)
- Policy decisions about whether the caller can receive the information (Policy Engine)
- Document creation or authoring (bank's content management process)
- Speech synthesis of the answer (Speech Layer)
- General LLM inference (Model Gateway)

---

## 4. Inputs

| Input | Source | Format | Notes |
|-------|--------|--------|-------|
| Knowledge query | Conversation Runtime | JSON | Query text, filters (jurisdiction, product, segment) |
| Documents for ingestion | Bank content team (via Control Plane) | PDF, HTML, markdown, JSON | New or updated knowledge content |
| Document metadata | Bank content team | JSON | Jurisdiction, product, segment, effective dates, ACLs |
| Approval status updates | Content approval workflow | JSON | Approved, rejected, pending review |
| Embedding model config | Control Plane | JSON | Embedding model selection, chunk size, overlap |

---

## 5. Outputs

| Output | Destination | Format | Notes |
|--------|-------------|--------|-------|
| Retrieval result | Conversation Runtime | JSON (see example) | Retrieved chunks with citations and scores |
| No-answer signal | Conversation Runtime | JSON | Explicit signal that knowledge base has no answer |
| Conflict alert | Conversation Runtime, Audit Ledger | JSON | Contradictory documents detected |
| Ingestion events | Audit Ledger | Structured events | Document ingested, updated, deprecated |

### Example Retrieval Result

```json
{
  "query_id": "q_789",
  "call_id": "call_123",
  "query_text": "What is the interest rate for savings accounts?",
  "results": [
    {
      "document_id": "doc_savings_rates_2026",
      "document_title": "Retail Savings Account Interest Rates",
      "document_version": "v3.2",
      "chunk_id": "chunk_042",
      "chunk_text": "The standard interest rate for Individual Savings Accounts is 0.75% p.a. for balances up to SGD 50,000 and 1.25% p.a. for balances above SGD 50,000, effective from 1 March 2026.",
      "relevance_score": 0.94,
      "jurisdiction": "SG",
      "product": "retail_savings",
      "effective_from": "2026-03-01",
      "effective_until": null,
      "approval_status": "approved",
      "approved_by": "content_team_sg"
    }
  ],
  "conflicts_detected": false,
  "answer_available": true,
  "retrieval_latency_ms": 85,
  "documents_searched": 142,
  "chunks_evaluated": 1247
}
```

---

## 6. APIs

### 6.1 Query API

**RetrieveKnowledge**
- `POST /query` - Retrieve knowledge for a caller question
  - Input: query_text, jurisdiction, product, customer_segment, call_id, tenant_id, max_results
  - Returns: RetrievalResult with ranked chunks, citations, conflict flags, answer_available flag
  - Latency target: under 200ms at p95

### 6.2 Document Management API

**Documents**
- `POST /documents` - Ingest a new document
  - Input: document content, metadata (jurisdiction, product, segment, effective dates)
  - Returns: document_id, ingestion_status, chunk_count
- `PUT /documents/{document_id}` - Update document content or metadata
- `DELETE /documents/{document_id}` - Deprecate a document (soft delete, not hard delete)
- `GET /documents/{document_id}` - Get document metadata and status
- `GET /documents` - List documents with filtering

**Approval Workflow**
- `POST /documents/{document_id}/approve` - Approve a document for use
- `POST /documents/{document_id}/reject` - Reject a document
- `GET /documents/pending` - List documents pending approval

**Versions**
- `GET /documents/{document_id}/versions` - List all versions of a document
- `GET /documents/{document_id}/versions/{version}` - Get a specific version

### 6.3 Evaluation API

**RAGEval**
- `POST /evaluate` - Run RAG evaluation on a test dataset
  - Input: test questions with expected answers and source documents
  - Returns: faithfulness score, relevance score, citation accuracy

---

## 7. Data Models

### 7.1 Document

```
Document {
  document_id: string
  tenant_id: string
  title: string
  source_url: string (nullable)
  content_type: "pdf" | "html" | "markdown" | "json"
  version: string
  status: "draft" | "pending_approval" | "approved" | "deprecated"
  jurisdictions: string[]
  products: string[]
  customer_segments: string[]
  effective_from: date
  effective_until: date (nullable)
  acl: DocumentACL
  ingested_at: timestamp
  approved_at: timestamp (nullable)
  approved_by: string (nullable)
  chunk_count: int
  embedding_model: string
  tags: string[]
}
```

### 7.2 DocumentChunk

```
DocumentChunk {
  chunk_id: string
  document_id: string
  document_version: string
  chunk_index: int
  chunk_text: string
  embedding: float[] (vector)
  metadata: ChunkMetadata
}
```

### 7.3 ChunkMetadata

```
ChunkMetadata {
  section_title: string
  page_number: int (for PDFs)
  content_type: "narrative" | "table" | "list" | "faq"
  keywords: string[]
  entities: string[] (product names, regulatory references)
}
```

---

## 8. Dependencies

| Dependency | Type | Criticality | Fallback |
|-----------|------|-------------|----------|
| Vector database (pgvector primary) | Data store | Critical | Read replica. If fully unavailable, return no-answer for all queries. |
| Embedding model | Model (via Model Gateway or self-hosted) | High | Cached embeddings remain available. New document ingestion paused. |
| Reranking model | Model | Medium | Skip reranking, use raw retrieval scores. Accept lower precision. |
| Audit Ledger | Sidecar | High | Buffer events locally |
| Conversation Runtime | Consumer | Critical | No queries without consumer |

---

## 9. Failure Modes

| Failure | Detection | Response | Recovery |
|---------|-----------|----------|----------|
| Vector database unavailable | Connection failure | Return no-answer for all queries. Conversation Runtime falls back to "I don't have that information right now, let me transfer you." | Monitor database, resume when available |
| Embedding model unavailable | API error | Existing document embeddings still work (search functions). New document ingestion is paused. | Monitor embedding service, resume ingestion when available |
| Search returns low-confidence results | All results below relevance threshold | Return no-answer. Do not fabricate answers from weak matches. | Log for query analysis, may indicate missing content |
| Conflict detected | Contradictory chunks from different documents | Flag conflict in response. Conversation Runtime uses the more recently effective document and adds caveat. Conflict logged for content team review. | Content team resolves conflict by deprecating or updating documents |
| Document ingestion failure | Processing error | Document marked as failed. Content team notified. Not available for retrieval until reprocessed. | Retry ingestion, investigate if persistent |
| Stale content (document past effective_until date) | Date comparison | Exclude expired documents from results. If the only relevant document is expired, return no-answer. | Content team updates or extends effective dates |

---

## 10. Security Controls

- mTLS for all internal communication
- Document ACLs enforced at query time (a customer segment that shouldn't see wealth-tier content won't receive it)
- Document content encrypted at rest (AES-256)
- Vector embeddings do not contain recoverable PII (but chunk text might, so access is controlled)
- No cross-tenant document access (tenant isolation at the database level)
- Document approval workflow prevents unapproved content from being served to callers
- Audit trail tracks who approved each document and when
- Content team access is role-based (viewers vs. editors vs. approvers)

---

## 11. Audit Events

| Event Type | Trigger | Payload |
|-----------|---------|---------|
| rag.query.executed | Knowledge retrieval request | query_id, call_id, tenant_id, query_hash, result_count, top_relevance_score, answer_available |
| rag.query.no_answer | No suitable results found | query_id, call_id, reason (low_relevance, no_documents, expired_only) |
| rag.conflict.detected | Contradictory documents found | query_id, document_ids, conflict_description |
| rag.document.ingested | New document ingested | document_id, tenant_id, content_type, chunk_count, ingested_by |
| rag.document.approved | Document approved for use | document_id, approved_by, effective_from |
| rag.document.deprecated | Document deprecated | document_id, deprecated_by, reason |
| rag.document.version_updated | Document version changed | document_id, from_version, to_version |

---

## 12. Metrics

| Metric | Type | Description |
|--------|------|-------------|
| rag_query_latency_ms | Histogram | Query processing latency |
| rag_result_relevance_score | Histogram | Top result relevance score distribution |
| rag_no_answer_rate | Gauge | Percentage of queries returning no answer |
| rag_conflict_rate | Gauge | Percentage of queries with conflicting results |
| rag_documents_total | Gauge | Total documents per tenant and status |
| rag_documents_expired | Gauge | Documents past effective_until date |
| rag_ingestion_queue_depth | Gauge | Documents pending ingestion |
| rag_citation_accuracy | Gauge | Citation validation pass rate (sampled) |
| rag_chunks_searched | Histogram | Number of chunks evaluated per query |

---

## 13. Test Cases

### Retrieval Tests

- Query about savings interest rate returns the correct, currently effective document
- Query filtered by jurisdiction (SG) does not return EU-only documents
- Query filtered by product (retail) does not return business banking documents
- Expired document is excluded from results even if highly relevant
- Pending-approval document is excluded from results
- ACL enforcement: wealth-tier document not returned for retail customer segment queries

### No-Answer Tests

- Query about a product not in the knowledge base returns no-answer (not a hallucinated answer)
- Query with only low-confidence matches returns no-answer
- Query where all relevant documents are expired returns no-answer

### Conflict Detection Tests

- Two documents with different interest rates for the same product: verify conflict flag
- Document updated but old version not yet deprecated: verify the newer version takes precedence

### Ingestion Tests

- PDF document ingested, chunked, and embedded correctly
- Document metadata (jurisdiction, product, effective dates) correctly indexed
- Document approval workflow: unapproved document not queryable, approved document queryable

### Performance Tests

- Query latency under 200ms at p95 with 100,000+ chunks in the database
- Support 500 concurrent queries per instance
- Document ingestion throughput: 100 documents per minute

---

## 14. Open Questions

- Should the knowledge service support multi-language retrieval (e.g., query in Mandarin retrieves an English document with Mandarin translation)?
- How should the service handle documents that reference other documents (e.g., "see our Terms and Conditions for details")?
- Should the service support structured data retrieval (e.g., fee schedules, rate tables) with different chunking and retrieval strategies than narrative content?
- How should the conflict detection model be trained or tuned for banking-specific contradictions (e.g., promotional rate vs. standard rate)?
- Should the service support real-time document updates (effective immediately for active calls) or only at session boundaries?
- How should the evaluation methodology handle questions that have legitimately different answers depending on context (e.g., different rates for different balances)?
