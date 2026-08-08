# Evaluation contract

Status: Accepted for P0
Updated: 2026-08-06

## Purpose

This contract isolates the value of a UI representation from planner quality,
privileged actions, initial-state differences, and hidden information.

## Baseline representations

| ID | Observation | Purpose |
| --- | --- | --- |
| B0 | Raw screenshot | Visual baseline |
| B1 | Raw native hierarchy (XML or structured JSON) | Structural baseline |
| B2 | Screenshot and raw native hierarchy | Naive multimodal baseline |
| B3 | Existing cleaned accessibility tree | Strong structural baseline |
| B4 | Existing interactive-element summary | Strong compact baseline |
| B5 | OCR text without structural processing | Text-only visual baseline |
| B6 | Screenshot, XML, and simple deterministic rules | Minimal hybrid baseline |

Candidate conditions add tree-only compilation, screenshot-only compilation,
fusion, task conditioning, delta, and an optional evidence-gated detector.

Compact-text-only and screenshot-plus-compact-text are separate experiment
families. They are not pooled because their cost and visual evidence differ.

## Representation experiment action set

All conditions receive the same coordinate-based actions:

- `tap(point)`
- `type_text(text)` after coordinate-based focus
- `swipe(start, end, duration)`
- `wait(duration)` within a fixed maximum
- `stop(result)`

Accessibility-identifier taps, app launch or termination, URL opening, direct
element lookup, and other privileged system actions are excluded. Multi-app
representation tasks begin from the same prearranged app state.

Privileged capabilities are evaluated separately and may not be reported as a
representation improvement. Long press, drag, slider motion, and pinch use a
separate interaction microbenchmark when implemented.

## Planner contract

The benchmark harness exposes a provider-neutral planner interface. Each paired
run fixes:

- Provider and exact model revision.
- Inference and reasoning configuration.
- System prompt, task prompt, and output schema.
- Image detail and screenshot resolution.
- Tool names, descriptions, schemas, and action validation.
- Maximum steps, retries, timeouts, and stop rules.

The run manifest stores hashes for prompts and tool schemas plus the effective
model identifier returned by the provider. A floating model alias cannot change
within a paired experiment. Different planners are analyzed separately.

Planner selection uses a pilot across representative single-app, multi-app,
text-heavy, icon-heavy, and hierarchy-gap tasks. The primary planner must support
image input, structured actions, stable configuration, and sufficient task
success to expose representation differences.

## Initial state and environment

Every paired condition uses the same:

- App build and pinned source revision.
- Seeded synthetic data and locale.
- Simulator runtime, device type, orientation, appearance, and Dynamic Type.
- Starting foreground app, navigation state, keyboard state, and permissions.
- Screenshot dimensions and crop policy.
- Network fixtures and time-dependent data controls.
- Task text, rubric, judge, and randomization policy.

State reset must be verified before the planner receives its first observation.

## Visibility policy

The main representation experiment includes elements visible in the current
viewport. Hidden and off-screen elements are excluded or explicitly marked and
handled identically across tree conditions.

Separate robustness experiments cover:

- Missing accessibility hierarchy.
- Hidden and off-screen nodes.
- Screenshot/tree timestamp mismatch.
- Occlusion, keyboard, sheets, dialogs, and animation.
- Unlabeled icons and custom-rendered controls.

## Perception and grounding metrics

- Critical visible-text recall.
- Role macro-F1 and task-critical element recall.
- Label/value and section/row relation F1.
- Bounding-box overlap and center-point-in-target.
- Grounding@1 and actual coordinate action success.
- Disabled or obscured element false-positive rate.

## Agent metrics

- Strict task pass and rubric score.
- Steps, wrong clicks, repeated actions, and loops.
- Premature stopping and recovery after failure.
- Tokens per step and total task tokens.
- Planner latency, action latency, total duration, and measured cost.

## System timings

Record independently:

```text
capture_ms
decode_ms
tree_snapshot_ms
xml_parse_ms
xcuitest_json_parse_ms
tree_cleaning_ms
geometry_ms
ocr_ms
detector_ms
fusion_ms
task_ranking_ms
frame_diff_ms
serialization_ms
planner_ms
action_execution_ms
total_ms
```

Report P50 and P95, cold and warm behavior, screenshot-only, cached-tree, and
fresh-tree configurations. Detector-only latency is never presented as total
latency.

## Token accounting

Store the exact serialized input and count tokens with the tokenizer associated
with the pinned planner. Also report representation bytes and Unicode scalar
counts so results remain inspectable when a tokenizer changes.

Image-token accounting, when available, is reported separately from text tokens.

## Statistical design

- Pair each task across baseline and candidate conditions.
- Use McNemar or a task-level paired bootstrap for binary success.
- Use paired task-level differences and bootstrap intervals for tokens and time.
- Cluster repeated seeds by task rather than treating them as independent tasks.
- Report framework, app, task category, language, viewport, and hierarchy-gap
  subsets separately.

## Experiment budget

1. Tier 0: 50-screen pilot, then 500–1,000 offline frames; no planner loop.
2. Tier 1: 20–30 tasks and four to six promising representations.
3. Tier 2: full benchmark with strongest baseline and one or two finalists.
4. Tier 3: repeated seeds only for close or critical conclusions.

Large paid runs require approval and a declared budget before execution.

## Claim gate

A representation improvement may be claimed only when action permissions,
initial states, visibility, planner configuration, prompts, resolution, step
budget, and scoring are matched. A shorter representation that lowers task
success is not an improvement.
