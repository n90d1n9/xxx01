import 'package:flutter/widgets.dart';

import '../models/experience_profile.dart';

/// Inherited scope that exposes the active product experience profile.
class ProductExperienceProfileScope extends InheritedWidget {
  const ProductExperienceProfileScope({
    super.key,
    required this.profile,
    required super.child,
  });

  final ProductExperienceProfile profile;

  static ProductExperienceProfile? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ProductExperienceProfileScope>()
        ?.profile;
  }

  @override
  bool updateShouldNotify(ProductExperienceProfileScope oldWidget) {
    return oldWidget.profile != profile;
  }
}
