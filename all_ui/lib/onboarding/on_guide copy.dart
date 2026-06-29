import 'package:flutter/material.dart';

// Main onboarding controller
class OnboardingController extends ChangeNotifier {
  List<OnboardingStep> _steps = [];
  int _currentStep = 0;
  bool _isActive = false;
  OverlayEntry? _overlayEntry;

  bool get isActive => _isActive;
  int get currentStep => _currentStep;
  OnboardingStep? get currentStepData =>
      _currentStep < _steps.length ? _steps[_currentStep] : null;

  void startOnboarding(List<OnboardingStep> steps) {
    _steps = steps;
    _currentStep = 0;
    _isActive = true;
    notifyListeners();
    _showOverlay();
  }

  void nextStep() {
    if (_currentStep < _steps.length - 1) {
      _currentStep++;
      notifyListeners();
      _updateOverlay();
    } else {
      finishOnboarding();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
      _updateOverlay();
    }
  }

  void finishOnboarding() {
    _isActive = false;
    _hideOverlay();
    notifyListeners();
  }

  void _showOverlay() {
    final context = _steps[_currentStep].targetKey.currentContext;
    if (context != null) {
      _overlayEntry = OverlayEntry(
        builder: (context) => OnboardingOverlay(controller: this),
      );
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _updateOverlay() {
    _overlayEntry?.markNeedsBuild();
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

// Onboarding step data model
class OnboardingStep {
  final GlobalKey targetKey;
  final String title;
  final String description;
  final Widget? customContent;
  final EdgeInsets tooltipPadding;
  final Color? backgroundColor;
  final double borderRadius;

  OnboardingStep({
    required this.targetKey,
    required this.title,
    required this.description,
    this.customContent,
    this.tooltipPadding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.borderRadius = 8.0,
  });
}

// Overlay widget that shows the onboarding UI
class OnboardingOverlay extends StatelessWidget {
  final OnboardingController controller;

  const OnboardingOverlay({Key? key, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final step = controller.currentStepData;
    if (step == null) return const SizedBox.shrink();

    final targetContext = step.targetKey.currentContext;
    if (targetContext == null) return const SizedBox.shrink();

    final renderBox = targetContext.findRenderObject() as RenderBox;
    final targetSize = renderBox.size;
    final targetPosition = renderBox.localToGlobal(Offset.zero);

    return Material(
      color: Colors.black54,
      child: Stack(
        children: [
          // Dark overlay with hole
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: HolePainter(
              targetPosition: targetPosition,
              targetSize: targetSize,
              borderRadius: step.borderRadius,
            ),
          ),

          // Tooltip
          Positioned(
            child: OnboardingTooltip(
              step: step,
              targetPosition: targetPosition,
              targetSize: targetSize,
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter to create hole in overlay
class HolePainter extends CustomPainter {
  final Offset targetPosition;
  final Size targetSize;
  final double borderRadius;

  HolePainter({
    required this.targetPosition,
    required this.targetSize,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;

    final holePath =
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              targetPosition.dx - 4,
              targetPosition.dy - 4,
              targetSize.width + 8,
              targetSize.height + 8,
            ),
            Radius.circular(borderRadius),
          ),
        );

    final fullPath =
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final combinedPath = Path.combine(
      PathOperation.difference,
      fullPath,
      holePath,
    );

    canvas.drawPath(combinedPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Tooltip widget
class OnboardingTooltip extends StatelessWidget {
  final OnboardingStep step;
  final Offset targetPosition;
  final Size targetSize;
  final OnboardingController controller;

  const OnboardingTooltip({
    Key? key,
    required this.step,
    required this.targetPosition,
    required this.targetSize,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final tooltipWidth = screenSize.width * 0.8;
    final targetCenter =
        targetPosition + Offset(targetSize.width / 2, targetSize.height / 2);

    // Determine tooltip position
    bool showAbove = targetCenter.dy > screenSize.height * 0.6;
    double tooltipX = (targetCenter.dx - tooltipWidth / 2).clamp(
      20,
      screenSize.width - tooltipWidth - 20,
    );
    double tooltipY =
        showAbove
            ? targetPosition.dy -
                20 -
                120 // Approximate tooltip height
            : targetPosition.dy + targetSize.height + 20;

    return Positioned(
      left: tooltipX,
      top: tooltipY,
      child: Container(
        width: tooltipWidth,
        decoration: BoxDecoration(
          color: step.backgroundColor ?? Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: step.tooltipPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                step.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (step.customContent != null) ...[
                const SizedBox(height: 12),
                step.customContent!,
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${controller.currentStep + 1} of ${controller._steps.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Row(
                    children: [
                      if (controller.currentStep > 0)
                        TextButton(
                          onPressed: controller.previousStep,
                          child: const Text('Previous'),
                        ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: controller.nextStep,
                        child: Text(
                          controller.currentStep == controller._steps.length - 1
                              ? 'Finish'
                              : 'Next',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget wrapper to mark onboarding targets
class OnboardingTarget extends StatelessWidget {
  final GlobalKey onboardingKey;
  final Widget child;

  const OnboardingTarget({
    Key? key,
    required this.onboardingKey,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(key: onboardingKey, child: child);
  }
}

// Example usage widget
class OnboardingExample extends StatefulWidget {
  @override
  _OnboardingExampleState createState() => _OnboardingExampleState();
}

class _OnboardingExampleState extends State<OnboardingExample> {
  final OnboardingController _onboardingController = OnboardingController();

  // Keys for targeting specific widgets
  final GlobalKey _menuKey = GlobalKey();
  final GlobalKey _fabKey = GlobalKey();
  final GlobalKey _drawerKey = GlobalKey();
  final GlobalKey _searchKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // Start onboarding after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startOnboarding();
    });
  }

  void _startOnboarding() {
    final steps = [
      OnboardingStep(
        targetKey: _menuKey,
        title: 'Welcome to the App!',
        description:
            'This is your main menu. Tap here to access different sections of the app.',
      ),
      OnboardingStep(
        targetKey: _searchKey,
        title: 'Search Feature',
        description:
            'Use this search button to quickly find what you\'re looking for.',
        customContent: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '💡 Pro tip: You can also use voice search!',
            style: TextStyle(fontSize: 12, color: Colors.blue),
          ),
        ),
      ),
      OnboardingStep(
        targetKey: _fabKey,
        title: 'Create New Items',
        description:
            'Tap this floating action button to create new content or start a new task.',
        backgroundColor: Colors.blue.shade50,
      ),
      OnboardingStep(
        targetKey: _drawerKey,
        title: 'Navigation Menu',
        description:
            'Access your profile, settings, and other options from this menu.',
      ),
    ];

    _onboardingController.startOnboarding(steps);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _onboardingController,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Onboarding Demo'),
            leading: OnboardingTarget(
              onboardingKey: _drawerKey,
              child: Builder(
                builder:
                    (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
              ),
            ),
            actions: [
              OnboardingTarget(
                onboardingKey: _searchKey,
                child: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
              ),
              OnboardingTarget(
                onboardingKey: _menuKey,
                child: PopupMenuButton<String>(
                  onSelected: (value) {},
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'settings',
                          child: Text('Settings'),
                        ),
                        const PopupMenuItem(
                          value: 'profile',
                          child: Text('Profile'),
                        ),
                        const PopupMenuItem(value: 'help', child: Text('Help')),
                      ],
                ),
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Text(
                    'Menu',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                ListTile(title: const Text('Home'), onTap: () {}),
                ListTile(title: const Text('Profile'), onTap: () {}),
                ListTile(title: const Text('Settings'), onTap: () {}),
              ],
            ),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Welcome to the app!'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _startOnboarding,
                  child: const Text('Restart Onboarding'),
                ),
              ],
            ),
          ),
          floatingActionButton: OnboardingTarget(
            onboardingKey: _fabKey,
            child: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _onboardingController.dispose();
    super.dispose();
  }
}

void main(List<String> args) {
  runApp(MaterialApp(home: OnboardingExample()));
}
