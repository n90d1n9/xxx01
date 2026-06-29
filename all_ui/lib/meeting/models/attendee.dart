import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'attendee_status.dart';

class Attendee {
  final String id;
  final String name;
  final String email;
  final bool isOrganizer;
  final bool isOptional;
  final AttendeeStatus status;
  Attendee({
    required this.id,
    required this.name,
    required this.email,
    this.isOrganizer = false,
    this.isOptional = false,
    this.status = AttendeeStatus.pending,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'isOrganizer': isOrganizer,
    'isOptional': isOptional,
    'status': status.name,
  };
  factory Attendee.fromJson(Map<String, dynamic> json) => Attendee(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    isOrganizer: json['isOrganizer'] ?? false,
    isOptional: json['isOptional'] ?? false,
    status: AttendeeStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => AttendeeStatus.pending,
    ),
  );
  Attendee copyWith({
    String? name,
    String? email,
    bool? isOrganizer,
    bool? isOptional,
    AttendeeStatus? status,
  }) {
    return Attendee(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      isOrganizer: isOrganizer ?? this.isOrganizer,
      isOptional: isOptional ?? this.isOptional,
      status: status ?? this.status,
    );
  }
}
