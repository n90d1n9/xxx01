import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MeetingStatistics {
  final int totalMeetings;
  final int upcomingMeetings;
  final int completedMeetings;
  final int totalActionItems;
  final int completedActionItems;
  final Map<MeetingType, int> meetingsByType;
  final Map<MeetingPriority, int> meetingsByPriority;
  MeetingStatistics({
    required this.totalMeetings,
    required this.upcomingMeetings,
    required this.completedMeetings,
    required this.totalActionItems,
    required this.completedActionItems,
    required this.meetingsByType,
    required this.meetingsByPriority,
  });
}
