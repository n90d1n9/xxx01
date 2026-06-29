import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project.dart';
import 'boq_tab.dart';
import 'budget_tab.dart';
import 'project_info_tab.dart';
import 'scheduled_tab.dart';

class ProjectDetailPage extends ConsumerStatefulWidget {
  final Project project;

  const ProjectDetailPage({super.key, required this.project});

  @override
  ConsumerState<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends ConsumerState<ProjectDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.nama),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'Info'),
            Tab(icon: Icon(Icons.list_alt), text: 'BoQ'),
            Tab(icon: Icon(Icons.attach_money), text: 'Budget'),
            Tab(icon: Icon(Icons.schedule), text: 'Jadwal'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ProjectInfoTab(project: widget.project),
          BoQTab(project: widget.project),
          BudgetTab(project: widget.project),
          ScheduleTab(project: widget.project),
        ],
      ),
    );
  }
}
