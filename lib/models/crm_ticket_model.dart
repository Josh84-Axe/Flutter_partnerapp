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
  final String senderType; // 'user' or 'agent'
  final DateTime? createdAt;

  CrmMessage({
    required this.id,
    required this.content,
    required this.senderType,
    this.createdAt,
  });

  factory CrmMessage.fromJson(Map<String, dynamic> json) {
    return CrmMessage(
      id: json['id']?.toString() ?? '',
      content: json['content'] ?? '',
      senderType: json['sender_type'] ?? 'agent',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender_type': senderType,
      'created_at': createdAt?.toIso8601String(),
    };
  }
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
