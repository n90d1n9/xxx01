import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';

import '../models/schema.dart';
import '../services/tranform_service.dart';

// Transformation Service Provider
final transformationServiceProvider = Provider(
  (ref) => TransformationService(),
);

// Schema Configuration State Notifier
class SchemaMappingState {
  final List<SchemaMappingConfiguration> configurations;
  final Option<SchemaMappingConfiguration> activeConfiguration;

  SchemaMappingState({
    this.configurations = const [],
    this.activeConfiguration = const None(),
  });

  SchemaMappingState copyWith({
    List<SchemaMappingConfiguration>? configurations,
    Option<SchemaMappingConfiguration>? activeConfiguration,
  }) {
    return SchemaMappingState(
      configurations: configurations ?? this.configurations,
      activeConfiguration: activeConfiguration ?? this.activeConfiguration,
    );
  }
}

class SchemaMappingNotifier extends StateNotifier<SchemaMappingState> {
  SchemaMappingNotifier() : super(SchemaMappingState());

  void addConfiguration(SchemaMappingConfiguration configuration) {
    state = state.copyWith(
      configurations: [...state.configurations, configuration],
      activeConfiguration: Some(configuration),
    );
  }

  void updateActiveConfiguration(SchemaMappingConfiguration configuration) {
    state = state.copyWith(
      configurations:
          state.configurations
              .map(
                (config) =>
                    config.sourceSchemaName == configuration.sourceSchemaName
                        ? configuration
                        : config,
              )
              .toList(),
      activeConfiguration: Some(configuration),
    );
  }

  void selectConfiguration(String sourceSchemaName) {
    final config = state.configurations.firstWhere(
      (config) => config.sourceSchemaName == sourceSchemaName,
      orElse: () => throw Exception('Configuration not found'),
    );
    state = state.copyWith(activeConfiguration: Some(config));
  }
}

// Providers
final schemaMappingProvider =
    StateNotifierProvider<SchemaMappingNotifier, SchemaMappingState>((ref) {
      return SchemaMappingNotifier();
    });

final activeConfigurationProvider =
    Provider<Option<SchemaMappingConfiguration>>((ref) {
      return ref.watch(schemaMappingProvider).activeConfiguration;
    });
