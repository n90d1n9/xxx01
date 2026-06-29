import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MeetingNote {
  final String id;
  final String content;
  final DateTime timestamp;
  final String? author;
  MeetingNote({
    required this.id,
    required this.content,
    required this.timestamp,
    this.author,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'author': author,
  };
  factory MeetingNote.fromJson(Map<String, dynamic> json) => MeetingNote(
    id: json['id'],
    content: json['content'],
    timestamp: DateTime.parse(json['timestamp']),
    author: json['author'],
  );
}
