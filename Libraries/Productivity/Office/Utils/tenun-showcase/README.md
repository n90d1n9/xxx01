# tenun_showcase

Storybook showcase for `tenun` charts.

## Run

```bash
cd ui/Packages/tenun_showcase
flutter pub get
flutter run
```

## Story Organization

Stories are grouped by data-shape intent:

- `Charts/By Data Shape/Cartesian/...`
- `Charts/By Data Shape/Hierarchy/...`
- `Charts/By Data Shape/Flow/...`
- `Charts/By Data Shape/Radial/...`
- `Charts/By Data Shape/Geo/...`
- `Charts/By Data Shape/Text-Timeline/...`
- `Charts/By Data Shape/Mixed/...` (aggregate galleries)
- `Charts/Tools/...` (zoom/drilldown helpers)

## Smart Switching Demo

See:

- `Charts/By Data Shape/Smart Type Switch`

This demo uses:

- `inferSeriesDataShape(...)`
- `compatibleChartTypesForJson(...)`
- `chartSwitchCompatibilityForJson(...)`
- `switchChartTypeForSeriesShape(...)`

with optional cross-shape conversion to types like `pie`, `treemap`, and `sunburst`.

## Data Mode + Sampling Demos

Use these stories to validate regular/simple vs large dataset behavior:

- `Charts/By Data Shape/Cartesian/Area Knobs`
- `Charts/By Data Shape/Cartesian/Line Knobs`
- `Charts/By Data Shape/Cartesian/Bar/Simple`
- `Charts/By Data Shape/Cartesian/Scatter/Basic`
- `Charts/By Data Shape/Financial/Candlestick/Basic`
- `Charts/By Data Shape/Smart Type Switch`
- `Charts/Tools/Large Data Sampling Lab`
- `Charts/Tools/Payload Normalize Playground`

Each story exposes:

- `Data Mode`: `Regular (Simple)`, `Auto`, `Large`
- `Point Count` (enabled for non-regular mode)
- `Sampling Threshold` (enabled for non-regular mode)
- `Sampling Strategy`: `Auto`, `LTTB`, `MinMax`, `Nth`

Recommended workflow:

1. Start with `Data Mode = Regular` and verify baseline appearance.
2. Switch to `Auto` and increase `Point Count` to simulate production load.
3. Use `Large` mode for stress cases and tune `threshold`/`strategy`.

For payload sanitation flow:

1. Open `Charts/Tools/Payload Normalize Playground`.
2. Keep `Strict Validation = true`.
3. Toggle `Auto Normalize Payload` off/on and compare raw vs normalized outcome.

## Bar Race Markers & Controls

The `Charts/By Data Shape/Mixed/New V3 Charts Gallery` story includes a
`Bar Race` sample using:

- shorthand `categories + frameLabels + frames`
- `markers` with text badge styling
- playback controls (`autoPlay`, `showControls`, `showStepControls`)
- progress display (`showProgressIndicator`)

Use this story as the quick visual check when editing `barRace` marker or
control behavior.

## Shared Sample Registry

Showcase sample JSON is centralized in:

- `lib/example/chart_samples_registry.dart`

This is the source of truth used by focused shape galleries and canonical mixed galleries.
