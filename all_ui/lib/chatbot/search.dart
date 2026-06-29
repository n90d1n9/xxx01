// Custom Painters for Advanced Effects
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:queue_ui/chatbot/search_1.dart';

// Models
class SearchResult {
  final String title;
  final String description;
  final String category;
  final String imageUrl;

  SearchResult({
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
  });
}

// Transition Effects Enum
enum TransitionEffect {
  slideUp,
  explode,
  spiral,
  wave,
  matrix,
  particles,
  ripple,
  fold,
}

class WaveClipper extends CustomClipper<Path> {
  final double animationValue;

  WaveClipper(this.animationValue);

  @override
  Path getClip(Size size) {
    final path = Path();
    final waveHeight = 20.0;
    final waveLength = size.width / 4;

    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x += 1) {
      final y =
          size.height * (1 - animationValue) +
          waveHeight *
              math.sin((x / waveLength + animationValue * 4) * 2 * math.pi);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) =>
      oldClipper.animationValue != animationValue;
}

class MatrixPainter extends CustomPainter {
  final double animationValue;

  MatrixPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.green.withOpacity(0.1 * animationValue)
          ..strokeWidth = 1;

    final random = math.Random(42);
    final lineCount = (size.height / 20).floor();

    for (int i = 0; i < lineCount; i++) {
      final x = random.nextDouble() * size.width;
      final startY = i * 20 - (size.height * (1 - animationValue));
      final endY = startY + 15;

      if (startY < size.height && endY > 0) {
        canvas.drawLine(
          Offset(x, math.max(0, startY)),
          Offset(x, math.min(size.height, endY)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(MatrixPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.purple.withOpacity(0.6);

    final random = math.Random(123);
    final particleCount = 50;

    for (int i = 0; i < particleCount; i++) {
      final progress = (animationValue + i / particleCount) % 1.0;
      final x = random.nextDouble() * size.width;
      final y = size.height * (1 - progress);
      final radius = 2 + progress * 3;

      paint.color = Colors.purple.withOpacity(0.6 * (1 - progress));
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class RipplePainter extends CustomPainter {
  final double animationValue;

  RipplePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius =
        math.sqrt(size.width * size.width + size.height * size.height) / 2;

    for (int i = 0; i < 3; i++) {
      final progress = (animationValue - i * 0.2).clamp(0.0, 1.0);
      if (progress > 0) {
        final radius = maxRadius * progress;
        final paint =
            Paint()
              ..color = Colors.blue.withOpacity(0.3 * (1 - progress))
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2;

        canvas.drawCircle(center, radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

// Providers
final chatbotVisibilityProvider = StateProvider<bool>((ref) => false);
final searchQueryProvider = StateProvider<String>((ref) => '');
final isSearchingProvider = StateProvider<bool>((ref) => false);
final searchResultsProvider = StateProvider<List<SearchResult>>((ref) => []);
final showResultsScreenProvider = StateProvider<bool>((ref) => false);
final transitionEffectProvider = StateProvider<TransitionEffect>(
  (ref) => TransitionEffect.slideUp,
);

// Search Provider
final searchProvider = FutureProvider.family<List<SearchResult>, String>((
  ref,
  query,
) async {
  if (query.isEmpty) return [];

  // Simulate API delay
  await Future.delayed(const Duration(milliseconds: 1500));

  // Mock search results
  return [
    SearchResult(
      title: 'Flutter Development Guide',
      description:
          'Complete guide to building modern Flutter applications with best practices',
      category: 'Development',
      imageUrl: 'https://picsum.photos/300/200?random=1',
    ),
    SearchResult(
      title: 'UI/UX Design Trends 2025',
      description:
          'Latest design trends and patterns for modern mobile applications',
      category: 'Design',
      imageUrl: 'https://picsum.photos/300/200?random=2',
    ),
    SearchResult(
      title: 'State Management with Riverpod',
      description:
          'Advanced techniques for managing application state efficiently',
      category: 'Architecture',
      imageUrl: 'https://picsum.photos/300/200?random=3',
    ),
    SearchResult(
      title: 'Animation Techniques',
      description: 'Creating smooth and engaging animations in Flutter apps',
      category: 'Animation',
      imageUrl: 'https://picsum.photos/300/200?random=4',
    ),
  ];
});

class ModernChatbotScreen extends ConsumerStatefulWidget {
  const ModernChatbotScreen({super.key});

  @override
  ConsumerState<ModernChatbotScreen> createState() =>
      _ModernChatbotScreenState();
}

class _ModernChatbotScreenState extends ConsumerState<ModernChatbotScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  late AnimationController _searchController;
  late AnimationController _resultsController;
  late AnimationController _particleController;
  late AnimationController _waveController;
  late AnimationController _spiralController;

  late Animation<double> _fabScaleAnimation;
  late Animation<double> _chatbotSlideAnimation;
  late Animation<double> _searchExpandAnimation;
  late Animation<double> _resultsSlideAnimation;
  late Animation<double> _backgroundBlurAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _spiralAnimation;

  final TextEditingController _searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _searchController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _resultsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _spiralController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _fabController, curve: Curves.easeInOut));

    _chatbotSlideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _searchController, curve: Curves.elasticOut),
    );

    _searchExpandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _searchController, curve: Curves.elasticOut),
    );

    _resultsSlideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _resultsController, curve: Curves.fastOutSlowIn),
    );

    _backgroundBlurAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _resultsController, curve: Curves.easeOut),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeOut),
    );

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    _spiralAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _spiralController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    _searchController.dispose();
    _resultsController.dispose();
    _particleController.dispose();
    _waveController.dispose();
    _spiralController.dispose();
    _searchTextController.dispose();
    super.dispose();
  }

  void _toggleChatbot() {
    final isVisible = ref.read(chatbotVisibilityProvider);
    ref.read(chatbotVisibilityProvider.notifier).state = !isVisible;

    if (!isVisible) {
      _fabController.forward();
    } else {
      _fabController.reverse();
      _searchController.reverse();
      ref.read(showResultsScreenProvider.notifier).state = false;
      _resultsController.reverse();
    }
  }

  void _performSearch() async {
    final query = _searchTextController.text;
    if (query.isEmpty) return;

    ref.read(searchQueryProvider.notifier).state = query;
    ref.read(isSearchingProvider.notifier).state = true;

    // Start search animation
    _searchController.forward();

    // Wait for search animation to complete, then show results
    await Future.delayed(const Duration(milliseconds: 400));

    ref.read(showResultsScreenProvider.notifier).state = true;

    // Start transition animations based on selected effect
    final effect = ref.read(transitionEffectProvider);
    switch (effect) {
      case TransitionEffect.slideUp:
        _resultsController.forward();
        break;
      case TransitionEffect.explode:
      case TransitionEffect.matrix:
        _resultsController.forward();
        break;
      case TransitionEffect.spiral:
        _spiralController.forward();
        break;
      case TransitionEffect.wave:
        _waveController.forward();
        break;
      case TransitionEffect.particles:
        _particleController.forward();
        break;
      case TransitionEffect.ripple:
      case TransitionEffect.fold:
        _resultsController.forward();
        break;
    }

    // Simulate search completion
    await Future.delayed(const Duration(milliseconds: 1500));
    ref.read(isSearchingProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    final chatbotVisible = ref.watch(chatbotVisibilityProvider);
    final showResults = ref.watch(showResultsScreenProvider);
    final isSearching = ref.watch(isSearchingProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background Home Content
          AnimatedBuilder(
            animation: _backgroundBlurAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.shade900.withOpacity(0.8),
                      Colors.blue.shade900.withOpacity(0.8),
                      Colors.teal.shade700.withOpacity(0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),
                        Text(
                          'Welcome Back!',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Discover amazing content with our AI-powered search',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 60),
                        _buildFeatureCards(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Search Results Screen
          if (showResults) _buildSearchResultsScreen(),

          // Floating Chatbot
          if (chatbotVisible) _buildFloatingChatbot(),

          // FAB
          Positioned(
            bottom: 24,
            right: 24,
            child: AnimatedBuilder(
              animation: _fabScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fabScaleAnimation.value,
                  child: FloatingActionButton.extended(
                    onPressed: _toggleChatbot,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple.shade700,
                    elevation: 8,
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text(
                      'Ask AI',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCards() {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildFeatureCard(
            'Smart Search',
            'AI-powered search for instant results',
            Icons.search_rounded,
            Colors.blue.shade400,
          ),
          _buildFeatureCard(
            'Quick Actions',
            'Fast access to your favorite features',
            Icons.flash_on_rounded,
            Colors.orange.shade400,
          ),
          _buildFeatureCard(
            'Personalized',
            'Content tailored just for you',
            Icons.person_rounded,
            Colors.green.shade400,
          ),
          _buildFeatureCard(
            'Analytics',
            'Track your usage and progress',
            Icons.analytics_rounded,
            Colors.purple.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingChatbot() {
    return AnimatedBuilder(
      animation: _chatbotSlideAnimation,
      builder: (context, child) {
        return Positioned(
          bottom: 24 + (100 * _chatbotSlideAnimation.value),
          right: 24,
          left: 24,
          child: Container(
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade600, Colors.blue.shade600],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.smart_toy_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Assistant',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'How can I help you today?',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _toggleChatbot,
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Input
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextField(
                            controller: _searchTextController,
                            decoration: InputDecoration(
                              hintText: 'Ask me anything...',
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(20),
                              suffixIcon: IconButton(
                                onPressed: _performSearch,
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.purple.shade600,
                                        Colors.blue.shade600,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Quick Actions
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildQuickAction(
                              'Flutter Tips',
                              Icons.code_rounded,
                            ),
                            _buildQuickAction(
                              'Design Ideas',
                              Icons.palette_rounded,
                            ),
                            _buildQuickAction(
                              'Best Practices',
                              Icons.star_rounded,
                            ),
                            _buildQuickAction(
                              'Tutorials',
                              Icons.school_rounded,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Transition Effect Selector
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.purple.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.auto_awesome_rounded,
                                    color: Colors.purple.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Animation Style',
                                    style: TextStyle(
                                      color: Colors.purple.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildTransitionSelector(),
                            ],
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
      },
    );
  }

  Widget _buildTransitionSelector() {
    final currentEffect = ref.watch(transitionEffectProvider);

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children:
          TransitionEffect.values.map((effect) {
            final isSelected = currentEffect == effect;
            final effectNames = {
              TransitionEffect.slideUp: 'Slide',
              TransitionEffect.explode: 'Explode',
              TransitionEffect.spiral: 'Spiral',
              TransitionEffect.wave: 'Wave',
              TransitionEffect.matrix: 'Matrix',
              TransitionEffect.particles: 'Particles',
              TransitionEffect.ripple: 'Ripple',
              TransitionEffect.fold: 'Fold',
            };

            return GestureDetector(
              onTap:
                  () =>
                      ref.read(transitionEffectProvider.notifier).state =
                          effect,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.purple.shade600 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        isSelected
                            ? Colors.purple.shade600
                            : Colors.purple.shade200,
                  ),
                ),
                child: Text(
                  effectNames[effect]!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.purple.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildQuickAction(String label, IconData icon) {
    return GestureDetector(
      onTap: () {
        _searchTextController.text = label;
        _performSearch();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.purple.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.purple.shade600),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.purple.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsScreen() {
    final searchQuery = ref.watch(searchQueryProvider);
    final isSearching = ref.watch(isSearchingProvider);
    final transitionEffect = ref.watch(transitionEffectProvider);

    return _buildTransitionWrapper(
      transitionEffect,
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        ref.read(showResultsScreenProvider.notifier).state =
                            false;
                        _resultsController.reverse();
                        _particleController.reverse();
                        _waveController.reverse();
                        _spiralController.reverse();
                        _searchController.reverse();
                      },
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Search Results',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'for "$searchQuery" (${transitionEffect.name})',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Results
              Expanded(
                child:
                    isSearching
                        ? _buildSearchingIndicator()
                        : _buildSearchResults(transitionEffect),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransitionWrapper(TransitionEffect effect, Widget child) {
    switch (effect) {
      case TransitionEffect.slideUp:
        return AnimatedBuilder(
          animation: _resultsSlideAnimation,
          builder: (context, _) {
            return Transform.translate(
              offset: Offset(
                0,
                MediaQuery.of(context).size.height *
                    _resultsSlideAnimation.value,
              ),
              child: child,
            );
          },
        );

      case TransitionEffect.explode:
        return AnimatedBuilder(
          animation: _resultsController,
          builder: (context, _) {
            final value = _resultsController.value;
            return Transform.scale(
              scale: value,
              child: Transform.rotate(
                angle: (1 - value) * 6.28,
                child: Opacity(opacity: value, child: child),
              ),
            );
          },
        );

      case TransitionEffect.spiral:
        return AnimatedBuilder(
          animation: _spiralAnimation,
          builder: (context, _) {
            final value = _spiralAnimation.value;
            return Transform.translate(
              offset: Offset(
                (1 - value) * 300 * math.cos(value * 6.28 * 3),
                (1 - value) * 300 * math.sin(value * 6.28 * 3),
              ),
              child: Transform.scale(
                scale: value,
                child: Transform.rotate(
                  angle: (1 - value) * 6.28 * 2,
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0), // Add clamp here
                    child: child,
                  ),
                ),
              ),
            );
          },
        );

      case TransitionEffect.wave:
        return AnimatedBuilder(
          animation: _waveAnimation,
          builder: (context, _) {
            return ClipPath(
              clipper: WaveClipper(_waveAnimation.value),
              child: child,
            );
          },
        );

      case TransitionEffect.matrix:
        return AnimatedBuilder(
          animation: _resultsController,
          builder: (context, _) {
            return CustomPaint(
              painter: MatrixPainter(_resultsController.value),
              child: Opacity(opacity: _resultsController.value, child: child),
            );
          },
        );

      case TransitionEffect.particles:
        return AnimatedBuilder(
          animation: _particleAnimation,
          builder: (context, _) {
            return Stack(
              children: [
                CustomPaint(
                  painter: ParticlePainter(_particleAnimation.value),
                  size: Size.infinite,
                ),
                Opacity(
                  opacity: _particleAnimation.value,
                  child: Transform.scale(
                    scale: _particleAnimation.value,
                    child: child,
                  ),
                ),
              ],
            );
          },
        );

      case TransitionEffect.ripple:
        return AnimatedBuilder(
          animation: _resultsController,
          builder: (context, _) {
            return CustomPaint(
              painter: RipplePainter(_resultsController.value),
              child: Opacity(opacity: _resultsController.value, child: child),
            );
          },
        );

      case TransitionEffect.fold:
        return AnimatedBuilder(
          animation: _resultsController,
          builder: (context, _) {
            final value = _resultsController.value;
            return Transform(
              alignment: Alignment.center,
              transform:
                  Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX((1 - value) * 1.57),
              child: Opacity(opacity: value, child: child),
            );
          },
        );
    }
  }

  Widget _buildSearchingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
          ),
          SizedBox(height: 20),
          Text(
            'Searching...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(SearchResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.blue.shade400],
                ),
              ),
              child: const Icon(
                Icons.article_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      result.category,
                      style: TextStyle(
                        color: Colors.purple.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.description,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(TransitionEffect effect) {
    // Mock results for demo
    final results = [
      SearchResult(
        title: 'Flutter Development Guide',
        description:
            'Complete guide to building modern Flutter applications with best practices',
        category: 'Development',
        imageUrl: 'https://picsum.photos/300/200?random=1',
      ),
      SearchResult(
        title: 'UI/UX Design Trends 2025',
        description:
            'Latest design trends and patterns for modern mobile applications',
        category: 'Design',
        imageUrl: 'https://picsum.photos/300/200?random=2',
      ),
      SearchResult(
        title: 'State Management with Riverpod',
        description:
            'Advanced techniques for managing application state efficiently',
        category: 'Architecture',
        imageUrl: 'https://picsum.photos/300/200?random=3',
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return _buildAnimatedResultCard(results[index], index, effect);
      },
    );
  }

  Widget _buildAnimatedResultCard(
    SearchResult result,
    int index,
    TransitionEffect effect,
  ) {
    switch (effect) {
      case TransitionEffect.slideUp:
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(opacity: value, child: _buildResultCard(result)),
            );
          },
        );

      case TransitionEffect.explode:
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 500 + (index * 150)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Transform.rotate(
                angle: (1 - value) * 3.14,
                child: Opacity(opacity: value, child: _buildResultCard(result)),
              ),
            );
          },
        );

      case TransitionEffect.spiral:
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 600 + (index * 200)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(
                (1 - value) * 200 * math.cos(value * 6.28 * 2 + index),
                (1 - value) * 100 * math.sin(value * 6.28 * 2 + index),
              ),
              child: Transform.rotate(
                angle: (1 - value) * 6.28,
                child: Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: _buildResultCard(result),
                  ),
                ),
              ),
            );
          },
        );

      case TransitionEffect.wave:
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(
                30 * math.sin(value * 6.28 + index * 0.5) * (1 - value),
                0,
              ),
              child: Opacity(opacity: value, child: _buildResultCard(result)),
            );
          },
        );

      case TransitionEffect.matrix:
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 80)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(
                (math.Random(index).nextDouble() - 0.5) * 100 * (1 - value),
                (math.Random(index + 100).nextDouble() - 0.5) *
                    100 *
                    (1 - value),
              ),
              child: Opacity(
                opacity: value,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3 * value),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: _buildResultCard(result),
                ),
              ),
            );
          },
        );

      case TransitionEffect.particles:
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 800 + (index * 200)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.5 + (value * 0.5),
              child: Stack(
                children: [
                  // Particle effects around the card
                  ...List.generate(8, (i) {
                    final angle = (i / 8) * 6.28;
                    final distance = 50 * (1 - value);
                    return Positioned(
                      left: 50 + math.cos(angle) * distance,
                      top: 50 + math.sin(angle) * distance,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(value),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),
                  Opacity(opacity: value, child: _buildResultCard(result)),
                ],
              ),
            );
          },
        );

      case TransitionEffect.ripple:
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 500 + (index * 150)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Ripple effect
                if (value < 0.8)
                  Container(
                    width: 200 * value,
                    height: 200 * value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.5 * (1 - value)),
                        width: 2,
                      ),
                    ),
                  ),
                Transform.scale(
                  scale: math.min(1.0, value * 1.2),
                  child: Opacity(
                    opacity: value,
                    child: _buildResultCard(result),
                  ),
                ),
              ],
            );
          },
        );

      case TransitionEffect.fold:
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 600 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform(
              alignment: Alignment.topCenter,
              transform:
                  Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX((1 - value) * 1.57),
              child: Opacity(opacity: value, child: _buildResultCard(result)),
            );
          },
        );
    }
  }
}

void main(List<String> args) {
  runApp(ProviderScope(child: MaterialApp(home: ModernChatbotScreen())));
}





/* 


 */