import 'dart:convert';

enum TypeFile { pdf, docx, pptx, ppt, xls, xlsx }

// Models
class FileBook {
  final String id;
  final String title;
  final String author;
  final String thumbnailUrl;
  final String downloadUrl;
  final int pages;
  final double size; // in MB
  final String category;
  final TypeFile filteType;

  FileBook(
      {required this.id,
      required this.title,
      required this.author,
      required this.thumbnailUrl,
      required this.downloadUrl,
      required this.pages,
      required this.size,
      required this.category,
      this.filteType = TypeFile.pdf});

  factory FileBook.fromJson(String str) => FileBook.fromMap(json.decode(str));

  factory FileBook.fromMap(Map<String, dynamic> json) => FileBook(
        id: json['id'],
        title: json['title'],
        author: json['author'],
        thumbnailUrl: json['thumbnailUrl'],
        downloadUrl: json['downloadUrl'],
        pages: json['pages'],
        size: json['size']?.toDouble(),
        category: json['category'],
        filteType: TypeFile.values[json['filteType'] ?? 0],
      );

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'author': author,
        'thumbnailUrl': thumbnailUrl,
        'downloadUrl': downloadUrl,
        'pages': pages,
        'size': size,
        'category': category,
        'filteType': filteType.index,
      };

  static List<FileBook> fromList(List<dynamic> list) =>
      List<FileBook>.from(list.map((x) => FileBook.fromMap(x)));

  @override
  String toString() =>
      'FileBook(id: $id, title: $title, author: $author, thumbnailUrl: $thumbnailUrl, downloadUrl: $downloadUrl, pages: $pages, size: $size, category: $category, filteType: $filteType)';
}
