import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'meeting.dart';

class MeetingRepository {
  static const String _storageKey = 'meetings_data';
  Future<void> saveMeetings(List<Meeting> meetings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = meetings.map((m) => m.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonData));
  }

  Future<List<Meeting>> loadMeetings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return [];
    final jsonData = jsonDecode(jsonString) as List;
    return jsonData.map((json) => Meeting.fromJson(json)).toList();
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
