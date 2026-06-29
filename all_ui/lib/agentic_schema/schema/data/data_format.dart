import '../common/compression_type.dart';
import 'data_format_type.dart';

class DataFormat {
  final DataFormatType type;
  final String? schema;
  final String? charset;
  final CompressionType? compression;

  DataFormat({required this.type, this.schema, this.charset, this.compression});

  factory DataFormat.fromJson(Map<String, dynamic> json) {
    return DataFormat(
      type: _parseDataFormatType(json['type']),
      schema: json['schema'] as String?,
      charset: json['charset'] as String?,
      compression: json['compression'] != null
          ? _parseCompressionType(json['compression'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      if (schema != null) 'schema': schema,
      if (charset != null) 'charset': charset,
      if (compression != null) 'compression': compression!.name,
    };
  }

  static DataFormatType _parseDataFormatType(dynamic value) {
    if (value is DataFormatType) return value;
    final stringValue = value.toString();
    return DataFormatType.values.firstWhere(
      (e) => e.name == stringValue,
      orElse: () => DataFormatType.json,
    );
  }

  static CompressionType _parseCompressionType(dynamic value) {
    if (value is CompressionType) return value;
    final stringValue = value.toString();
    return CompressionType.values.firstWhere(
      (e) => e.name == stringValue,
      orElse: () => CompressionType.none,
    );
  }
}
