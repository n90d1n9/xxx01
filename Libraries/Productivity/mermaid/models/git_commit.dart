import 'package:flutter/material.dart';

class GitCommit {
  final String id;
  final String message;
  final String branch;
  final DateTime timestamp;
  final bool isMerge;
  final String? mergedBranch;
  final Offset position;

  GitCommit({
    required this.id,
    required this.message,
    required this.branch,
    required this.timestamp,
    this.isMerge = false,
    this.mergedBranch,
    this.position = Offset.zero,
  });

  GitCommit copyWith({
    String? id,
    String? message,
    String? branch,
    DateTime? timestamp,
    bool? isMerge,
    String? mergedBranch,
    Offset? position,
  }) {
    return GitCommit(
      id: id ?? this.id,
      message: message ?? this.message,
      branch: branch ?? this.branch,
      timestamp: timestamp ?? this.timestamp,
      isMerge: isMerge ?? this.isMerge,
      mergedBranch: mergedBranch ?? this.mergedBranch,
      position: position ?? this.position,
    );
  }

  String get shortHash => id.length > 7 ? id.substring(0, 7) : id;

  String get displayMessage {
    if (isMerge) {
      return 'Merge $mergedBranch into $branch';
    }
    return message;
  }

  @override
  String toString() {
    return 'GitCommit(id: $id, message: $message, branch: $branch, isMerge: $isMerge, mergedBranch: $mergedBranch)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GitCommit && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
