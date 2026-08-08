# Pilot annotation guide

Status: Accepted for pilot trial
Version: 0.1.0
Updated: 2026-08-08

## Annotation unit

Annotate one stable screenshot at a time. The screenshot is the authority for
visual presence. A native tree is separate supporting evidence and may be stale,
missing, incomplete, or inconsistent with the screenshot.

Use only synthetic accounts and seeded content. Exclude a record if private or
sensitive content cannot be removed without changing the task.

## Required pass

1. Confirm screenshot integrity, viewport, locale, appearance, orientation, and
   capture metadata.
2. Mark every task-relevant visible element and all visible text needed to
   understand the screen.
3. Assign role, label, value, frame, visible state, enabled state, selected state,
   and confidence without inventing unavailable values.
4. Record reading order and section, row, label/value, and modal relationships.
5. For actionable elements, mark one interior point that is visibly within the
   intended target and record its coordinate space.
6. Compare tree evidence, preserving missing-tree, conflicting, obscured,
   disabled, and ambiguous flags.
7. Record a concise note for every ambiguity that could change evaluation.

Unknown is distinct from false. Use `null` for evidence that is not available;
do not infer disabled, hidden, or unselected from a missing attribute.

## Element boundaries

- Use the smallest visible region that represents the interactive or semantic
  element.
- A control and its visible text may be one element when they form one target.
- Keep a row and its child label/value elements separate when their relationships
  matter.
- Do not annotate invisible hit-area expansion as visual bounds.
- Clip partially visible elements to the viewport and mark them as obscured.
- Decorative images without task or semantic value may be omitted, but the
  omission rule must be applied consistently.

## Roles and labels

Choose the most specific role supported by visible or native evidence. Use
`unknown` when evidence is insufficient. Preserve displayed text as written,
including language and punctuation. Do not translate labels in the annotation.

Icon-only controls use `icon_button` only when actionability is supported. Their
label may come from the native tree, but provenance must identify that source.
Do not name an icon solely from reviewer expectation.

## Reading order and relations

Reading order follows the visually natural order for the recorded locale. Record
containment separately from semantic relations. The minimum relation vocabulary
for the pilot is:

- `contains`
- `reading_before`
- `label_for`
- `value_for`
- `row_in`
- `section_in`
- `presented_by`

If two plausible orders remain, record the ambiguity instead of forcing a high
confidence ordering.

## Action verification

Candidate actions are hypotheses. A verified action pair requires an executed
coordinate action, an after screenshot, a reviewer-confirmed outcome, and matching
environment metadata. Native identifiers may help audit provenance but cannot be
used to execute the main representation benchmark.

## Review states

- `single_review`: one completed annotation.
- `agreement`: two reviewers agree on evaluation-relevant fields.
- `adjudicated`: a disagreement was resolved with a logged rationale.

The first five pilot records receive two reviews. After that checkpoint, double
review may focus on held-out records and ambiguous examples. All 50 records still
receive at least one named human review.

## Reviewer checklist

- Screenshot and tree timestamps are not conflated.
- Boxes use the declared coordinate space.
- No visible task-critical text is missing.
- Tree-only elements are not marked visually present without evidence.
- Unknown values remain unknown.
- Action points lie inside the intended visible target.
- Ambiguities and disagreements are preserved.
- The manifest record, annotation hash, and license entry agree.
