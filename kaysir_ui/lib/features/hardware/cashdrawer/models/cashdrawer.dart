class CashDrawerSettings {
  CashDrawerSettings({
    required String port,
    required bool autoOpen,
    required bool requireApprovalToOpen,
    required int openTimeout,
    required Map<String, dynamic> customSettings,
  });
}