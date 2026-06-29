class ColumnConfig {
  final int index;
  final double width;
  final bool hidden;

  ColumnConfig({required this.index, this.width = 100, this.hidden = false});

  ColumnConfig copyWith({int? index, double? width, bool? hidden}) =>
      ColumnConfig(
        index: index ?? this.index,
        width: width ?? this.width,
        hidden: hidden ?? this.hidden,
      );
}
