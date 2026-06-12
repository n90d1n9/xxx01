const projectCustomAttributeTruthyValues = {'true', 'yes', 'y', '1', 'enabled'};

const projectCustomAttributeFalsyValues = {'false', 'no', 'n', '0', 'disabled'};

bool? parseProjectCustomAttributeBool(String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized.isEmpty) return null;
  if (projectCustomAttributeTruthyValues.contains(normalized)) return true;
  if (projectCustomAttributeFalsyValues.contains(normalized)) return false;
  return null;
}

String projectCustomAttributeBooleanDisplayValue(String value) {
  final parsed = parseProjectCustomAttributeBool(value);
  if (parsed == true) return 'Yes';
  if (parsed == false) return 'No';
  return value.trim();
}

String projectCustomAttributeBooleanEditValue(String value) {
  final parsed = parseProjectCustomAttributeBool(value);
  if (parsed == true) return 'Yes';
  if (parsed == false) return 'No';
  return '';
}

double? parseProjectCustomAttributeNumber(String value) {
  final normalized = value.trim().replaceAll(',', '');
  if (normalized.isEmpty) return null;

  final number = double.tryParse(normalized);
  return number != null && number.isFinite ? number : null;
}

DateTime? parseProjectCustomAttributeIsoDate(String value) {
  final normalized = value.trim();
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(normalized);
  if (match == null) return null;

  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  final date = DateTime.tryParse(normalized);

  if (date == null ||
      date.year != year ||
      date.month != month ||
      date.day != day) {
    return null;
  }

  return date;
}

Uri? parseProjectCustomAttributeWebUrl(String value) {
  final uri = Uri.tryParse(value.trim());
  if (uri == null) return null;
  if (uri.scheme != 'http' && uri.scheme != 'https') return null;
  if (uri.host.trim().isEmpty) return null;
  return uri;
}
