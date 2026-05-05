# QA Team Charter - VocalIQ Bank-Grade Research & Architecture

**Effective:** 2026-05-03  
**Authority:** Chief Product Officer mandate  
**Scope:** All deliverables produced under the VocalIQ Bank-Grade Research & Architecture Handoff

## Purpose

This QA team operates as an independent review function with exclusive write access to the QA_Restricted folder. Its role is to maintain the highest integrity and professional standard across all deliverables, ensuring they meet enterprise bank-grade quality requirements.

## Review Process

1. **Submission:** The production team completes a deliverable and flags it for QA review.
2. **Review:** QA Agent reads the deliverable against the handoff document's acceptance criteria, the documentation quality bar (Section 28), and banking-specific requirements.
3. **Report:** QA produces a review file in `QA_Restricted/step_XX/review_[deliverable].md` containing findings categorized as BLOCKER, HIGH, MEDIUM, or LOW.
4. **Action:** The production team reads the review, addresses all findings, and resubmits.
5. **Re-review:** QA re-reviews and either clears the deliverable or raises new findings.
6. **Gate:** Only when QA clears all BLOCKERs and HIGHs does the production team proceed to the next step.

## Review Criteria

Every deliverable is assessed against:

- **Completeness:** Does it cover everything the handoff mandates for this step?
- **Specificity:** Does it use concrete controls, not vague statements like "ensure compliance"?
- **Source quality:** Are claims sourced, dated, and confidence-rated?
- **Banking relevance:** Does it reflect actual banking operations, not generic tech content?
- **Consistency:** Does it align with the product thesis, architecture principles, and prior deliverables?
- **Actionability:** Can an engineering or compliance team act on this without guessing?
- **Professional tone:** Is it written at a level suitable for a bank CRO, CISO, or Enterprise Architect?

## Severity Levels

- **BLOCKER:** Missing critical content, factual error, or unsafe recommendation. Must fix before proceeding.
- **HIGH:** Significant gap or vagueness that would undermine bank credibility. Must fix before proceeding.
- **MEDIUM:** Improvement needed for professional quality. Fix before final submission.
- **LOW:** Minor suggestion or polish. Address at discretion.

## Independence

QA findings are not negotiable on BLOCKER items. The production team may propose alternatives for HIGH items with justification, but QA makes the final call on whether the step is cleared.
