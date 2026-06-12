// models/wordpress_post.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class WordPressPost {
  final int id;
  final int author;
  final String date;
  final String dateGmt;
  final String content;
  final String title;
  final int category;
  final String excerpt;
  final String status;
  final String commentStatus;
  final String pingStatus;
  final String password;
  final String name;
  final String toPing;
  final String pinged;
  final String postModified;
  final String postModifiedGmt;
  final String contentFiltered;
  final int parent;
  final String guid;
  final int menuOrder;
  final String type;
  final int commentCount;
  final String mimeType;

  WordPressPost({
    required this.id,
    required this.author,
    required this.date,
    required this.dateGmt,
    required this.content,
    required this.title,
    required this.category,
    required this.excerpt,
    required this.status,
    required this.commentStatus,
    required this.pingStatus,
    required this.password,
    required this.name,
    required this.toPing,
    required this.pinged,
    required this.postModified,
    required this.postModifiedGmt,
    required this.contentFiltered,
    required this.parent,
    required this.guid,
    required this.menuOrder,
    required this.type,
    required this.commentCount,
    required this.mimeType,
  });

  factory WordPressPost.fromJson(Map<String, dynamic> json) {
    return WordPressPost.fromMap(json);
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  factory WordPressPost.fromMap(Map<String, dynamic> map) {
    return WordPressPost(
      id: map['id'],
      author: map['author'],
      date: map['date'],
      dateGmt: map['dateGmt'],
      content: map['content'],
      title: map['title'],
      category: map['category'],
      excerpt: map['excerpt'],
      status: map['status'],
      commentStatus: map['commentStatus'],
      pingStatus: map['pingStatus'],
      password: map['password'],
      name: map['name'],
      toPing: map['toPing'],
      pinged: map['pinged'],
      postModified: map['postModified'],
      postModifiedGmt: map['postModifiedGmt'],
      contentFiltered: map['contentFiltered'],
      parent: map['parent'],
      guid: map['guid'],
      menuOrder: map['menuOrder'],
      type: map['type'],
      commentCount: map['commentCount'],
      mimeType: map['mimeType'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'author': author,
      'date': date,
      'dateGmt': dateGmt,
      'content': content,
      'title': title,
      'category': category,
      'excerpt': excerpt,
      'status': status,
      'commentStatus': commentStatus,
      'pingStatus': pingStatus,
      'password': password,
      'name': name,
      'toPing': toPing,
      'pinged': pinged,
      'postModified': postModified,
      'postModifiedGmt': postModifiedGmt,
      'contentFiltered': contentFiltered,
      'parent': parent,
      'guid': guid,
      'menuOrder': menuOrder,
      'type': type,
      'commentCount': commentCount,
      'mimeType': mimeType,
    };
  }

  @override
  String toString() {
    return 'WordPressPost(id: $id, author: $author, date: $date, dateGmt: $dateGmt, content: $content, title: $title, category: $category, excerpt: $excerpt, status: $status, commentStatus: $commentStatus, pingStatus: $pingStatus, password: $password, name: $name, toPing: $toPing, pinged: $pinged, postModified: $postModified, postModifiedGmt: $postModifiedGmt, contentFiltered: $contentFiltered, parent: $parent, guid: $guid, menuOrder: $menuOrder, type: $type, commentCount: $commentCount, mimeType: $mimeType)';
  }
}

final wordpressPostsProvider = FutureProvider<List<WordPressPost>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 800));

  final random = Random();
  final images = [
    'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=800&h=600&fit=crop',
    'https://images.unsplash.com/photo-1586953208448-b95a79798f07?w=800&h=600&fit=crop',
    'https://images.unsplash.com/photo-1432821596592-e2c18b78144f?w=800&h=600&fit=crop',
    'https://images.unsplash.com/photo-1553484771-371a605b060b?w=800&h=600&fit=crop',
    'https://images.unsplash.com/photo-1611224923853-80b023f02d71?w=800&h=600&fit=crop',
  ];

  final categories = ['Technology', 'Business', 'Science', 'Health', 'Culture'];
  final authors = [
    'Sarah Chen',
    'Michael Rodriguez',
    'Emma Thompson',
    'David Park',
    'Lisa Wang',
  ];

  return List.generate(8, (index) {
    final isHero = index == 0;
    return WordPressPost(
      id: 113000 + index,
      author: random.nextInt(5) + 1,
      date: DateTime.now()
          .subtract(Duration(days: random.nextInt(30)))
          .toIso8601String(),
      dateGmt: DateTime.now()
          .subtract(Duration(days: random.nextInt(30)))
          .toIso8601String(),
      content: _generateContent(index),
      title: _generateTitle(index, isHero),
      category: random.nextInt(5),
      excerpt: _generateExcerpt(index),
      status: "publish",
      commentStatus: "open",
      pingStatus: "closed",
      password: "",
      name: "post-${index + 1}",
      toPing: "",
      pinged: "",
      postModified: DateTime.now()
          .subtract(Duration(days: random.nextInt(5)))
          .toIso8601String(),
      postModifiedGmt: DateTime.now()
          .subtract(Duration(days: random.nextInt(5)))
          .toIso8601String(),
      contentFiltered: "",
      parent: 0,
      guid: "https://example.com/?p=${113000 + index}",
      menuOrder: 0,
      type: "post",
      commentCount: random.nextInt(50) + 5,
      mimeType: "",
      /*  imageUrl: images[index % images.length],
      authorName: authors[random.nextInt(authors.length)],
      categoryName: categories[random.nextInt(categories.length)],
      readTime: random.nextInt(8) + 2, */
    );
  });
});

