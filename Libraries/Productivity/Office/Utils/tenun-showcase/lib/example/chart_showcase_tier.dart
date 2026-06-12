enum ChartShowcaseTier { core, pro, custom }

extension ChartShowcaseTierLabel on ChartShowcaseTier {
  String get key => name;

  String get label => switch (this) {
    ChartShowcaseTier.core => 'Core',
    ChartShowcaseTier.pro => 'Pro',
    ChartShowcaseTier.custom => 'Custom',
  };
}

enum ChartShowcaseTierFilter { all, core, pro, custom }

extension ChartShowcaseTierFilterLabel on ChartShowcaseTierFilter {
  String get label => switch (this) {
    ChartShowcaseTierFilter.all => 'All',
    ChartShowcaseTierFilter.core => 'Core',
    ChartShowcaseTierFilter.pro => 'Pro',
    ChartShowcaseTierFilter.custom => 'Custom',
  };

  bool includes(ChartShowcaseTier tier) => switch (this) {
    ChartShowcaseTierFilter.all => true,
    ChartShowcaseTierFilter.core => tier == ChartShowcaseTier.core,
    ChartShowcaseTierFilter.pro => tier == ChartShowcaseTier.pro,
    ChartShowcaseTierFilter.custom => tier == ChartShowcaseTier.custom,
  };
}
