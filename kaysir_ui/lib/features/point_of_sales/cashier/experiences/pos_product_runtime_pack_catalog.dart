import 'pos_product_runtime_pack.dart';

class POSProductRuntimePackCatalog {
  final List<POSProductRuntimePackCatalogSection> sections;

  const POSProductRuntimePackCatalog({required this.sections});

  factory POSProductRuntimePackCatalog.fromPacks(
    Iterable<POSProductRuntimePack> packs,
  ) {
    final sectionsByProductLine = <String, List<POSProductRuntimePack>>{};
    final productLineOrder = <String>[];

    for (final pack in packs) {
      final productLine = pack.productLine.trim();
      final sectionKey = productLine.isEmpty ? 'Unassigned' : productLine;

      if (!sectionsByProductLine.containsKey(sectionKey)) {
        productLineOrder.add(sectionKey);
        sectionsByProductLine[sectionKey] = <POSProductRuntimePack>[];
      }

      sectionsByProductLine[sectionKey]!.add(pack);
    }

    return POSProductRuntimePackCatalog(
      sections: List.unmodifiable(
        productLineOrder.map((productLine) {
          return POSProductRuntimePackCatalogSection(
            productLine: productLine,
            packs: List.unmodifiable(sectionsByProductLine[productLine]!),
          );
        }),
      ),
    );
  }

  bool get isEmpty => sections.isEmpty;

  bool get isSinglePack {
    return sections.fold<int>(
          0,
          (count, section) => count + section.packs.length,
        ) <=
        1;
  }

  Iterable<POSProductRuntimePack> get packs {
    return sections.expand((section) => section.packs);
  }
}

class POSProductRuntimePackCatalogSection {
  final String productLine;
  final List<POSProductRuntimePack> packs;

  const POSProductRuntimePackCatalogSection({
    required this.productLine,
    required this.packs,
  });

  int get packCount => packs.length;
}
