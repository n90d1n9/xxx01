// components/summary_panel.dart
import 'package:flutter/material.dart';

import '../models/family_member.dart';
import '../models/relation_type.dart';

class SummaryPanel extends StatefulWidget {
  final List<FamilyMember> heirs;
  final double netEstate;
  final VoidCallback? onShowCalculation;

  const SummaryPanel({
    super.key,
    required this.heirs,
    required this.netEstate,
    this.onShowCalculation,
  });

  @override
  State<SummaryPanel> createState() => _SummaryPanelState();
}

class _SummaryPanelState extends State<SummaryPanel> {
  bool _isExpanded = true;
  bool _isMinimized = false;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _toggleMinimize() {
    setState(() {
      _isMinimized = !_isMinimized;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isMinimized) {
      return _buildMinimizedPanel();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Colors.grey[50]!]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          if (_isExpanded) ..._buildExpandedContent(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.pie_chart, color: Colors.teal, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Pembagian Waris',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          children: [
            if (widget.netEstate > 0) _buildNetEstateChip(),
            const SizedBox(width: 8),
            _buildControlButtons(),
          ],
        ),
      ],
    );
  }

  Widget _buildNetEstateChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Net: \$${widget.netEstate.toStringAsFixed(2)}',
        style: const TextStyle(
          fontSize: 14,
          color: Colors.green,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
            size: 20,
          ),
          onPressed: _toggleExpand,
          tooltip: _isExpanded ? 'Collapse' : 'Expand',
        ),
        IconButton(
          icon: const Icon(Icons.minimize, size: 20),
          onPressed: _toggleMinimize,
          tooltip: 'Minimize',
        ),
      ],
    );
  }

  List<Widget> _buildExpandedContent() {
    return [
      const SizedBox(height: 20),
      ...widget.heirs.map((heir) => _buildHeirItem(heir)),
    ];
  }

  Widget _buildHeirItem(FamilyMember heir) {
    final amount = widget.netEstate * heir.faraidShare;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          _buildAvatar(heir),
          const SizedBox(width: 14),
          _buildHeirInfo(heir),
          const Spacer(),
          _buildShareInfo(heir, amount),
          _buildInfoButton(heir),
        ],
      ),
    );
  }

  Widget _buildAvatar(FamilyMember heir) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              heir.gender == Gender.male
                  ? [Colors.blue[300]!, Colors.blue[500]!]
                  : [Colors.pink[300]!, Colors.pink[500]!],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child:
          heir.photoPath != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  heir.photoPath!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildGenderIcon(heir.gender),
                ),
              )
              : _buildGenderIcon(heir.gender),
    );
  }

  Widget _buildGenderIcon(Gender gender) {
    return Icon(
      gender == Gender.male ? Icons.man : Icons.woman,
      color: Colors.white,
      size: 28,
    );
  }

  Widget _buildHeirInfo(FamilyMember heir) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heir.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            _getRelationLabel(heir.relation),
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildShareInfo(FamilyMember heir, double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.teal, Colors.tealAccent],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${(heir.faraidShare * 100).toStringAsFixed(2)}%',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        if (widget.netEstate > 0) ...[
          const SizedBox(height: 4),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoButton(FamilyMember heir) {
    return IconButton(
      icon: const Icon(Icons.info_outline, size: 20),
      onPressed:
          widget.onShowCalculation != null
              ? () => widget.onShowCalculation!()
              : null,
    );
  }

  Widget _buildMinimizedPanel() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.pie_chart, color: Colors.teal, size: 20),
              const SizedBox(width: 8),
              Text(
                '${widget.heirs.length} Heirs',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              if (widget.netEstate > 0)
                Text(
                  '\$${widget.netEstate.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.green),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.open_in_full, size: 18),
            onPressed: _toggleMinimize,
            tooltip: 'Restore',
          ),
        ],
      ),
    );
  }

  String _getRelationLabel(RelationType relation) {
    const labels = {
      RelationType.deceased: 'Meninggal',
      RelationType.father: 'Ayah',
      RelationType.mother: 'Ibu',
      RelationType.spouse: 'Pasangan',
      RelationType.son: 'Anak Laki-laki',
      RelationType.daughter: 'Anak Perempuan',
      RelationType.brother: 'Brother',
      RelationType.sister: 'Sister',
      RelationType.paternalGrandfather: 'P. Grandfather',
      RelationType.paternalGrandmother: 'P. Grandmother',
      RelationType.grandson: 'Grandson',
      RelationType.granddaughter: 'Granddaughter',
    };
    return labels[relation] ?? relation.name;
  }
}
