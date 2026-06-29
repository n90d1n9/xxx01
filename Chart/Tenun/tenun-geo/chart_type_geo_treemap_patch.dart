/// chart_type_geo_treemap_patch.dart
///
/// Add these values to chart_type.dart for the 6 geo + 3 treemap variants.
///
/// ── STEP 1: Add to `enum ChartType` ──────────────────────────────────────
///
///   // ── Geo variants ──────────────────────────────────────────────────────
///   geoGraph,                // network graph on a geographic map
///   geoChoroplethScatter,    // choropleth regions + scatter point overlay
///   geoBeefCuts,             // body/anatomy region map (normalised coords)
///   geoHeatmap,              // gaussian intensity heatmap on a map
///   geoSvgLines,             // animated arc-line connections between locations
///   geoMorph,                // animated morph between map view and bar chart
///
///   // ── Treemap variants ──────────────────────────────────────────────────
///   treemapSunburstMorph,    // animated morph between treemap and sunburst
///   treemapGradient,         // treemap with per-cell gradient colour mapping
///   treemapParentLabels,     // treemap with sticky parent-group labels
///
/// ── STEP 2: Add to `getChartType()` switch ───────────────────────────────
///
///   // geo variants
///   case 'geograph':                 return ChartType.geoGraph;
///   case 'geochoroplethscatter':
///   case 'choroplethscatter':        return ChartType.geoChoroplethScatter;
///   case 'geobeefcuts':
///   case 'beefcuts':
///   case 'anatomymap':               return ChartType.geoBeefCuts;
///   case 'geoheatmap':               return ChartType.geoHeatmap;
///   case 'geosvglines':
///   case 'geolines':
///   case 'flightmap':                return ChartType.geoSvgLines;
///   case 'geomorph':
///   case 'maptobar':                 return ChartType.geoMorph;
///   // treemap variants
///   case 'treemapsunburstmorph':
///   case 'treemapmorph':             return ChartType.treemapSunburstMorph;
///   case 'treemapgradient':
///   case 'gradienttreemap':          return ChartType.treemapGradient;
///   case 'treemapparentlabels':
///   case 'parentlabelstreemap':      return ChartType.treemapParentLabels;
///
/// ── STEP 3: Add to `chartTypeToString()` switch ───────────────────────────
///
///   case ChartType.geoGraph:              return 'geoGraph';
///   case ChartType.geoChoroplethScatter:  return 'geoChoroplethScatter';
///   case ChartType.geoBeefCuts:           return 'geoBeefCuts';
///   case ChartType.geoHeatmap:            return 'geoHeatmap';
///   case ChartType.geoSvgLines:           return 'geoSvgLines';
///   case ChartType.geoMorph:              return 'geoMorph';
///   case ChartType.treemapSunburstMorph:  return 'treemapSunburstMorph';
///   case ChartType.treemapGradient:       return 'treemapGradient';
///   case ChartType.treemapParentLabels:   return 'treemapParentLabels';
///
// ignore_for_file: unused_element
library chart_type_geo_treemap_patch;
