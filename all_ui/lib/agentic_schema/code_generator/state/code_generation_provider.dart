import 'package:flutter_riverpod/legacy.dart';

import '../../schema/common/ai_agen_builder_model.dart';
import '../service/code_generator_factory.dart';

class CodeGenerationState {
  final bool isGenerating;
  final String? error;
  final Map<String, String>? generatedFiles;
  final double progress;

  CodeGenerationState({
    this.isGenerating = false,
    this.error,
    this.generatedFiles,
    this.progress = 0.0,
  });

  CodeGenerationState copyWith({
    bool? isGenerating,
    String? error,
    Map<String, String>? generatedFiles,
    double? progress,
  }) {
    return CodeGenerationState(
      isGenerating: isGenerating ?? this.isGenerating,
      error: error ?? this.error,
      generatedFiles: generatedFiles ?? this.generatedFiles,
      progress: progress ?? this.progress,
    );
  }
}

class CodeGenerationNotifier extends StateNotifier<CodeGenerationState> {
  CodeGenerationNotifier() : super(CodeGenerationState());

  Future<void> generate({
    required AIAgentBuilderModel model,
    required String generatorType,
    required String outputDirectory,
  }) async {
    state = state.copyWith(isGenerating: true, progress: 0.0, error: null);

    try {
      state = state.copyWith(progress: 0.2);

      final generator = CodeGeneratorFactory.create(
        type: generatorType,
        templateDirectory: 'assets/templates',
        outputDirectory: outputDirectory,
      );

      state = state.copyWith(progress: 0.4);

      final files = await generator.generate(model);

      state = state.copyWith(progress: 0.7);

      await generator.writeToFiles(files);

      state = state.copyWith(
        isGenerating: false,
        generatedFiles: files,
        progress: 1.0,
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: e.toString(),
        progress: 0.0,
      );
    }
  }

  void reset() {
    state = CodeGenerationState();
  }
}

final codeGenerationProvider =
    StateNotifierProvider<CodeGenerationNotifier, CodeGenerationState>(
      (ref) => CodeGenerationNotifier(),
    );
