import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/terminal.dart';
import '../services/api_services.dart';

// API Service class to handle network requests

// Provider for the API service
final apiServiceProvider = Provider<ApiService>((ref) {
  // You can replace this with your actual API base URL

  return ApiService();
});

// Terminal providers
final terminalsProvider = FutureProvider<List<Terminal>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getTerminals();
});

// We'll use this provider to access the current terminal
final currentTerminalProvider = StateProvider<Terminal?>((ref) => null);
