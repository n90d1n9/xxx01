

class Attachment {
  final String id;
  final String name;
  final String url;
  final DateTime uploadDate;
  final DateTime timestamp;
  
  Attachment({required this.uploadDate,
    required this.id,
    required this.name,
    required this.url,
    required this.timestamp,
  });
}


// Enum for attachment types
enum AttachmentType { file, link, image }


// Model for Task Attachments
class TaskAttachment {
  final String? id;
  final String? name;
  final AttachmentType? type;
  final String? url;
  final DateTime? uploadedAt;
  final int? size;
  final String? path;

  TaskAttachment({
     this.id,
     this.name,
     this.type,
     this.url,
     this.size,
     this.path,
    DateTime? uploadedAt,
  }) : uploadedAt = uploadedAt ?? DateTime.now();
}