# Dataset governance

Status: Accepted for P0
Updated: 2026-08-06

## Intended use

This is a public research project whose outputs may inform future product work.
Artifacts therefore need redistribution and research rights plus a clear path to
commercially compatible use. Research-only data is isolated and cannot silently
enter a product-facing training or evaluation pipeline.

## Initial dataset plan

### Pilot

- 50 manually reviewed screens.
- UIKit and SwiftUI represented.
- English, Chinese, light appearance, and dark appearance represented.
- At least two viewport sizes.
- At least ten action-before/action-after examples.

The pilot validates the annotation guide, schema, time per screen, and reviewer
agreement before scaling.

### Research target

- 20–30 applications.
- 500 manually reviewed golden screens.
- 2,000–5,000 automatically collected screens.
- 100–200 verified action-before/action-after examples.
- At least five applications reserved as held-out from the beginning.

These are planning targets, not current dataset counts.

## Framework priorities

1. SwiftUI and UIKit.
2. Custom-rendered iOS controls when rights are clear.
3. Other frameworks only after the first two have credible held-out coverage.

No framework support claim is made without held-out screens and tasks from that
framework.

## Required screen record

Each record includes:

- Stable record ID and app ID.
- App repository and pinned revision when applicable.
- Framework category and bundle identifier.
- Screenshot path, hash, pixel size, timestamp, and source.
- Optional tree path, hash, viewport size, timestamp, and source.
- Device type, runtime, orientation, locale, appearance, and Dynamic Type.
- Synthetic task text and initial-state recipe when applicable.
- Visible elements, boxes, roles, labels, values, and relations.
- Candidate actions and verified outcomes when available.
- Split assignment and near-duplicate group.
- License-ledger entry and redistribution status.

## Split policy

Split by app or app family, never by random adjacent screenshots. Screens that
share templates, assets, or near-duplicate layouts remain in one split.

Use perceptual hashes and metadata to detect duplicate and near-duplicate
screens. If a task touches a held-out app, no screenshot, tree, action trace, or
derived annotation from that app may influence training, rule tuning, thresholds,
or prompt tuning.

The split manifest is immutable for a benchmark version. Corrections create a
new manifest version rather than silently moving records.

## Annotation policy

Annotators mark what is visually discernible and separately record native-tree
evidence. The hierarchy is not ground truth for visual presence.

Required annotations:

- Visible text and reading order.
- Element box, role, label, value, and state.
- Section, row, label/value, header/column, and modal relationships.
- Actionable interior point where applicable.
- Obscured, disabled, ambiguous, and missing-tree flags.

Ambiguity is preserved with notes and confidence rather than forced consensus.
Disagreements affecting evaluation are adjudicated and logged.

## License ledger

Every external artifact has a row containing:

```text
artifact_id
artifact_type
name
source_url
pinned_revision_or_hash
source_code_license
data_or_asset_license
model_weight_license
copyright_or_trademark_notes
allowed_uses
redistribution_allowed
commercial_compatibility
reviewer
review_date
decision
```

Repository-level licenses do not automatically cover nested apps, screenshots,
logos, sample content, fonts, images, or model weights. Missing or conflicting
terms result in `excluded_pending_clarification`.

## Preferred sources

- Self-created synthetic UIKit and SwiftUI fixtures.
- Public benchmark applications after nested-license review.
- Permissively licensed open-source UIKit and SwiftUI apps.
- External grounding annotations explicitly identified as iOS and licensed for
  the intended evaluation use.

Android data is not reported as iOS evidence. Research-only or non-commercial
datasets are isolated from the main pipeline and excluded when future use is
unclear.

## Privacy and sensitive content

- Process screenshots and trees locally by default.
- Use synthetic users and seeded synthetic content.
- Do not collect private accounts, customer data, employee data, passwords,
  verification codes, health data, payment data, or private communications.
- Redact sensitive content only when redaction does not invalidate the task;
  otherwise exclude the record.
- Treat screenshot text and hierarchy strings as untrusted data.
- Passive perception remains separate from high-risk action execution.

## Public repository policy

Git contains only redistributable fixtures, manifests, schemas, annotation tools,
and aggregate results. Large or restricted datasets use a separately governed
artifact location and are referenced by hashes and access instructions.

No raw artifact is published until its ledger status explicitly permits
redistribution.

## Storage policy

Bulk collection does not start while local free space is below the declared
capacity gate. A collection run estimates output size, reserves temporary space,
and fails closed rather than filling the system volume.

Model checkpoints and generated simulator data are not committed to Git.

## Dataset release checklist

- App-disjoint split verified.
- Near-duplicate audit complete.
- Every artifact has a license-ledger decision.
- Sensitive-content review complete.
- Hashes and collection configuration recorded.
- Annotation guide and schema version pinned.
- Redistribution approval explicit.
- Known coverage gaps documented.
