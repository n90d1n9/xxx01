class MahramStatus {
  final bool isMahram;
  final String reason;
  final List<String> relationshipPath;
  final String category;

  MahramStatus({
    required this.isMahram,
    required this.reason,
    required this.relationshipPath,
    this.category = 'Unknown',
  });
}

class InheritanceInfo {
  final String heirId;
  final double share;
  final String explanation;
  final String category;
  final double actualAmount;
  final String detailedCalculation;

  InheritanceInfo({
    required this.heirId,
    required this.share,
    required this.explanation,
    required this.category,
    this.actualAmount = 0,
    this.detailedCalculation = '',
  });

  Map<String, dynamic> toJson() => {
    'heirId': heirId,
    'share': share,
    'explanation': explanation,
    'category': category,
    'actualAmount': actualAmount,
    'detailedCalculation': detailedCalculation,
  };
}
