class CrmTicket {
  final String id;
  final String subject;
  final String description;
  final String contactEmail;
  final String contactName;
  final String priority;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CrmTicket({
    required this.id,
    required this.subject,
    required this.description,
    required this.contactEmail,
    required this.contactName,
    required this.priority,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory CrmTicket.fromJson(Map<String, dynamic> json) {
    return CrmTicket(
      id: json['id']?.toString() ?? '',
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      contactEmail: json['contact_email'] ?? '',
      contactName: json['contact_name'] ?? '',
      priority: json['priority'] ?? 'LOW',
      status: json['status'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'description': description,
      'contact_email': contactEmail,
      'contact_name': contactName,
      'priority': priority,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class CrmMessage {
  final String id;
  final String content;
  final String direction; // 'INBOUND' or 'OUTBOUND'
  final String senderName;
  final DateTime? sentAt;
  final bool isInternal;

  CrmMessage({
    required this.id,
    required this.content,
    required this.direction,
    required this.senderName,
    this.sentAt,
    this.isInternal = false,
  });

  factory CrmMessage.fromJson(Map<String, dynamic> json) {
    return CrmMessage(
      id: json['id']?.toString() ?? '',
      content: json['content'] ?? '',
      direction: json['direction'] ?? 'OUTBOUND',
      senderName: json['sender_name'] ?? 'Agent',
      sentAt: json['sent_at'] != null ? DateTime.tryParse(json['sent_at']) : null,
      isInternal: json['is_internal'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'direction': direction,
      'sender_name': senderName,
      'sent_at': sentAt?.toIso8601String(),
      'is_internal': isInternal,
    };
  }

  bool get isFromUser => direction == 'INBOUND';
}

class CrmTicketPayload {
  final String subject;
  final String description;
  final String contactEmail;
  final String contactName;
  final String priority;

  CrmTicketPayload({
    required this.subject,
    required this.description,
    required this.contactEmail,
    required this.contactName,
    required this.priority,
  });

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'description': description,
      'contact_email': contactEmail,
      'contact_name': contactName,
      'priority': priority,
    };
  }
}
