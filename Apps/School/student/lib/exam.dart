import 'package:flutter/material.dart';

enum ParticipationLevel { Leader, Active, Regular }

class ExtracurricularProgressScreen extends StatefulWidget {
  const ExtracurricularProgressScreen({super.key});

  @override
  _ExtracurricularProgressScreenState createState() =>
      _ExtracurricularProgressScreenState();
}

class _ExtracurricularProgressScreenState
    extends State<ExtracurricularProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _progressIdController = TextEditingController();
  final _activityNameController = TextEditingController();
  final _periodController = TextEditingController();
  ParticipationLevel _selectedLevel = ParticipationLevel.Regular;
  final _skillsController = TextEditingController();
  final _achievementsController = TextEditingController();
  final _competitionController = TextEditingController();
  final _attendanceController = TextEditingController();
  final _contributionController = TextEditingController();
  final _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _progressIdController.dispose();
    _activityNameController.dispose();
    _periodController.dispose();
    _skillsController.dispose();
    _achievementsController.dispose();
    _competitionController.dispose();
    _attendanceController.dispose();
    _contributionController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Extracurricular Progress'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.edit), text: 'Input'),
            Tab(icon: Icon(Icons.view_list), text: 'View'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInputForm(),
          _buildProgressView(),
        ],
      ),
    );
  }

  Widget _buildInputForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Basic Information',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _progressIdController,
                      decoration: InputDecoration(
                        labelText: 'Progress ID',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.tag),
                      ),
                      validator: (value) {
                        if (value?.length != 10) {
                          return 'Progress ID must be exactly 10 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _activityNameController,
                      decoration: InputDecoration(
                        labelText: 'Activity Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.sports),
                      ),
                      validator: (value) {
                        if (value!.length < 3 || value.length > 50) {
                          return 'Activity name must be between 3 and 50 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Participation Details',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<ParticipationLevel>(
                      value: _selectedLevel,
                      decoration: InputDecoration(
                        labelText: 'Participation Level',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.star),
                      ),
                      items: ParticipationLevel.values.map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(level.toString().split('.').last),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLevel = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _attendanceController,
                      decoration: InputDecoration(
                        labelText: 'Attendance (%)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter attendance';
                        final attendance = double.tryParse(value);
                        if (attendance == null ||
                            attendance < 0 ||
                            attendance > 100) {
                          return 'Enter valid attendance percentage';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Achievements & Feedback',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _skillsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Skills Developed',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.psychology),
                      ),
                      validator: (value) {
                        if (value!.length > 200) {
                          return 'Skills description cannot exceed 200 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _achievementsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Achievements',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.emoji_events),
                      ),
                      validator: (value) {
                        if (value!.length > 200) {
                          return 'Achievements cannot exceed 200 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text('Save Progress'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Save logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Progress saved successfully!')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressView() {
    // Sample data for viewing
    Map<String, dynamic> progress = {
      'progressId': 'PROG123456',
      'activityName': 'Chess Club',
      'period': '2023-2024',
      'participationLevel': ParticipationLevel.Leader,
      'attendance': 95.5,
      'skillsDeveloped': 'Strategic thinking, patience, problem-solving',
      'achievements': '1st place in inter-school championship',
    };

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.sports, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        progress['activityName']!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow('Progress ID', progress['progressId']!),
                      _buildInfoRow('Period', progress['period']!),
                      _buildInfoRow(
                          'Participation',
                          progress['participationLevel']
                              .toString()
                              .split('.')
                              .last),
                      _buildInfoRow('Attendance', '${progress['attendance']}%'),
                      _buildInfoRow('Skills', progress['skillsDeveloped']!),
                      _buildInfoRow('Achievements', progress['achievements']!),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
