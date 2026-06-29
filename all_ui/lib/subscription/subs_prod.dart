import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

// Models
class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String billingCycle;
  final List<String> features;
  final bool isPopular;
  final String category;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.billingCycle,
    required this.features,
    this.isPopular = false,
    required this.category,
  });
}

// Sample data
final subscriptionPlans = [
  SubscriptionPlan(
    id: 'software_basic',
    name: 'Basic',
    description: 'Perfect for individuals',
    price: 9.99,
    billingCycle: 'monthly',
    features: ['Core features', '5GB storage', 'Email support'],
    category: 'Software',
  ),
  SubscriptionPlan(
    id: 'software_pro',
    name: 'Pro',
    description: 'Ideal for professionals',
    price: 19.99,
    billingCycle: 'monthly',
    features: [
      'All Basic features',
      '25GB storage',
      'Priority support',
      'Advanced analytics',
    ],
    isPopular: true,
    category: 'Software',
  ),
  SubscriptionPlan(
    id: 'software_team',
    name: 'Team',
    description: 'Best for small teams',
    price: 49.99,
    billingCycle: 'monthly',
    features: [
      'All Pro features',
      '100GB storage',
      'Dedicated support',
      'Team collaboration',
      'Custom branding',
    ],
    category: 'Software',
  ),
  SubscriptionPlan(
    id: 'service_starter',
    name: 'Starter',
    description: 'Essential service package',
    price: 29.99,
    billingCycle: 'monthly',
    features: ['24/7 monitoring', 'Basic reporting', 'Email alerts'],
    category: 'Service',
  ),
  SubscriptionPlan(
    id: 'service_business',
    name: 'Business',
    description: 'Complete service solution',
    price: 79.99,
    billingCycle: 'monthly',
    features: [
      'Advanced monitoring',
      'Detailed analytics',
      '24/7 phone support',
      'Custom integrations',
    ],
    isPopular: true,
    category: 'Service',
  ),
];

// Providers
final selectedCategoryProvider = StateProvider<String>((ref) => 'Software');
final billingCycleProvider = StateProvider<String>((ref) => 'monthly');

final filteredPlansProvider = Provider<List<SubscriptionPlan>>((ref) {
  final selectedCategory = ref.watch(selectedCategoryProvider);
  return subscriptionPlans
      .where((plan) => plan.category == selectedCategory)
      .toList();
});

final selectedPlanProvider = StateProvider<SubscriptionPlan?>((ref) {
  final plans = ref.watch(filteredPlansProvider);
  return plans.isEmpty
      ? null
      : plans.firstWhere((plan) => plan.isPopular, orElse: () => plans.first);
});

// UI
class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final billingCycle = ref.watch(billingCycleProvider);
    final filteredPlans = ref.watch(filteredPlansProvider);
    final selectedPlan = ref.watch(selectedPlanProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 180,
              backgroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Choose Your Plan',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        'https://images.unsplash.com/photo-1620641788421-7a1c342ea42e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1074&q=80',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Selector
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap:
                                  () =>
                                      ref
                                          .read(
                                            selectedCategoryProvider.notifier,
                                          )
                                          .state = 'Software',
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color:
                                      selectedCategory == 'Software'
                                          ? const Color(0xFF6366F1)
                                          : Colors.white,
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Software',
                                  style: TextStyle(
                                    color:
                                        selectedCategory == 'Software'
                                            ? Colors.white
                                            : const Color(0xFF64748B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap:
                                  () =>
                                      ref
                                          .read(
                                            selectedCategoryProvider.notifier,
                                          )
                                          .state = 'Service',
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color:
                                      selectedCategory == 'Service'
                                          ? const Color(0xFF6366F1)
                                          : Colors.white,
                                  borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Service',
                                  style: TextStyle(
                                    color:
                                        selectedCategory == 'Service'
                                            ? Colors.white
                                            : const Color(0xFF64748B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Billing Cycle Toggle
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap:
                                  () =>
                                      ref
                                          .read(billingCycleProvider.notifier)
                                          .state = 'monthly',
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color:
                                      billingCycle == 'monthly'
                                          ? const Color(0xFF6366F1)
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Monthly',
                                  style: TextStyle(
                                    color:
                                        billingCycle == 'monthly'
                                            ? Colors.white
                                            : const Color(0xFF64748B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap:
                                  () =>
                                      ref
                                          .read(billingCycleProvider.notifier)
                                          .state = 'yearly',
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color:
                                          billingCycle == 'yearly'
                                              ? const Color(0xFF6366F1)
                                              : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Yearly',
                                      style: TextStyle(
                                        color:
                                            billingCycle == 'yearly'
                                                ? Colors.white
                                                : const Color(0xFF64748B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 20,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Save 20%',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Subscription Plans
                    ...filteredPlans.map(
                      (plan) => SubscriptionPlanCard(
                        plan: plan,
                        isSelected: selectedPlan?.id == plan.id,
                        billingCycle: billingCycle,
                        onTap:
                            () =>
                                ref.read(selectedPlanProvider.notifier).state =
                                    plan,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Subscribe Button
                    if (selectedPlan != null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle subscription
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Subscribed to ${selectedPlan.name} plan',
                                ),
                                backgroundColor: const Color(0xFF6366F1),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Subscribe Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Terms & Conditions
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // Show terms and conditions
                        },
                        child: const Text(
                          'Terms and Conditions apply',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubscriptionPlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isSelected;
  final String billingCycle;
  final VoidCallback onTap;

  const SubscriptionPlanCard({
    Key? key,
    required this.plan,
    required this.isSelected,
    required this.billingCycle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final multiplier = billingCycle == 'yearly' ? 10 : 1;
    final finalPrice = plan.price * multiplier;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  if (plan.isPopular)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'POPULAR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Price
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${finalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    billingCycle == 'yearly' ? '/year' : '/month',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  if (billingCycle == 'yearly')
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Save 20%',
                        style: TextStyle(
                          color: Color(0xFF6366F1),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Features
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What\'s included:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...plan.features.map(
                    (feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            feature,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Selection Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      isSelected ? Colors.white : const Color(0xFF6366F1),
                  backgroundColor:
                      isSelected ? const Color(0xFF6366F1) : Colors.white,
                  side: BorderSide(color: const Color(0xFF6366F1), width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Center(
                  child: Text(
                    isSelected ? 'Selected' : 'Select Plan',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color:
                          isSelected ? Colors.white : const Color(0xFF6366F1),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Subscription App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF6366F1),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        fontFamily: 'Inter',
      ),
      home: const SubscriptionScreen(),
    );
  }
}
