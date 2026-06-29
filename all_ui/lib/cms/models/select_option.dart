class SelectOption {
  final String value;
  final String label;
  final String? description;
  final String? icon;

  const SelectOption({
    required this.value,
    required this.label,
    this.description,
    this.icon,
  });

  Map<String, dynamic> toJson() => {
    'value': value,
    'label': label,
    'description': description,
    'icon': icon,
  };

  factory SelectOption.fromJson(Map<String, dynamic> json) => SelectOption(
    value: json['value'],
    label: json['label'],
    description: json['description'],
    icon: json['icon'],
  );
}
