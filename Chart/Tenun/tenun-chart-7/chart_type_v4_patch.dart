/// chart_type_v4_patch.dart
///
/// COMPLETE MERGE INSTRUCTIONS — apply ALL of these to
/// `core/config/chart_type.dart` to support every chart added in
/// bar_chart_variants.dart, line_area_variants.dart,
/// pie_chart_variants.dart, and remaining_charts.dart.
///
/// ═══════════════════════════════════════════════════════════════════
/// STEP 1 — Add inside `enum ChartType { … }` (after existing values)
/// ═══════════════════════════════════════════════════════════════════
///
///   // ── Bar variants ────────────────────────────────────────────
///   barBackground,       // bar with translucent track behind each bar
///   barRace,             // animated racing bar chart
///   barGradient,         // gradient-filled clickable column chart
///   barLabelRotation,    // bar with rotated X-axis labels
///   barRounded,          // stacked bar with rounded top segment
///   barNormalized,       // 100 %-normalised stacked bar
///   barBrush,            // bar with brush-select range overlay
///   negativeBar,         // horizontal diverging bar (negative values)
///   tangentialPolarBar,  // polar bar with tangential arc labels
///
///   // ── Line / Area variants ────────────────────────────────────
///   areaPieces,          // area split by threshold colour bands
///   lineGradient,        // gradient stroke + fill area
///   lineConfidenceBand,  // line + shaded confidence/error band
///   lineMarkline,        // line with named horizontal reference lines
///   logAxis,             // line on logarithmic Y axis
///   functionPlot,        // mathematical y = f(x) plotter
///   sparklineMatrix,     // grid of mini sparklines
///   dynamicTimeSeries,   // live-updating sliding-window series
///   intradayLine,        // line with explicit data-gap breaks
///   lineClickAdd,        // interactive — tap to add data points
///   lineRace,            // animated line race
///
///   // ── Pie variants ────────────────────────────────────────────
///   halfDonut,           // 180° semicircle donut
///   paddedPie,           // pie with configurable pad angle
///   nightingale,         // rose / nightingale chart
///   nestedPie,           // concentric ring charts
///   partitionPie,        // one slice subdivided into sub-slices
///   calendarPie,         // mini pies inside a calendar grid
///
///   // ── Remaining / specialised ──────────────────────────────────
///   rainfall,            // bar styled as rainfall + optional line
///   multiXAxes,          // line with two independent X axes
///   lineStyleItem,       // line with per-series dash/dot styles
///   largeScaleArea,      // LTTB-downsampled large-dataset area
///   areaTimeAxis,        // area/line with DateTime X axis
///   polarLine,           // line on polar coordinates
///   customizedPie,       // pie with per-slice explode & border
///   pieLabelAlign,       // pie with polyline-aligned edge labels
///   pieSpecialLabel,     // donut with rich multi-line labels
///
/// ═══════════════════════════════════════════════════════════════════
/// STEP 2 — Add to getChartType() switch
/// ═══════════════════════════════════════════════════════════════════
///
///   // bar variants
///   case 'barbackground':     return ChartType.barBackground;
///   case 'barrace':           return ChartType.barRace;
///   case 'bargradient':       return ChartType.barGradient;
///   case 'barlabelrotation':  return ChartType.barLabelRotation;
///   case 'barrounded':        return ChartType.barRounded;
///   case 'barnormalized':
///   case 'bar100':            return ChartType.barNormalized;
///   case 'barbrush':          return ChartType.barBrush;
///   case 'negativebar':       return ChartType.negativeBar;
///   case 'tangentialpolarbbar':
///   case 'tangentialpolarbr': return ChartType.tangentialPolarBar;
///   // line/area variants
///   case 'areapieces':        return ChartType.areaPieces;
///   case 'linegradient':      return ChartType.lineGradient;
///   case 'lineconfidenceband':
///   case 'confidenceband':    return ChartType.lineConfidenceBand;
///   case 'linemarkline':
///   case 'markline':          return ChartType.lineMarkline;
///   case 'logaxis':
///   case 'logarithmic':       return ChartType.logAxis;
///   case 'functionplot':
///   case 'function':          return ChartType.functionPlot;
///   case 'sparklinematrix':
///   case 'minilines':         return ChartType.sparklineMatrix;
///   case 'dynamictimeseries':
///   case 'liveChart':         return ChartType.dynamicTimeSeries;
///   case 'intradayline':
///   case 'intraday':          return ChartType.intradayLine;
///   case 'lineclickadd':
///   case 'clicktoadd':        return ChartType.lineClickAdd;
///   case 'linerace':          return ChartType.lineRace;
///   // pie variants
///   case 'halfdonut':
///   case 'semicircle':        return ChartType.halfDonut;
///   case 'paddedpie':
///   case 'gappedpie':         return ChartType.paddedPie;
///   case 'nightingale':
///   case 'rose':              return ChartType.nightingale;
///   case 'nestedpie':
///   case 'concentric':        return ChartType.nestedPie;
///   case 'partitionpie':
///   case 'drilldownpie':      return ChartType.partitionPie;
///   case 'calendarpie':       return ChartType.calendarPie;
///   // remaining
///   case 'rainfall':
///   case 'rain':              return ChartType.rainfall;
///   case 'multixaxes':
///   case 'dualxaxis':         return ChartType.multiXAxes;
///   case 'linestyleitem':
///   case 'styledline':        return ChartType.lineStyleItem;
///   case 'largescalearea':
///   case 'bigdata':           return ChartType.largeScaleArea;
///   case 'areatimeaxis':
///   case 'timearea':          return ChartType.areaTimeAxis;
///   case 'polarline':
///   case 'spiderline':        return ChartType.polarLine;
///   case 'customizedpie':
///   case 'custompie':         return ChartType.customizedPie;
///   case 'pielabelAlign':
///   case 'alignedlabels':     return ChartType.pieLabelAlign;
///   case 'piespeciallabel':
///   case 'richlabelpie':      return ChartType.pieSpecialLabel;
///
/// ═══════════════════════════════════════════════════════════════════
/// STEP 3 — Add to chartTypeToString() switch
/// ═══════════════════════════════════════════════════════════════════
///
///   case ChartType.barBackground:     return 'barBackground';
///   case ChartType.barRace:           return 'barRace';
///   case ChartType.barGradient:       return 'barGradient';
///   case ChartType.barLabelRotation:  return 'barLabelRotation';
///   case ChartType.barRounded:        return 'barRounded';
///   case ChartType.barNormalized:     return 'barNormalized';
///   case ChartType.barBrush:          return 'barBrush';
///   case ChartType.negativeBar:       return 'negativeBar';
///   case ChartType.tangentialPolarBar:return 'tangentialPolarBar';
///   case ChartType.areaPieces:        return 'areaPieces';
///   case ChartType.lineGradient:      return 'lineGradient';
///   case ChartType.lineConfidenceBand:return 'lineConfidenceBand';
///   case ChartType.lineMarkline:      return 'lineMarkline';
///   case ChartType.logAxis:           return 'logAxis';
///   case ChartType.functionPlot:      return 'functionPlot';
///   case ChartType.sparklineMatrix:   return 'sparklineMatrix';
///   case ChartType.dynamicTimeSeries: return 'dynamicTimeSeries';
///   case ChartType.intradayLine:      return 'intradayLine';
///   case ChartType.lineClickAdd:      return 'lineClickAdd';
///   case ChartType.lineRace:          return 'lineRace';
///   case ChartType.halfDonut:         return 'halfDonut';
///   case ChartType.paddedPie:         return 'paddedPie';
///   case ChartType.nightingale:       return 'nightingale';
///   case ChartType.nestedPie:         return 'nestedPie';
///   case ChartType.partitionPie:      return 'partitionPie';
///   case ChartType.calendarPie:       return 'calendarPie';
///   case ChartType.rainfall:          return 'rainfall';
///   case ChartType.multiXAxes:        return 'multiXAxes';
///   case ChartType.lineStyleItem:     return 'lineStyleItem';
///   case ChartType.largeScaleArea:    return 'largeScaleArea';
///   case ChartType.areaTimeAxis:      return 'areaTimeAxis';
///   case ChartType.polarLine:         return 'polarLine';
///   case ChartType.customizedPie:     return 'customizedPie';
///   case ChartType.pieLabelAlign:     return 'pieLabelAlign';
///   case ChartType.pieSpecialLabel:   return 'pieSpecialLabel';

// ignore_for_file: unused_element
library chart_type_v4_patch;
