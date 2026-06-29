// components/member_cards.dart
import 'package:flutter/material.dart';

import '../models/family_member.dart';

import '../models/mahram_relationship.dart';
import 'member_card.dart';

class MemberCards extends StatefulWidget {
  final List<FamilyMember> members;
  final String? selectedMemberId;
  final List<MahramRelationship> mahramRelationships;
  final Function(String?) onSelectMember;
  final Function(FamilyMember, Offset?) onShowContextMenu;
  final Function(FamilyMember) onDelete;
  final Function(FamilyMember) onEdit;
  final Function(String, Offset) onUpdatePosition;
  final Function(BuildContext, FamilyMember, List<MahramRelationship>)
  onShowMahramDetails;

  const MemberCards({
    super.key,
    required this.members,
    required this.selectedMemberId,
    required this.mahramRelationships,
    required this.onSelectMember,
    required this.onShowContextMenu,
    required this.onDelete,
    required this.onEdit,
    required this.onUpdatePosition,
    required this.onShowMahramDetails,
  });

  @override
  State<MemberCards> createState() => _MemberCardsState();
}

class _MemberCardsState extends State<MemberCards> {
  String? _draggedMemberId;
  Offset? _dragStartOffset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children:
          widget.members.map((member) {
            return Positioned(
              left: member.position.dx,
              top: member.position.dy,
              child: _buildDraggableMemberCard(member),
            );
          }).toList(),
    );
  }

  Widget _buildDraggableMemberCard(FamilyMember member) {
    final isSelected = widget.selectedMemberId == member.id;
    final isDragging = _draggedMemberId == member.id;

    return GestureDetector(
      onTap: () => widget.onSelectMember(member.id),
      onLongPressStart: (details) {
        widget.onShowContextMenu(member, details.globalPosition);
      },
      onLongPress: () => widget.onShowContextMenu(member, null),
      onSecondaryTapDown:
          (details) => widget.onShowContextMenu(member, details.globalPosition),
      onPanStart: (details) {
        setState(() {
          _draggedMemberId = member.id;
          _dragStartOffset = details.localPosition;
        });
        widget.onSelectMember(member.id);
      },
      onPanUpdate: (details) {
        if (_draggedMemberId == member.id) {
          // Update position with the drag delta
          widget.onUpdatePosition(member.id, details.delta);
        }
      },
      onPanEnd: (details) {
        setState(() {
          _draggedMemberId = null;
          _dragStartOffset = null;
        });
      },
      onPanCancel: () {
        setState(() {
          _draggedMemberId = null;
          _dragStartOffset = null;
        });
      },
      child: MemberCard(
        member: member,
        isSelected: isSelected,
        isDragging: isDragging,
        onDelete: () => widget.onDelete(member),
        onEdit: () => widget.onEdit(member),
        mahramRelationships: widget.mahramRelationships,
        onShowMahramDetails:
            () => widget.onShowMahramDetails(
              context,
              member,
              widget.mahramRelationships
                  .where(
                    (r) =>
                        r.fromMemberId == member.id ||
                        r.toMemberId == member.id,
                  )
                  .toList(),
            ),
      ),
    );
  }
}
