# Action and coordinate contract

Status: Accepted for P0
Updated: 2026-08-06

## Canonical spaces

| Name | Origin | Units | Intended source |
| --- | --- | --- | --- |
| `vision_normalized` | Bottom-left | 0.0–1.0 | Vision observations |
| `image_pixels` | Top-left | Physical pixels | Screenshot and OCR output |
| `screen_points` | Top-left | iOS logical points | Native hierarchy and actions |
| `action_1000` | Top-left | Integer 0–1000 | Optional executor transport |

Every point and rectangle carries its coordinate-space name. A bare pair of
numbers is not a valid public action coordinate.

Rectangles use `x, y, width, height`. Points use `x, y`. Width and height must be
non-negative. Viewport and image dimensions must be positive and finite.

## Vision rectangle to image pixels

For a normalized Vision rectangle `(x, y, width, height)` and image dimensions
`Wpx, Hpx`:

```text
x_px = x * Wpx
y_px = (1 - y - height) * Hpx
width_px = width * Wpx
height_px = height * Hpx
```

This conversion flips the vertical origin.

## Screen points to image pixels

For viewport dimensions `Wpt, Hpt`:

```text
scale_x = Wpx / Wpt
scale_y = Hpx / Hpt
x_px = x_pt * scale_x
y_px = y_pt * scale_y
width_px = width_pt * scale_x
height_px = height_pt * scale_y
```

Do not assume `scale_x == scale_y` and do not hardcode 2x or 3x. A mismatch is
recorded and tested rather than silently rounded away.

## Screen points to action_1000

```text
x_1000 = round(x_pt / Wpt * 1000)
y_1000 = round(y_pt / Hpt * 1000)
```

The inverse uses the recorded viewport dimensions. Conversion code must define
its rounding rule and clamp only at an executor boundary, never in canonical
geometry.

## Action targets

- A tap target defaults to the center of the verified visible intersection of
  its evidence boxes.
- If the center is obscured or outside the hittable region, use a documented
  interior point and lower confidence.
- Tree-declared, visually inferred, and execution-verified actions are separate
  evidence levels.
- Stale tree coordinates are invalid after page change, modal transition, or
  material screenshot/tree disagreement.

## Orientation and viewport metadata

Every screen record includes image size, logical viewport size, orientation, and
capture timestamps. Safe-area insets, keyboard presence, sheets, and simulator
window scaling are recorded when they affect geometry.

## Verification matrix

- Multiple iPhone sizes.
- At least one iPad size before iPad support is claimed.
- Portrait and landscape.
- Safe areas and status bars.
- Keyboard, sheet, alert, and full-screen modal.
- Different image-to-point scales.
- Screenshot/tree viewport mismatch.
- Vision vertical-origin conversion.
- Round trips among all declared spaces.

## Acceptance

Coordinate conversion passes deterministic unit tests with at most 1–2 logical
points of round-trip error, or demonstrates that the final action point lies
inside the intended target. Both numeric error and point-in-element results are
reported.
