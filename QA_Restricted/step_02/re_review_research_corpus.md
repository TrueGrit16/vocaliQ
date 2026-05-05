# QA Re-Review: Step 2 - Research Corpus

**Reviewer:** QA Agent  
**Re-Review Date:** 2026-05-03  
**Previous Verdict:** CONDITIONAL_PASS (3 HIGH findings)  
**Scope:** Verify resolution of HIGH-01, HIGH-02, HIGH-03 from initial review.

---

## HIGH-01: Folder structure incomplete against Section 10.1

**Status: RESOLVED**

All required directories now exist:

- docs/research/market (contains source_index.md)
- docs/research/banking_workflows (empty, expected at this stage)
- docs/research/regulatory (contains source_index.md)
- docs/research/risk (empty, expected)
- docs/architecture/component_specs (empty, expected)
- docs/architecture/api_contracts (empty, expected)
- docs/product (empty, expected)
- docs/evaluation (empty, expected)
- docs/operations (empty, expected)
- docs/00_master_brief.md (present)

Empty directories are acceptable since their content is produced in later steps. The tree is in place for downstream work.

---

## HIGH-02: Missing Section 28 documentation quality bar fields

**Status: RESOLVED**

Both source index files now include all six required Section 28 fields in their front matter:

**Market source_index.md:** Scope (defines included/excluded vendor categories and deferred items), Assumptions (English-language only, vendor claims unverified, pricing point-in-time), Decisions Made (source prioritization rationale, five-category market split, open-source inclusion rationale), Alternatives Considered (combined index rejected, analyst-first approach deferred), Risks (staleness, vendor self-reporting, geographic gaps, missing buyer-side perspectives), Open Questions (analyst report inclusion, dual-role vendor handling).

**Regulatory source_index.md:** Scope (jurisdictions, domain coverage, exclusions, no-legal-conclusions disclaimer), Assumptions (ICT third-party classification, call recording consent, high-risk AI Act trigger, PCI scope minimization), Decisions Made (jurisdiction prioritization, source hierarchy, legal/best-practice split per Section 10.3), Alternatives Considered (jurisdiction-first organization rejected), Risks (regulatory pace, staleness, evolving interpretation), Open Questions (GDPR Article 22 applicability, PCI scope for AI in call flow, MAS AIRG final version delta).

The regulatory index also adds a "Legal Review Required: Yes" top-level flag, which is a useful addition beyond the minimum requirement.

All fields are substantive rather than boilerplate. No concerns.

---

## HIGH-03: No separation of "legal requirement" vs "product best practice"

**Status: RESOLVED**

The regulatory source_index.md now splits product implications into two clearly labeled subsections per entry: "Legal Obligations" and "Product Best Practices." Verified across all 12 completed entries (REG-001 through REG-012).

The front matter includes an explicit note referencing Section 10.3 as the basis for this classification. The "Decisions Made" field also documents this structural choice.

Spot-check examples:

- REG-001 (EU AI Act): Legal Obligations covers high-risk compliance requirements and deadlines. Product Best Practices covers proactive classification, building evaluation lab evidence from day one even for non-high-risk use cases.
- REG-002 (DORA): Legal Obligations covers RoI documentation, incident reporting, exit plans. Product Best Practices covers automated failover, degraded-mode operation, pre-built evidence export templates.
- REG-010 (PCI DSS): Legal Obligations covers mandatory compliance if cardholder data is in scope. Product Best Practices covers designing architecture to stay out of PCI scope entirely.

The separation is clean and the distinction is meaningful in each case. The legal obligations describe what the law mandates; the best practices describe VocalIQ design choices that go further. This is exactly what Section 10.3 called for.

Two entries (REG-004 MAS TRM, REG-006 NIST AI RMF) use the original combined "Product Implications" format. REG-004 is a broad technology risk standard where the obligation/practice line is less clear-cut. REG-006 is a voluntary framework (not regulation), so "Legal Obligations" wouldn't apply. Both are reasonable editorial decisions. No issue raised.

---

## MEDIUM findings (not re-reviewed in detail)

The three HIGH findings were the gate condition. MEDIUM findings (MEDIUM-01 through MEDIUM-05) and LOW findings remain noted from the initial review and should still be addressed before final Step 2 submission, but they do not block progression to Step 3.

---

## Gate Decision

**PASS.** All three HIGH findings are resolved. The folder structure is complete, Section 28 fields are present and substantive in both source indexes, and the regulatory index cleanly separates legal obligations from product best practices. Step 3 may proceed.
