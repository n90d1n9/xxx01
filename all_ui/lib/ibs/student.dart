import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

// Models
class School {
  final String id;
  final String name;
  final String? address;
  final String? phoneNumber;
  final String? email;
  final String? website;

  School({
    required this.id,
    required this.name,
    this.address,
    this.phoneNumber,
    this.email,
    this.website,
  });
}

class Student {
  final String id;
  final String firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? contactNumber;
  final String? email;
  final String? address;
  final String? parentName;
  final String? parentContact;
  final String? enrollmentDate;
  final String? profileImageUrl;
  final School? school;

  Student({
    required this.id,
    required this.firstName,

    this.lastName,
    this.dateOfBirth,
    this.gender,
    this.contactNumber,
    this.email,
    this.address,
    this.parentName,
    this.parentContact,
    this.enrollmentDate,
    this.profileImageUrl,
    required this.school,
  });

  String get fullName => '$firstName $lastName';
  int get age => DateTime.now().difference(dateOfBirth!).inDays ~/ 365;
}

class AcademicRecord {
  final String id;
  final String semester;
  final String year;
  final List<Subject> subjects;
  final double gpa;

  AcademicRecord({
    required this.id,
    required this.semester,
    required this.year,
    required this.subjects,
    required this.gpa,
  });
}

class Subject {
  final String name;
  final String grade;
  final int score;

  Subject({required this.name, required this.grade, required this.score});
}

class QuranProgress {
  final String id;
  final int surahNumber;
  final String surahName;
  final int ayahFrom;
  final int ayahTo;
  final int memorizedVerses;
  final int totalVerses;
  final DateTime lastUpdated;

  QuranProgress({
    required this.id,
    required this.surahNumber,
    required this.surahName,
    required this.ayahFrom,
    required this.ayahTo,
    required this.memorizedVerses,
    required this.totalVerses,
    required this.lastUpdated,
  });

  double get progressPercentage => memorizedVerses / totalVerses;
}

class Payment {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String status;
  final String paymentMethod;

  Payment({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.status,
    required this.paymentMethod,
  });
}

class Attendance {
  final String id;
  final DateTime date;
  final bool present;
  final String? reason;

  Attendance({
    required this.id,
    required this.date,
    required this.present,
    this.reason,
  });
}

class HealthRecord {
  final String id;
  final String condition;
  final String severity;
  final DateTime recordedDate;
  final String treatment;
  final String notes;

  HealthRecord({
    required this.id,
    required this.condition,
    required this.severity,
    required this.recordedDate,
    required this.treatment,
    required this.notes,
  });
}

class DisciplinaryRecord {
  final String id;
  final String incident;
  final DateTime date;
  final String action;
  final String notes;

  DisciplinaryRecord({
    required this.id,
    required this.incident,
    required this.date,
    required this.action,
    required this.notes,
  });
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String category;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
  });
}

// StudentDetailScreen Widget
class StudentDetailScreen extends StatefulWidget {
  final Student student;
  final List<AcademicRecord> academicRecords;
  final List<QuranProgress> quranProgress;
  final List<Payment> payments;
  final List<Attendance> attendance;
  final List<HealthRecord> healthRecords;
  final List<DisciplinaryRecord> disciplinaryRecords;
  final List<Achievement> achievements;

  const StudentDetailScreen({
    Key? key,
    required this.student,
    required this.academicRecords,
    required this.quranProgress,
    required this.payments,
    required this.attendance,
    required this.healthRecords,
    required this.disciplinaryRecords,
    required this.achievements,
  }) : super(key: key);

