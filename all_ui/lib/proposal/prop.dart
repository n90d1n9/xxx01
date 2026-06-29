import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

// Models
class Proposal {
  final String id;
  final String title;
  final String description;
  final String category;
  final String thumbnailUrl;
  final double rating;
  final int reviewCount;
  final bool isPremium;
  final bool isFavorite;

  Proposal({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.thumbnailUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isPremium = false,
    this.isFavorite = false,
  });

  Proposal copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? thumbnailUrl,
    double? rating,
    int? reviewCount,
    bool? isPremium,
    bool? isFavorite,
  }) {
    return Proposal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isPremium: isPremium ?? this.isPremium,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

// Comment model
class ProposalComment {
  final String id;
  final String proposalId;
  final String userName;
  final String userAvatar;
  final String text;
  final double rating;
  final DateTime createdAt;

  ProposalComment({
    required this.id,
    required this.proposalId,
    required this.userName,
    required this.userAvatar,
    required this.text,
    required this.rating,
    required this.createdAt,
  });
}

// Providers
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final proposalsProvider =
    StateNotifierProvider<ProposalsNotifier, List<Proposal>>((ref) {
      return ProposalsNotifier();
    });

final filteredProposalsProvider = Provider<List<Proposal>>((ref) {
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final proposals = ref.watch(proposalsProvider);

  if (selectedCategory == null || selectedCategory == 'All') {
    return proposals;
  }

  return proposals
      .where((proposal) => proposal.category == selectedCategory)
      .toList();
});

final proposalCommentsProvider = StateNotifierProvider.family<
  CommentsNotifier,
  List<ProposalComment>,
  String
>((ref, proposalId) {
  return CommentsNotifier(proposalId);
});

// Notifiers
class ProposalsNotifier extends StateNotifier<List<Proposal>> {
  ProposalsNotifier()
    : super([
        Proposal(
          id: '1',
          title: 'Business Proposal Template',
          description:
              'Professional business proposal template with modern design and customizable sections.',
          category: 'Business',
          thumbnailUrl: 'assets/images/business_proposal.jpg',
          rating: 4.7,
          reviewCount: 128,
          isPremium: false,
        ),
        Proposal(
          id: '2',
          title: 'Marketing Campaign Proposal',
          description:
              'Comprehensive marketing proposal template with budget sections and timeline planning.',
          category: 'Marketing',
          thumbnailUrl: 'assets/images/marketing_proposal.jpg',
          rating: 4.5,
          reviewCount: 85,
          isPremium: true,
        ),
        Proposal(
          id: '3',
          title: 'Web Development Project Proposal',
          description:
              'Technical proposal template for web development projects with milestones and deliverables.',
          category: 'Technology',
          thumbnailUrl: 'assets/images/web_dev_proposal.jpg',
          rating: 4.8,
          reviewCount: 214,
          isPremium: true,
        ),
        Proposal(
          id: '4',
          title: 'Event Planning Proposal',
          description:
              'Event proposal template with venue details, schedule planning, and budget breakdowns.',
          category: 'Events',
          thumbnailUrl: 'assets/images/event_proposal.jpg',
          rating: 4.3,
          reviewCount: 56,
          isPremium: false,
        ),
        Proposal(
          id: '5',
          title: 'Research Grant Proposal',
          description:
              'Academic research proposal template with methodology sections and literature review framework.',
          category: 'Academic',
          thumbnailUrl: 'assets/images/research_proposal.jpg',
          rating: 4.6,
          reviewCount: 92,
          isPremium: true,
        ),
      ]);

  void toggleFavorite(String proposalId) {
    state =
        state.map((proposal) {
          if (proposal.id == proposalId) {
            return proposal.copyWith(isFavorite: !proposal.isFavorite);
          }
          return proposal;
        }).toList();
  }

  void rateProposal(String proposalId, double rating) {
    state =
        state.map((proposal) {
          if (proposal.id == proposalId) {
            // Simple average calculation for demo purposes
            final newCount = proposal.reviewCount + 1;
            final newRating =
                ((proposal.rating * proposal.reviewCount) + rating) / newCount;
            return proposal.copyWith(
              rating: double.parse(newRating.toStringAsFixed(1)),
              reviewCount: newCount,
            );
          }
          return proposal;
        }).toList();
  }
}

class CommentsNotifier extends StateNotifier<List<ProposalComment>> {
  final String proposalId;

  CommentsNotifier(this.proposalId)
    : super([
        // Sample comments for proposal 1
        if (proposalId == '1') ...[
          ProposalComment(
            id: '1',
            proposalId: '1',
            userName: 'Sarah Johnson',
            userAvatar: 'assets/avatars/sarah.jpg',
            text:
                'This template saved me hours of work! The layout is professional and easy to customize.',
            rating: 5.0,
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
          ),
          ProposalComment(
            id: '2',
            proposalId: '1',
            userName: 'Michael Chen',
            userAvatar: 'assets/avatars/michael.jpg',
            text: 'Good template but could use more financial section details.',
            rating: 4.0,
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
        // Sample comments for proposal 2
        if (proposalId == '2') ...[
          ProposalComment(
            id: '3',
            proposalId: '2',
            userName: 'Emily Rodriguez',
            userAvatar: 'assets/avatars/emily.jpg',
            text:
                'Perfect for our agency needs. Clients love the professional look!',
            rating: 5.0,
            createdAt: DateTime.now().subtract(const Duration(days: 7)),
          ),
        ],
      ]);

  void addComment(
    String text,
    double rating,
    String userName,
    String userAvatar,
  ) {
    final newComment = ProposalComment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      proposalId: proposalId,
      userName: userName,
      userAvatar: userAvatar,
      text: text,
      rating: rating,
      createdAt: DateTime.now(),
    );

    state = [...state, newComment];
  }
}

// Main App
class ProposalTemplateApp extends StatelessWidget {
  const ProposalTemplateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Proposal Templates',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4),
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        home: const ProposalHomeScreen(),
      ),
    );
  }
}

