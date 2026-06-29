import 'package:flutter/material.dart';
import 'package:wayang_builder/features/workflow/components/node/widget/node_shape/node_header_shape.dart';

import '../../../connection/model/connection_state.dart';
import '../../../connection/model/node_port.dart';
import 'node_port_shape.dart';

class ConditionalNode extends StatefulWidget {
  final List<String> conditions;
  final String elseLabel;
  final String headerTitle;
  final String headerSubtitle;
  final ValueChanged<NodePort>? onNodePortTap;
  final ValueChanged<NodePort>? onNodePortHover;

  const ConditionalNode({
    super.key,
    required this.conditions,
    this.elseLabel = 'else',
    this.headerTitle = 'Condition',
    this.headerSubtitle = '',
    this.onNodePortTap,
    this.onNodePortHover,
  });

  @override
  State<ConditionalNode> createState() => _ConditionalNodeState();
}

class _ConditionalNodeState extends State<ConditionalNode> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const itemHeight = 21.0;
        const horizontalPadding = 12.0;
        const verticalPadding = 8.0;

        final headerHeight = widget.headerSubtitle.isEmpty ? 20.0 : 32.0;
        final contentHeight =
            widget.conditions.length * itemHeight +
            (widget.conditions.length - 1) * 2;
        final elseHeight = 25.0;
        final totalContentHeight =
            verticalPadding * 2 + headerHeight + contentHeight + elseHeight;

        // Add extra space for circles (12px on each side)
        double totalHeight = totalContentHeight;
        double totalWidth = 200 + 24; // 12px left + 12px right for circles

        return SizedBox(
          width: totalWidth,
          height: totalHeight,
          child: Stack(
            clipBehavior:
                Clip.none, // Important: Allow children to draw outside
            children: [
              // Background container (shifted right by 12px to make space for left circle)
              Positioned(
                left: 12, // Make space for left circle
                child: Container(
                  width: 200,
                  height: totalHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF979797),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),

              // Content (also shifted right by 12px)
              Positioned(
                left: 12 + horizontalPadding,
                top: verticalPadding,
                child: SizedBox(
                  width: 200 - horizontalPadding * 2,
                  height: totalHeight - verticalPadding * 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      /*  NodeHeaderShape(
                        height: headerHeight,
                        title: widget.headerTitle,
                        subtitle: widget.headerTitle,
                      ), */
                      const SizedBox(height: 8),

                      // Conditions - Use Expanded with constraints
                      Expanded(child: _buildConditionsList(itemHeight)),

                      // Else section
                      _buildElseSection(),
                    ],
                  ),
                ),
              ),

              // Interactive connection points - positioned absolutely
              ..._buildNodePorts(
                totalHeight,
                itemHeight,
                headerHeight,
                verticalPadding,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConditionsList(double itemHeight) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.conditions.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: SizedBox(
            height: itemHeight,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF979797), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.conditions[index],
                    style: const TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 8,
                      color: Color(0xFF5C5B5B),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildElseSection() {
    return Align(
      alignment: Alignment.bottomRight,
      child: SizedBox(
        width: 64,
        height: 21,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFF979797), width: 1),
          ),
          child: Center(
            child: Text(
              widget.elseLabel,
              style: const TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 8,
                color: Color(0xFF5C5B5B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNodePorts(
    double totalHeight,
    double itemHeight,
    double headerHeight,
    double verticalPadding,
  ) {
    final points = <Widget>[];
    final contentTop = verticalPadding + headerHeight + 8;

    // Input connection point (left side) - at position 0,0 in the Stack
    points.add(
      NodePortShape(
        id: 'input',
        position: const Offset(0, 0), // Top-left of the expanded container
        type: ConnectionType.input,
        totalHeight: totalHeight,
      ),
    );

    // Output connection points for conditions (right side)
    for (int i = 0; i < widget.conditions.length; i++) {
      final top = contentTop + (i * (itemHeight + 2)) + itemHeight / 2;
      points.add(
        NodePortShape(
          id: 'condition_$i',
          position: Offset(
            200 + 5,
            top - 6,
          ), // Right edge of main container + 12px
          type: ConnectionType.output,
          conditionIndex: i,
          totalHeight: totalHeight,
        ),
      );
    }

    // Output connection point for else (right side)
    points.add(
      NodePortShape(
        id: 'else',
        position: Offset(200 + 12, totalHeight - 14.5),
        type: ConnectionType.output,
        isElse: true,
        totalHeight: totalHeight,
      ),
    );

    return points;
  }
}
