import 'dart:convert';

class Ticket {
  int id;
  String ticketNumber;
  String? customerName;
  String? customerPhone;
  String? customerEmail;
  String? customerPhoto;
  String customerLanguage;
  String? notes;
  String? internalNotes;
  DateTime checkInTime;
  DateTime? estimatedServiceTime;
  DateTime? startServiceTime;
  DateTime? endServiceTime;
  int? waitingTime;
  int? serviceTime;
  bool isNotified;
  bool isPriority;
  int notificationCount;
  String? notificationHistory;
  String? customFields;
  String? sourceChannel;
  String? barcode;
  String? qrCode;
  String? signature;
  String? attachments;
  String? feedback;
  int? feedbackRating;
  int rebookCount;
  bool? isFirstVisit;
  DateTime createdAt;
  DateTime? updatedAt;
  int? createdBy;
  int? updatedBy;
  TicketStatus status;
  TicketPriority priority;
  TicketSourceType sourceType;

  Ticket({
    required this.id,
    required this.ticketNumber,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.customerPhoto,
    this.customerLanguage = "en",
    this.notes,
    this.internalNotes,
    required this.checkInTime,
    this.estimatedServiceTime,
    this.startServiceTime,
    this.endServiceTime,
    this.waitingTime,
    this.serviceTime,
    this.isNotified = false,
    this.isPriority = false,
    this.notificationCount = 0,
    this.notificationHistory,
    this.customFields,
    this.sourceChannel,
    this.barcode,
    this.qrCode,
    this.signature,
    this.attachments,
    this.feedback,
    this.feedbackRating,
    this.rebookCount = 0,
    this.isFirstVisit,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.status = TicketStatus.MENUNGGU,
    this.priority = TicketPriority.NORMAL,
    this.sourceType = TicketSourceType.WALK_IN,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ticketNumber': ticketNumber,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'customerPhoto': customerPhoto,
      'customerLanguage': customerLanguage,
      'notes': notes,
      'internalNotes': internalNotes,
      'checkInTime': checkInTime.toIso8601String(),
      'estimatedServiceTime': estimatedServiceTime?.toIso8601String(),
      'startServiceTime': startServiceTime?.toIso8601String(),
      'endServiceTime': endServiceTime?.toIso8601String(),
      'waitingTime': waitingTime,
      'serviceTime': serviceTime,
      'isNotified': isNotified,
      'isPriority': isPriority,
      'notificationCount': notificationCount,
      'notificationHistory': notificationHistory,
      'customFields': customFields,
      'sourceChannel': sourceChannel,
      'barcode': barcode,
      'qrCode': qrCode,
      'signature': signature,
      'attachments': attachments,
      'feedback': feedback,
      'feedbackRating': feedbackRating,
      'rebookCount': rebookCount,
      'isFirstVisit': isFirstVisit,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'sourceType': sourceType.toString().split('.').last,
    };
  }

