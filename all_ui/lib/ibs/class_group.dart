import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Models
class Teacher {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final List<String> subjects;

  Teacher({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.subjects,
  });
}

class Subject {
  final String id;
  final String name;
  final String code;
  final Color color;

  Subject({
    required this.id,
    required this.name,
    required this.code,
    required this.color,
  });
}

class Student {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final List<String> enrolledSubjects;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.enrolledSubjects,
  });
}

class ClassGroup {
  final String id;
  final String name;
  final String teacherId;
  final List<String> studentIds;
  final String subjectId;
  final String schedule;
  final DateTime startDate;
  final DateTime endDate;

  ClassGroup({
    required this.id,
    required this.name,
    required this.teacherId,
    required this.studentIds,
    required this.subjectId,
    required this.schedule,
    required this.startDate,
    required this.endDate,
  });
}

// Providers
final classGroupsProvider =
    StateNotifierProvider<ClassGroupsNotifier, List<ClassGroup>>((ref) {
      return ClassGroupsNotifier();
    });

final teachersProvider = StateNotifierProvider<TeachersNotifier, List<Teacher>>(
  (ref) {
    return TeachersNotifier();
  },
);

final studentsProvider = StateNotifierProvider<StudentsNotifier, List<Student>>(
  (ref) {
    return StudentsNotifier();
  },
);

final subjectsProvider = StateNotifierProvider<SubjectsNotifier, List<Subject>>(
  (ref) {
    return SubjectsNotifier();
  },
);

// Selected Class Group Provider
final selectedClassGroupIdProvider = StateProvider<String?>((ref) => null);

final selectedClassGroupProvider = Provider<ClassGroup?>((ref) {
  final classGroups = ref.watch(classGroupsProvider);
  final selectedId = ref.watch(selectedClassGroupIdProvider);

  if (selectedId == null) return null;

  return classGroups.firstWhere(
    (classGroup) => classGroup.id == selectedId,
    orElse: () => throw Exception('Class group not found'),
  );
});

// Notifiers
class ClassGroupsNotifier extends StateNotifier<List<ClassGroup>> {
  ClassGroupsNotifier()
    : super([
        ClassGroup(
          id: '1',
          name: 'Physics 101',
          teacherId: '1',
          studentIds: ['1', '2', '3', '4', '5'],
          subjectId: '1',
          schedule: 'Mon, Wed, Fri - 10:00 AM',
          startDate: DateTime(2025, 1, 15),
          endDate: DateTime(2025, 5, 30),
        ),
        ClassGroup(
          id: '2',
          name: 'Advanced Mathematics',
          teacherId: '2',
          studentIds: ['2', '3', '6', '7'],
          subjectId: '2',
          schedule: 'Tue, Thu - 2:00 PM',
          startDate: DateTime(2025, 1, 16),
          endDate: DateTime(2025, 5, 25),
        ),
        ClassGroup(
          id: '3',
          name: 'Computer Science 202',
          teacherId: '3',
          studentIds: ['1', '4', '5', '8'],
          subjectId: '3',
          schedule: 'Mon, Wed - 3:30 PM',
          startDate: DateTime(2025, 1, 14),
          endDate: DateTime(2025, 5, 27),
        ),
      ]);

  void addClassGroup(ClassGroup classGroup) {
    state = [...state, classGroup];
  }

  void removeClassGroup(String id) {
    state = state.where((classGroup) => classGroup.id != id).toList();
  }

  void updateClassGroup(ClassGroup updatedClassGroup) {
    state =
        state
            .map(
              (classGroup) =>
                  classGroup.id == updatedClassGroup.id
                      ? updatedClassGroup
                      : classGroup,
            )
            .toList();
  }
}

