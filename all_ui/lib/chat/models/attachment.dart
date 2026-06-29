enum AttachmentType { image, document, video, audio, voice, gif, sticker }

class Attachment {
  final String id;
  final String name;
  final String url;
  final AttachmentType type;
  final int? size;
  final String? thumbnail;
  final Duration? duration;
  final Map<String, dynamic>? metadata;

  Attachment({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    this.size,
    this.thumbnail,
    this.duration,
    this.metadata,
  });
}
