# ky_website_builder

Visual website builder package for Kaysir.

This package now uses `ky_builder_shared` for reusable builder primitives, so website-builder and layout-builder work can converge instead of growing separate canvas, snapping, breakpoint, and component catalog implementations.

## Features

- Maintained `WebsiteBuilderScreen` entry point.
- `WebsiteBuilderController` for component add/select/move/resize/duplicate/export behavior.
- Shared component catalog with website sections, content, media, controls, and commerce blocks.
- Shared layout mechanisms: freeform, grid, tabular columns, auto grid, and flex flow.
- JSON export for the composed website document.

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:ky_website_builder/ky_website_builder.dart';

void main() {
  runApp(const MaterialApp(home: WebsiteBuilderScreen()));
}
```
