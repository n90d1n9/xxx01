import 'package:flutter_riverpod/legacy.dart';

import '../models/complete_pipeline.dart';
import '../models/model_version.dart';

final currentPipelineProvider = StateProvider<CompletePipeline?>((ref) => null);
final selectedTabProvider = StateProvider<int>((ref) => 0);
final pipelinesProvider = StateProvider<List<CompletePipeline>>((ref) => []);
final modelRegistryProvider = StateProvider<List<ModelVersion>>((ref) => []);