class TeachersNotifier extends StateNotifier<List<Teacher>> {
  TeachersNotifier()
    : super([
        Teacher(
          id: '1',
          name: 'Dr. Sarah Johnson',
          email: 'sarah.johnson@example.edu',
          photoUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
          subjects: ['1', '2'],
        ),
        Teacher(
          id: '2',
          name: 'Prof. James Smith',
          email: 'james.smith@example.edu',
          photoUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
          subjects: ['2'],
        ),
        Teacher(
          id: '3',
          name: 'Dr. Michael Chen',
          email: 'michael.chen@example.edu',
          photoUrl: 'https://randomuser.me/api/portraits/men/22.jpg',
          subjects: ['3'],
        ),
      ]);
}

class StudentsNotifier extends StateNotifier<List<Student>> {
  StudentsNotifier()
    : super([
        Student(
          id: '1',
          name: 'Emma Wilson',
          email: 'emma.w@example.edu',
          photoUrl: 'https://randomuser.me/api/portraits/women/17.jpg',
          enrolledSubjects: ['1', '3'],
        ),
        Student(
          id: '2',
          name: 'David Lee',
          email: 'david.l@example.edu',
          photoUrl: 'https://randomuser.me/api/portraits/men/91.jpg',
          enrolledSubjects: ['1', '2'],
        ),
        Student(
          id: '3',
          name: 'Olivia Martinez',
          email: 'olivia.m@example.edu',
          photoUrl: 'https://randomuser.me/api/portraits/women/62.jpg',
          enrolledSubjects: ['1', '2'],
        ),
        Student(
          id: '4',
          name: 'Ethan Johnson',
          email: 'ethan.j@example.edu',
          photoUrl: 'https://randomuser.me/api/portraits/men/55.jpg',
          enrolledSubjects: ['1', '3'],
        ),
        Student(
          id: '5',
          name: 'Sophia Wang',
          email: 'sophia.w@example.edu',
          photoUrl: 'https://randomuser.me/api/portraits/women/28.jpg',
          enrolledSubjects: ['1', '3'],
        ),
        Student(
          id: '6',
          name: 'Noah Garcia',
          email: 'noah.g@example.edu',
          photoUrl: 'https://randomuser.me/api/portraits/men/75.jpg',
          enrolledSubjects: ['2'],
        ),
        Student(
          id: '7',
          name: 'Ava Thompson',
          email: 'ava.t@example.edu',
          photoUrl: 'https://randomuser.me/api/portraits/women/35.jpg',
          enrolledSubjects: ['2'],
        ),
        Student(
          id: '8',
          name: 'Liam Brown',
          email: 'liam.b@example.edu',
          photoUrl: 'https://randomuser.me/api/portraits/men/24.jpg',
          enrolledSubjects: ['3'],
        ),
      ]);
}

class SubjectsNotifier extends StateNotifier<List<Subject>> {
  SubjectsNotifier()
    : super([
        Subject(
          id: '1',
          name: 'Physics',
          code: 'PHY101',
          color: Color(0xFF5C6BC0),
        ),
        Subject(
          id: '2',
          name: 'Mathematics',
          code: 'MTH202',
          color: Color(0xFF66BB6A),
        ),
        Subject(
          id: '3',
          name: 'Computer Science',
          code: 'CS202',
          color: Color(0xFFEF5350),
        ),
      ]);
}

