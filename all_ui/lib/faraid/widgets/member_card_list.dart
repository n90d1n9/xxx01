// components/member_cards.dart
import 'package:flutter/material.dart';

import '../models/family_member.dart';
import 'member_card.dart';

class MemberCards extends StatefulWidget {
  final List<FamilyMember> members;
  final String? selectedMemberId;
  final void Function(String?) onSelectMember;
  final void Function(FamilyMember, Offset?) onShowContextMenu;
  final void Function(FamilyMember) onDelete;
  final void Function(FamilyMember) onEdit;
  final void Function(String, Offset) onUpdatePosition;

  const MemberCards({
    super.key,
    required this.members,
    required this.selectedMemberId,
    required this.onSelectMember,
    required this.onShowContextMenu,
    required this.onDelete,
    required this.onEdit,
    required this.onUpdatePosition,
  });

  @override
  State<MemberCards> createState() => _MemberCardsState();
}

class _MemberCardsState extends State<MemberCards> {
  String? _draggedMemberId;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children:
          widget.members.map((member) {
            return _buildMemberCard(member);
          }).toList(),
    );
  }

  Widget _buildMemberCard(FamilyMember member) {
    final isSelected = widget.selectedMemberId == member.id;

    return Positioned(
      left: member.position.dx,
      top: member.position.dy,
      child: GestureDetector(
        onTap: () => widget.onSelectMember(isSelected ? null : member.id),
        onSecondaryTapDown:
            (details) =>
                widget.onShowContextMenu(member, details.globalPosition),
        onLongPress: () => widget.onShowContextMenu(member, null),
        onPanStart: (_) => setState(() => _draggedMemberId = member.id),
        onPanUpdate: (details) {
          if (_draggedMemberId == member.id) {
            widget.onUpdatePosition(member.id, details.delta);
          }
        },
        onPanEnd: (_) => setState(() => _draggedMemberId = null),
        child: AnimatedScale(
          scale:
              isSelected ? 1.1 : (_draggedMemberId == member.id ? 1.05 : 1.0),
          duration: const Duration(milliseconds: 200),
          child: MemberCard(
            member: member,
            isSelected: isSelected,
            isDragging: _draggedMemberId == member.id,
            onDelete: () => widget.onDelete(member),
            onEdit: () => widget.onEdit(member),
          ),
        ),
      ),
    );
  }
}