  factory Ticket.fromMap(Map<String, dynamic> map) {
    return Ticket(
      id: map['id'],
      ticketNumber: map['ticketNumber'],
      customerName: map['customerName'],
      customerPhone: map['customerPhone'],
      customerEmail: map['customerEmail'],
      customerPhoto: map['customerPhoto'],
      customerLanguage: map['customerLanguage'],
      notes: map['notes'],
      internalNotes: map['internalNotes'],
      checkInTime: DateTime.parse(map['checkInTime']),
      estimatedServiceTime:
          map['estimatedServiceTime'] != null
              ? DateTime.parse(map['estimatedServiceTime'])
              : null,
      startServiceTime:
          map['startServiceTime'] != null
              ? DateTime.parse(map['startServiceTime'])
              : null,
      endServiceTime:
          map['endServiceTime'] != null
              ? DateTime.parse(map['endServiceTime'])
              : null,
      waitingTime: map['waitingTime'],
      serviceTime: map['serviceTime'],
      isNotified: map['isNotified'],
      isPriority: map['isPriority'],
      notificationCount: map['notificationCount'],
      notificationHistory: map['notificationHistory'],
      customFields: map['customFields'],
      sourceChannel: map['sourceChannel'],
      barcode: map['barcode'],
      qrCode: map['qrCode'],
      signature: map['signature'],
      attachments: map['attachments'],
      feedback: map['feedback'],
      feedbackRating: map['feedbackRating'],
      rebookCount: map['rebookCount'],
      isFirstVisit: map['isFirstVisit'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      createdBy: map['createdBy'],
      updatedBy: map['updatedBy'],
      status: TicketStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
      ),
      priority: TicketPriority.values.firstWhere(
        (e) => e.toString().split('.').last == map['priority'],
      ),
      sourceType: TicketSourceType.values.firstWhere(
        (e) => e.toString().split('.').last == map['sourceType'],
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Ticket.fromJson(String source) => Ticket.fromMap(json.decode(source));

  Ticket copyWith({
    int? id,
    String? ticketNumber,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? customerPhoto,
    String? customerLanguage,
    String? notes,
    String? internalNotes,
    DateTime? checkInTime,
    DateTime? estimatedServiceTime,
    DateTime? startServiceTime,
    DateTime? endServiceTime,
    int? waitingTime,
    int? serviceTime,
    bool? isNotified,
    bool? isPriority,
    int? notificationCount,
    String? notificationHistory,
    String? customFields,
    String? sourceChannel,
    String? barcode,
    String? qrCode,
    String? signature,
    String? attachments,
    String? feedback,
    int? feedbackRating,
    int? rebookCount,
    bool? isFirstVisit,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdBy,
    int? updatedBy,
    TicketStatus? status,
    TicketPriority? priority,
    TicketSourceType? sourceType,
  }) {
    return Ticket(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhoto: customerPhoto ?? this.customerPhoto,
      customerLanguage: customerLanguage ?? this.customerLanguage,
      notes: notes ?? this.notes,
      internalNotes: internalNotes ?? this.internalNotes,
      checkInTime: checkInTime ?? this.checkInTime,
      estimatedServiceTime: estimatedServiceTime ?? this.estimatedServiceTime,
      startServiceTime: startServiceTime ?? this.startServiceTime,
      endServiceTime: endServiceTime ?? this.endServiceTime,
      waitingTime: waitingTime ?? this.waitingTime,
      serviceTime: serviceTime ?? this.serviceTime,
      isNotified: isNotified ?? this.isNotified,
      isPriority: isPriority ?? this.isPriority,
      notificationCount: notificationCount ?? this.notificationCount,
      notificationHistory: notificationHistory ?? this.notificationHistory,
      customFields: customFields ?? this.customFields,
      sourceChannel: sourceChannel ?? this.sourceChannel,
      barcode: barcode ?? this.barcode,
      qrCode: qrCode ?? this.qrCode,
      signature: signature ?? this.signature,
      attachments: attachments ?? this.attachments,
      feedback: feedback ?? this.feedback,
      feedbackRating: feedbackRating ?? this.feedbackRating,
      rebookCount: rebookCount ?? this.rebookCount,
      isFirstVisit: isFirstVisit ?? this.isFirstVisit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      sourceType: sourceType ?? this.sourceType,
    );
  }

  @override
  String toString() {
    return 'Ticket(id: $id, ticketNumber: $ticketNumber, customerName: $customerName, customerPhone: $customerPhone, customerEmail: $customerEmail, customerPhoto: $customerPhoto, customerLanguage: $customerLanguage, notes: $notes, internalNotes: $internalNotes, checkInTime: $checkInTime, estimatedServiceTime: $estimatedServiceTime, startServiceTime: $startServiceTime, endServiceTime: $endServiceTime, waitingTime: $waitingTime, serviceTime: $serviceTime, isNotified: $isNotified, isPriority: $isPriority, notificationCount: $notificationCount, notificationHistory: $notificationHistory, customFields: $customFields, sourceChannel: $sourceChannel, barcode: $barcode, qrCode: $qrCode, signature: $signature, attachments: $attachments, feedback: $feedback, feedbackRating: $feedbackRating, rebookCount: $rebookCount, isFirstVisit: $isFirstVisit, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy, updatedBy: $updatedBy, status: $status, priority: $priority, sourceType: $sourceType)';
  }
}

// Enums in Bahasa Indonesia
enum TicketStatus {
  DITERBITKAN,
  MENUNGGU,
  DIPANGGIL,
  MELAYANI,
  SELESAI,
  DIBATALKAN,
  TIDAK_HADIR,
  DITRANSFER,
}

enum TicketPriority { NORMAL, PRIORITAS, VIP }

enum TicketSourceType { WALK_IN, ONLINE, TELEPON }
