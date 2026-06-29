import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

// Enums
enum AchievementLevel { school, city, province, national, international }

enum AchievementType { academic, nonAcademic, sports, arts, competition }

// Models
class Achievement {
  final int? id;
  final String title;
  final String description;
  final DateTime date;
  final String issuer;
  final String certificateNumber;
  final String? certificateFile;
  final AchievementLevel achievementLevel;
  final AchievementType achievementType;
  final int studentId;
  final int schoolId;

  Achievement({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.issuer,
    required this.certificateNumber,
    this.certificateFile,
    required this.achievementLevel,
    required this.achievementType,
    required this.studentId,
    required this.schoolId,
  });

  Achievement copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? date,
    String? issuer,
    String? certificateNumber,
    String? certificateFile,
    AchievementLevel? achievementLevel,
    AchievementType? achievementType,
    int? studentId,
    int? schoolId,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      issuer: issuer ?? this.issuer,
      certificateNumber: certificateNumber ?? this.certificateNumber,
      certificateFile: certificateFile ?? this.certificateFile,
      achievementLevel: achievementLevel ?? this.achievementLevel,
      achievementType: achievementType ?? this.achievementType,
      studentId: studentId ?? this.studentId,
      schoolId: schoolId ?? this.schoolId,
    );
  }
}

// Providers
final achievementsProvider =
    StateNotifierProvider<AchievementNotifier, AsyncValue<List<Achievement>>>((
      ref,
    ) {
      return AchievementNotifier();
    });

final selectedAchievementProvider = StateProvider<Achievement?>((ref) => null);

final achievementTypeFilterProvider = StateProvider<AchievementType?>(
  (ref) => null,
);

final achievementLevelFilterProvider = StateProvider<AchievementLevel?>(
  (ref) => null,
);

// Notifier
class AchievementNotifier extends StateNotifier<AsyncValue<List<Achievement>>> {
  AchievementNotifier() : super(const AsyncValue.loading()) {
    getAchievements();
  }

  // Sample data for demonstration
  final List<Achievement> _achievements = [
    Achievement(
      id: 1,
      title: "Juara 1 Olimpiade Matematika",
      description: "Juara pertama dalam olimpiade matematika tingkat provinsi",
      date: DateTime(2023, 5, 15),
      issuer: "Dinas Pendidikan Provinsi",
      certificateNumber: "CERT-2023-001",
      certificateFile: null,
      achievementLevel: AchievementLevel.province,
      achievementType: AchievementType.academic,
      studentId: 1,
      schoolId: 1,
    ),
    Achievement(
      id: 2,
      title: "Juara 2 Lomba Melukis",
      description: "Juara kedua dalam lomba melukis tingkat kota",
      date: DateTime(2023, 6, 20),
      issuer: "Dinas Kebudayaan Kota",
      certificateNumber: "CULT-2023-042",
      certificateFile: null,
      achievementLevel: AchievementLevel.city,
      achievementType: AchievementType.arts,
      studentId: 1,
      schoolId: 1,
    ),
  ];

  Future<void> getAchievements({Map<String, dynamic>? filters}) async {
    state = const AsyncValue.loading();
    try {
      // Simulate API call with delay
      await Future.delayed(const Duration(seconds: 1));

      // Apply filters if provided
      List<Achievement> filteredAchievements = _achievements;
      if (filters != null) {
        if (filters['achievementType'] != null) {
          filteredAchievements =
              filteredAchievements
                  .where((a) => a.achievementType == filters['achievementType'])
                  .toList();
        }
        if (filters['achievementLevel'] != null) {
          filteredAchievements =
              filteredAchievements
                  .where(
                    (a) => a.achievementLevel == filters['achievementLevel'],
                  )
                  .toList();
        }
        if (filters['studentId'] != null) {
          filteredAchievements =
              filteredAchievements
                  .where((a) => a.studentId == filters['studentId'])
                  .toList();
        }
      }

      state = AsyncValue.data(filteredAchievements);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<Achievement?> createAchievement(Achievement achievement) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final newAchievement = achievement.copyWith(
        id: _achievements.isNotEmpty ? _achievements.last.id! + 1 : 1,
      );

      _achievements.add(newAchievement);
      state = AsyncValue.data(_achievements);
      return newAchievement;
    } catch (e) {
      return null;
    }
  }

