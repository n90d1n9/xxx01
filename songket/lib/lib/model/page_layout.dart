import 'package:flutter/material.dart';

/// Page layout configuration for report pages
enum PageOrientation { portrait, landscape }

enum PageSize { a4, a3, letter, legal, tabloid, custom }

class PageLayout {
  final String id;
  final PageSize size;
  final PageOrientation orientation;
  final EdgeInsets margins;
  final Color backgroundColor;
  final String? backgroundImage;
  final bool showHeader;
  final bool showFooter;
  final bool showPageNumbers;
  final int columns;
  final double columnGap;

  PageLayout({
    required this.id,
    this.size = PageSize.a4,
    this.orientation = PageOrientation.portrait,
    this.margins = const EdgeInsets.all(40),
    this.backgroundColor = Colors.white,
    this.backgroundImage,
    this.showHeader = true,
    this.showFooter = true,
    this.showPageNumbers = true,
    this.columns = 1,
    this.columnGap = 20,
  });

  double get width {
    switch (size) {
      case PageSize.a4:
        return orientation == PageOrientation.portrait ? 595 : 842;
      case PageSize.a3:
        return orientation == PageOrientation.portrait ? 842 : 1191;
      case PageSize.letter:
        return orientation == PageOrientation.portrait ? 612 : 792;
      case PageSize.legal:
        return orientation == PageOrientation.portrait ? 612 : 1008;
      case PageSize.tabloid:
        return orientation == PageOrientation.portrait ? 792 : 1224;
      case PageSize.custom:
        return 800;
    }
  }

  double get height {
    switch (size) {
      case PageSize.a4:
        return orientation == PageOrientation.portrait ? 842 : 595;
      case PageSize.a3:
        return orientation == PageOrientation.portrait ? 1191 : 842;
      case PageSize.letter:
        return orientation == PageOrientation.portrait ? 792 : 612;
      case PageSize.legal:
        return orientation == PageOrientation.portrait ? 1008 : 612;
      case PageSize.tabloid:
        return orientation == PageOrientation.portrait ? 1224 : 792;
      case PageSize.custom:
        return 1000;
    }
  }
}
