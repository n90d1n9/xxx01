import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'page_size.dart';

class PageSettings {
  final PageSize pageSize;
  final EdgeInsets margins;
  final bool showPageNumbers;
  final String pageNumberFormat;
  final int pageNumberStart;
  final String? header;
  final String? footer;
  final bool showHeader;
  final bool showFooter;
  const PageSettings({
    this.pageSize = PageSize.a4,
    this.margins = const EdgeInsets.all(72),
    this.showPageNumbers = true,
    this.pageNumberFormat = 'Page {n}',
    this.pageNumberStart = 1,
    this.header,
    this.footer,
    this.showHeader = false,
    this.showFooter = false,
  });
  PageSettings copyWith({
    PageSize? pageSize,
    EdgeInsets? margins,
    bool? showPageNumbers,
    String? pageNumberFormat,
    int? pageNumberStart,
    String? header,
    String? footer,
    bool? showHeader,
    bool? showFooter,
  }) {
    return PageSettings(
      pageSize: pageSize ?? this.pageSize,
      margins: margins ?? this.margins,
      showPageNumbers: showPageNumbers ?? this.showPageNumbers,
      pageNumberFormat: pageNumberFormat ?? this.pageNumberFormat,
      pageNumberStart: pageNumberStart ?? this.pageNumberStart,
      header: header ?? this.header,
      footer: footer ?? this.footer,
      showHeader: showHeader ?? this.showHeader,
      showFooter: showFooter ?? this.showFooter,
    );
  }

  Size getPageSize() {
    switch (pageSize) {
      case PageSize.a4:
        return const Size(595, 842);
      case PageSize.letter:
        return const Size(612, 792);
      case PageSize.legal:
        return const Size(612, 1008);
    }
  }

  double getContentHeight() {
    final size = getPageSize();
    return size.height - margins.top - margins.bottom;
  }
}
