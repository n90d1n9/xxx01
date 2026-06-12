import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'meeting_status.dart';
import 'meeting.dart';
import 'meeting_repository.dart';

class MeetingsNotifier extends StateNotifier<AsyncValue<List<Meeting>>> {
  final MeetingRepository repository;
  MeetingsNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadMeetings();
  }
  Future<void> loadMeetings() async {
    state = const AsyncValue.loading();
    try {
      final meetings = await repository.loadMeetings();
      state = AsyncValue.data(meetings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addMeeting(Meeting meeting) async {
    final currentState = state.value ?? [];
    final newState = [...currentState, meeting];
    state = AsyncValue.data(newState);
    await repository.saveMeetings(newState);
  }

  Future<void> updateMeeting(Meeting updatedMeeting) async {
    final currentState = state.value ?? [];
    final newState = [
      for (final meeting in currentState)
        if (meeting.id == updatedMeeting.id) updatedMeeting else meeting,
    ];
    state = AsyncValue.data(newState);
    await repository.saveMeetings(newState);
  }

  Future<void> deleteMeeting(String id) async {
    final currentState = state.value ?? [];
    final newState = currentState.where((m) => m.id != id).toList();
    state = AsyncValue.data(newState);
    await repository.saveMeetings(newState);
  }

  Future<void> updateMeetingStatus(String id, MeetingStatus status) async {
    final currentState = state.value ?? [];
    final newState = [
      for (final meeting in currentState)
        if (meeting.id == id) meeting.copyWith(status: status) else meeting,
    ];
    state = AsyncValue.data(newState);
    await repository.saveMeetings(newState);
  }
}
