class DropOffPoint {
  final String fieldId;
  final String fieldLabel;
  final int dropOffCount;
  final double dropOffRate;

  const DropOffPoint({
    required this.fieldId,
    required this.fieldLabel,
    required this.dropOffCount,
    required this.dropOffRate,
  });

  Map<String, dynamic> toJson() {
    return {
      'fieldId': fieldId,
      'fieldLabel': fieldLabel,
      'dropOffCount': dropOffCount,
      'dropOffRate': dropOffRate,
    };
  }
}
