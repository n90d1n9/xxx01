import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

// Models
class Curriculum {
  final int id;
  final String name;
  final String description;
  final int implementationYear;
  final bool isActive;

  Curriculum({
    required this.id,
    required this.name,
    required this.description,
    required this.implementationYear,
    this.isActive = true,
  });

  Curriculum copyWith({
    int? id,
    String? name,
    String? description,
    int? implementationYear,
    bool? isActive,
  }) {
    return Curriculum(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      implementationYear: implementationYear ?? this.implementationYear,
      isActive: isActive ?? this.isActive,
    );
  }
}

// Riverpod providers
final curriculumsProvider =
    StateNotifierProvider<CurriculumNotifier, AsyncValue<List<Curriculum>>>((
      ref,
    ) {
      return CurriculumNotifier();
    });

final activeCurriculumProvider = Provider<Curriculum?>((ref) {
  final curriculumsState = ref.watch(curriculumsProvider);
  return curriculumsState.whenData((curriculums) {
    if (curriculums.isEmpty) return null;
    return curriculums.firstWhere(
      (c) => c.isActive,
      orElse: () => curriculums.first,
    );
  }).value;
});

final selectedCurriculumProvider = StateProvider<Curriculum?>((ref) => null);

final filterTextProvider = StateProvider<String>((ref) => '');

final filteredCurriculumsProvider = Provider<AsyncValue<List<Curriculum>>>((
  ref,
) {
  final curriculumsState = ref.watch(curriculumsProvider);
  final filterText = ref.watch(filterTextProvider);

  return curriculumsState.whenData((curriculums) {
    if (filterText.isEmpty) return curriculums;
    return curriculums
        .where(
          (c) =>
              c.name.toLowerCase().contains(filterText.toLowerCase()) ||
              c.description.toLowerCase().contains(filterText.toLowerCase()),
        )
        .toList();
  });
});

// Notifier
class CurriculumNotifier extends StateNotifier<AsyncValue<List<Curriculum>>> {
  CurriculumNotifier() : super(const AsyncValue.loading()) {
    getCurriculums();
  }

