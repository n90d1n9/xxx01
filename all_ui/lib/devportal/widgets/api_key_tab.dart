import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/enums.dart';
import '../states/provider.dart';
import 'apikey_status_badge.dart';

class ApiKeysTab extends ConsumerWidget {
  final bool isDarkMode;

  const ApiKeysTab({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiKeys = ref.watch(apiKeysProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'API Keys',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Generate New Key'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Security Notice
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'API keys provide full access to your account resources. Keep your API keys secure and never share them in publicly accessible areas.',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // API Keys Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2D2D42) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: apiKeys.when(
                data:
                    (keyList) => Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isDarkMode
                                            ? const Color(0xFF1E1E2D)
                                            : const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.search,
                                        color:
                                            isDarkMode
                                                ? Colors.white70
                                                : Colors.black54,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          decoration: InputDecoration(
                                            hintText: 'Search API keys',
                                            border: InputBorder.none,
                                            hintStyle: TextStyle(
                                              color:
                                                  isDarkMode
                                                      ? Colors.white30
                                                      : Colors.black38,
                                            ),
                                          ),
                                          style: TextStyle(
                                            color:
                                                isDarkMode
                                                    ? Colors.white
                                                    : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isDarkMode
                                          ? const Color(0xFF1E1E2D)
                                          : const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: 'All Status',
                                    items:
                                        ['All Status', 'Active', 'Expired'].map(
                                          (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value,
                                                style: TextStyle(
                                                  color:
                                                      isDarkMode
                                                          ? Colors.white
                                                          : Colors.black87,
                                                ),
                                              ),
                                            );
                                          },
                                        ).toList(),
                                    onChanged: (_) {},
                                    icon: Icon(
                                      Icons.keyboard_arrow_down,
                                      color:
                                          isDarkMode
                                              ? Colors.white70
                                              : Colors.black54,
                                    ),
                                    dropdownColor:
                                        isDarkMode
                                            ? const Color(0xFF1E1E2D)
                                            : Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            itemCount: keyList.length,
                            separatorBuilder:
                                (context, index) => Divider(
                                  color:
                                      isDarkMode
                                          ? Colors.white12
                                          : Colors.black12,
                                ),
                            itemBuilder: (context, index) {
                              final apiKey = keyList[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            apiKey.name!,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  isDarkMode
                                                      ? Colors.white
                                                      : Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            apiKey.id,
                                            style: TextStyle(
                                              color:
                                                  isDarkMode
                                                      ? Colors.white60
                                                      : Colors.black54,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Created: ${DateFormat('MMM d, yyyy').format(apiKey.createdAt!)}',
                                        style: TextStyle(
                                          color:
                                              isDarkMode
                                                  ? Colors.white60
                                                  : Colors.black54,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Expires: ${DateFormat('MMM d, yyyy').format(apiKey.expiresAt!)}',
                                        style: TextStyle(
                                          color:
                                              isDarkMode
                                                  ? Colors.white60
                                                  : Colors.black54,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 100,
                                      child: ApiKeyStatusBadge(
                                        status: ApiKeyStatus.active,
                                        isDarkMode: isDarkMode,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.copy_outlined,
                                            color:
                                                isDarkMode
                                                    ? Colors.white60
                                                    : Colors.black54,
                                          ),
                                          onPressed: () {},
                                          tooltip: 'Copy Key',
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.refresh_outlined,
                                            color:
                                                isDarkMode
                                                    ? Colors.white60
                                                    : Colors.black54,
                                          ),
                                          onPressed: () {},
                                          tooltip: 'Regenerate',
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete_outline,
                                            color:
                                                isDarkMode
                                                    ? Colors.white60
                                                    : Colors.black54,
                                          ),
                                          onPressed: () {},
                                          tooltip: 'Delete',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (_, __) =>
                        const Center(child: Text('Failed to load API keys')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
