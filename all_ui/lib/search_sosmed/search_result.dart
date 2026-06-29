import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Models
enum SearchResultType { article, video, audio, image, other }

class SearchResult {
  final String title;
  final String description;
  final String category;
  final SearchResultType type;
  final String? url;
  final String? videoUrl;
  final String? audioUrl;
  final String? imageUrl;

  const SearchResult({
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    this.url,
    this.videoUrl,
    this.audioUrl,
    this.imageUrl,
  });
}

// State management
class SearchState {
  final List<SearchResult> results;
  final bool isLoading;
  final String? error;
  final String query;

  const SearchState({
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.query = '',
  });

  SearchState copyWith({
    List<SearchResult>? results,
    bool? isLoading,
    String? error,
    String? query,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      query: query ?? this.query,
    );
  }
}

// Mock data for demonstration
final mockSearchResults = [
  SearchResult(
    title: 'Flutter Development Best Practices',
    description:
        'Learn the latest Flutter development techniques and patterns for building scalable mobile applications.',
    category: 'Technology',
    type: SearchResultType.article,
    url: 'https://flutter.dev',
    imageUrl: 'https://picsum.photos/400/200?random=1',
  ),
  SearchResult(
    title: 'Building Beautiful UIs with Flutter',
    description:
        'A comprehensive video tutorial covering advanced Flutter UI development techniques.',
    category: 'Education',
    type: SearchResultType.video,
    videoUrl: 'https://youtube.com/watch?v=example',
    imageUrl: 'https://picsum.photos/400/200?random=2',
  ),
  SearchResult(
    title: 'Flutter Podcast Episode 42',
    description:
        'Discussion about the future of Flutter and mobile development trends.',
    category: 'Podcast',
    type: SearchResultType.audio,
    audioUrl: 'https://example.com/audio.mp3',
  ),
  SearchResult(
    title: 'Flutter Architecture Diagram',
    description:
        'Visual representation of clean architecture in Flutter applications.',
    category: 'Design',
    type: SearchResultType.image,
    imageUrl: 'https://picsum.photos/400/300?random=3',
  ),
  SearchResult(
    title: 'Flutter Resources Collection',
    description:
        'Curated list of Flutter tools, packages, and learning resources.',
    category: 'Resources',
    type: SearchResultType.other,
    url: 'https://flutter.dev/resources',
  ),
];

// Riverpod providers
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(const SearchState());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(results: [], query: query);
      return;
    }

    state = state.copyWith(isLoading: true, error: null, query: query);

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Filter mock results based on query
      final filteredResults =
          mockSearchResults
              .where(
                (result) =>
                    result.title.toLowerCase().contains(query.toLowerCase()) ||
                    result.description.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    result.category.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();

      state = state.copyWith(results: filteredResults, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to search: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  void clearResults() {
    state = const SearchState();
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((
  ref,
) {
  return SearchNotifier();
});

// Main Screen Widget
class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  ConsumerState<SearchResultsScreen> createState() =>
      _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(),
            Expanded(child: _buildSearchContent(searchState)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  foregroundColor: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Search',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSearchField(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        onSubmitted: (value) {
          ref.read(searchProvider.notifier).search(value);
        },
        decoration: InputDecoration(
          hintText: 'What are you looking for?',
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF64748B),
            size: 20,
          ),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      ref.read(searchProvider.notifier).clearResults();
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildSearchContent(SearchState state) {
    if (state.query.isEmpty) {
      return _buildEmptyState();
    }

    if (state.isLoading) {
      return _buildLoadingState();
    }

    if (state.error != null) {
      return _buildErrorState(state.error!);
    }

    if (state.results.isEmpty) {
      return _buildNoResultsState(state.query);
    }

    return _buildResultsList(state.results);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(Icons.search, size: 48, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Start searching',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your search query to find\narticles, videos, and more',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF3B82F6), strokeWidth: 3),
          SizedBox(height: 16),
          Text(
            'Searching...',
            style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 48,
              color: Color(0xFFEF4444),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Search failed',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.read(searchProvider.notifier).search(_searchController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.search_off,
              size: 48,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No results found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We couldn\'t find anything for "$query"\nTry a different search term',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<SearchResult> results) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            '${results.length} results found',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: results.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SearchResultCard(result: results[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Search Result Card Widget
class SearchResultCard extends StatelessWidget {
  final SearchResult result;

  const SearchResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Handle result tap
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tapped: ${result.title}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildContent(),
              if (result.imageUrl != null) ...[
                const SizedBox(height: 12),
                _buildImage(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildTypeIcon(),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCategoryColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  result.category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getCategoryColor(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _getIconColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(_getTypeIcon(), color: _getIconColor(), size: 20),
    );
  }

  Widget _buildContent() {
    return Text(
      result.description,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF64748B),
        height: 1.5,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        result.imageUrl!,
        width: double.infinity,
        height: 160,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.image_not_supported,
              color: Color(0xFF94A3B8),
              size: 32,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF94A3B8),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (result.type) {
      case SearchResultType.article:
        return Icons.article;
      case SearchResultType.video:
        return Icons.play_circle_fill;
      case SearchResultType.audio:
        return Icons.headphones;
      case SearchResultType.image:
        return Icons.image;
      case SearchResultType.other:
        return Icons.link;
    }
  }

  Color _getIconColor() {
    switch (result.type) {
      case SearchResultType.article:
        return const Color(0xFF3B82F6);
      case SearchResultType.video:
        return const Color(0xFFEF4444);
      case SearchResultType.audio:
        return const Color(0xFF8B5CF6);
      case SearchResultType.image:
        return const Color(0xFF10B981);
      case SearchResultType.other:
        return const Color(0xFF64748B);
    }
  }

  Color _getCategoryColor() {
    switch (result.category.toLowerCase()) {
      case 'technology':
        return const Color(0xFF3B82F6);
      case 'education':
        return const Color(0xFF10B981);
      case 'podcast':
        return const Color(0xFF8B5CF6);
      case 'design':
        return const Color(0xFFF59E0B);
      case 'resources':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFF64748B);
    }
  }
}

void main(List<String> args) {
  runApp(
    const ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SearchResultsScreen(),
      ),
    ),
  );
}
