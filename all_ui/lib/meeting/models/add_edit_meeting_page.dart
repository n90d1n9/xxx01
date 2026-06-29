import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '_add_edit_meeting_page_state.dart';

class AddEditMeetingPage extends ConsumerStatefulWidget {
  final Meeting? meeting;
  const AddEditMeetingPage({Key? key, this.meeting}) : super(key: key);
  @override
  ConsumerState<AddEditMeetingPage> createState() => _AddEditMeetingPageState();
}
