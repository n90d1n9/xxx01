// models/wordpress_post.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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

// providers/wordpress_providers.dart

// Mock data provider - replace with actual API call
final wordpressPostProvider = FutureProvider<WordPressPost>((ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(seconds: 1));

  return WordPressPost(
    id: 113000,
    author: 8,
    date: "2017-07-19T16:17:55",
    dateGmt: "2017-07-19T09:17:55",
    content: "this is content",
    title: "judul",
    category: 0,
    excerpt: "",
    status: "inherit",
    commentStatus: "open",
    pingStatus: "closed",
    password: "",
    name: "myname",
    toPing: "",
    pinged: "",
    postModified: "2017-07-19T16:17:55",
    postModifiedGmt: "2017-07-19T09:17:55",
    contentFiltered: "",
    parent: 112999,
    guid: "http://example.com/?attachment_id=113000",
    menuOrder: 0,
    type: "attachment",
    commentCount: 0,
    mimeType: "image/jpeg",
  );
});

final wordpressPostsProvider = FutureProvider<List<WordPressPost>>((ref) async {
  await Future.delayed(const Duration(seconds: 1));

  // Mock list of posts
  return List.generate(
    5,
    (index) => WordPressPost(
      id: 113000 + index,
      author: 8,
      date: "2017-07-19T16:17:55",
      dateGmt: "2017-07-19T09:17:55",
      content:
          "This is sample content for post ${index + 1}. Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
      title: "Sample Post ${index + 1}",
      category: index % 3,
      excerpt: "This is an excerpt for post ${index + 1}",
      status: "publish",
      commentStatus: "open",
      pingStatus: "closed",
      password: "",
      name: "sample-post-${index + 1}",
      toPing: "",
      pinged: "",
      postModified: "2017-07-19T16:17:55",
      postModifiedGmt: "2017-07-19T09:17:55",
      contentFiltered: "",
      parent: 0,
      guid: "http://example.com/?p=${113000 + index}",
      menuOrder: 0,
      type: "post",
      commentCount: index * 2,
      mimeType: "",
    ),
  );
});

// screens/wordpress_content_screen.dart

class WordPressContentScreen extends ConsumerWidget {
  const WordPressContentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'WordPress Content',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              titlePadding: EdgeInsets.only(left: 16, bottom: 16),
            ),
          ),

          // Content
          ref
              .watch(wordpressPostsProvider)
              .when(
                data:
                    (posts) => SliverPadding(
                      padding: EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _PostCard(post: posts[index]),
                          childCount: posts.length,
                        ),
                      ),
                    ),
                loading:
                    () => SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation(
                                Colors.blue[600],
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Loading content...',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                error:
                    (error, stack) => SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[300],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Something went wrong',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Please try again later',
                              style: TextStyle(color: Colors.grey[600]),
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

class _PostCard extends StatelessWidget {
  final WordPressPost post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showPostDetails(context, post),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with type indicator
              if (post.type == "attachment")
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple[400]!, Colors.purple[600]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.attachment, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Attachment • ${post.mimeType}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              // Content
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      post.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[900],
                        height: 1.3,
                      ),
                    ),

                    SizedBox(height: 12),

                    // Content preview
                    Text(
                      post.content.isNotEmpty
                          ? post.content
                          : post.excerpt.isNotEmpty
                          ? post.excerpt
                          : 'No content available',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 16),

                    // Meta information
                    Row(
                      children: [
                        _MetaChip(
                          icon: Icons.calendar_today,
                          label: _formatDate(post.date),
                          color: Colors.blue,
                        ),
                        SizedBox(width: 8),
                        _MetaChip(
                          icon: Icons.comment,
                          label: '${post.commentCount}',
                          color: Colors.green,
                        ),
                        SizedBox(width: 8),
                        _MetaChip(
                          icon: Icons.person,
                          label: 'Author ${post.author}',
                          color: Colors.orange,
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  void _showPostDetails(BuildContext context, WordPressPost post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PostDetailsBottomSheet(post: post),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PostDetailsBottomSheet extends StatelessWidget {
  final WordPressPost post;

  const _PostDetailsBottomSheet({required this.post});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder:
          (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),

                        SizedBox(height: 16),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _DetailChip(label: 'ID: ${post.id}'),
                            _DetailChip(label: 'Type: ${post.type}'),
                            _DetailChip(label: 'Status: ${post.status}'),
                            if (post.mimeType.isNotEmpty)
                              _DetailChip(label: 'MIME: ${post.mimeType}'),
                          ],
                        ),

                        SizedBox(height: 24),

                        Text(
                          'Content',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),

                        SizedBox(height: 12),

                        Text(
                          post.content.isNotEmpty
                              ? post.content
                              : 'No content available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            height: 1.6,
                          ),
                        ),

                        SizedBox(height: 24),

                        // Additional details
                        _buildDetailSection('Details', [
                          'Author ID: ${post.author}',
                          'Category: ${post.category}',
                          'Comment Count: ${post.commentCount}',
                          'Menu Order: ${post.menuOrder}',
                          if (post.parent > 0) 'Parent ID: ${post.parent}',
                        ]),

                        SizedBox(height: 16),

                        _buildDetailSection('Timestamps', [
                          'Published: ${_formatDateTime(post.date)}',
                          'Modified: ${_formatDateTime(post.postModified)}',
                        ]),

                        SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text(
              item,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy - HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }
}

class _DetailChip extends StatelessWidget {
  final String label;

  const _DetailChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}

// main.dart

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
      home: WordPressContentScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
