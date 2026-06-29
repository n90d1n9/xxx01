import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/station.dart';

class OfflineModeManager {
  bool _isOfflineMode = false;
  List<Station> _offlineStations = [];

  bool get isOfflineMode => _isOfflineMode;
  List<Station> get offlineStations => _offlineStations;

  Future<void> enableOfflineMode(List<Station> stations) async {
    _isOfflineMode = true;

    // Select subset of stations for offline mode
    _offlineStations =
        stations.where((station) => station.isFavorite).take(10).toList();

    // Background download of offline resources
    await _downloadOfflineResources();
  }

  Future<void> _downloadOfflineResources() async {
    // Implement download logic for station logos, metadata
    for (var station in _offlineStations) {
      try {
        // Download and cache logo
        final dir = await getTemporaryDirectory();
        final logoPath = '${dir.path}/${station.id}_logo.png';

        final response = await http.get(Uri.parse(station.logoUrl));
        await File(logoPath).writeAsBytes(response.bodyBytes);
      } catch (e) {
        print('Offline resource download failed: ${e}');
      }
    }
  }

  void disableOfflineMode() {
    _isOfflineMode = false;
    _offlineStations.clear();
  }
}
