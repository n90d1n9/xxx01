// Reminder Model
class ReminderSetting {
  final int minutesBefore;
  final bool enabled;

  ReminderSetting({required this.minutesBefore, this.enabled = true});

  Map<String, dynamic> toJson() {
    return {'minutesBefore': minutesBefore, 'enabled': enabled};
  }

  factory ReminderSetting.fromJson(Map<String, dynamic> json) {
    return ReminderSetting(
      minutesBefore: json['minutesBefore'],
      enabled: json['enabled'] ?? true,
    );
  }
}