  Future<void> getCurriculums({
    Map<String, dynamic>? filters,
    Map<String, dynamic>? pagination,
  }) async {
    try {
      state = const AsyncValue.loading();
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      final curriculums = [
        Curriculum(
          id: 1,
          name: "Kurikulum Merdeka",
          description:
              "Kurikulum berbasis kompetensi yang dirancang untuk menjawab tantangan abad 21",
          implementationYear: 2022,
          isActive: true,
        ),
        Curriculum(
          id: 2,
          name: "Kurikulum 2013",
          description:
              "Kurikulum yang menekankan pada pendekatan saintifik dalam pembelajaran",
          implementationYear: 2013,
        ),
        Curriculum(
          id: 3,
          name: "Kurikulum KTSP",
          description:
              "Kurikulum tingkat satuan pendidikan yang memberikan otonomi kepada sekolah",
          implementationYear: 2006,
        ),
      ];

      state = AsyncValue.data(curriculums);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> createCurriculum(Curriculum curriculum) async {
    try {
      // Optimistic update
      final currentCurriculums = state.value ?? [];
      final newCurriculum = curriculum.copyWith(
        id: currentCurriculums.length + 1,
      );

      state = AsyncValue.data([...currentCurriculums, newCurriculum]);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // If there's an error, we would revert the state here
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateCurriculum(int id, Curriculum updatedCurriculum) async {
    try {
      final currentCurriculums = state.value ?? [];
      final index = currentCurriculums.indexWhere((c) => c.id == id);

      if (index >= 0) {
        final updatedList = [...currentCurriculums];
        updatedList[index] = updatedCurriculum;
        state = AsyncValue.data(updatedList);

        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteCurriculum(int id) async {
    try {
      final currentCurriculums = state.value ?? [];
      state = AsyncValue.data(
        currentCurriculums.where((c) => c.id != id).toList(),
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> setActiveCurriculum(int id) async {
    try {
      final currentCurriculums = state.value ?? [];
      final updatedList =
          currentCurriculums
              .map((c) => c.copyWith(isActive: c.id == id))
              .toList();

      state = AsyncValue.data(updatedList);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// UI Components
class CurriculumScreen extends ConsumerStatefulWidget {
  const CurriculumScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CurriculumScreen> createState() => _CurriculumScreenState();
}

class _CurriculumScreenState extends ConsumerState<CurriculumScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _showCurriculumForm({Curriculum? curriculum}) {
    if (curriculum != null) {
      _nameController.text = curriculum.name;
      _descriptionController.text = curriculum.description;
      _yearController.text = curriculum.implementationYear.toString();
    } else {
      _nameController.clear();
      _descriptionController.clear();
      _yearController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      curriculum == null
                          ? 'Add New Curriculum'
                          : 'Edit Curriculum',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Curriculum Name',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: 'Kurikulum Merdeka',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter curriculum name';
                              }
                              if (value.length < 3) {
                                return 'Name must be at least 3 characters';
                              }
                              if (value.length > 100) {
                                return 'Name cannot exceed 100 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              hintText: 'Deskripsi kurikulum',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            maxLines: 4,
                            validator: (value) {
                              if (value != null && value.length > 500) {
                                return 'Description cannot exceed 500 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Implementation Year',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _yearController,
                            decoration: InputDecoration(
                              hintText: '2023',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter implementation year';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid year';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  final curriculumNotifier = ref.read(
                                    curriculumsProvider.notifier,
                                  );

                                  final newCurriculum = Curriculum(
                                    id: curriculum?.id ?? 0,
                                    name: _nameController.text,
                                    description: _descriptionController.text,
                                    implementationYear: int.parse(
                                      _yearController.text,
                                    ),
                                    isActive: curriculum?.isActive ?? false,
                                  );

                                  if (curriculum == null) {
                                    curriculumNotifier.createCurriculum(
                                      newCurriculum,
                                    );
                                  } else {
                                    curriculumNotifier.updateCurriculum(
                                      curriculum.id,
                                      newCurriculum,
                                    );
                                  }

                                  Navigator.pop(context);
                                }
                              },
                              child: Text(
                                curriculum == null
                                    ? 'Create Curriculum'
                                    : 'Update Curriculum',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final curriculumsState = ref.watch(filteredCurriculumsProvider);
    final activeCurriculum = ref.watch(activeCurriculumProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Curriculum Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Curriculums'),
            Tab(text: 'Active Curriculum'),
          ],
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All Curriculums Tab
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Search curriculums',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) {
                    ref.read(filterTextProvider.notifier).state = value;
                  },
                ),
              ),
              Expanded(
                child: curriculumsState.when(
                  data: (curriculums) {
                    if (curriculums.isEmpty) {
                      return const Center(child: Text('No curriculums found'));
                    }

                    return RefreshIndicator(
                      onRefresh:
                          () =>
                              ref
                                  .read(curriculumsProvider.notifier)
                                  .getCurriculums(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: curriculums.length,
                        itemBuilder: (context, index) {
                          final curriculum = curriculums[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Slidable(
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    icon: Icons.edit,
                                    label: 'Edit',
                                    onPressed: (context) {
                                      _showCurriculumForm(
                                        curriculum: curriculum,
                                      );
                                    },
                                  ),
                                  SlidableAction(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Delete',
                                    onPressed: (context) {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              title: const Text(
                                                'Delete Curriculum',
                                              ),
                                              content: Text(
                                                'Are you sure you want to delete "${curriculum.name}"?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    ref
                                                        .read(
                                                          curriculumsProvider
                                                              .notifier,
                                                        )
                                                        .deleteCurriculum(
                                                          curriculum.id,
                                                        );
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      ref
                                          .read(
                                            selectedCurriculumProvider.notifier,
                                          )
                                          .state = curriculum;
                                      // Navigate to curriculum detail page
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color:
                                                  curriculum.isActive
                                                      ? Colors.green.withValues(
                                                        alpha: 0.1,
                                                      )
                                                      : Colors.grey.withValues(
                                                        alpha: 0.1,
                                                      ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.school,
                                                color:
                                                    curriculum.isActive
                                                        ? Colors.green
                                                        : Colors.grey,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        curriculum.name,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                    if (curriculum.isActive)
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.green
                                                              .withValues(
                                                                alpha: 0.1,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        child: const Text(
                                                          'Active',
                                                          style: TextStyle(
                                                            color: Colors.green,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  curriculum.description,
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 14,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue
                                                            .withValues(
                                                              alpha: 0.1,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        'Since ${curriculum.implementationYear}',
                                                        style: const TextStyle(
                                                          color: Colors.blue,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    if (!curriculum.isActive)
                                                      TextButton(
                                                        onPressed: () {
                                                          ref
                                                              .read(
                                                                curriculumsProvider
                                                                    .notifier,
                                                              )
                                                              .setActiveCurriculum(
                                                                curriculum.id,
                                                              );
                                                        },
                                                        style: TextButton.styleFrom(
                                                          foregroundColor:
                                                              Theme.of(
                                                                context,
                                                              ).primaryColor,
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 12,
                                                              ),
                                                          minimumSize:
                                                              Size.zero,
                                                          tapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                        ),
                                                        child: const Text(
                                                          'Set as Active',
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
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (error, stackTrace) =>
                          Center(child: Text('Error: $error')),
                ),
              ),
            ],
          ),

          // Active Curriculum Tab
          activeCurriculum == null
              ? const Center(child: Text('No active curriculum'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Active Curriculum',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      activeCurriculum.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            activeCurriculum.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _InfoCard(
                                  icon: Icons.calendar_today,
                                  title: 'Implementation Year',
                                  value:
                                      activeCurriculum.implementationYear
                                          .toString(),
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _InfoCard(
                                  icon: Icons.pie_chart,
                                  title: 'Subjects',
                                  value: '12', // Mock data
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _InfoCard(
                                  icon: Icons.school,
                                  title: 'Academic Years',
                                  value: '3', // Mock data
                                  color: Colors.purple,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _InfoCard(
                                  icon: Icons.domain,
                                  title: 'School',
                                  value: 'SMA 1', // Mock data
                                  color: Colors.teal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    _showCurriculumForm(
                                      curriculum: activeCurriculum,
                                    );
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Edit'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    side: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Navigate to subjects management
                                  },
                                  icon: const Icon(Icons.view_list),
                                  label: const Text('View Subjects'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.people,
                            title: 'Assign Teachers',
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.calendar_month,
                            title: 'Academic Years',
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.assessment,
                            title: 'Reports',
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCurriculumForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Main app entry point
void main() {
  runApp(const ProviderScope(child: CurriculumApp()));
}

class CurriculumApp extends StatelessWidget {
  const CurriculumApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Curriculum Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4361EE),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4361EE),
          brightness: Brightness.light,
        ),
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[50],
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const CurriculumScreen(),
    );
  }
}
