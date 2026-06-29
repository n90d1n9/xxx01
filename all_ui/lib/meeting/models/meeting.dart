import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'meeting_priority.dart';
import 'meeting_status.dart';
import 'meeting_type.dart';
import 'attendee.dart';
import 'action_item.dart';
import 'meeting_note.dart';

class Meeting {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final int durationMinutes;
  final List<Attendee> attendees;
  final List<MeetingNote> notes;
  final List<ActionItem> actionItems;
  final MeetingPriority priority;
  final MeetingStatus status;
  final MeetingType type;
  final String? location;
  final String? meetingLink;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? recurringPattern;
  Meeting({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.durationMinutes = 60,
    required this.attendees,
    required this.notes,
    required this.actionItems,
    required this.priority,
    required this.status,
    required this.type,
    this.location,
    this.meetingLink,
    required this.tags,
    required this.createdAt,
    this.updatedAt,
    this.recurringPattern,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'dateTime': dateTime.toIso8601String(),
    'durationMinutes': durationMinutes,
    'attendees': attendees.map((a) => a.toJson()).toList(),
    'notes': notes.map((n) => n.toJson()).toList(),
    'actionItems': actionItems.map((a) => a.toJson()).toList(),
    'priority': priority.name,
    'status': status.name,
    'type': type.name,
    'location': location,
    'meetingLink': meetingLink,
    'tags': tags,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'recurringPattern': recurringPattern,
  };
  factory Meeting.fromJson(Map<String, dynamic> json) => Meeting(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    dateTime: DateTime.parse(json['dateTime']),
    durationMinutes: json['durationMinutes'] ?? 60,
    attendees:
        (json['attendees'] as List).map((a) => Attendee.fromJson(a)).toList(),
    notes: (json['notes'] as List).map((n) => MeetingNote.fromJson(n)).toList(),
    actionItems:
        (json['actionItems'] as List)
            .map((a) => ActionItem.fromJson(a))
            .toList(),
    priority: MeetingPriority.values.firstWhere(
      (e) => e.name == json['priority'],
    ),
    status: MeetingStatus.values.firstWhere((e) => e.name == json['status']),
    type: MeetingType.values.firstWhere((e) => e.name == json['type']),
    location: json['location'],
    meetingLink: json['meetingLink'],
    tags: List<String>.from(json['tags'] ?? []),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt:
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    recurringPattern: json['recurringPattern'],
  );
  Meeting copyWith({
    String? title,
    String? description,
    DateTime? dateTime,
    int? durationMinutes,
    List<Attendee>? attendees,
    List<MeetingNote>? notes,
    List<ActionItem>? actionItems,
    MeetingPriority? priority,
    MeetingStatus? status,
    MeetingType? type,
    String? location,
    String? meetingLink,
    List<String>? tags,
    DateTime? updatedAt,
    String? recurringPattern,
  }) {
    return Meeting(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      attendees: attendees ?? this.attendees,
      notes: notes ?? this.notes,
      actionItems: actionItems ?? this.actionItems,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      type: type ?? this.type,
      location: location ?? this.location,
      meetingLink: meetingLink ?? this.meetingLink,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      recurringPattern: recurringPattern ?? this.recurringPattern,
    );
  }

  DateTime get endTime => dateTime.add(Duration(minutes: durationMinutes));
}
