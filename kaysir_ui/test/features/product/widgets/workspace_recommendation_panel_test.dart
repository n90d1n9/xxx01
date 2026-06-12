import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_workspace_recommendation.dart';
import 'package:kaysir/features/product/widgets/workspace_recommendation_panel.dart';

void main() {
  testWidgets('workspace recommendation panel renders and delegates actions', (
    tester,
  ) async {
    ProductWorkspaceRecommendation? selectedRecommendation;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductWorkspaceRecommendationPanel(
            recommendations: _recommendations,
            onRecommendationSelected:
                (recommendation) => selectedRecommendation = recommendation,
          ),
        ),
      ),
    );

    expect(find.text('Recommended next steps'), findsOneWidget);
    expect(find.text('Clear launch queue'), findsOneWidget);
    expect(find.text('Fix catalog setup'), findsOneWidget);
    expect(find.text('Review stock attention'), findsOneWidget);
    expect(find.text('Core'), findsWidgets);
    expect(find.text('Open queue'), findsOneWidget);

    await tester.tap(find.text('Open queue'));

    expect(selectedRecommendation?.id, 'launch_queue');
  });

  testWidgets('workspace recommendation panel disables missing route actions', (
    tester,
  ) async {
    ProductWorkspaceRecommendation? selectedRecommendation;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductWorkspaceRecommendationPanel(
            recommendations: const [
              ProductWorkspaceRecommendation(
                id: 'workflow_setup',
                title: 'Connect workflow',
                subtitle: 'Freshness Queue - Connect freshness route first',
                actionLabel: 'Review setup',
                statusLabel: 'Partial',
                priority: ProductWorkspaceRecommendationPriority.medium,
              ),
            ],
            onRecommendationSelected:
                (recommendation) => selectedRecommendation = recommendation,
          ),
        ),
      ),
    );

    expect(find.text('Connect workflow'), findsOneWidget);
    await tester.tap(find.text('Review setup'));

    expect(selectedRecommendation, isNull);
  });
}

const _recommendations = [
  ProductWorkspaceRecommendation(
    id: 'launch_queue',
    title: 'Clear launch queue',
    subtitle: 'Self-Service Kiosk: Fix missing scan code',
    actionLabel: 'Open queue',
    statusLabel: 'Priority',
    priority: ProductWorkspaceRecommendationPriority.critical,
    routePath: '/products?filter=in_stock&q=Missing+scan+code',
  ),
  ProductWorkspaceRecommendation(
    id: 'catalog_setup',
    title: 'Fix catalog setup',
    subtitle: '2 missing description',
    actionLabel: 'Open setup',
    statusLabel: 'Setup',
    priority: ProductWorkspaceRecommendationPriority.high,
    sourceLabel: 'Grocery Fresh Goods',
    routePath: '/products?q=No+description',
  ),
  ProductWorkspaceRecommendation(
    id: 'stock_attention',
    title: 'Review stock attention',
    subtitle: '3 products need attention',
    actionLabel: 'Open attention',
    statusLabel: 'Attention',
    priority: ProductWorkspaceRecommendationPriority.medium,
    routePath: '/products?filter=attention',
  ),
];
