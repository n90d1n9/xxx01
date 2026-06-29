/// chart_type_v3_patch.dart
///
/// MERGE INSTRUCTIONS — add the following values to [ChartType] in
/// `core/config/chart_type.dart`, then add their string mappings to
/// `getChartType()` and `chartTypeToString()`.
///
/// ─────────────────────────────────────────────────────────────────────────
/// STEP 1 — New enum values to add inside `enum ChartType { … }`
/// ─────────────────────────────────────────────────────────────────────────
///
///   // ---- Bar variants ----
///   /// Animated bar-race (sorted descending, racing each frame).
///   barRace,
///   /// Bar with translucent background track behind each bar.
///   barBackground,
///   /// Bar / column with per-bar gradient fill.
///   barGradient,
///   /// Stacked bar with rounded top corners on each segment.
///   barRounded,
///   /// 100 %-normalised stacked bar.
///   barNormalized,
///   /// Bar chart with interactive brush-select range.
///   barBrush,
///   /// Bar chart correctly handling negative values (two-axis baseline).
///   negativeBar,
///
///   // ---- Line / Area variants ----
///   /// Area split into colour-coded pieces by threshold.
///   areaPieces,
///   /// Line with gradient fill / stroke.
///   lineGradient,
///   /// Line with symmetric or asymmetric confidence-band shading.
///   lineConfidenceBand,
///   /// Line with named reference mark-lines (min, max, average, custom).
///   lineMarkline,
///   /// Animated racing lines (rank over time).
///   lineRace,
///   /// Line on a polar (spider) coordinate system with two value axes.
///   polarLine,
///   /// Interactive line — click anywhere to add a new data point.
///   lineClickAdd,
///   /// Line / area chart with a logarithmic Y-axis.
///   logAxis,
///   /// Mathematical function plot (y = f(x) evaluated at runtime).
///   functionPlot,
///   /// Matrix of small sparklines — one per row/column cell.
///   sparklineMatrix,
///   /// Dynamic time-series — data appended at runtime, old points shifted out.
///   dynamicTimeSeries,
///   /// Intraday line with explicit break intervals (no-data gaps).
///   intradayLine,
///
///   // ---- Pie variants ----
///   /// Half (180 °) donut / semicircle.
///   halfDonut,
///   /// Nested concentric pie rings (same centre, different radii).
///   nestedPie,
///   /// Pie chart rendered inside a GitHub-calendar cell.
///   calendarPie,
///   /// Pie with configurable padding angle between slices.
///   paddedPie,
///   /// Pie where one slice is subdivided (partition / treemap-pie hybrid).
///   partitionPie,
///   /// Nightingale / rose (polar bar arc, identical to polarBar but
///   /// in a circular rose arrangement rather than a spider grid).
///   nightingale,
///
/// ─────────────────────────────────────────────────────────────────────────
/// STEP 2 — String mappings to add to getChartType()
/// ─────────────────────────────────────────────────────────────────────────
///
///   case 'barrace':        return ChartType.barRace;
///   case 'barbackground':  return ChartType.barBackground;
///   case 'bargradient':    return ChartType.barGradient;
///   case 'barrounded':     return ChartType.barRounded;
///   case 'barnormalized':
///   case 'bar100':         return ChartType.barNormalized;
///   case 'barbrush':       return ChartType.barBrush;
///   case 'negativebar':    return ChartType.negativeBar;
///   case 'areapieces':     return ChartType.areaPieces;
///   case 'linegradient':   return ChartType.lineGradient;
///   case 'lineconfidenceband':
///   case 'confidenceband': return ChartType.lineConfidenceBand;
///   case 'linemarkline':
///   case 'markline':       return ChartType.lineMarkline;
///   case 'linerace':       return ChartType.lineRace;
///   case 'polarline':      return ChartType.polarLine;
///   case 'lineclickadd':
///   case 'clicktoadd':     return ChartType.lineClickAdd;
///   case 'logaxis':        return ChartType.logAxis;
///   case 'functionplot':
///   case 'function':       return ChartType.functionPlot;
///   case 'sparklinematrix':
///   case 'minilines':      return ChartType.sparklineMatrix;
///   case 'dynamictimeseries':
///   case 'dynamictime':    return ChartType.dynamicTimeSeries;
///   case 'intradayline':
///   case 'intraday':       return ChartType.intradayLine;
///   case 'halfdonut':
///   case 'semicircle':     return ChartType.halfDonut;
///   case 'nestedpie':      return ChartType.nestedPie;
///   case 'calendarpie':    return ChartType.calendarPie;
///   case 'paddedpie':      return ChartType.paddedPie;
///   case 'partitionpie':   return ChartType.partitionPie;
///   case 'nightingale':
///   case 'rose':           return ChartType.nightingale;
///
/// ─────────────────────────────────────────────────────────────────────────
/// STEP 3 — chartTypeToString() reverse mappings (add to switch)
/// ─────────────────────────────────────────────────────────────────────────
///
///   case ChartType.barRace:           return 'barRace';
///   case ChartType.barBackground:     return 'barBackground';
///   case ChartType.barGradient:       return 'barGradient';
///   case ChartType.barRounded:        return 'barRounded';
///   case ChartType.barNormalized:     return 'barNormalized';
///   case ChartType.barBrush:          return 'barBrush';
///   case ChartType.negativeBar:       return 'negativeBar';
///   case ChartType.areaPieces:        return 'areaPieces';
///   case ChartType.lineGradient:      return 'lineGradient';
///   case ChartType.lineConfidenceBand:return 'lineConfidenceBand';
///   case ChartType.lineMarkline:      return 'lineMarkline';
///   case ChartType.lineRace:          return 'lineRace';
///   case ChartType.polarLine:         return 'polarLine';
///   case ChartType.lineClickAdd:      return 'lineClickAdd';
///   case ChartType.logAxis:           return 'logAxis';
///   case ChartType.functionPlot:      return 'functionPlot';
///   case ChartType.sparklineMatrix:   return 'sparklineMatrix';
///   case ChartType.dynamicTimeSeries: return 'dynamicTimeSeries';
///   case ChartType.intradayLine:      return 'intradayLine';
///   case ChartType.halfDonut:         return 'halfDonut';
///   case ChartType.nestedPie:         return 'nestedPie';
///   case ChartType.calendarPie:       return 'calendarPie';
///   case ChartType.paddedPie:         return 'paddedPie';
///   case ChartType.partitionPie:      return 'partitionPie';
///   case ChartType.nightingale:       return 'nightingale';

// ignore_for_file: unused_element
library chart_type_v3_patch;
