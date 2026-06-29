import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/station.dart';

// Caching and Offline Support
class CacheManager {
  static const _boxName = 'radio_cache';
  static const _stationsKey = 'stations';
  static const _favoritesKey = 'favorites';

  Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  // Advanced Caching Mechanism
  Future<void> cacheStations(List<Station> stations) async {
    final box = Hive.box(_boxName);
    final cachedData = stations.map((station) => station.toJson()).toList();

    await box.put(_stationsKey, cachedData);
    await box.put('timestamp', DateTime.now().toIso8601String());
  }

  Future<List<Station>> getCachedStations() async {
    final box = Hive.box(_boxName);
    final cachedData = box.get(_stationsKey);

    if (cachedData == null) return [];

    return (cachedData as List).map((json) => Station.fromJson(json)).toList();
  }

  bool isCacheValid() {
    final box = Hive.box(_boxName);
    final timestamp = box.get('timestamp');

    if (timestamp == null) return false;

    final cachedTime = DateTime.parse(timestamp);
    return DateTime.now().difference(cachedTime).inHours < 24;
  }

  // Favorites Management
  Future<void> saveFavorite(Station station) async {
    final box = Hive.box(_boxName);
    final favorites = box.get(_favoritesKey, defaultValue: []);

    // Prevent duplicates
    if (!favorites.any((fav) => fav['id'] == station.id)) {
      favorites.add(station.toJson());
      await box.put(_favoritesKey, favorites);
    }
  }

  Future<void> removeFavorite(String stationId) async {
    final box = Hive.box(_boxName);
    final favorites = box.get(_favoritesKey, defaultValue: []);

    favorites.removeWhere((fav) => fav['id'] == stationId);
    await box.put(_favoritesKey, favorites);
  }

  Future<List<Station>> getFavorites() async {
    final box = Hive.box(_boxName);
    final favorites = box.get(_favoritesKey, defaultValue: []);

    return favorites.map<Station>((fav) => Station.fromJson(fav)).toList();
  }
}