String _generateTitle(int index, bool isHero) {
  final titles = [
    "Breaking: Revolutionary AI Technology Transforms Global Markets",
    "The Future of Sustainable Energy: What Experts Predict",
    "Digital Privacy in 2025: New Regulations Change Everything",
    "Climate Innovation: Cities Leading the Green Revolution",
    "Cryptocurrency Market Sees Unprecedented Growth",
    "Healthcare Technology: Personalized Medicine Era Begins",
    "Space Exploration: Private Companies Race to Mars",
    "Quantum Computing: The Next Technological Frontier",
  ];
  return titles[index % titles.length];
}

String _generateExcerpt(int index) {
  final excerpts = [
    "Industry leaders discuss the implications of breakthrough technology that could reshape how we work and live in the digital age.",
    "Scientists and policy makers unite to address the most pressing environmental challenges of our time with innovative solutions.",
    "New legislation promises to give users unprecedented control over their personal data while maintaining technological progress.",
    "Urban planners and environmental experts collaborate on sustainable city designs that could serve as models worldwide.",
    "Market analysts examine the factors driving digital currency adoption across traditional financial institutions.",
    "Medical professionals explore how AI and genomics are creating personalized treatment plans for patients.",
    "Commercial space ventures accelerate timeline for human settlement beyond Earth's atmosphere.",
    "Researchers achieve quantum supremacy milestones that promise to revolutionize computing capabilities.",
  ];
  return excerpts[index % excerpts.length];
}

String _generateContent(int index) {
  return """
In a rapidly evolving technological landscape, innovation continues to reshape our understanding of what's possible. Recent developments have shown unprecedented growth in sectors that were once considered niche markets.

The convergence of artificial intelligence, sustainable technology, and human-centered design has created opportunities that extend far beyond traditional boundaries. Industry experts emphasize the importance of ethical considerations as these technologies become more integrated into daily life.

Key stakeholders across various sectors are collaborating to ensure that technological advancement serves the broader public interest while maintaining competitive innovation cycles. This balance between progress and responsibility represents a critical challenge for the coming decade.

Research institutions and private enterprises are investing heavily in foundational technologies that promise to address global challenges including climate change, healthcare accessibility, and economic inequality.

The implications of these developments extend to policy frameworks, educational systems, and social structures that must adapt to accommodate rapid technological change. Forward-thinking organizations are already implementing strategies to navigate this transformation successfully.

As we look toward the future, the intersection of technology and human values will likely determine the trajectory of global development. The choices made today in research labs, boardrooms, and policy chambers will shape the world of tomorrow.
""";
}

// screens/home_screen.dart

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [_buildHeader(), _buildContent()],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NEXUS',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      'DIGITAL MAGAZINE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[500],
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.account_circle_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
            Text(
              DateFormat('EEEE, MMMM d').format(DateTime.now()).toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Today\'s Stories',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    print('Fetching content...');
    return ref
        .watch(wordpressPostsProvider)
        .when(
          data: (posts) => SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index == 0) {
                return _HeroArticleCard(post: posts[0]);
              }
              print('Fetching content.${posts[index]}..');
              return _ArticleCard(post: posts[index]);
            }, childCount: posts.length),
          ),
          loading: () => SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Color(0xFF6366F1)),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Loading stories...',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          error: (error, stack) => SliverFillRemaining(
            child: Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
          ),
        );
  }
}

class _HeroArticleCard extends StatelessWidget {
  final WordPressPost post;

