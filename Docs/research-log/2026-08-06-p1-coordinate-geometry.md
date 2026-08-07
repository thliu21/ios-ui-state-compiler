# P1 coordinate geometry implementation

Date: 2026-08-06
Status: Accepted for Task 3

## Scope

Implement the coordinate contract without simulator access, third-party
dependencies, or platform geometry frameworks. The public API must make
coordinate-space mixing visible and reject invalid external dimensions.

## Interface decision

- `CoordinatePoint`, `CoordinateRect`, and `CoordinateSize` use generic marker
  types for Vision-normalized, image-pixel, and logical-point spaces.
- `ActionPoint1000` is a separate integer value type constrained to the
  inclusive transport range `0...1000`.
- Every value exposes its declared `CoordinateSpace` name.
- Values are immutable and validate finite coordinates, non-negative rectangle
  dimensions, and positive finite sizes at construction.
- `ScreenGeometry` owns the captured image and viewport dimensions and is the
  only public conversion surface.

This keeps conversions contract-first and prevents a pixel rectangle from being
passed to an API that expects logical points.

## Test-driven evidence

1. The first focused test run failed to compile because none of the geometry
   types or conversion functions existed.
2. The first implementation run passed four geometry cases and exposed one
   floating-point boundary in the test tolerance: a theoretical `0.195` point
   half-grid error was represented as `0.1950000000000216`.
3. The tolerance was expressed as half an action grid plus `1e-9`; conversion
   formulas were unchanged.
4. The focused run then passed five tests, followed by a full regression run of
   eight tests across two suites.

## Verified transformations

- Vision bottom-left rectangles convert to top-left pixels with the required
  vertical flip and round trip within `1e-9` in the tested fixture.
- Logical points use independent horizontal and vertical scale factors. The
  nonuniform `3.0 x 2.25` fixture round trips within `1e-9`.
- Logical points convert to integer `action_1000` coordinates using
  nearest-or-away-from-zero rounding.
- The action round trip stays within half a normalized grid: `0.195` point
  horizontally and `0.422` point vertically in the tested `390 x 844` viewport.
  Both are below the accepted 1–2 logical-point tolerance.
- Zero, infinite, or negative dimensions fail with structured geometry errors.

## Acceptance commands

```text
swift test --filter ScreenGeometryTests
swift test
swift build
swift format lint --recursive --strict Sources Tests Package.swift
```

All commands passed on the recorded local Swift toolchain. The full Swift
Testing run reported eight tests in two suites.

## Storage observation

The system reported 39 GiB available after cleanup, and the SwiftPM build
directory occupied 35 MiB. This is sufficient for the current P1 source and
synthetic-fixture work. It is not approval to start the planned P2 bulk dataset;
that phase still needs a larger storage margin or external artifact location.
