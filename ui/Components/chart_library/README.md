# Flutter Chart Library v2

A high-performance, config/JSON-driven Flutter chart library.
**37+ chart types**, zero external dependencies, full tree-shaking support.

## Quick Start

```dart
void main() {
  completeChartsBundle.register();
  runApp(const MyApp());
}

// Build any chart from JSON at runtime
final chart = BaseChartConfig.fromJson({
  "type": "candlestick",
  "series": [{ "data": [...] }]
}).buildChart();
```

## Chart Types (37+)

| Category        | Types |
|-----------------|-------|
| Core            | bar, line, area, pie, donut, scatter, bubble |
| Advanced        | sunburst, funnel, sankey, waterfall, gauge, radar, gantt, polarBar, treemap |
| Statistical     | histogram, boxPlot, violin, ridgeline, strip, errorBar |
| Trading         | candlestick, ohlc, kagi, renko, macd |
| Comparison/KPI  | combo, lollipop, bullet, sparkline |
| Relational/Misc | heatmap, calendar, parallel, network, radial, timeline, wordcloud |

## Selective Registration

```dart
coreChartsBundle.register();       // only 6 core charts
tradingChartsBundle.register();    // only trading charts
statisticalChartsBundle.register(); // only statistical charts
// OR
ChartRegistry.register(gaugeRegistration); // single chart
```

## File Structure

```
lib/
  flutter_chart_library.dart       ← main export barrel
  src/
    core/
      config/     chart_type, axis_config, controller, base_config
      painters/   chart_painter_base
      utils/      data_processor, cache, sampler, animation, export, validator
      registry/   chart_registry, all registration bundles
      interaction/ zoom_state, viewport, interaction_layer, drilldown
      chart_builder.dart
    charts/        20 chart implementation files (37+ chart types)
```

## Performance Features

- Zero-allocation paint loop (PaintCache, TextPainterCache, PathCache)
- LTTB downsampling for large datasets
- Viewport culling — only paint visible elements
- RepaintBoundary isolation per chart
- Picture caching via ChartRenderPipeline

## License
MIT
