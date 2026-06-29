import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screen/form_build_designer.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MaterialApp(
        title: 'Form Builder Designer',
        debugShowCheckedModeBanner: false,
        home: FormBuilderDesigner(),
      ),
    ),
  );
}
