import 'pos_experience.dart';

class POSExperienceCatalog {
  final List<POSExperienceCatalogSection> sections;

  const POSExperienceCatalog({required this.sections});

  factory POSExperienceCatalog.fromExperiences(
    Iterable<POSExperience> experiences,
  ) {
    final sectionsByProductLine = <String, List<POSExperience>>{};
    final productLineOrder = <String>[];

    for (final experience in experiences) {
      final productLine = experience.manifest.productLine.trim();
      final sectionKey = productLine.isEmpty ? 'Unassigned' : productLine;

      if (!sectionsByProductLine.containsKey(sectionKey)) {
        productLineOrder.add(sectionKey);
        sectionsByProductLine[sectionKey] = <POSExperience>[];
      }

      sectionsByProductLine[sectionKey]!.add(experience);
    }

    return POSExperienceCatalog(
      sections: List.unmodifiable(
        productLineOrder.map((productLine) {
          return POSExperienceCatalogSection(
            productLine: productLine,
            experiences: List.unmodifiable(sectionsByProductLine[productLine]!),
          );
        }),
      ),
    );
  }

  bool get isEmpty => sections.isEmpty;

  bool get isSingleExperience {
    return sections.fold<int>(
          0,
          (count, section) => count + section.experiences.length,
        ) <=
        1;
  }

  Iterable<POSExperience> get experiences {
    return sections.expand((section) => section.experiences);
  }
}

class POSExperienceCatalogSection {
  final String productLine;
  final List<POSExperience> experiences;

  const POSExperienceCatalogSection({
    required this.productLine,
    required this.experiences,
  });

  int get experienceCount => experiences.length;
}
