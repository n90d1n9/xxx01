import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

import 'package:flutter_riverpod/legacy.dart';

// Models
class Book {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String description;
  final double rating;
  final int pages;
  final int currentPage;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.description,
    required this.rating,
    required this.pages,
    this.currentPage = 0,
  });
}

// Providers
final currentBookProvider = StateProvider<Book?>((ref) => null);

final booksProvider = StateProvider<List<Book>>(
  (ref) => [
    Book(
      id: '1',
      title: 'Dune',
      author: 'Frank Herbert',
      coverUrl:
          'https://m.media-amazon.com/images/I/41DzygSvjYL._SX331_BO1,204,203,200_.jpg',
      description:
          'Set on the desert planet Arrakis, Dune is the story of the boy Paul Atreides, heir to a noble family tasked with ruling an inhospitable world where the only thing of value is the "spice" melange.',
      rating: 4.7,
      pages: 658,
      currentPage: 112,
    ),
    Book(
      id: '2',
      title: 'Project Hail Mary',
      author: 'Andy Weir',
      coverUrl:
          'https://m.media-amazon.com/images/I/51wH91YObML._SY445_SX342_.jpg',
      description:
          'Ryland Grace is the sole survivor on a desperate, last-chance mission—and if he fails, humanity and the Earth itself will perish.',
      rating: 4.8,
      pages: 496,
      currentPage: 0,
    ),
    Book(
      id: '3',
      title: 'The Alchemist',
      author: 'Paulo Coelho',
      coverUrl:
          'https://m.media-amazon.com/images/I/51Z0nLAfLmL._SY445_SX342_.jpg',
      description:
          'A magical story about Santiago, an Andalusian shepherd boy who yearns to travel in search of a worldly treasure as extravagant as any ever found.',
      rating: 4.6,
      pages: 208,
      currentPage: 75,
    ),
  ],
);

final recentlyReadProvider = StateProvider<List<Book>>((ref) {
  final books = ref.watch(booksProvider);
  return books.where((book) => book.currentPage > 0).toList();
});

final pageControllerProvider = StateProvider.autoDispose<PageController>((ref) {
  return PageController(viewportFraction: 0.85);
});

