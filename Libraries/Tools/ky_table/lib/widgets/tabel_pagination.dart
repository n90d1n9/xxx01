import 'dart:math';

import 'package:flutter/material.dart';

import '../tabel_controller.dart';

class TablePagination extends StatelessWidget {
  final TableController controller;
  const TablePagination({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final pageInfo = controller.pageInfo;
    final currentPage = pageInfo['currentPage'] as int;
    final totalPages = pageInfo['totalPages'] as int? ?? 1;
    final totalItems = pageInfo['totalItems'] as int? ?? 0;
    final itemsPerPage = pageInfo['itemsPerPage'] as int;

    final startItem = currentPage * itemsPerPage + 1;
    final endItem = min((currentPage + 1) * itemsPerPage, totalItems);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Items per page
          Row(
            children: [
              const Text('Items per page:'),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: itemsPerPage,
                onChanged: (value) {
                  if (value != null) {
                    final newPageInfo = Map<String, dynamic>.from(pageInfo);
                    newPageInfo['itemsPerPage'] = value;
                    newPageInfo['currentPage'] = 0;
                    controller.setPageInfo(newPageInfo);
                  }
                },
                items:
                    [10, 25, 50, 100].map((pageSize) {
                      return DropdownMenuItem<int>(
                        value: pageSize,
                        child: Text('$pageSize'),
                      );
                    }).toList(),
              ),
            ],
          ),

          // Page info
          Text(
            totalItems > 0
                ? 'Showing $startItem-$endItem of $totalItems items'
                : 'No items',
          ),

          // Pagination controls
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.first_page),
                onPressed:
                    currentPage > 0
                        ? () {
                          final newPageInfo = Map<String, dynamic>.from(
                            pageInfo,
                          );
                          newPageInfo['currentPage'] = 0;
                          controller.setPageInfo(newPageInfo);
                        }
                        : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed:
                    currentPage > 0
                        ? () {
                          final newPageInfo = Map<String, dynamic>.from(
                            pageInfo,
                          );
                          newPageInfo['currentPage'] = currentPage - 1;
                          controller.setPageInfo(newPageInfo);
                        }
                        : null,
              ),
              for (
                int i = max(0, currentPage - 1);
                i <= min(totalPages - 1, currentPage + 1);
                i++
              )
                InkWell(
                  onTap:
                      i != currentPage
                          ? () {
                            final newPageInfo = Map<String, dynamic>.from(
                              pageInfo,
                            );
                            newPageInfo['currentPage'] = i;
                            controller.setPageInfo(newPageInfo);
                          }
                          : null,
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color:
                          i == currentPage
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color:
                            i == currentPage
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade300,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: i == currentPage ? Colors.white : null,
                        ),
                      ),
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed:
                    currentPage < totalPages - 1
                        ? () {
                          final newPageInfo = Map<String, dynamic>.from(
                            pageInfo,
                          );
                          newPageInfo['currentPage'] = currentPage + 1;
                          controller.setPageInfo(newPageInfo);
                        }
                        : null,
              ),
              IconButton(
                icon: const Icon(Icons.last_page),
                onPressed:
                    currentPage < totalPages - 1
                        ? () {
                          final newPageInfo = Map<String, dynamic>.from(
                            pageInfo,
                          );
                          newPageInfo['currentPage'] = totalPages - 1;
                          controller.setPageInfo(newPageInfo);
                        }
                        : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