// UI
class ClassGroupScreen extends ConsumerWidget {
  const ClassGroupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allClassGroups = ref.watch(classGroupsProvider);
    final selectedClassGroupId = ref.watch(selectedClassGroupIdProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Class Groups',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open add class group dialog
        },
        backgroundColor: Color(0xFF6200EE),
        child: Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'Your Class Groups',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12),
              itemCount: allClassGroups.length,
              itemBuilder: (context, index) {
                final classGroup = allClassGroups[index];
                final subject = ref
                    .watch(subjectsProvider)
                    .firstWhere(
                      (subject) => subject.id == classGroup.subjectId,
                    );
                final teacher = ref
                    .watch(teachersProvider)
                    .firstWhere(
                      (teacher) => teacher.id == classGroup.teacherId,
                    );

                return GestureDetector(
                  onTap: () {
                    ref.read(selectedClassGroupIdProvider.notifier).state =
                        classGroup.id;
                  },
                  child: Container(
                    width: 220,
                    margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: subject.color.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color:
                            selectedClassGroupId == classGroup.id
                                ? subject.color
                                : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: subject.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  subject.code,
                                  style: TextStyle(
                                    color: subject.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.people,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${classGroup.studentIds.length}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            classGroup.name,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            teacher.name,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child:
                selectedClassGroupId == null
                    ? _buildEmptyState()
                    : _buildClassGroupDetails(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.class_, size: 72, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Select a class group to view details',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildClassGroupDetails(BuildContext context, WidgetRef ref) {
    final classGroup = ref.watch(selectedClassGroupProvider);
    if (classGroup == null) return SizedBox.shrink();

    final subject = ref
        .watch(subjectsProvider)
        .firstWhere((subject) => subject.id == classGroup.subjectId);

    final teacher = ref
        .watch(teachersProvider)
        .firstWhere((teacher) => teacher.id == classGroup.teacherId);

    final students =
        ref
            .watch(studentsProvider)
            .where((student) => classGroup.studentIds.contains(student.id))
            .toList();

    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    classGroup.name,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(icon: Icon(Icons.edit_outlined), onPressed: () {}),
                IconButton(icon: Icon(Icons.delete_outline), onPressed: () {}),
              ],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: subject.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    subject.name,
                    style: TextStyle(
                      color: subject.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  classGroup.schedule,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(teacher.photoUrl),
                ),
                SizedBox(width: 8),
                Text(
                  teacher.name,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 4),
                Text(
                  '(Teacher)',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          TabBar(
            labelColor: Color(0xFF6200EE),
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Color(0xFF6200EE),
            tabs: [
              Tab(text: 'Students'),
              Tab(text: 'Schedule'),
              Tab(text: 'Materials'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildStudentsList(students),
                _buildScheduleTab(classGroup),
                _buildMaterialsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList(List<Student> students) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(student.photoUrl),
            ),
            title: Text(
              student.name,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(student.email),
            trailing: IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
          ),
        );
      },
    );
  }

  Widget _buildScheduleTab(ClassGroup classGroup) {
    final formattedStart = DateFormat(
      'MMM d, yyyy',
    ).format(classGroup.startDate);
    final formattedEnd = DateFormat('MMM d, yyyy').format(classGroup.endDate);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[200]!),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Class Schedule',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Colors.grey[700],
                      ),
                      SizedBox(width: 8),
                      Text(
                        classGroup.schedule,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.date_range, size: 18, color: Colors.grey[700]),
                      SizedBox(width: 8),
                      Text(
                        '$formattedStart - $formattedEnd',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Upcoming Classes',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(0xFF6200EE).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ['Mon', 'Wed', 'Fri'][index],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6200EE),
                            ),
                          ),
                          Text(
                            '${20 + index}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6200EE),
                            ),
                          ),
                        ],
                      ),
                    ),
                    title: Text(
                      'Class ${index + 1}',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text('10:00 AM - 11:30 AM'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsTab() {
    final materials = [
      {
        'title': 'Course Syllabus',
        'type': 'PDF',
        'date': 'Jan 15, 2025',
        'icon': Icons.description,
      },
      {
        'title': 'Lecture Notes - Week 1',
        'type': 'PDF',
        'date': 'Jan 18, 2025',
        'icon': Icons.note,
      },
      {
        'title': 'Assignment 1',
        'type': 'DOCX',
        'date': 'Jan 22, 2025',
        'icon': Icons.assignment,
      },
      {
        'title': 'Lab Instructions',
        'type': 'PDF',
        'date': 'Jan 25, 2025',
        'icon': Icons.science,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Class Materials',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: materials.length,
              itemBuilder: (context, index) {
                final material = materials[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(0xFF6200EE).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        material['icon'] as IconData,
                        color: Color(0xFF6200EE),
                      ),
                    ),
                    title: Text(
                      material['title'] as String,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text('${material['type']} • ${material['date']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.download),
                      onPressed: () {},
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Main entry point
void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        title: 'Class Group Manager',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          fontFamily: 'Poppins',
        ),
        home: ClassGroupScreen(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
