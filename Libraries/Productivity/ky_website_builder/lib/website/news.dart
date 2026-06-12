import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_svg/flutter_svg.dart';

// Models
class Article {
  final String id;
  final String title;
  final String subtitle;
  final String content;
  final String imageUrl;
  final String source;
  final DateTime publishDate;
  final String author;
  final String sourceUrl;
  final String category;
  final bool isPremium;

  Article({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.imageUrl,
    required this.source,
    required this.publishDate,
    required this.author,
    required this.sourceUrl,
    required this.category,
    this.isPremium = false,
  });
}

// Repositories
class NewsRepository {
  Future<List<Article>> fetchArticles({String category = 'all'}) async {
    // Simulate API call to RSS feeds and WordPress
    await Future.delayed(const Duration(seconds: 1));

    // Mock data
    return [
      Article(
        id: '1',
        title: 'Flutter 3.0 Released with Major Performance Improvements',
        subtitle:
            'The latest Flutter update brings significant performance enhancements and new features',
        content:
            'Flutter 3.0 has been released with major performance improvements...',
        imageUrl: 'https://picsum.photos/seed/flutter1/800/600',
        source: 'Flutter Blog',
        publishDate: DateTime.now().subtract(const Duration(hours: 2)),
        author: 'Tim Sneath',
        sourceUrl: 'https://medium.com/flutter',
        category: 'Technology',
      ),
      Article(
        id: '2',
        title: 'Riverpod 2.0: The Next Evolution in State Management',
        subtitle:
            'Remi Rousselet introduces the next major version of Riverpod with enhanced features',
        content:
            'Riverpod 2.0 has been announced with a focus on improved developer experience...',
        imageUrl: 'https://picsum.photos/seed/riverpod/800/600',
        source: 'Dev.to',
        publishDate: DateTime.now().subtract(const Duration(hours: 5)),
        author: 'Remi Rousselet',
        sourceUrl: 'https://dev.to',
        category: 'Technology',
        isPremium: true,
      ),
      Article(
        id: '3',
        title: 'AI Developments Changing How We Interact with Mobile Apps',
        subtitle:
            'New AI capabilities are transforming mobile application development',
        content:
            'Artificial intelligence is rapidly changing how users interact with mobile applications...',
        imageUrl: 'https://picsum.photos/seed/ai/800/600',
        source: 'TechCrunch',
        publishDate: DateTime.now().subtract(const Duration(days: 1)),
        author: 'Sara Johnson',
        sourceUrl: 'https://techcrunch.com',
        category: 'Technology',
      ),
      Article(
        id: '4',
        title: 'Climate Change Report Shows Accelerating Impact',
        subtitle:
            'Scientists warn that climate change effects are becoming more evident',
        content:
            'A new climate report published today indicates that the effects of global warming...',
        imageUrl: 'https://picsum.photos/seed/climate/800/600',
        source: 'Science Daily',
        publishDate: DateTime.now().subtract(const Duration(hours: 10)),
        author: 'Dr. Emily Chen',
        sourceUrl: 'https://sciencedaily.com',
        category: 'Science',
      ),
    ];
  }
}

// Providers
final newsRepositoryProvider = Provider((ref) => NewsRepository());

final selectedCategoryProvider = StateProvider<String>((ref) => 'all');

final articlesProvider = FutureProvider<List<Article>>((ref) {
  final repository = ref.watch(newsRepositoryProvider);
  final category = ref.watch(selectedCategoryProvider);
  return repository.fetchArticles(category: category);
});

final savedArticlesProvider =
    StateNotifierProvider<SavedArticlesNotifier, List<String>>((ref) {
      return SavedArticlesNotifier();
    });

class SavedArticlesNotifier extends StateNotifier<List<String>> {
  SavedArticlesNotifier() : super([]);

  void toggleSaved(String articleId) {
    if (state.contains(articleId)) {
      state = state.where((id) => id != articleId).toList();
    } else {
      state = [...state, articleId];
    }
  }

  bool isSaved(String articleId) {
    return state.contains(articleId);
  }
}

// UI Components
class NewsApp extends ConsumerWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: MediaQuery.of(context).platformBrightness,
        ),
        fontFamily: 'Poppins',
      ),
      home: const NewsHomePage(),
    );
  }
}

class NewsHomePage extends ConsumerWidget {
  const NewsHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                floating: true,
                snap: true,
                title: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/logo.svg',
                      height: 28,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'NewsFlash',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      // Show search dialog
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmarks_outlined),
                    onPressed: () {
                      // Navigate to saved articles
                    },
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(50),
                  child: CategorySelector(),
                ),
              ),
            ];
          },
          body: const ArticleListView(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.6),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmarks_outlined),
            activeIcon: Icon(Icons.bookmarks),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
}

class CategorySelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    final categories = [
      'all',
      'technology',
      'science',
      'health',
      'business',
      'entertainment',
      'sports',
      'politics',
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                category.substring(0, 1).toUpperCase() + category.substring(1),
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(selectedCategoryProvider.notifier).state = category;
                }
              },
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ArticleListView extends ConsumerWidget {
  const ArticleListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsync = ref.watch(articlesProvider);

    return articlesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          Center(child: Text('Error loading articles: $err')),
      data: (articles) {
        return RefreshIndicator(
          onRefresh: () async {
            ref.refresh(articlesProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: articles.length + 1, // +1 for the featured article
            itemBuilder: (context, index) {
              if (index == 0) {
                // Featured article card
                return FeaturedArticleCard(article: articles.first);
              }

              final article = articles[index - 1];
              return ArticleCard(article: article);
            },
          ),
        );
      },
    );
  }
}

class FeaturedArticleCard extends ConsumerWidget {
  final Article article;

  const FeaturedArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedArticlesNotifier = ref.watch(savedArticlesProvider.notifier);
    final isSaved = ref.watch(savedArticlesProvider).contains(article.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () {
          // Navigate to article detail
        },
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: article.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey.shade300),
                    ),
                  ),
                  if (article.isPremium)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'PREMIUM',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            article.category,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          timeago.format(article.publishDate),
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/100?u=${article.author}',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            article.author,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: isSaved
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                          onPressed: () {
                            savedArticlesNotifier.toggleSaved(article.id);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share_outlined),
                          onPressed: () {
                            Share.share(
                              'Check out this article: ${article.title} - ${article.sourceUrl}',
                            );
                          },
                        ),
                      ],
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
}

class ArticleCard extends ConsumerWidget {
  final Article article;

  const ArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedArticlesNotifier = ref.watch(savedArticlesProvider.notifier);
    final isSaved = ref.watch(savedArticlesProvider).contains(article.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () {
          // Navigate to article detail
        },
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: CachedNetworkImage(
                      imageUrl: article.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (article.isPremium)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PREMIUM',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      Text(
                        article.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        article.subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${article.source} · ${timeago.format(article.publishDate)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              savedArticlesNotifier.toggleSaved(article.id);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                size: 18,
                                color: isSaved
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Share.share(
                                'Check out this article: ${article.title} - ${article.sourceUrl}',
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.share_outlined, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const ProviderScope(child: NewsApp()));
}
