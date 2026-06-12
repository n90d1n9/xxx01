import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_fonts/google_fonts.dart';

// Models
class ImpactProject {
  final String id;
  final String title;
  final String category;
  final String description;
  final String imageUrl;
  final int impactScore;
  final int supporters;
  final bool isFeatured;

  ImpactProject({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.impactScore,
    required this.supporters,
    this.isFeatured = false,
  });
}

// Sample data
final List<ImpactProject> _sampleProjects = [
  ImpactProject(
    id: '1',
    title: 'Clean Water Initiative',
    category: 'Environment',
    description:
        'Providing clean water solutions to remote villages using sustainable technology.',
    imageUrl: 'https://example.com/water.jpg',
    impactScore: 87,
    supporters: 342,
    isFeatured: true,
  ),
  ImpactProject(
    id: '2',
    title: 'Digital Education for All',
    category: 'Education',
    description:
        'Bringing digital literacy to underprivileged children through mobile learning centers.',
    imageUrl: 'https://example.com/education.jpg',
    impactScore: 92,
    supporters: 528,
  ),
  ImpactProject(
    id: '3',
    title: 'Urban Farming Network',
    category: 'Food Security',
    description:
        'Creating sustainable urban farms to address food deserts in metropolitan areas.',
    imageUrl: 'https://example.com/farming.jpg',
    impactScore: 79,
    supporters: 215,
  ),
  ImpactProject(
    id: '4',
    title: 'Disability Inclusion Program',
    category: 'Accessibility',
    description:
        'Creating employment opportunities for people with disabilities through specialized training.',
    imageUrl: 'https://example.com/inclusion.jpg',
    impactScore: 84,
    supporters: 193,
  ),
];

// Providers
final projectsProvider =
    StateNotifierProvider<ProjectsNotifier, List<ImpactProject>>(
      (ref) => ProjectsNotifier(),
    );

final filteredProjectsProvider = StateProvider<String>((ref) => 'All');

final displayProjectsProvider = Provider<List<ImpactProject>>((ref) {
  final projects = ref.watch(projectsProvider);
  final filter = ref.watch(filteredProjectsProvider);

  if (filter == 'All') {
    return projects;
  } else if (filter == 'Featured') {
    return projects.where((project) => project.isFeatured).toList();
  } else {
    return projects.where((project) => project.category == filter).toList();
  }
});

// Notifier
class ProjectsNotifier extends StateNotifier<List<ImpactProject>> {
  ProjectsNotifier() : super(_sampleProjects);

  void toggleSupport(String projectId) {
    state = state.map((project) {
      if (project.id == projectId) {
        return ImpactProject(
          id: project.id,
          title: project.title,
          category: project.category,
          description: project.description,
          imageUrl: project.imageUrl,
          impactScore: project.impactScore,
          supporters: project.supporters + 1,
          isFeatured: project.isFeatured,
        );
      }
      return project;
    }).toList();
  }
}

// Main Screen
class SocialEntrepreneurScreen extends ConsumerWidget {
  const SocialEntrepreneurScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(displayProjectsProvider);
    final currentFilter = ref.watch(filteredProjectsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text(
                'Impact Hub',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF2E3A59),
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Color(0xFF2E3A59)),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFF2E3A59),
                  ),
                  onPressed: () {},
                ),
              ],
            ),

            // User Stats Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF5A54D1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(
                              'https://example.com/profile.jpg',
                            ),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Sarah Johnson',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatItem(
                            'Impact Score',
                            '842',
                            Icons.trending_up,
                          ),
                          _buildStatItem('Supported', '12', Icons.favorite),
                          _buildStatItem('Network', '68', Icons.people),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Category Filters
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: [
                      _buildFilterChip('All', currentFilter, ref),
                      _buildFilterChip('Featured', currentFilter, ref),
                      _buildFilterChip('Education', currentFilter, ref),
                      _buildFilterChip('Environment', currentFilter, ref),
                      _buildFilterChip('Food Security', currentFilter, ref),
                      _buildFilterChip('Accessibility', currentFilter, ref),
                    ],
                  ),
                ),
              ),
            ),

            // Section Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Impact Projects',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2E3A59),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'View All',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF6C63FF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Projects Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final project = projects[index];
                  return _buildProjectCard(project, ref);
                }, childCount: projects.length),
              ),
            ),

            SliverToBoxAdapter(child: const SizedBox(height: 20)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF6C63FF),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String currentFilter, WidgetRef ref) {
    final isSelected = currentFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () {
          ref.read(filteredProjectsProvider.notifier).state = label;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6C63FF) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey.shade300,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(ImpactProject project, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Image with Category Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  project.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, color: Colors.grey),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    project.category,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              if (project.isFeatured)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.black),
                        const SizedBox(width: 2),
                        Text(
                          'Featured',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Project Details
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  project.description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.insights,
                            size: 12,
                            color: Color(0xFF2196F3),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${project.impactScore}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF2196F3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        ref
                            .read(projectsProvider.notifier)
                            .toggleSupport(project.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.favorite_border,
                              size: 12,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${project.supporters}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
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
  }
}

// Main app
class SocialEntrepreneurApp extends StatelessWidget {
  const SocialEntrepreneurApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Social Entrepreneur',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          fontFamily: GoogleFonts.poppins().fontFamily,
          scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        ),
        home: const SocialEntrepreneurScreen(),
      ),
    );
  }
}

void main() {
  runApp(const SocialEntrepreneurApp());
}
