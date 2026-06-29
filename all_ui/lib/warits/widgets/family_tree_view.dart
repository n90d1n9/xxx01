import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphview/GraphView.dart';

import '../models/family_state.dart';
import '../states/family_provider.dart';
import 'member_node_widget.dart';

class FamilyTreeView extends ConsumerStatefulWidget {
  final FamilyState familyState;

  const FamilyTreeView({super.key, required this.familyState});

  @override
  ConsumerState<FamilyTreeView> createState() => _FamilyTreeViewState();
}

class _FamilyTreeViewState extends ConsumerState<FamilyTreeView> {
  final Graph graph = Graph();
  final BuchheimWalkerConfiguration builder =
      BuchheimWalkerConfiguration()
        ..siblingSeparation = 60
        ..levelSeparation = 100
        ..subtreeSeparation = 120
        ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;

  @override
  void didUpdateWidget(FamilyTreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.familyState != widget.familyState) {
      _buildGraph();
    }
  }

  @override
  void initState() {
    super.initState();
    _buildGraph();
  }

  void _buildGraph() {
    graph.nodes.clear();
    graph.edges.clear();

    final nodeMap = <String, Node>{};

    for (final member in widget.familyState.members.values) {
      final node = Node.Id(member.id);
      nodeMap[member.id] = node;
      graph.addNode(node);
    }

    for (final relation in widget.familyState.relations) {
      final fromNode = nodeMap[relation.fromId];
      final toNode = nodeMap[relation.toId];

      if (fromNode != null && toNode != null) {
        graph.addEdge(fromNode, toNode);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.familyState.members.isEmpty) {
      return const Center(child: Text('No members to display'));
    }

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(200),
      minScale: 0.1,
      maxScale: 5.0,
      child: GraphView(
        graph: graph,
        algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
        paint:
            Paint()
              ..color = Colors.teal
              ..strokeWidth = 2
              ..style = PaintingStyle.stroke,
        builder: (Node node) {
          final memberId = node.key?.value as String;
          final member = widget.familyState.members[memberId];

          if (member == null) return const SizedBox();

          return MemberNodeWidget(
            member: member,
            isSelected: widget.familyState.selectedMemberId == memberId,
            hasInheritance:
                widget.familyState.inheritanceData?.containsKey(memberId) ??
                false,
            onTap: () {
              ref.read(familyProvider.notifier).selectMember(memberId);
            },
          );
        },
      ),
    );
  }
}
