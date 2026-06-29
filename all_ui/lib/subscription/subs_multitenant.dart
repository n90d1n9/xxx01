import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

// Models
class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double monthlyPrice;
  final double yearlyPrice;
  final List<String> features;
  final bool isPopular;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
    this.isPopular = false,
  });
}

class Tenant {
  final String id;
  final String name;
  final String logoUrl;

  Tenant({required this.id, required this.name, required this.logoUrl});
}

// Providers
final selectedTenantProvider = StateProvider<Tenant?>((ref) => null);

final tenantsProvider = Provider<List<Tenant>>(
  (ref) => [
    Tenant(
      id: "tenant1",
      name: "Workspace One",
      logoUrl: "assets/tenant1_logo.png",
    ),
    Tenant(
      id: "tenant2",
      name: "Brand X Solutions",
      logoUrl: "assets/tenant2_logo.png",
    ),
    Tenant(
      id: "tenant3",
      name: "Tech Innovators",
      logoUrl: "assets/tenant3_logo.png",
    ),
  ],
);

final subscriptionPlansProvider = Provider<List<SubscriptionPlan>>(
  (ref) => [
    SubscriptionPlan(
      id: "basic",
      name: "Starter",
      description: "Basic features for small teams",
      monthlyPrice: 9.99,
      yearlyPrice: 99.99,
      features: ["5 users", "10GB storage", "Basic analytics", "Email support"],
    ),
    SubscriptionPlan(
      id: "pro",
      name: "Professional",
      description: "Advanced tools for growing businesses",
      monthlyPrice: 19.99,
      yearlyPrice: 199.99,
      features: [
        "20 users",
        "50GB storage",
        "Advanced analytics",
        "Priority support",
        "Custom branding",
        "API access",
      ],
      isPopular: true,
    ),
    SubscriptionPlan(
      id: "enterprise",
      name: "Enterprise",
      description: "Full-featured solution for large organizations",
      monthlyPrice: 49.99,
      yearlyPrice: 499.99,
      features: [
        "Unlimited users",
        "500GB storage",
        "Enterprise analytics",
        "24/7 support",
        "Custom branding",
        "API access",
        "Dedicated account manager",
        "Custom integrations",
      ],
    ),
  ],
);

final isYearlyBillingProvider = StateProvider<bool>((ref) => false);
final selectedPlanIdProvider = StateProvider<String?>((ref) => null);

final subscriptionStateProvider = Provider<SubscriptionState>((ref) {
  final selectedTenant = ref.watch(selectedTenantProvider);
  final isYearlyBilling = ref.watch(isYearlyBillingProvider);
  final selectedPlanId = ref.watch(selectedPlanIdProvider);
  final plans = ref.watch(subscriptionPlansProvider);

  final selectedPlan = plans.firstWhere(
    (plan) => plan.id == selectedPlanId,
    orElse: () => plans.firstWhere((plan) => plan.isPopular),
  );

  return SubscriptionState(
    tenant: selectedTenant,
    isYearlyBilling: isYearlyBilling,
    selectedPlan: selectedPlan,
    plans: plans,
  );
});

class SubscriptionState {
  final Tenant? tenant;
  final bool isYearlyBilling;
  final SubscriptionPlan selectedPlan;
  final List<SubscriptionPlan> plans;

  SubscriptionState({
    this.tenant,
    required this.isYearlyBilling,
    required this.selectedPlan,
    required this.plans,
  });

  double get selectedPrice =>
      isYearlyBilling ? selectedPlan.yearlyPrice : selectedPlan.monthlyPrice;

  String get billingPeriod => isYearlyBilling ? "year" : "month";
}

