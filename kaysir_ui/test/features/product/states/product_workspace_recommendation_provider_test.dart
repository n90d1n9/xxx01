import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/product/models/product_workspace_recommendation.dart';
import 'package:kaysir/features/product/states/product_workspace_recommendation_provider.dart';

void main() {
  test('workspace recommendation contributions provider exposes defaults', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container
          .read(productWorkspaceRecommendationContributionsProvider)
          .map((contribution) => contribution.id),
      [
        'freshness_data_setup',
        'coffee_counter_operations_recommendations',
        'restaurant_menu_operations_recommendations',
        'retail_assortment_operations_recommendations',
        'kiosk_self_service_operations_recommendations',
      ],
    );
  });

  test('workspace recommendation contributions provider is overrideable', () {
    final customContribution = ProductWorkspaceRecommendationContribution(
      id: 'custom_pack_recommendations',
      buildRecommendations: (_) => const [],
    );
    final container = ProviderContainer(
      overrides: [
        productWorkspaceRecommendationContributionsProvider.overrideWithValue([
          customContribution,
        ]),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(productWorkspaceRecommendationContributionsProvider),
      [customContribution],
    );
  });
}