// Home Screen
class ProposalHomeScreen extends ConsumerStatefulWidget {
  const ProposalHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProposalHomeScreen> createState() => _ProposalHomeScreenState();
}

class _ProposalHomeScreenState extends ConsumerState<ProposalHomeScreen> {
  final List<String> categories = [
    'All',
    'Business',
    'Marketing',
    'Technology',
    'Events',
    'Academic',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final filteredProposals = ref.watch(filteredProposalsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Proposal Templates',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Navigate to favorites
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              // Navigate to profile
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search templates...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ),

          // Categories
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected =
                    selectedCategory == category ||
                    (selectedCategory == null && category == 'All');

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      ref.read(selectedCategoryProvider.notifier).state =
                          category;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                                : null,
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Templates heading
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Popular Templates',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Templates grid
          Expanded(
            child:
                filteredProposals.isEmpty
                    ? const Center(child: Text('No templates found'))
                    : GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                          ),
                      itemCount: filteredProposals.length,
                      itemBuilder: (context, index) {
                        final proposal = filteredProposals[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ProposalDetailScreen(
                                      proposal: proposal,
                                    ),
                              ),
                            );
                          },
                          child: ProposalCard(proposal: proposal),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create new proposal
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Proposal Card Widget
class ProposalCard extends ConsumerWidget {
  final Proposal proposal;

  const ProposalCard({Key? key, required this.proposal}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.description,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              if (proposal.isPremium)
                Positioned(
                  top: 8,
                  left: 8,
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
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    ref
                        .read(proposalsProvider.notifier)
                        .toggleFavorite(proposal.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      proposal.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: proposal.isFavorite ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  proposal.category,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  proposal.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      proposal.rating.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${proposal.reviewCount})',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Detail Screen
class ProposalDetailScreen extends ConsumerStatefulWidget {
  final Proposal proposal;

  const ProposalDetailScreen({Key? key, required this.proposal})
    : super(key: key);

  @override
  ConsumerState<ProposalDetailScreen> createState() =>
      _ProposalDetailScreenState();
}

class _ProposalDetailScreenState extends ConsumerState<ProposalDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  double _newRating = 0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(proposalCommentsProvider(widget.proposal.id));
    final proposal = ref.watch(
      proposalsProvider.select(
        (proposals) => proposals.firstWhere((p) => p.id == widget.proposal.id),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Template Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              proposal.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: proposal.isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              ref.read(proposalsProvider.notifier).toggleFavorite(proposal.id);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview image
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.description, size: 64, color: Colors.grey),
              ),
            ),

            // Title and rating
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          proposal.category,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (proposal.isPremium)
                        Container(
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
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    proposal.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        proposal.rating.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${proposal.reviewCount} reviews)',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Description
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    proposal.description,
                    style: TextStyle(color: Colors.grey[800], height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Preview functionality
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Preview'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Use template functionality
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Use Template'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Reviews and ratings
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reviews & Ratings',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),

                  // Add review
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rate this template',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RatingBar.builder(
                          initialRating: 0,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 28,
                          itemBuilder:
                              (context, _) =>
                                  const Icon(Icons.star, color: Colors.amber),
                          onRatingUpdate: (rating) {
                            setState(() {
                              _newRating = rating;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Write your review...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(12),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_commentController.text.isNotEmpty &&
                                  _newRating > 0) {
                                // Submit review
                                ref
                                    .read(proposalsProvider.notifier)
                                    .rateProposal(proposal.id, _newRating);
                                ref
                                    .read(
                                      proposalCommentsProvider(
                                        proposal.id,
                                      ).notifier,
                                    )
                                    .addComment(
                                      _commentController.text,
                                      _newRating,
                                      'Current User',
                                      'assets/avatars/user.jpg',
                                    );
                                _commentController.clear();
                                setState(() {
                                  _newRating = 0;
                                });
                                FocusScope.of(context).unfocus();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Submit Review'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Reviews list
                  comments.isEmpty
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No reviews yet. Be the first to review!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                      : ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: comments.length,
                        separatorBuilder:
                            (_, __) => Divider(color: Colors.grey[200]),
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.grey[300],
                                      radius: 16,
                                      child: const Icon(
                                        Icons.person,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment.userName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${comment.createdAt.day}/${comment.createdAt.month}/${comment.createdAt.year}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          comment.rating.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  comment.text,
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    height: 1.4,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                ],
              ),
            ),

            // Related templates
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Similar Templates',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        final similarProposals = ref.read(proposalsProvider);
                        // Skip the current proposal
                        final similarProposal =
                            similarProposals[index % similarProposals.length];
                        if (similarProposal.id == proposal.id &&
                            similarProposals.length > 1) {
                          return Container();
                        }

                        return Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Thumbnail
                              Container(
                                height: 100,
                                decoration: const BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.description,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              // Content
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      similarProposal.category,
                                      style: TextStyle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 10,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      similarProposal.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          similarProposal.rating.toString(),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Main function to run the app
void main() {
  runApp(const ProposalTemplateApp());
}