// UI Components
class BookReaderApp extends ConsumerWidget {
  const BookReaderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(booksProvider);
    final recentlyRead = ref.watch(recentlyReadProvider);
    final pageController = ref.watch(pageControllerProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Bookshelf',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.primary,
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.search), onPressed: () {}),
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Continue Reading',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(onPressed: () {}, child: const Text('See All')),
                ],
              ),
            ),
          ),
          // Continue Reading Section
          SliverToBoxAdapter(
            child:
                recentlyRead.isEmpty
                    ? const Center(child: Text('No books in progress'))
                    : SizedBox(
                      height: 200,
                      child: PageView.builder(
                        controller: pageController,
                        itemCount: recentlyRead.length,
                        itemBuilder: (context, index) {
                          final book = recentlyRead[index];
                          return GestureDetector(
                            onTap: () {
                              ref.read(currentBookProvider.notifier).state =
                                  book;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const BookReadingScreen(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: ContinueReadingCard(book: book),
                            ),
                          );
                        },
                      ),
                    ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Library',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(onPressed: () {}, child: const Text('See All')),
                ],
              ),
            ),
          ),
          // Library Grid
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final book = books[index];
                return GestureDetector(
                  onTap: () {
                    ref.read(currentBookProvider.notifier).state = book;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BookDetailScreen(),
                      ),
                    );
                  },
                  child: BookCard(book: book),
                );
              }, childCount: books.length),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) {},
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class ContinueReadingCard extends StatelessWidget {
  final Book book;

  const ContinueReadingCard({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = book.currentPage / book.pages;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.network(
                book.coverUrl,
                height: double.infinity,
                width: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    color: Colors.grey.shade300,
                    child: Center(
                      child: Icon(
                        Icons.book,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Page ${book.currentPage}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade200,
                        minHeight: 5,
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

class BookCard extends StatelessWidget {
  final Book book;

  const BookCard({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                book.coverUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: Center(
                      child: Icon(
                        Icons.book,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          book.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          book.author,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(Icons.star, size: 14, color: Colors.amber.shade600),
            const SizedBox(width: 4),
            Text(
              book.rating.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(currentBookProvider);

    if (book == null) {
      return const Scaffold(body: Center(child: Text('No book selected')));
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 80,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {},
              ),
              IconButton(icon: const Icon(Icons.share), onPressed: () {}),
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Book Cover
                      Container(
                        width: 120,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            book.coverUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.book, size: 50),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Book details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              book.author,
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 18,
                                  color: Colors.amber.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  book.rating.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${book.pages} pages',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (book.currentPage > 0) ...[
                              Text(
                                'Your progress',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: book.currentPage / book.pages,
                                        backgroundColor: Colors.grey.shade200,
                                        minHeight: 8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${(book.currentPage / book.pages * 100).toInt()}%',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BookReadingScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.menu_book),
                          label: Text(
                            book.currentPage > 0
                                ? 'Continue Reading'
                                : 'Start Reading',
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.file_download_outlined),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Book description
                  Text(
                    'About this book',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.description,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onBackground.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Book metadata section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Information',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(context, 'Pages', book.pages.toString()),
                        _buildInfoRow(context, 'Rating', '${book.rating} / 5'),
                        _buildInfoRow(context, 'Language', 'English'),
                        _buildInfoRow(context, 'Format', 'eBook'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class BookReadingScreen extends ConsumerStatefulWidget {
  const BookReadingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BookReadingScreen> createState() => _BookReadingScreenState();
}

class _BookReadingScreenState extends ConsumerState<BookReadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isControlsVisible = true;
  double _fontSize = 16.0;
  String _fontFamily = 'Merriweather';
  double _lineHeight = 1.6;
  Color _textColor = Colors.black87;
  Color _backgroundColor = Colors.white;
  double _brightness = 1.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
      if (_isControlsVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  // Sample book content
  final String _sampleContent = '''
Chapter 1

The desert landscape stretched out before him, shimmering in the intense heat of midday. The sun beat down relentlessly, a cruel overseer to the harsh environment below. In the distance, the silhouette of massive rock formations cut sharp lines against the clear blue sky.

Paul Atreides stood at the viewport of the ornithopter, watching as the craft descended toward the surface of Arrakis. This was to be his new home, though nothing about it seemed welcoming. The reputation of this planet preceded it—Dune, the desert planet, where water was more precious than the most valuable metals in the Imperium.

"What do you think?" his father, Duke Leto Atreides, asked from behind him.

Paul considered his response carefully. His training with the Bene Gesserit taught him to observe details others might miss. The patterns of the sand dunes below suggested constant wind activity. The lack of visible moisture in the air explained the parched appearance of the few people they had seen during their approach.

"It's exactly as described," Paul replied, "but seeing it makes it more real. The challenges will be significant."

Duke Leto nodded. "The Harkonnens would have us believe this planet is nothing but a burden, a punishment assignment. But there is value here beyond the spice, if one knows where to look."

The ornithopter banked, offering a view of Arrakeen, the principal city and their new base of operations. The structures were bulky, built to withstand the abrasive sand storms. Everything about this place spoke of hardship and adaptation.

"Remember what I told you," the Duke continued. "Desert power."

Paul nodded, understanding the underlying message. In this environment, traditional forms of power and influence would need to be reconsidered. New strategies would be required.

As they prepared for landing, Paul could not shake the feeling that their arrival on Arrakis represented more than just a change in their family's fortunes. It felt like the beginning of something much larger, something that would reshape not just their lives, but potentially the entire Imperium.

The journey ahead would not be easy, but then again, nothing worthwhile ever was.
''';

  @override
  Widget build(BuildContext context) {
    final book = ref.watch(currentBookProvider);

    if (book == null) {
      return const Scaffold(body: Center(child: Text('No book selected')));
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Reading content
            SafeArea(
              child: Container(
                color: _backgroundColor,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: TextStyle(
                          fontSize: _fontSize + 4,
                          fontFamily: _fontFamily,
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'by ${book.author}',
                        style: TextStyle(
                          fontSize: _fontSize - 2,
                          fontFamily: _fontFamily,
                          color: _textColor.withValues(alpha: 0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        _sampleContent,
                        style: TextStyle(
                          fontSize: _fontSize,
                          fontFamily: _fontFamily,
                          height: _lineHeight,
                          color: _textColor,
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
            // Top controls
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return AnimatedOpacity(
                  opacity: _isControlsVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Visibility(
                    visible: _isControlsVisible,
                    child: Container(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.9),
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.bookmark_border),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.share),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed:
                                    () => _showSettingsBottomSheet(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Bottom progress indicator
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedOpacity(
                opacity: _isControlsVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Visibility(
                  visible: _isControlsVisible,
                  child: Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.9),
                    padding: const EdgeInsets.all(16.0),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 4,
                              activeTrackColor:
                                  Theme.of(context).colorScheme.primary,
                              inactiveTrackColor: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.2),
                              thumbColor: Theme.of(context).colorScheme.primary,
                              overlayColor: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                            ),
                            child: Slider(
                              value: (book.currentPage + 1) / book.pages,
                              onChanged: (value) {},
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Page ${book.currentPage + 1} of ${book.pages}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${((book.currentPage + 1) / book.pages * 100).toInt()}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reading Settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Font Size
                  Row(
                    children: [
                      const Icon(Icons.format_size, size: 24),
                      const SizedBox(width: 16),
                      const Text('Font Size'),
                      Expanded(
                        child: Slider(
                          value: _fontSize,
                          min: 12,
                          max: 24,
                          divisions: 6,
                          onChanged: (value) {
                            setState(() {
                              _fontSize = value;
                            });
                            this.setState(() {});
                          },
                        ),
                      ),
                      Text('${_fontSize.toInt()}'),
                    ],
                  ),
                  // Line Height
                  Row(
                    children: [
                      const Icon(Icons.height, size: 24),
                      const SizedBox(width: 16),
                      const Text('Line Spacing'),
                      Expanded(
                        child: Slider(
                          value: _lineHeight,
                          min: 1.0,
                          max: 2.2,
                          divisions: 6,
                          onChanged: (value) {
                            setState(() {
                              _lineHeight = value;
                            });
                            this.setState(() {});
                          },
                        ),
                      ),
                      Text('${_lineHeight.toStringAsFixed(1)}'),
                    ],
                  ),
                  // Brightness
                  Row(
                    children: [
                      const Icon(Icons.brightness_6, size: 24),
                      const SizedBox(width: 16),
                      const Text('Brightness'),
                      Expanded(
                        child: Slider(
                          value: _brightness,
                          min: 0.3,
                          max: 1.0,
                          divisions: 7,
                          onChanged: (value) {
                            setState(() {
                              _brightness = value;
                            });
                            this.setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Font selection
                  Text(
                    'Font',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFontOption(context, 'Merriweather', setState),
                        _buildFontOption(context, 'Roboto', setState),
                        _buildFontOption(context, 'Lora', setState),
                        _buildFontOption(context, 'OpenSans', setState),
                        _buildFontOption(context, 'Poppins', setState),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Theme selection
                  Text(
                    'Theme',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildThemeOption(
                          context,
                          'Light',
                          Colors.white,
                          Colors.black87,
                          setState,
                        ),
                        _buildThemeOption(
                          context,
                          'Sepia',
                          const Color(0xFFF8F1E3),
                          Colors.brown.shade900,
                          setState,
                        ),
                        _buildThemeOption(
                          context,
                          'Dark',
                          const Color(0xFF303030),
                          Colors.white,
                          setState,
                        ),
                        _buildThemeOption(
                          context,
                          'Black',
                          Colors.black,
                          Colors.white70,
                          setState,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: const Text('Apply Changes'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFontOption(
    BuildContext context,
    String fontName,
    StateSetter setState,
  ) {
    final isSelected = _fontFamily == fontName;

    return GestureDetector(
      onTap: () {
        setState(() {
          _fontFamily = fontName;
        });
        this.setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          fontName,
          style: TextStyle(
            fontFamily: fontName,
            color:
                isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String themeName,
    Color bgColor,
    Color txtColor,
    StateSetter setState,
  ) {
    final isSelected = _backgroundColor == bgColor && _textColor == txtColor;

    return GestureDetector(
      onTap: () {
        setState(() {
          _backgroundColor = bgColor;
          _textColor = txtColor;
        });
        this.setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          themeName,
          style: TextStyle(
            color: txtColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const ProviderScope(child: BookReaderApp()));
}