// Controllers
class SubscriptionController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  SubscriptionController(this.ref) : super(const AsyncValue.data(null));

  Future<void> subscribe() async {
    final subscriptionState = ref.read(subscriptionStateProvider);

    if (subscriptionState.tenant == null) {
      throw Exception("No tenant selected");
    }

    state = const AsyncValue.loading();

    try {
      // Here you would integrate with your payment provider
      // and backend service to create the subscription
      await Future.delayed(const Duration(seconds: 2)); // Simulating API call

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void selectPlan(String planId) {
    ref.read(selectedPlanIdProvider.notifier).state = planId;
  }

  void toggleBillingPeriod() {
    ref.read(isYearlyBillingProvider.notifier).update((state) => !state);
  }

  void selectTenant(Tenant tenant) {
    ref.read(selectedTenantProvider.notifier).state = tenant;
  }
}

final subscriptionControllerProvider =
    StateNotifierProvider<SubscriptionController, AsyncValue<void>>(
      (ref) => SubscriptionController(ref),
    );

// UI Components
class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionStateProvider);
    final tenants = ref.watch(tenantsProvider);
    final subscriptionControllerState = ref.watch(
      subscriptionControllerProvider,
    );
    final controller = ref.read(subscriptionControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, subscriptionState),
              const SizedBox(height: 20),
              if (subscriptionState.tenant == null)
                _buildTenantSelector(context, tenants, controller)
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBillingToggle(
                        context,
                        subscriptionState,
                        controller,
                      ),
                      const SizedBox(height: 24),
                      _buildSubscriptionPlans(
                        context,
                        subscriptionState,
                        controller,
                      ),
                      const SizedBox(height: 32),
                      _buildSubscribeButton(
                        context,
                        subscriptionState,
                        controller,
                        subscriptionControllerState,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SubscriptionState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.tenant != null)
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: Image.asset(
                    state.tenant!.logoUrl,
                    width: 24,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            Text(state.tenant!.name[0]),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  state.tenant!.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            )
          else
            const SizedBox.shrink(),
          const SizedBox(height: 16),
          Text(
            state.tenant == null
                ? "Choose Your Workspace"
                : "Choose Your Subscription Plan",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.tenant == null
                ? "Select the workspace you want to subscribe to"
                : "Flexible plans designed to meet your needs",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTenantSelector(
    BuildContext context,
    List<Tenant> tenants,
    SubscriptionController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Available Workspaces",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...tenants.map(
            (tenant) => _buildTenantCard(context, tenant, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildTenantCard(
    BuildContext context,
    Tenant tenant,
    SubscriptionController controller,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.selectTenant(tenant),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Image.asset(
                  tenant.logoUrl,
                  width: 28,
                  errorBuilder:
                      (context, error, stackTrace) => Text(
                        tenant.name[0],
                        style: const TextStyle(fontSize: 20),
                      ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tenant.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "ID: ${tenant.id}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.primary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillingToggle(
    BuildContext context,
    SubscriptionState state,
    SubscriptionController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            context,
            "Monthly",
            !state.isYearlyBilling,
            () => controller.toggleBillingPeriod(),
          ),
          _buildToggleButton(
            context,
            "Yearly",
            state.isYearlyBilling,
            () => controller.toggleBillingPeriod(),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context,
    String text,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Text(
              text,
              style: TextStyle(
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (text == "Yearly" && isSelected)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Save 16%",
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionPlans(
    BuildContext context,
    SubscriptionState state,
    SubscriptionController controller,
  ) {
    return Column(
      children:
          state.plans
              .map((plan) => _buildPlanCard(context, plan, state, controller))
              .toList(),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    SubscriptionPlan plan,
    SubscriptionState state,
    SubscriptionController controller,
  ) {
    final isSelected = plan.id == state.selectedPlan.id;
    final price = state.isYearlyBilling ? plan.yearlyPrice : plan.monthlyPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Material(
          color:
              isSelected
                  ? Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.2)
                  : Theme.of(context).colorScheme.surface,
          child: InkWell(
            onTap: () => controller.selectPlan(plan.id),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  plan.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                if (plan.isPopular)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "POPULAR",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSecondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              plan.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Radio(
                        value: plan.id,
                        groupValue: state.selectedPlan.id,
                        onChanged:
                            (value) => controller.selectPlan(value as String),
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "\$${price.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        "/${state.billingPeriod}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children:
                        plan.features.map((feature) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubscribeButton(
    BuildContext context,
    SubscriptionState state,
    SubscriptionController controller,
    AsyncValue<void> subscriptionState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                subscriptionState.isLoading
                    ? null
                    : () => controller.subscribe(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child:
                subscriptionState.isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Text(
                      "Subscribe for \$${state.selectedPrice.toStringAsFixed(2)}/${state.billingPeriod}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "You can cancel your subscription anytime",
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// Theme configuration
ThemeData createAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF6750A4),
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.background,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
    ),
  );
}

// Example usage
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-Tenant Subscription',
      theme: createAppTheme(),
      home: const SubscriptionScreen(),
    );
  }
}
