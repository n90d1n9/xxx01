import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/ibs/models/enums.dart';

import '../models/subject.dart';

final subjectsProvider = StateNotifierProvider<SubjectsNotifier, List<Subject>>(
  (ref) {
    return SubjectsNotifier();
  },
);

class SubjectsNotifier extends StateNotifier<List<Subject>> {
  SubjectsNotifier() : super([]);

  getSubjectById(int subjectId) {}
}