  Future<Achievement?> updateAchievement(
    int id,
    Achievement achievement,
  ) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final index = _achievements.indexWhere((a) => a.id == id);
      if (index >= 0) {
        _achievements[index] = achievement;
        state = AsyncValue.data(_achievements);
        return achievement;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteAchievement(int id) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final index = _achievements.indexWhere((a) => a.id == id);
      if (index >= 0) {
        _achievements.removeAt(index);
        state = AsyncValue.data(_achievements);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Achievement?> getAchievement(int id) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      return _achievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Achievement>> getAchievementsByStudent(int studentId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      return _achievements.where((a) => a.studentId == studentId).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Achievement>> getAchievementsByType(
    AchievementType achievementType,
  ) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      return _achievements
          .where((a) => a.achievementType == achievementType)
          .toList();
    } catch (e) {
      return [];
    }
  }
}

// UI Components
class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final achievementType = ref.read(achievementTypeFilterProvider);
    final achievementLevel = ref.read(achievementLevelFilterProvider);

    final filters = <String, dynamic>{};
    if (achievementType != null) filters['achievementType'] = achievementType;
    if (achievementLevel != null)
      filters['achievementLevel'] = achievementLevel;

    ref.read(achievementsProvider.notifier).getAchievements(filters: filters);
  }

  @override
  Widget build(BuildContext context) {
    final achievements = ref.watch(achievementsProvider);
    final achievementTypeFilter = ref.watch(achievementTypeFilterProvider);
    final achievementLevelFilter = ref.watch(achievementLevelFilterProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Prestasi Siswa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Semua Prestasi'), Tab(text: 'Statistik')],
          labelColor: Theme.of(context).primaryColor,
          indicatorColor: Theme.of(context).primaryColor,
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All Achievements Tab
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari prestasi...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),
              if (achievementTypeFilter != null ||
                  achievementLevelFilter != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      if (achievementTypeFilter != null)
                        Chip(
                          label: Text(
                            achievementTypeFilter.toString().split('.').last,
                          ),
                          onDeleted: () {
                            ref
                                .read(achievementTypeFilterProvider.notifier)
                                .state = null;
                            _applyFilters();
                          },
                        ),
                      if (achievementLevelFilter != null)
                        Chip(
                          label: Text(
                            achievementLevelFilter.toString().split('.').last,
                          ),
                          onDeleted: () {
                            ref
                                .read(achievementLevelFilterProvider.notifier)
                                .state = null;
                            _applyFilters();
                          },
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: achievements.when(
                  data: (data) {
                    if (data.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.emoji_events_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada prestasi',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final achievement = data[index];
                        return AchievementCard(achievement: achievement);
                      },
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

          // Statistics Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ringkasan Prestasi',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                achievements.when(
                  data: (data) => _buildStatisticsCards(data),
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton:
          _tabController.index == 0
              ? FloatingActionButton(
                onPressed: () {
                  _showAddAchievementDialog(context);
                },
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  Widget _buildStatisticsCards(List<Achievement> achievements) {
    // Calculate statistics
    final totalAchievements = achievements.length;

    // Count by type
    final Map<AchievementType, int> countByType = {};
    for (final achievement in achievements) {
      countByType[achievement.achievementType] =
          (countByType[achievement.achievementType] ?? 0) + 1;
    }

    // Count by level
    final Map<AchievementLevel, int> countByLevel = {};
    for (final achievement in achievements) {
      countByLevel[achievement.achievementLevel] =
          (countByLevel[achievement.achievementLevel] ?? 0) + 1;
    }

    return Column(
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.amber),
                    const SizedBox(width: 8),
                    const Text(
                      'Total Prestasi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$totalAchievements',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Berdasarkan Jenis',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                ...AchievementType.values.map((type) {
                  final count = countByType[type] ?? 0;
                  final percentage =
                      totalAchievements > 0
                          ? (count / totalAchievements * 100).toStringAsFixed(1)
                          : '0';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _formatEnumValue(type.toString()),
                              style: const TextStyle(fontSize: 14),
                            ),
                            const Spacer(),
                            Text(
                              '$count ($percentage%)',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value:
                              totalAchievements > 0
                                  ? count / totalAchievements
                                  : 0,
                          backgroundColor: Colors.grey[200],
                          color: _getColorForType(type),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Berdasarkan Tingkat',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                ...AchievementLevel.values.map((level) {
                  final count = countByLevel[level] ?? 0;
                  final percentage =
                      totalAchievements > 0
                          ? (count / totalAchievements * 100).toStringAsFixed(1)
                          : '0';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _formatEnumValue(level.toString()),
                              style: const TextStyle(fontSize: 14),
                            ),
                            const Spacer(),
                            Text(
                              '$count ($percentage%)',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value:
                              totalAchievements > 0
                                  ? count / totalAchievements
                                  : 0,
                          backgroundColor: Colors.grey[200],
                          color: _getColorForLevel(level),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getColorForType(AchievementType type) {
    switch (type) {
      case AchievementType.academic:
        return Colors.blue;
      case AchievementType.nonAcademic:
        return Colors.purple;
      case AchievementType.sports:
        return Colors.green;
      case AchievementType.arts:
        return Colors.orange;
      case AchievementType.competition:
        return Colors.red;
    }
  }

  Color _getColorForLevel(AchievementLevel level) {
    switch (level) {
      case AchievementLevel.school:
        return Colors.teal;
      case AchievementLevel.city:
        return Colors.amber;
      case AchievementLevel.province:
        return Colors.deepPurple;
      case AchievementLevel.national:
        return Colors.red;
      case AchievementLevel.international:
        return Colors.indigo;
    }
  }

  String _formatEnumValue(String value) {
    final parts = value.split('.');
    if (parts.length < 2) return value;

    final name = parts[1];
    final formattedName = name[0].toUpperCase() + name.substring(1);

    return formattedName;
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final selectedType = ref.watch(achievementTypeFilterProvider);
            final selectedLevel = ref.watch(achievementLevelFilterProvider);

            return StatefulBuilder(
              builder: (context, setState) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter Prestasi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Jenis Prestasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            AchievementType.values.map((type) {
                              final isSelected = selectedType == type;
                              return ChoiceChip(
                                label: Text(_formatEnumValue(type.toString())),
                                selected: isSelected,
                                onSelected: (selected) {
                                  ref
                                      .read(
                                        achievementTypeFilterProvider.notifier,
                                      )
                                      .state = selected ? type : null;
                                },
                                selectedColor: _getColorForType(
                                  type,
                                ).withValues(alpha: 0.2),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Tingkat Prestasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            AchievementLevel.values.map((level) {
                              final isSelected = selectedLevel == level;
                              return ChoiceChip(
                                label: Text(_formatEnumValue(level.toString())),
                                selected: isSelected,
                                onSelected: (selected) {
                                  ref
                                      .read(
                                        achievementLevelFilterProvider.notifier,
                                      )
                                      .state = selected ? level : null;
                                },
                                selectedColor: _getColorForLevel(
                                  level,
                                ).withValues(alpha: 0.2),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                ref
                                    .read(
                                      achievementTypeFilterProvider.notifier,
                                    )
                                    .state = null;
                                ref
                                    .read(
                                      achievementLevelFilterProvider.notifier,
                                    )
                                    .state = null;
                                Navigator.pop(context);
                                _applyFilters();
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Reset'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _applyFilters();
                              },
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Terapkan'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showAddAchievementDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final issuerController = TextEditingController();
    final certificateNumberController = TextEditingController();

    DateTime selectedDate = DateTime.now();
    AchievementType selectedType = AchievementType.academic;
    AchievementLevel selectedLevel = AchievementLevel.school;
    String? certificateFile;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Tambah Prestasi Baru'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Judul Prestasi',
                          hintText: 'Juara 1 Olimpiade Matematika',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Judul tidak boleh kosong';
                          }
                          if (value.length < 3) {
                            return 'Judul minimal 3 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          hintText: 'Deskripsi prestasi',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Tanggal'),
                        subtitle: Text(
                          DateFormat('dd MMMM yyyy').format(selectedDate),
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<AchievementType>(
                        value: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Jenis Prestasi',
                        ),
                        items:
                            AchievementType.values.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(_formatEnumValue(type.toString())),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedType = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<AchievementLevel>(
                        value: selectedLevel,
                        decoration: const InputDecoration(
                          labelText: 'Tingkat Prestasi',
                        ),
                        items:
                            AchievementLevel.values.map((level) {
                              return DropdownMenuItem(
                                value: level,
                                child: Text(_formatEnumValue(level.toString())),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedLevel = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: issuerController,
                        decoration: const InputDecoration(
                          labelText: 'Lembaga Pemberi',
                          hintText: 'Dinas Pendidikan Kota',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lembaga pemberi tidak boleh kosong';
                          }
                          if (value.length < 3) {
                            return 'Lembaga pemberi minimal 3 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: certificateNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Nomor Sertifikat',
                          hintText: 'CERT-2023-001',
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Upload Sertifikat'),
                        subtitle: Text(
                          certificateFile ?? 'Belum ada file dipilih',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.upload_file),
                        onTap: () async {
                          final result = await FilePicker.platform.pickFiles();
                          if (result != null) {
                            setState(() {
                              certificateFile = result.files.single.name;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final newAchievement = Achievement(
                        title: titleController.text,
                        description: descriptionController.text,
                        date: selectedDate,
                        issuer: issuerController.text,
                        certificateNumber: certificateNumberController.text,
                        certificateFile: certificateFile,
                        achievementLevel: selectedLevel,
                        achievementType: selectedType,
                        studentId: 1, // Assuming for current student
                        schoolId: 1, // Assuming for current school
                      );

                      ref
                          .read(achievementsProvider.notifier)
                          .createAchievement(newAchievement);
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Prestasi berhasil ditambahkan'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class AchievementCard extends ConsumerWidget {
  final Achievement achievement;

  const AchievementCard({Key? key, required this.achievement})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          _showAchievementDetails(context, achievement);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTypeChip(achievement.achievementType),
                  const SizedBox(width: 8),
                  _buildLevelChip(achievement.achievementLevel),
                  const Spacer(),
                  PopupMenuButton<String>(
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Hapus',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        // Handle edit
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, ref);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                achievement.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (achievement.description.isNotEmpty) ...[
                Text(
                  achievement.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd MMMM yyyy').format(achievement.date),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.business, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      achievement.issuer,
                      style: TextStyle(color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(AchievementType type) {
    Color chipColor;
    switch (type) {
      case AchievementType.academic:
        chipColor = Colors.blue;
        break;
      case AchievementType.nonAcademic:
        chipColor = Colors.purple;
        break;
      case AchievementType.sports:
        chipColor = Colors.green;
        break;
      case AchievementType.arts:
        chipColor = Colors.orange;
        break;
      case AchievementType.competition:
        chipColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        _formatEnumValue(type.toString()),
        style: TextStyle(
          fontSize: 12,
          color: chipColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLevelChip(AchievementLevel level) {
    Color chipColor;
    switch (level) {
      case AchievementLevel.school:
        chipColor = Colors.teal;
        break;
      case AchievementLevel.city:
        chipColor = Colors.amber;
        break;
      case AchievementLevel.province:
        chipColor = Colors.deepPurple;
        break;
      case AchievementLevel.national:
        chipColor = Colors.red;
        break;
      case AchievementLevel.international:
        chipColor = Colors.indigo;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        _formatEnumValue(level.toString()),
        style: TextStyle(
          fontSize: 12,
          color: chipColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatEnumValue(String value) {
    final parts = value.split('.');
    if (parts.length < 2) return value;

    final name = parts[1];
    final formattedName = name[0].toUpperCase() + name.substring(1);

    return formattedName;
  }

  void _showAchievementDetails(BuildContext context, Achievement achievement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    achievement.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildTypeChip(achievement.achievementType),
                      const SizedBox(width: 8),
                      _buildLevelChip(achievement.achievementLevel),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Deskripsi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    achievement.description.isNotEmpty
                        ? achievement.description
                        : 'Tidak ada deskripsi',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Informasi Detail',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Tanggal',
                    DateFormat('dd MMMM yyyy').format(achievement.date),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.business,
                    'Lembaga Pemberi',
                    achievement.issuer,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.badge,
                    'Nomor Sertifikat',
                    achievement.certificateNumber.isNotEmpty
                        ? achievement.certificateNumber
                        : 'Tidak ada nomor sertifikat',
                  ),
                  if (achievement.certificateFile != null) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Dokumen Sertifikat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.insert_drive_file,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  achievement.certificateFile!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () {
                              // Download file logic here
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            // Edit achievement
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.share),
                          label: const Text('Bagikan'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            // Share achievement
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Prestasi'),
          content: Text(
            'Apakah Anda yakin ingin menghapus prestasi "${achievement.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                if (achievement.id != null) {
                  ref
                      .read(achievementsProvider.notifier)
                      .deleteAchievement(achievement.id!);
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Prestasi berhasil dihapus'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: FilledButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}

// Main entry point for the app
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prestasi Siswa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
      home: const AchievementsScreen(),
    );
  }
}
