import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../widgets/layout_preview.dart';
import 'responsive_preview_provider.dart';

class ResponsivePreview extends ConsumerWidget {
  const ResponsivePreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previewMode = ref.watch(responsivePreviewProvider);

    return SizedBox(
      width: previewMode.width,
      height: previewMode.height,
      child: const LayoutPreview(),
    );
  }
}
