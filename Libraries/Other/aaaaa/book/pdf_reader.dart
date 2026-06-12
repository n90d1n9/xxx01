// pubspec.yaml dependencies needed:
// flutter_riverpod: ^2.4.9
// dio: ^5.3.2
// path_provider: ^2.1.1
// flutter_pdfview: ^1.3.2
// cached_network_image: ^3.3.0
// permission_handler: ^11.0.1

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:convert';

// Models
class PdfBook {
  final String id;
  final String title;
  final String author;
  final String thumbnailUrl;
  final String downloadUrl;
  final int pages;
  final double size; // in MB
  final String category;

  PdfBook({
    required this.id,
    required this.title,
    required this.author,
    required this.thumbnailUrl,
    required this.downloadUrl,
    required this.pages,
    required this.size,
    required this.category,
  });

  factory PdfBook.fromJson(Map<String, dynamic> json) {
    return PdfBook(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      thumbnailUrl: json['thumbnail_url'],
      downloadUrl: json['download_url'],
      pages: json['pages'],
      size: json['size'].toDouble(),
      category: json['category'],
    );
  }
}

class DownloadProgress {
  final String bookId;
  final double progress;
  final bool isDownloading;
  final bool isCompleted;
  final String? localPath;

  DownloadProgress({
    required this.bookId,
    this.progress = 0.0,
    this.isDownloading = false,
    this.isCompleted = false,
    this.localPath,
  });

  DownloadProgress copyWith({
    String? bookId,
    double? progress,
    bool? isDownloading,
    bool? isCompleted,
    String? localPath,
  }) {
    return DownloadProgress(
      bookId: bookId ?? this.bookId,
      progress: progress ?? this.progress,
      isDownloading: isDownloading ?? this.isDownloading,
      isCompleted: isCompleted ?? this.isCompleted,
      localPath: localPath ?? this.localPath,
    );
  }
}

// Providers
final dioProvider = Provider<Dio>((ref) => Dio());

final pdfBooksProvider =
    StateNotifierProvider<PdfBooksNotifier, AsyncValue<List<PdfBook>>>((ref) {
      return PdfBooksNotifier(ref.read(dioProvider));
    });

final downloadProgressProvider =
    StateNotifierProvider<DownloadNotifier, Map<String, DownloadProgress>>((
      ref,
    ) {
      return DownloadNotifier(ref.read(dioProvider));
    });

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

// Notifiers
class PdfBooksNotifier extends StateNotifier<AsyncValue<List<PdfBook>>> {
  final Dio dio;

  PdfBooksNotifier(this.dio) : super(const AsyncValue.loading()) {
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    try {
      // Simulate API call - replace with your actual endpoint
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - replace with actual API call
      final List<PdfBook> books = [
        PdfBook(
          id: '1',
          title: 'The Art of Programming',
          author: 'John Smith',
          thumbnailUrl:
              'https://via.placeholder.com/200x280/4F46E5/white?text=Art+of+Programming',
          downloadUrl:
              'https://staibabussalamsula.ac.id/wp-content/uploads/2024/05/Science-and-Islam-staibabussalamsula.ac_.id_.pdf',
          pages: 350,
          size: 15.2,
          category: 'Technology',
        ),
        PdfBook(
          id: '2',
          title: 'Design Patterns',
          author: 'Jane Doe',
          thumbnailUrl:
              'https://via.placeholder.com/200x280/7C3AED/white?text=Design+Patterns',
          downloadUrl: 'https://example.com/books/design-patterns.pdf',
          pages: 420,
          size: 18.7,
          category: 'Technology',
        ),
        PdfBook(
          id: '3',
          title: 'Digital Marketing Guide',
          author: 'Mike Johnson',
          thumbnailUrl:
              'https://via.placeholder.com/200x280/EF4444/white?text=Marketing+Guide',
          downloadUrl: 'https://example.com/books/marketing.pdf',
          pages: 280,
          size: 12.3,
          category: 'Business',
        ),
        PdfBook(
          id: '4',
          title: 'Modern UI/UX Design',
          author: 'Sarah Wilson',
          thumbnailUrl:
              'https://via.placeholder.com/200x280/10B981/white?text=UI+UX+Design',
          downloadUrl: 'https://example.com/books/ui-ux.pdf',
          pages: 195,
          size: 25.8,
          category: 'Design',
        ),
      ];

      state = AsyncValue.data(books);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void refresh() => fetchBooks();
}

class DownloadNotifier extends StateNotifier<Map<String, DownloadProgress>> {
  final Dio dio;

  DownloadNotifier(this.dio) : super({});

  Future<void> downloadBook(PdfBook book) async {
    if (state[book.id]?.isDownloading == true) return;

    state = {
      ...state,
      book.id: DownloadProgress(bookId: book.id, isDownloading: true),
    };

    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/${book.title.replaceAll(' ', '_')}.pdf';

      await dio.download(
        book.downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            state = {
              ...state,
              book.id: state[book.id]!.copyWith(progress: progress),
            };
          }
        },
      );

      state = {
        ...state,
        book.id: state[book.id]!.copyWith(
          isDownloading: false,
          isCompleted: true,
          localPath: filePath,
        ),
      };
    } catch (e) {
      state = {...state, book.id: DownloadProgress(bookId: book.id)};
      rethrow;
    }
  }

  bool isBookDownloaded(String bookId) {
    return state[bookId]?.isCompleted == true;
  }

  String? getLocalPath(String bookId) {
    return state[bookId]?.localPath;
  }
}

