import 'package:flutter/material.dart';

import '../models/dashboard_action_detail.dart';
import '../models/dashboard_action_detail_section.dart';
import '../models/dashboard_action_detail_section_progress.dart';
import 'dashboard_action_detail_body_controller.dart';
import 'dashboard_action_detail_section_nav.dart';
import 'dashboard_action_detail_section_stack.dart';

class DashboardActionDetailBody extends StatefulWidget {
  final DashboardActionDetail detail;
  final DashboardActionDetailBodyController? controller;
  final ValueChanged<DashboardActionDetailSectionProgress>?
  onSectionProgressChanged;

  const DashboardActionDetailBody({
    super.key,
    required this.detail,
    this.controller,
    this.onSectionProgressChanged,
  });

  @override
  State<DashboardActionDetailBody> createState() =>
      _DashboardActionDetailBodyState();
}

class _DashboardActionDetailBodyState extends State<DashboardActionDetailBody> {
  final _scrollController = ScrollController();
  final _scrollViewportKey = GlobalKey();
  final _sectionKeys = {
    for (final section in DashboardActionDetailSection.values)
      section: GlobalKey(),
  };
  var _selectedSection = DashboardActionDetailSection.overview;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_syncSelectedSectionWithScroll);
    widget.controller?.addListener(_handleControllerCommand);
  }

  @override
  void didUpdateWidget(covariant DashboardActionDetailBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }

    oldWidget.controller?.removeListener(_handleControllerCommand);
    widget.controller?.addListener(_handleControllerCommand);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerCommand);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DashboardActionDetailSectionNav(sections: _sectionLinks),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            key: _scrollViewportKey,
            controller: _scrollController,
            child: DashboardActionDetailSectionStack(
              detail: widget.detail,
              sectionKey: _sectionKey,
            ),
          ),
        ),
      ],
    );
  }

  List<DashboardActionDetailSectionLink> get _sectionLinks => [
    for (final section in DashboardActionDetailSection.values)
      DashboardActionDetailSectionLink(
        label: section.label,
        icon: section.icon,
        selected: _selectedSection == section,
        onSelected: () => _selectSectionTarget(section),
      ),
  ];

  void _handleControllerCommand() {
    switch (widget.controller?.command) {
      case DashboardActionDetailBodyCommand.returnToOverview:
        _selectSectionTarget(DashboardActionDetailSection.overview);
        break;
      case DashboardActionDetailBodyCommand.goToPreviousSection:
        _selectPreviousSection();
        break;
      case DashboardActionDetailBodyCommand.goToNextSection:
        _selectNextSection();
        break;
      case null:
        return;
    }
  }

  void _selectPreviousSection() {
    final previousSection = _selectedSection.previous;
    if (previousSection == null) {
      return;
    }

    _selectSectionTarget(previousSection);
  }

  void _selectNextSection() {
    final nextSection = _selectedSection.next;
    if (nextSection == null) {
      return;
    }

    _selectSectionTarget(nextSection);
  }

  void _selectSectionTarget(DashboardActionDetailSection section) {
    _setSelectedSection(section);
    _jumpTo(_sectionKey(section));
  }

  void _syncSelectedSectionWithScroll() {
    final viewportBox =
        _scrollViewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (viewportBox == null) {
      return;
    }

    final viewportTop = viewportBox.localToGlobal(Offset.zero).dy;
    final activationOffset = viewportBox.size.height * 0.32;
    var nextSection = DashboardActionDetailSection.overview;

    for (final section in DashboardActionDetailSection.values) {
      final sectionBox =
          _sectionKey(section).currentContext?.findRenderObject() as RenderBox?;
      if (sectionBox == null) {
        continue;
      }

      final sectionTop = sectionBox.localToGlobal(Offset.zero).dy - viewportTop;
      if (sectionTop <= activationOffset) {
        nextSection = section;
      }
    }

    _setSelectedSection(nextSection);
  }

  void _setSelectedSection(DashboardActionDetailSection section) {
    if (!mounted || _selectedSection == section) {
      return;
    }

    setState(() => _selectedSection = section);
    widget.onSectionProgressChanged?.call(section.progress);
  }

  void _jumpTo(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) {
      return;
    }

    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
  }

  GlobalKey _sectionKey(DashboardActionDetailSection section) =>
      _sectionKeys[section]!;
}
