# P0 source audit — 2026-08-06

## Environment evidence

The initial machine is an Apple M1 Pro MacBook Pro with 16 GB unified memory,
macOS 26.5.2, Xcode 26.5, and Swift 6.3.2. The system data volume had about 14 GiB
available. These facts define the first reproducibility target, not the minimum
supported environment.

## Apple screen-recognition evidence

Apple's Screen Recognition research used 77,637 screens from 4,068 iPhone apps
and combined pixel-based detection with heuristics and semantic models. Apple
reported that 59% of screens had visually annotated elements that did not all
match accessible elements, and 94% of apps had at least one such screen. This
supports testing screenshot/tree fusion rather than assuming the hierarchy is
complete.

The reported final detector was approximately 20 MB and about 10 ms per screen
on an iPhone 11. That number is detector inference, not screenshot acquisition,
OCR, tree retrieval, fusion, serialization, or agent latency.

Source:

- https://machinelearning.apple.com/research/mobile-applications-accessible
- https://machinelearning.apple.com/research/creating-accessibility-metadata

## Apple Vision OCR evidence

The current Swift Vision API exposes `RecognizeTextRequest` and returns recognized
text observations with locations. Its `minimumTextHeightFraction` default is
1/32 of image height. Raising the threshold reduces work but ignores smaller
text, which makes an explicit UI-text parameter sweep necessary.

The older `VNRecognizeTextRequest` API exposes the equivalent
`minimumTextHeight`. The P1 implementation should prefer the current Swift API
for the recorded deployment target and add compatibility code only when an
actual minimum-platform requirement justifies it.

Sources:

- https://developer.apple.com/documentation/vision/recognizetextrequest
- https://developer.apple.com/documentation/vision/recognizetextrequest/minimumtextheightfraction
- https://developer.apple.com/documentation/vision/vnrecognizetextrequest/minimumtextheight

## iOSWorld baseline evidence

The public iOSWorld repository was pinned at commit
`e91f4cb2ef4c9dd48fef83a894477b41fd5e209d` on 2026-08-06. Repository metadata
reported Apache-2.0 at the root and no releases. Nested app, screenshot, image,
font, trademark, and sample-content rights still require individual review.

The existing strong compact baselines are implemented in
`scripts/llm_action_generator.py`:

- `extract_interactive_elements`
- `build_cleaned_accessibility_tree`

The project must compare against both rather than claim success from beating raw
XML alone.

Sources:

- https://github.com/ljang0/iOSWorld/tree/e91f4cb2ef4c9dd48fef83a894477b41fd5e209d
- https://github.com/ljang0/iOSWorld/blob/e91f4cb2ef4c9dd48fef83a894477b41fd5e209d/scripts/llm_action_generator.py

## Conclusions entering P1

1. Deterministic tree compression and current-system OCR are the correct first
   baselines.
2. Screenshot/tree fusion has an evidence-backed motivation, but its benefit is
   not yet measured for agent tasks.
3. Detector-only timing must never substitute for end-to-end latency.
4. Public data reuse requires artifact-level rights review.
5. No model training is justified at P0.