  @override
  _StudentDetailScreenState createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 260,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Theme.of(context).primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeaderBackground(),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(100),
                child: Container(
                  color: Colors.white,
                  child: _buildStudentInfo(),
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.edit_rounded, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.more_vert_rounded, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).primaryColor,
                  tabs: [
                    Tab(text: "Academic"),
                    Tab(text: "Quran"),
                    Tab(text: "Payments"),
                    Tab(text: "Attendance"),
                    Tab(text: "Health"),
                    Tab(text: "Discipline"),
                    Tab(text: "Achievements"),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAcademicTab(),
            _buildQuranTab(),
            _buildPaymentsTab(),
            _buildAttendanceTab(),
            _buildHealthTab(),
            _buildDisciplineTab(),
            _buildAchievementsTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.message_rounded),
        onPressed: () {},
      ),
    );
  }

  Widget _buildHeaderBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
        Positioned(
          top: 80,
          left: 0,
          right: 0,
          child: Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    widget.student.profileImageUrl!,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  widget.student.fullName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "ID: ${widget.student.id}",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _infoColumn("Age", "${widget.student.age} years"),
          _infoColumn("Class", "Grade 8"),
          _infoColumn("School", widget.student.school!.name),
          _infoColumn("Joined", widget.student.enrollmentDate!),
        ],
      ),
    );
  }

  Widget _infoColumn(String title, String value) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Colors.grey, fontSize: 12)),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildAcademicTab() {
    if (widget.academicRecords.isEmpty) {
      return _buildEmptyState("No academic records found");
    }

    final latestRecord = widget.academicRecords.first;

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${latestRecord.semester} ${latestRecord.year}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "GPA: ${latestRecord.gpa.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ...latestRecord.subjects.map(
                  (subject) => _buildSubjectCard(subject),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        _buildSectionTitle("Previous Semesters"),
        ...widget.academicRecords
            .skip(1)
            .map((record) => _buildPreviousSemesterCard(record)),
      ],
    );
  }

  Widget _buildSubjectCard(Subject subject) {
    Color gradeColor;
    if (subject.grade == 'A' || subject.grade == 'A+') {
      gradeColor = Colors.green;
    } else if (subject.grade == 'B' || subject.grade == 'B+') {
      gradeColor = Colors.blue;
    } else if (subject.grade == 'C' || subject.grade == 'C+') {
      gradeColor = Colors.orange;
    } else {
      gradeColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(subject.name, style: TextStyle(fontWeight: FontWeight.w500)),
            Row(
              children: [
                Text(
                  "${subject.score}/100",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(width: 12),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: gradeColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      subject.grade,
                      style: TextStyle(
                        color: gradeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousSemesterCard(AcademicRecord record) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        title: Text(
          "${record.semester} ${record.year}",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text("${record.subjects.length} subjects"),
        trailing: Text(
          "GPA: ${record.gpa.toStringAsFixed(2)}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildQuranTab() {
    if (widget.quranProgress.isEmpty) {
      return _buildEmptyState("No Quran progress records found");
    }

    // Calculate overall progress
    int totalMemorized = widget.quranProgress.fold(
      0,
      (sum, progress) => sum + progress.memorizedVerses,
    );
    int totalVerses = widget.quranProgress.fold(
      0,
      (sum, progress) => sum + progress.totalVerses,
    );
    double overallProgress = totalMemorized / totalVerses;

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Overall Progress",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                CircularPercentIndicator(
                  radius: 80.0,
                  lineWidth: 12.0,
                  animation: true,
                  percent: overallProgress,
                  center: Text(
                    "${(overallProgress * 100).toStringAsFixed(1)}%",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withValues(alpha: 0.2),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statColumn("Memorized", "$totalMemorized verses"),
                    _statColumn("Total", "$totalVerses verses"),
                    _statColumn(
                      "Remaining",
                      "${totalVerses - totalMemorized} verses",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        _buildSectionTitle("Recent Progress"),
        ...widget.quranProgress.map(
          (progress) => _buildQuranProgressCard(progress),
        ),
      ],
    );
  }

  Widget _buildQuranProgressCard(QuranProgress progress) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Surah ${progress.surahNumber}: ${progress.surahName}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  DateFormat('MMM d, yyyy').format(progress.lastUpdated),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              "Ayah ${progress.ayahFrom} to ${progress.ayahTo}",
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress.progressPercentage,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "${progress.memorizedVerses}/${progress.totalVerses} verses (${(progress.progressPercentage * 100).toStringAsFixed(1)}%)",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsTab() {
    if (widget.payments.isEmpty) {
      return _buildEmptyState("No payment records found");
    }

    // Calculate total paid and due
    double totalPaid = widget.payments
        .where((payment) => payment.status == "Paid")
        .fold(0, (sum, payment) => sum + payment.amount);

    double totalDue = widget.payments
        .where((payment) => payment.status == "Due")
        .fold(0, (sum, payment) => sum + payment.amount);

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                "Total Paid",
                "\$${totalPaid.toStringAsFixed(2)}",
                Colors.green,
                Icons.check_circle_outline,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                "Due Amount",
                "\$${totalDue.toStringAsFixed(2)}",
                Colors.red,
                Icons.warning_amber_rounded,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        _buildSectionTitle("Recent Transactions"),
        ...widget.payments.map((payment) => _buildPaymentCard(payment)),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    IconData icon;
    Color statusColor;

    if (payment.status == "Paid") {
      icon = Icons.check_circle;
      statusColor = Colors.green;
    } else if (payment.status == "Due") {
      icon = Icons.schedule;
      statusColor = Colors.orange;
    } else {
      icon = Icons.error_outline;
      statusColor = Colors.red;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.receipt_long,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          payment.description,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          DateFormat('MMM d, yyyy').format(payment.date),
          style: TextStyle(fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "\$${payment.amount.toStringAsFixed(2)}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: statusColor, size: 12),
                SizedBox(width: 4),
                Text(
                  payment.status,
                  style: TextStyle(color: statusColor, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceTab() {
    if (widget.attendance.isEmpty) {
      return _buildEmptyState("No attendance records found");
    }

    // Calculate attendance rate
    int totalDays = widget.attendance.length;
    int presentDays = widget.attendance.where((a) => a.present).length;
    double attendanceRate = presentDays / totalDays;

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Attendance Summary",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                CircularPercentIndicator(
                  radius: 80.0,
                  lineWidth: 12.0,
                  animation: true,
                  percent: attendanceRate,
                  center: Text(
                    "${(attendanceRate * 100).toStringAsFixed(1)}%",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor:
                      attendanceRate > 0.9
                          ? Colors.green
                          : attendanceRate > 0.8
                          ? Colors.orange
                          : Colors.red,
                  backgroundColor: Colors.grey[200]!,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statColumn("Present", "$presentDays days"),
                    _statColumn("Absent", "${totalDays - presentDays} days"),
                    _statColumn("Total", "$totalDays days"),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        _buildSectionTitle("Recent Attendance"),
        ...widget.attendance.map((record) => _buildAttendanceCard(record)),
      ],
    );
  }

  Widget _buildAttendanceCard(Attendance record) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                record.present
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            record.present ? Icons.check : Icons.close,
            color: record.present ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          DateFormat('EEEE, MMM d, yyyy').format(record.date),
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle:
            record.present
                ? Text("Present")
                : Text(
                  "Absent: ${record.reason ?? 'No reason provided'}",
                  style: TextStyle(color: Colors.red[700]),
                ),
      ),
    );
  }

  Widget _buildHealthTab() {
    if (widget.healthRecords.isEmpty) {
      return _buildEmptyState("No health records found");
    }

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildSectionTitle("Health Records"),
        ...widget.healthRecords.map((record) => _buildHealthCard(record)),
      ],
    );
  }

  Widget _buildHealthCard(HealthRecord record) {
    Color severityColor;
    if (record.severity == "High") {
      severityColor = Colors.red;
    } else if (record.severity == "Medium") {
      severityColor = Colors.orange;
    } else {
      severityColor = Colors.green;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  record.condition,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    record.severity,
                    style: TextStyle(
                      color: severityColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, yyyy').format(record.recordedDate),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              "Treatment: ${record.treatment}",
              style: TextStyle(color: Colors.grey[800]),
            ),
            SizedBox(height: 8),
            if (record.notes.isNotEmpty)
              Text(
                "Notes: ${record.notes}",
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisciplineTab() {
    if (widget.disciplinaryRecords.isEmpty) {
      return _buildEmptyState("No disciplinary records found");
    }

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildSectionTitle("Disciplinary Records"),
        ...widget.disciplinaryRecords.map(
          (record) => _buildDisciplinaryCard(record),
        ),
      ],
    );
  }

  Widget _buildDisciplinaryCard(DisciplinaryRecord record) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    record.incident,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Text(
                  DateFormat('MMM d, yyyy').format(record.date),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Action: ${record.action}",
                style: TextStyle(color: Colors.amber[800], fontSize: 13),
              ),
            ),
            SizedBox(height: 12),
            if (record.notes.isNotEmpty)
              Text(
                "Notes: ${record.notes}",
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsTab() {
    if (widget.achievements.isEmpty) {
      return _buildEmptyState("No achievements recorded yet");
    }

    // Group achievements by category
    Map<String, List<Achievement>> categorizedAchievements = {};
    for (var achievement in widget.achievements) {
      if (!categorizedAchievements.containsKey(achievement.category)) {
        categorizedAchievements[achievement.category] = [];
      }
      categorizedAchievements[achievement.category]!.add(achievement);
    }

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildSectionTitle("Student Achievements"),
        ...categorizedAchievements.entries.map(
          (entry) => _buildAchievementCategory(entry.key, entry.value),
        ),
      ],
    );
  }

  Widget _buildAchievementCategory(
    String category,
    List<Achievement> achievements,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            category,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ),
        ...achievements.map(
          (achievement) => _buildAchievementCard(achievement),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    IconData iconData;
    switch (achievement.category) {
      case "Academic":
        iconData = Icons.school;
        break;
      case "Sports":
        iconData = Icons.sports;
        break;
      case "Arts":
        iconData = Icons.palette;
        break;
      case "Leadership":
        iconData = Icons.emoji_events;
        break;
      default:
        iconData = Icons.star;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(iconData, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          achievement.title,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.description, style: TextStyle(fontSize: 13)),
            SizedBox(height: 4),
            Text(
              DateFormat('MMM d, yyyy').format(achievement.date),
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _statColumn(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 4),
        Text(title, style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 60, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}

void main(List<String> args) {
  runApp(
    MaterialApp(
      home: StudentDetailScreen(
        student: Student(
          dateOfBirth: DateTime(2000),
          id: "12345",
          firstName: "John Doe",
          //age: 15,
          profileImageUrl: "https://example.com/profile.jpg",
          enrollmentDate: "2021-09-01",
          school: School(id: '1', name: "ABC International School"),
        ),
        academicRecords: [],
        quranProgress: [],
        payments: [],
        attendance: [],
        healthRecords: [],
        disciplinaryRecords: [],
        achievements: [],
      ),
    ),
  );
}
