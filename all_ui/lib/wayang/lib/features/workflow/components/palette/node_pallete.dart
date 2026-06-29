import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../config/config.dart';
import '../../../../dummy.dart';
import 'category_grouping.dart';

class NodePalette extends StatelessWidget {
  final void Function(dynamic nodeType) onNodeSelected;

  const NodePalette({super.key, required this.onNodeSelected});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final availableHeight = MediaQuery.of(context).size.height;
    double width = 260;
    return Container(
      //color: Colors.transparent,
      height: availableHeight,
      width: width,
      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          Image.asset(imageIcon, width: 200),
          const SizedBox(height: 16),
          Container(
            height:
                availableHeight -
                width -
                32, // Total height - logo height - padding
            constraints: BoxConstraints(
              maxWidth: 350,
              minHeight: availableHeight - 250 - 32,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                  spreadRadius: -8,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                  spreadRadius: -4,
                ),
                if (isDark)
                  BoxShadow(
                    color: Colors.white.withOpacity(0.03),
                    blurRadius: 2,
                    spreadRadius: 1,
                    offset: const Offset(0, 1),
                  ),
              ],
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            Colors.white.withOpacity(0.05),
                            Colors.white.withOpacity(0.02),
                          ]
                        : [
                            Colors.white.withOpacity(0.8),
                            Colors.white.withOpacity(0.6),
                          ],
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Column(
                    children: [
                      // Search Bar
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search nodes...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      // Divider
                      Container(height: 1, color: Colors.grey.withOpacity(0.2)),
                      // Node list
                      Expanded(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(8),
                          children: nodeTypesByCategory.entries.map((entry) {
                            return CategoryGrouping(
                              category: entry.key,
                              nodes: entry.value,
                              onNodeSelected: onNodeSelected,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
