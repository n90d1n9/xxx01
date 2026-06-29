import 'env_var_source.dart';

class EnvVar {
  final String name;
  final String? value;
  final EnvVarSource? valueFrom;
  EnvVar({required this.name, this.value, this.valueFrom});
  factory EnvVar.fromJson(Map<String, dynamic> json) {
    return EnvVar(
      name: json['name'],
      value: json['value'],
      valueFrom:
          json['valueFrom'] != null
              ? EnvVarSource.fromJson(json['valueFrom'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (value != null) 'value': value,
      if (valueFrom != null) 'valueFrom': valueFrom!.toJson(),
    };
  }
}
