class FinancialReportPackageFingerprint {
  final String algorithm;
  final String hash;

  const FinancialReportPackageFingerprint({
    required this.algorithm,
    required this.hash,
  });

  String get shortHash {
    if (hash.length <= 12) {
      return hash.toUpperCase();
    }
    return hash.substring(0, 12).toUpperCase();
  }
}
