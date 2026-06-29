import '../../survey/pool.dart';
import 'attachment.dart';
import 'contact.dart';
import 'location.dart';
import 'message_reaction.dart';
import 'voice_note.dart';

enum MessageStatus { sending, sent, delivered, read, failed }

enum MessageType {
  text,
  image,
  file,
  voice,
  video,
  location,
  contact,
  poll,
  sticker,
  gif,
}

class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final List<Attachment> attachments;
  final bool isMe;
  final MessageStatus status;
  final String? replyToId;
  final bool isForwarded;
  final bool isEdited;
  final DateTime? editedAt;
  final List<MessageReaction> reactions;
  final Location? location;
  final Contact? contact;
  final Poll? poll;
  final VoiceNote? voiceNote;
  final bool isStarred;
  final Map<String, dynamic>? metadata;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
    this.attachments = const [],
    this.isMe = false,
    this.status = MessageStatus.sent,
    this.replyToId,
    this.isForwarded = false,
    this.isEdited = false,
    this.editedAt,
    this.reactions = const [],
    this.location,
    this.contact,
    this.poll,
    this.voiceNote,
    this.isStarred = false,
    this.metadata,
  });

  Message copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    MessageType? type,
    List<Attachment>? attachments,
    bool? isMe,
    MessageStatus? status,
    String? replyToId,
    bool? isForwarded,
    bool? isEdited,
    DateTime? editedAt,
    List<MessageReaction>? reactions,
    Location? location,
    Contact? contact,
    Poll? poll,
    VoiceNote? voiceNote,
    bool? isStarred,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      attachments: attachments ?? this.attachments,
      isMe: isMe ?? this.isMe,
      status: status ?? this.status,
      replyToId: replyToId ?? this.replyToId,
      isForwarded: isForwarded ?? this.isForwarded,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      reactions: reactions ?? this.reactions,
      location: location ?? this.location,
      contact: contact ?? this.contact,
      poll: poll ?? this.poll,
      voiceNote: voiceNote ?? this.voiceNote,
      isStarred: isStarred ?? this.isStarred,
      metadata: metadata ?? this.metadata,
    );
  }
}
