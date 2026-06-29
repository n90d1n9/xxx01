import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/code_generator.dart';
import 'provider.dart';

final codeGeneratorProvider = Provider.family<String, String>((ref, framework) {
  final state = ref.watch(designerProvider);
  return CodeGenerator.generate(framework, state.components);
});
