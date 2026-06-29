import 'dart:convert';

class Queue {
  int id;
  String name;
  String? description;
  int maxCapacity;
  bool isActive;
  int estimatedWaitTimePerCustomer;
  int? currentWaitTime;
  int? averageServiceTime;
  int displayOrder;
  String? customTicketPrefix;
  int customTicketStartNumber;
  int currentTicketNumber;
  String? operatingHours;
  bool allowPriority;
  bool allowTransfer;
  bool allowRebooking;
  String? customCSS;
  String? customHeaderText;
  String? customFooterText;
  DateTime createdAt;
  DateTime? updatedAt;
  int? createdBy;
  int? updatedBy;
  QueueStatus status;
  QueuePriority priority;
  QueueSortingStrategy sortingStrategy;
  QueueDisplayMode displayMode;

  Queue({
    required this.id,
    required this.name,
    this.description,
    this.maxCapacity = 50,
    this.isActive = true,
    this.estimatedWaitTimePerCustomer = 5,
    this.currentWaitTime,
    this.averageServiceTime,
    this.displayOrder = 0,
    this.customTicketPrefix,
    this.customTicketStartNumber = 1,
    this.currentTicketNumber = 0,
    this.operatingHours,
    this.allowPriority = true,
    this.allowTransfer = true,
    this.allowRebooking = false,
    this.customCSS,
    this.customHeaderText,
    this.customFooterText,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.status = QueueStatus.open,
    this.priority = QueuePriority.normal,
    this.sortingStrategy = QueueSortingStrategy.fifo,
    this.displayMode = QueueDisplayMode.standard,
  });

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'maxCapacity': maxCapacity,
      'isActive': isActive,
      'estimatedWaitTimePerCustomer': estimatedWaitTimePerCustomer,
      'currentWaitTime': currentWaitTime,
      'averageServiceTime': averageServiceTime,
      'displayOrder': displayOrder,
      'customTicketPrefix': customTicketPrefix,
      'customTicketStartNumber': customTicketStartNumber,
      'currentTicketNumber': currentTicketNumber,
      'operatingHours': operatingHours,
      'allowPriority': allowPriority,
      'allowTransfer': allowTransfer,
      'allowRebooking': allowRebooking,
      'customCSS': customCSS,
      'customHeaderText': customHeaderText,
      'customFooterText': customFooterText,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'sortingStrategy': sortingStrategy.toString().split('.').last,
      'displayMode': displayMode.toString().split('.').last,
    };
  }

  // Create from Map
  factory Queue.fromMap(Map<String, dynamic> map) {
    return Queue(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      maxCapacity: map['maxCapacity'],
      isActive: map['isActive'],
      estimatedWaitTimePerCustomer: map['estimatedWaitTimePerCustomer'],
      currentWaitTime: map['currentWaitTime'],
      averageServiceTime: map['averageServiceTime'],
      displayOrder: map['displayOrder'],
      customTicketPrefix: map['customTicketPrefix'],
      customTicketStartNumber: map['customTicketStartNumber'],
      currentTicketNumber: map['currentTicketNumber'],
      operatingHours: map['operatingHours'],
      allowPriority: map['allowPriority'],
      allowTransfer: map['allowTransfer'],
      allowRebooking: map['allowRebooking'],
      customCSS: map['customCSS'],
      customHeaderText: map['customHeaderText'],
      customFooterText: map['customFooterText'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      createdBy: map['createdBy'],
      updatedBy: map['updatedBy'],
      status: QueueStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
      ),
      priority: QueuePriority.values.firstWhere(
        (e) => e.toString().split('.').last == map['priority'],
      ),
      sortingStrategy: QueueSortingStrategy.values.firstWhere(
        (e) => e.toString().split('.').last == map['sortingStrategy'],
      ),
      displayMode: QueueDisplayMode.values.firstWhere(
        (e) => e.toString().split('.').last == map['displayMode'],
      ),
    );
  }

  // Convert to JSON
  String toJson() => json.encode(toMap());

  // Create from JSON
  factory Queue.fromJson(String source) => Queue.fromMap(json.decode(source));

  // CopyWith
  Queue copyWith({
    int? id,
    String? name,
    String? description,
    int? maxCapacity,
    bool? isActive,
    int? estimatedWaitTimePerCustomer,
    int? currentWaitTime,
    int? averageServiceTime,
    int? displayOrder,
    String? customTicketPrefix,
    int? customTicketStartNumber,
    int? currentTicketNumber,
    String? operatingHours,
    bool? allowPriority,
    bool? allowTransfer,
    bool? allowRebooking,
    String? customCSS,
    String? customHeaderText,
    String? customFooterText,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdBy,
    int? updatedBy,
    QueueStatus? status,
    QueuePriority? priority,
    QueueSortingStrategy? sortingStrategy,
    QueueDisplayMode? displayMode,
  }) {
    return Queue(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      isActive: isActive ?? this.isActive,
      estimatedWaitTimePerCustomer:
          estimatedWaitTimePerCustomer ?? this.estimatedWaitTimePerCustomer,
      currentWaitTime: currentWaitTime ?? this.currentWaitTime,
      averageServiceTime: averageServiceTime ?? this.averageServiceTime,
      displayOrder: displayOrder ?? this.displayOrder,
      customTicketPrefix: customTicketPrefix ?? this.customTicketPrefix,
      customTicketStartNumber:
          customTicketStartNumber ?? this.customTicketStartNumber,
      currentTicketNumber: currentTicketNumber ?? this.currentTicketNumber,
      operatingHours: operatingHours ?? this.operatingHours,
      allowPriority: allowPriority ?? this.allowPriority,
      allowTransfer: allowTransfer ?? this.allowTransfer,
      allowRebooking: allowRebooking ?? this.allowRebooking,
      customCSS: customCSS ?? this.customCSS,
      customHeaderText: customHeaderText ?? this.customHeaderText,
      customFooterText: customFooterText ?? this.customFooterText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      sortingStrategy: sortingStrategy ?? this.sortingStrategy,
      displayMode: displayMode ?? this.displayMode,
    );
  }

  @override
  String toString() {
    return 'Queue(id: $id, name: $name, description: $description, maxCapacity: $maxCapacity, isActive: $isActive, estimatedWaitTimePerCustomer: $estimatedWaitTimePerCustomer, currentWaitTime: $currentWaitTime, averageServiceTime: $averageServiceTime, displayOrder: $displayOrder, customTicketPrefix: $customTicketPrefix, customTicketStartNumber: $customTicketStartNumber, currentTicketNumber: $currentTicketNumber, operatingHours: $operatingHours, allowPriority: $allowPriority, allowTransfer: $allowTransfer, allowRebooking: $allowRebooking, customCSS: $customCSS, customHeaderText: $customHeaderText, customFooterText: $customFooterText, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy, updatedBy: $updatedBy, status: $status, priority: $priority, sortingStrategy: $sortingStrategy, displayMode: $displayMode)';
  }
}

// Enums in Bahasa Indonesia
enum QueueStatus { open, closed, pause }

enum QueuePriority { normal, priority, vip }

enum QueueSortingStrategy { fifo, lifo, priority }

enum QueueDisplayMode { standard, compact, detail }
