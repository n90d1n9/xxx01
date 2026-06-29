
class MatrixOptions {
  final List<MatrixRow> rows;
  final List<MatrixColumn> columns;
  final bool allowMultipleResponses;
  final bool requireAllRows;
  final bool randomizeRows;

  MatrixOptions({
    required this.rows,
    required this.columns,
    required this.allowMultipleResponses,
    required this.requireAllRows,
    required this.randomizeRows,
  });

  Map<String, dynamic> toJson() => {
        'rows': rows.map((r) => r.toJson()).toList(),
        'columns': columns.map((c) => c.toJson()).toList(),
        'allowMultipleResponses': allowMultipleResponses,
        'requireAllRows': requireAllRows,
        'randomizeRows': randomizeRows,
      };

  factory MatrixOptions.fromJson(Map<String, dynamic> json) => MatrixOptions(
        rows: (json['rows'] as List).map((r) => MatrixRow.fromJson(r)).toList(),
        columns: (json['columns'] as List)
            .map((c) => MatrixColumn.fromJson(c))
            .toList(),
        allowMultipleResponses: json['allowMultipleResponses'],
        requireAllRows: json['requireAllRows'],
        randomizeRows: json['randomizeRows'],
      );
}

class MatrixRow {
  final String id;
  final String text;
  final String? description;

  MatrixRow({
    required this.id,
    required this.text,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'description': description,
      };

  factory MatrixRow.fromJson(Map<String, dynamic> json) => MatrixRow(
        id: json['id'],
        text: json['text'],
        description: json['description'],
      );
}

class MatrixColumn {
  final String id;
  final String text;
  final dynamic value;

  MatrixColumn({
    required this.id,
    required this.text,
    required this.value,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'value': value,
      };

  factory MatrixColumn.fromJson(Map<String, dynamic> json) => MatrixColumn(
        id: json['id'],
        text: json['text'],
        value: json['value'],
      );
}
