import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';

import '../models/station.dart';
import 'cache_manager.dart';

class BackgroundSyncService {
  static void initialize() {
    Workmanager().initialize(_backgroundCallback, isInDebugMode: true);

    // Schedule periodic sync
    Workmanager().registerPeriodicTask(
      'radio-station-sync',
      'syncStations',
      frequency: Duration(hours: 6),
    );
  }

  static void _backgroundCallback(String task) async {
    switch (task) {
      case 'syncStations':
        await _syncStations();
        break;
    }
  }

  static Future<void> _syncStations() async {
    final cacheManager = CacheManager();

    try {
      final stations = await _fetchStationsFromAPI();
      await cacheManager.cacheStations(stations);
    } catch (e) {
      // Handle sync failure
      print('Background sync failed: $e');
    }
  }

  static Future<List<Station>> _fetchStationsFromAPI() async {
    // Implement actual API call
    final response = await http.get(Uri.parse('https://your-api.com/stations'));

    if (response.statusCode == 200) {
      final List<dynamic> stationsJson = json.decode(response.body);
      return stationsJson.map((json) => Station.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load stations');
    }
  }
}