// Main App
class PdfReaderApp extends ConsumerWidget {
  const PdfReaderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'PDF Reader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// Home Screen
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(pdfBooksProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'PDF Library',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.indigo.withOpacity(0.1),
                      Colors.purple.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.read(pdfBooksProvider.notifier).refresh(),
              ),
            ],
          ),
          const SliverToBoxAdapter(child: CategorySelector()),
          booksAsync.when(
            data: (books) {
              final filteredBooks = selectedCategory == 'All'
                  ? books
                  : books
                        .where((book) => book.category == selectedCategory)
                        .toList();

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => BookCard(book: filteredBooks[index]),
                    childCount: filteredBooks.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading books',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(pdfBooksProvider.notifier).refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Category Selector
class CategorySelector extends ConsumerWidget {
  const CategorySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ['All', 'Technology', 'Business', 'Design', 'Science'];
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) =>
                  ref.read(selectedCategoryProvider.notifier).state = category,
              backgroundColor: Colors.white,
              selectedColor: Colors.indigo.withOpacity(0.2),
              checkmarkColor: Colors.indigo,
              labelStyle: TextStyle(
                color: isSelected ? Colors.indigo : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? Colors.indigo : Colors.grey[300]!,
              ),
            ),
          );
        },
      ),
    );
  }
}

// Book Card
class BookCard extends ConsumerWidget {
  final PdfBook book;

  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadProgress = ref.watch(downloadProgressProvider)[book.id];
    final isDownloaded = downloadProgress?.isCompleted == true;
    final isDownloading = downloadProgress?.isDownloading == true;

    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: isDownloaded
            ? () => _openPdf(context, ref)
            : isDownloading
            ? null
            : () => _downloadBook(ref),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.indigo.withOpacity(0.1),
                      Colors.purple.withOpacity(0.1),
                    ],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: book.thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.picture_as_pdf,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.error, size: 48, color: Colors.red),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.description,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${book.pages}p',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        _buildActionButton(
                          isDownloaded,
                          isDownloading,
                          downloadProgress,
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
  }

  Widget _buildActionButton(
    bool isDownloaded,
    bool isDownloading,
    DownloadProgress? progress,
  ) {
    if (isDownloaded) {
      return Icon(Icons.check_circle, color: Colors.green[600], size: 20);
    }

    if (isDownloading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          value: progress?.progress,
          color: Colors.indigo,
        ),
      );
    }

    return Icon(Icons.download, color: Colors.indigo[600], size: 20);
  }

  void _downloadBook(WidgetRef ref) async {
    try {
      await ref.read(downloadProgressProvider.notifier).downloadBook(book);
    } catch (e) {
      // Handle download error
      debugPrint('Download failed: $e');
    }
  }

  void _openPdf(BuildContext context, WidgetRef ref) {
    final localPath = ref
        .read(downloadProgressProvider.notifier)
        .getLocalPath(book.id);
    if (localPath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PdfViewerScreen(book: book, filePath: localPath),
        ),
      );
    }
  }
}

// PDF Viewer Screen
class PdfViewerScreen extends StatefulWidget {
  final PdfBook book;
  final String filePath;

  const PdfViewerScreen({
    super.key,
    required this.book,
    required this.filePath,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  int currentPage = 0;
  int totalPages = 0;
  bool isReady = false;
  PDFViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          if (isReady)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  '${currentPage + 1} / $totalPages',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: PDFView(
        filePath: widget.filePath,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: false,
        pageFling: true,
        pageSnap: true,
        defaultPage: currentPage,
        fitPolicy: FitPolicy.BOTH,
        preventLinkNavigation: false,
        onRender: (pages) {
          setState(() {
            totalPages = pages!;
            isReady = true;
          });
        },
        onError: (error) {
          debugPrint('PDF Error: $error');
        },
        onPageError: (page, error) {
          debugPrint('Page $page Error: $error');
        },
        onViewCreated: (PDFViewController pdfViewController) {
          controller = pdfViewController;
        },
        onLinkHandler: (String? uri) {
          debugPrint('Link: $uri');
        },
        onPageChanged: (int? page, int? total) {
          setState(() {
            currentPage = page ?? 0;
          });
        },
      ),
    );
  }
}

void main() {
  runApp(const ProviderScope(child: PdfReaderApp()));
}