  const _HeroArticleCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: InkWell(
        onTap: () => _navigateToArticle(context, post),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: Image.network(
                    post.guid ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Color(0xFF1A1A1A),
                      child: Icon(
                        Icons.image,
                        color: Colors.grey[700],
                        size: 64,
                      ),
                    ),
                  ),
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.8),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                // Content
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF6366F1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          /* post. ?? */ 'FEATURED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        post.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            post.name ?? 'Unknown Author',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            ' • ',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                          Text(
                            '${post.date ?? 5} min read',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
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

  void _navigateToArticle(BuildContext context, WordPressPost post) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ArticleDetailScreen(post: post),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(
                begin: Offset(1.0, 0.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutCubic)),
            ),
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 400),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final WordPressPost post;

  const _ArticleCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: InkWell(
        onTap: () => _navigateToArticle(context, post),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF111111),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[800]!, width: 0.5),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      /* post.?.toUpperCase() ?? */ 'GENERAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6366F1),
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      post.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Text(
                      post.excerpt,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          post.name ?? 'Unknown',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          ' • ${_formatDate(post.date)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Color(0xFF1A1A1A),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    post.guid ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Color(0xFF1A1A1A),
                      child: Icon(
                        Icons.article,
                        color: Colors.grey[700],
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      if (difference == 0) return 'Today';
      if (difference == 1) return 'Yesterday';
      if (difference < 7) return '${difference}d ago';
      return DateFormat('MMM dd').format(date);
    } catch (e) {
      return 'Recently';
    }
  }

  void _navigateToArticle(BuildContext context, WordPressPost post) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ArticleDetailScreen(post: post),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(
                begin: Offset(1.0, 0.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutCubic)),
            ),
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 400),
      ),
    );
  }
}

// screens/article_detail_screen.dart
class ArticleDetailScreen extends StatefulWidget {
  final WordPressPost post;

  const ArticleDetailScreen({super.key, required this.post});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _scrollController.addListener(() {
      setState(() {
        _showAppBarTitle = _scrollController.offset > 200;
      });
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          controller: _scrollController,
          physics: BouncingScrollPhysics(),
          slivers: [_buildAppBar(), _buildHeroImage(), _buildContent()],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 0,
      backgroundColor: Color(0xFF0A0A0A).withOpacity(0.95),
      elevation: 0,
      leading: IconButton(
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[800]!, width: 0.5),
          ),
          child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: AnimatedOpacity(
        opacity: _showAppBarTitle ? 1.0 : 0.0,
        duration: Duration(milliseconds: 200),
        child: Text(
          widget.post.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      actions: [
        IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[800]!, width: 0.5),
            ),
            child: Icon(Icons.bookmark_border, color: Colors.white, size: 18),
          ),
          onPressed: () {},
        ),
        SizedBox(width: 8),
        IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[800]!, width: 0.5),
            ),
            child: Icon(Icons.share, color: Colors.white, size: 18),
          ),
          onPressed: () {},
        ),
        SizedBox(width: 16),
      ],
    );
  }

  Widget _buildHeroImage() {
    return SliverToBoxAdapter(
      child: Container(
        height: 300,
        margin: EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.network(
            widget.post.guid ?? '',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Color(0xFF1A1A1A),
              child: Icon(Icons.image, color: Colors.grey[700], size: 64),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFF6366F1).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0xFF6366F1).withOpacity(0.3)),
              ),
              child: Text(
                /*  widget.post.categoryName?.toUpperCase() ?? */ 'GENERAL',
                style: TextStyle(
                  color: Color(0xFF6366F1),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            SizedBox(height: 20),

            // Title
            Text(
              widget.post.title,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),

            SizedBox(height: 16),

            // Excerpt
            Text(
              widget.post.excerpt,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[400],
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),

            SizedBox(height: 24),

            // Author and Meta Info
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(Icons.person, color: Colors.white, size: 24),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.name ?? 'Unknown Author',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_formatDate(widget.post.date)} • ${widget.post.date ?? 5} min read',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[800]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        color: Colors.grey[400],
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${widget.post.commentCount}',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(0xFF111111),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[800]!, width: 0.5),
              ),
              child: Text(
                widget.post.content,
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.grey[300],
                  height: 1.7,
                  letterSpacing: 0.2,
                ),
              ),
            ),

            SizedBox(height: 40),

            // Tags (if available)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTag('Technology'),
                _buildTag('Innovation'),
                _buildTag('Future'),
                _buildTag('Analysis'),
              ],
            ),

            SizedBox(height: 60),

            // Related Articles Section
            Text(
              'Related Stories',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 20),

            // Related articles placeholder
            Container(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) => _buildRelatedArticle(index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRelatedArticle(int index) {
    final titles = [
      'AI Revolution Continues',
      'Climate Technology Advances',
      'Digital Future Insights',
    ];

    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(Icons.article, color: Colors.grey[700], size: 24),
            ),
          ),
          SizedBox(height: 12),
          Text(
            titles[index],
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Spacer(),
          Text(
            '3 min read',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMMM dd, yyyy').format(date);
    } catch (e) {
      return 'Recently';
    }
  }
}

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WordPress Content',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
