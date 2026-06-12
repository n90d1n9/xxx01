import 'package:tenun_pro/tenun_pro.dart' hide FontWeight;

abstract final class SimpleChartsShowcaseCompositionData {
  static const portfolioShare = [
    SimpleWaffleChartData(label: 'Core', value: 42),
    SimpleWaffleChartData(label: 'Growth', value: 28),
    SimpleWaffleChartData(label: 'Education', value: 18),
    SimpleWaffleChartData(label: 'Support', value: 12),
  ];

  static const portfolioPackedBubbles = [
    SimplePackedBubbleData(label: 'Core', value: 42),
    SimplePackedBubbleData(label: 'Growth', value: 28),
    SimplePackedBubbleData(label: 'Education', value: 18),
    SimplePackedBubbleData(label: 'Support', value: 12),
    SimplePackedBubbleData(label: 'Research', value: 8),
  ];

  static const strategyTernary = [
    SimpleTernaryPoint(
      label: 'Balanced',
      a: 34,
      b: 33,
      c: 33,
      size: 42,
      group: 'Core',
    ),
    SimpleTernaryPoint(
      label: 'Fast Track',
      a: 58,
      b: 26,
      c: 16,
      size: 36,
      group: 'Growth',
    ),
    SimpleTernaryPoint(
      label: 'Quality Led',
      a: 22,
      b: 60,
      c: 18,
      size: 32,
      group: 'Education',
    ),
    SimpleTernaryPoint(
      label: 'Cost Guard',
      a: 20,
      b: 24,
      c: 56,
      size: 28,
      group: 'Operations',
    ),
    SimpleTernaryPoint(
      label: 'Scale Play',
      a: 44,
      b: 18,
      c: 38,
      size: 34,
      group: 'Growth',
    ),
  ];

  static const voiceThemes = [
    SimpleWordCloudData(text: 'Trust', value: 42, group: 'Brand'),
    SimpleWordCloudData(text: 'Speed', value: 36, group: 'Product'),
    SimpleWordCloudData(text: 'Support', value: 31, group: 'Service'),
    SimpleWordCloudData(text: 'Learning', value: 27, group: 'Education'),
    SimpleWordCloudData(text: 'Quality', value: 25, group: 'Product'),
    SimpleWordCloudData(text: 'Clarity', value: 22, group: 'Brand'),
    SimpleWordCloudData(text: 'Access', value: 19, group: 'Service'),
    SimpleWordCloudData(text: 'Growth', value: 17, group: 'Education'),
    SimpleWordCloudData(text: 'Security', value: 15, group: 'Product'),
    SimpleWordCloudData(text: 'Confidence', value: 13, group: 'Brand'),
    SimpleWordCloudData(text: 'Guidance', value: 11, group: 'Education'),
    SimpleWordCloudData(text: 'Care', value: 9, group: 'Service'),
  ];

  static const audienceVennSets = [
    SimpleVennSet(id: 'growth', label: 'Growth', value: 72),
    SimpleVennSet(id: 'product', label: 'Product', value: 64),
    SimpleVennSet(id: 'learning', label: 'Learning', value: 52),
  ];

  static const audienceVennIntersections = [
    SimpleVennIntersection(
      setIds: ['growth', 'product'],
      value: 34,
      label: 'Growth + Product',
    ),
    SimpleVennIntersection(
      setIds: ['growth', 'learning'],
      value: 22,
      label: 'Growth + Learning',
    ),
    SimpleVennIntersection(
      setIds: ['product', 'learning'],
      value: 18,
      label: 'Product + Learning',
    ),
    SimpleVennIntersection(
      setIds: ['growth', 'product', 'learning'],
      value: 12,
      label: 'All three',
    ),
  ];

  static const audienceUpsetSets = [
    SimpleUpsetSet(id: 'growth', label: 'Growth', value: 72),
    SimpleUpsetSet(id: 'product', label: 'Product', value: 64),
    SimpleUpsetSet(id: 'learning', label: 'Learning', value: 52),
  ];

