class FormFieldOption {
  final String label;
  final dynamic value;
  final bool disabled;

  FormFieldOption({
    required this.label,
    required this.value,
    this.disabled = false,
  });

  factory FormFieldOption.fromJson(Map<String, dynamic> json) {
    return FormFieldOption(
      label: json['label'] as String,
      value: json['value'],
      disabled: json['disabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'value': value,
    'disabled': disabled,
  };
}
