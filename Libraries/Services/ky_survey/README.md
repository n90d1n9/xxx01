# ky_survey

Role-aware survey builder, collection, analytics, and reporting UI for Kaysir.

## Features

- Admin, interviewer, participant, analyst, and report workspace roles.
- Survey lifecycle metadata for draft, review, published, collecting, analyzing, closed, and archived states.
- Reusable dashboard widgets for metrics, status chips, role switching, and response progress.
- Pure Dart analytics helpers for response progress, question mix, lifecycle counts, and attention items.
- Backward-compatible survey JSON parsing for older payloads.

## Usage

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:ky_survey/ky_survey.dart';

void main() {
  runApp(const ProviderScope(child: SurveyApp()));
}

class SurveyApp extends StatelessWidget {
  const SurveyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SurveyDashboardScreen(),
    );
  }
}
```

## Testing

```bash
dart test
```
