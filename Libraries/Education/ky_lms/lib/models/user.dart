import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/legacy.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final DateTime joinedDate;
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.joinedDate,
  });
}
