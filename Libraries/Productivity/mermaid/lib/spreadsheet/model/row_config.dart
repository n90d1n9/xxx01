class RowConfig {
  final int index;
  final double height;
  final bool hidden;

  RowConfig({required this.index, this.height = 40, this.hidden = false});

  RowConfig copyWith({int? index, double? height, bool? hidden}) => RowConfig(
    index: index ?? this.index,
    height: height ?? this.height,
    hidden: hidden ?? this.hidden,
  );
}