  static const audienceUpsetIntersections = [
    SimpleUpsetIntersection(
      setIds: ['growth'],
      value: 38,
      label: 'Growth only',
    ),
    SimpleUpsetIntersection(
      setIds: ['product'],
      value: 30,
      label: 'Product only',
    ),
    SimpleUpsetIntersection(
      setIds: ['learning'],
      value: 22,
      label: 'Learning only',
    ),
    SimpleUpsetIntersection(
      setIds: ['growth', 'product'],
      value: 34,
      label: 'Growth + Product',
    ),
    SimpleUpsetIntersection(
      setIds: ['growth', 'learning'],
      value: 22,
      label: 'Growth + Learning',
    ),
    SimpleUpsetIntersection(
      setIds: ['product', 'learning'],
      value: 18,
      label: 'Product + Learning',
    ),
    SimpleUpsetIntersection(
      setIds: ['growth', 'product', 'learning'],
      value: 12,
      label: 'All three',
    ),
  ];

  static const portfolioTreemap = [
    SimpleTreemapData(
      label: 'Core',
      value: 42,
      children: [
        SimpleTreemapData(label: 'Product', value: 18),
        SimpleTreemapData(label: 'Platform', value: 14),
        SimpleTreemapData(label: 'Trust', value: 10),
      ],
    ),
    SimpleTreemapData(
      label: 'Growth',
      value: 28,
      children: [
        SimpleTreemapData(label: 'Acquisition', value: 12),
        SimpleTreemapData(label: 'Expansion', value: 10),
        SimpleTreemapData(label: 'Labs', value: 6),
      ],
    ),
    SimpleTreemapData(
      label: 'Education',
      value: 18,
      children: [
        SimpleTreemapData(label: 'Academy', value: 10),
        SimpleTreemapData(label: 'Workshops', value: 8),
      ],
    ),
    SimpleTreemapData(
      label: 'Support',
      value: 12,
      children: [
        SimpleTreemapData(label: 'Success', value: 7),
        SimpleTreemapData(label: 'Ops', value: 5),
      ],
    ),
  ];

  static const portfolioSunburst = [
    SimpleSunburstData(
      label: 'Core',
      value: 42,
      children: [
        SimpleSunburstData(label: 'Product', value: 18),
        SimpleSunburstData(label: 'Platform', value: 14),
        SimpleSunburstData(label: 'Trust', value: 10),
      ],
    ),
    SimpleSunburstData(
      label: 'Growth',
      value: 28,
      children: [
        SimpleSunburstData(label: 'Acquisition', value: 12),
        SimpleSunburstData(label: 'Expansion', value: 10),
        SimpleSunburstData(label: 'Labs', value: 6),
      ],
    ),
    SimpleSunburstData(
      label: 'Education',
      value: 18,
      children: [
        SimpleSunburstData(label: 'Academy', value: 10),
        SimpleSunburstData(label: 'Workshops', value: 8),
      ],
    ),
    SimpleSunburstData(
      label: 'Support',
      value: 12,
      children: [
        SimpleSunburstData(label: 'Success', value: 7),
        SimpleSunburstData(label: 'Ops', value: 5),
      ],
    ),
  ];

