import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';

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

// Providers
final chatbotVisibilityProvider = StateProvider<bool>((ref) => false);
final searchQueryProvider = StateProvider<String>((ref) => '');
final isSearchingProvider = StateProvider<bool>((ref) => false);
final searchResultsProvider = StateProvider<List<SearchResult>>((ref) => []);
final showResultsScreenProvider = StateProvider<bool>((ref) => false);

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

  late Animation<double> _fabScaleAnimation;
  late Animation<double> _chatbotSlideAnimation;
  late Animation<double> _searchExpandAnimation;
  late Animation<double> _resultsSlideAnimation;
  late Animation<double> _backgroundBlurAnimation;

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
  }

  @override
  void dispose() {
    _fabController.dispose();
    _searchController.dispose();
    _resultsController.dispose();
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
    _resultsController.forward();

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
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
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

    return AnimatedBuilder(
      animation: _resultsSlideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            MediaQuery.of(context).size.height * _resultsSlideAnimation.value,
          ),
          child: Container(
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
                                'for "$searchQuery"',
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
                    child: isSearching
                        ? _buildSearchingIndicator()
                        : _buildSearchResults(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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

  Widget _buildSearchResults() {
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
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: _buildResultCard(results[index]),
              ),
            );
          },
        );
      },
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
}

void main(List<String> args) {
  runApp(ProviderScope(child: MaterialApp(home: ModernChatbotScreen())));
}
