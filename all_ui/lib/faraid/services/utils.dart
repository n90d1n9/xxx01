import 'package:flutter/services.dart';

Future<String> loadDrlFile(String path) async {
  // Load DRL from assets or file system
  return await rootBundle.loadString(path);
}

// Add these helper methods to your FaraidDrlEngine class
Map<String, double> safeCastToDoubleMap(Map<dynamic, dynamic> dynamicMap) {
  final result = <String, double>{};
  dynamicMap.forEach((key, value) {
    if (key is String) {
      if (value is double) {
        result[key] = value;
      } else if (value is int) {
        result[key] = value.toDouble();
      } else if (value is num) {
        result[key] = value.toDouble();
      }
      // Ignore other types
    }
  });
  return result;
}

Map<String, String> safeCastToStringMap(Map<dynamic, dynamic> dynamicMap) {
  final result = <String, String>{};
  dynamicMap.forEach((key, value) {
    if (key is String && value is String) {
      result[key] = value;
    }
  });
  return result;
}

List<String> safeCastToStringList(List<dynamic> dynamicList) {
  return dynamicList.whereType<String>().toList();
}