  static const portfolioTree = [
    SimpleTreeDiagramData(
      label: 'Portfolio',
      value: 100,
      children: [
        SimpleTreeDiagramData(
          label: 'Core',
          value: 42,
          children: [
            SimpleTreeDiagramData(label: 'Product', value: 18),
            SimpleTreeDiagramData(label: 'Platform', value: 14),
            SimpleTreeDiagramData(label: 'Trust', value: 10),
          ],
        ),
        SimpleTreeDiagramData(
          label: 'Growth',
          value: 28,
          children: [
            SimpleTreeDiagramData(label: 'Acquire', value: 12),
            SimpleTreeDiagramData(label: 'Expand', value: 10),
            SimpleTreeDiagramData(label: 'Labs', value: 6),
          ],
        ),
        SimpleTreeDiagramData(
          label: 'Education',
          value: 18,
          children: [
            SimpleTreeDiagramData(label: 'Academy', value: 10),
            SimpleTreeDiagramData(label: 'Workshops', value: 8),
          ],
        ),
        SimpleTreeDiagramData(
          label: 'Support',
          value: 12,
          children: [
            SimpleTreeDiagramData(label: 'Success', value: 7),
            SimpleTreeDiagramData(label: 'Ops', value: 5),
          ],
        ),
      ],
    ),
  ];

  static const portfolioIcicle = [
    SimpleIcicleData(
      label: 'Portfolio',
      value: 100,
      children: [
        SimpleIcicleData(
          label: 'Core',
          value: 42,
          children: [
            SimpleIcicleData(label: 'Product', value: 18),
            SimpleIcicleData(label: 'Platform', value: 14),
            SimpleIcicleData(label: 'Trust', value: 10),
          ],
        ),
        SimpleIcicleData(
          label: 'Growth',
          value: 28,
          children: [
            SimpleIcicleData(label: 'Acquire', value: 12),
            SimpleIcicleData(label: 'Expand', value: 10),
            SimpleIcicleData(label: 'Labs', value: 6),
          ],
        ),
        SimpleIcicleData(
          label: 'Education',
          value: 18,
          children: [
            SimpleIcicleData(label: 'Academy', value: 10),
            SimpleIcicleData(label: 'Workshops', value: 8),
          ],
        ),
        SimpleIcicleData(
          label: 'Support',
          value: 12,
          children: [
            SimpleIcicleData(label: 'Success', value: 7),
            SimpleIcicleData(label: 'Ops', value: 5),
          ],
        ),
      ],
    ),
  ];

  static const readinessIcons = [
    SimplePictogramChartData(label: 'Ready', value: 72),
    SimplePictogramChartData(label: 'Coached', value: 18),
    SimplePictogramChartData(label: 'Needs Help', value: 10),
  ];

  static const readinessDots = [
    SimpleDotDensityChartData(label: 'Ready', value: 72),
    SimpleDotDensityChartData(label: 'Coached', value: 18),
    SimpleDotDensityChartData(label: 'Needs Help', value: 10),
  ];

  static const marketMosaicCategories = ['SMB', 'Mid', 'Enterprise'];

  static const marketMosaic = [
    SimpleMarimekkoSeries(name: 'Online', values: [32, 24, 18]),
    SimpleMarimekkoSeries(name: 'Partner', values: [18, 28, 34]),
    SimpleMarimekkoSeries(name: 'Field', values: [10, 22, 46]),
  ];

  static const marketMosaicPlot = [
    SimpleMosaicPlotCell(xLabel: 'SMB', yLabel: 'Online', value: 32),
    SimpleMosaicPlotCell(xLabel: 'SMB', yLabel: 'Partner', value: 18),
    SimpleMosaicPlotCell(xLabel: 'SMB', yLabel: 'Field', value: 10),
    SimpleMosaicPlotCell(xLabel: 'Mid', yLabel: 'Online', value: 24),
    SimpleMosaicPlotCell(xLabel: 'Mid', yLabel: 'Partner', value: 28),
    SimpleMosaicPlotCell(xLabel: 'Mid', yLabel: 'Field', value: 22),
    SimpleMosaicPlotCell(xLabel: 'Enterprise', yLabel: 'Online', value: 18),
    SimpleMosaicPlotCell(xLabel: 'Enterprise', yLabel: 'Partner', value: 34),
    SimpleMosaicPlotCell(xLabel: 'Enterprise', yLabel: 'Field', value: 46),
  ];
}
