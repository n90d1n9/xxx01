import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/station.dart';
import '../services/background_service.dart';
import '../services/cache_manager.dart';
import '../services/offline_mode.dart';
import '../services/stream_quality.dart';

class RadioPlayerScreen extends StatefulWidget {
  const RadioPlayerScreen({super.key});

  @override
  _RadioPlayerScreenState createState() => _RadioPlayerScreenState();
}

class _RadioPlayerScreenState extends State<RadioPlayerScreen> {
  late CacheManager _cacheManager;
  late StreamQualityManager _qualityManager;
  late OfflineModeManager _offlineModeManager;

  List<Station> _stations = [];
  List<Station> _favoriteStations = [];

  @override
  void initState() {
    super.initState();
    _initializeManagers();
  }

  Future<void> _initializeManagers() async {
    // Initialize managers
    _cacheManager = CacheManager();
    _qualityManager = StreamQualityManager();
    _offlineModeManager = OfflineModeManager();

    await _cacheManager.initialize();

    // Load stations
    await _loadStations();

    // Initialize background sync
    BackgroundSyncService.initialize();
  }

  Future<void> _loadStations() async {
    // Check cached stations first
    if (_cacheManager.isCacheValid()) {
      _stations = await _cacheManager.getCachedStations();
    } else {
      // Fetch from API or use fallback
      _stations = await _fetchStations();
    }

    // Load favorites
    _favoriteStations = await _cacheManager.getFavorites();

    setState(() {});
  }

  Future<List<Station>> _fetchStations() async {
    try {
      // Implement actual API call
      final response = await http.get(
        Uri.parse('https://your-api.com/stations'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> stationsJson = json.decode(response.body);
        final stations =
            stationsJson.map((json) => Station.fromJson(json)).toList();

        // Cache fetched stations
        await _cacheManager.cacheStations(stations);

        return stations;
      } else {
        // Fallback to cached or default stations
        return _cacheManager.getCachedStations();
      }
    } catch (e) {
      // Handle network errors
      return _cacheManager.getCachedStations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Advanced Radio Player'),
        actions: [
          // Offline Mode Toggle
          Switch(
            value: _offlineModeManager.isOfflineMode,
            onChanged: (bool value) {
              if (value) {
                _offlineModeManager.enableOfflineMode(_stations);
              } else {
                _offlineModeManager.disableOfflineMode();
              }
              setState(() {});
            },
          ),
          // Quality Selection
          PopupMenuButton<String>(
            icon: Icon(Icons.signal_cellular_alt),
            onSelected: (String quality) {
              _qualityManager.setQuality(quality);
              setState(() {});
            },
            itemBuilder: (BuildContext context) {
              return _qualityManager.qualityLevels.map((String quality) {
                return PopupMenuItem<String>(
                  value: quality,
                  child: Text('${quality.capitalize()} Quality'),
                );
              }).toList();
            },
          ),
        ],
      ),
      body:
          _offlineModeManager.isOfflineMode
              ? _buildOfflineView()
              : _buildOnlineView(),
    );
  }

  Widget _buildOfflineView() {
    return ListView.builder(
      itemCount: _offlineModeManager.offlineStations.length,
      itemBuilder: (context, index) {
        final station = _offlineModeManager.offlineStations[index];
        return ListTile(
          title: Text(station.name),
          subtitle: Text(station.frequency),
        );
      },
    );
  }

  Widget _buildOnlineView() {
    return ListView.builder(
      itemCount: _stations.length,
      itemBuilder: (context, index) {
        final station = _stations[index];
        return ListTile(
          title: Text(station.name),
          subtitle: Text(station.frequency),
          trailing: IconButton(
            icon: Icon(
              station.isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
            onPressed: () {
              setState(() {
                station.isFavorite = !station.isFavorite;
                if (station.isFavorite) {
                  _cacheManager.saveFavorite(station);
                } else {
                  _cacheManager.removeFavorite(station.id);
                }
              });
            },
          ),
        );
      },
    );
  }
}

// Utility Extension
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
