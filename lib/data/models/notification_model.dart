import 'package:equatable/equatable.dart';

enum NotificationType {
  taskAssigned,
  taskDueSoon,
  taskOverdue,
  commentAdded,
  memberJoined,
  projectInvite,
  taskMoved,
  mention,
}

class NotificationModel extends Equatable {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.data = const {},
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: _parseType(json['type'] as String),
      title: json['title'] as String,
      body: json['body'] as String,
      data: json['data'] as Map<String, dynamic>? ?? {},
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static NotificationType _parseType(String type) {
    switch (type) {
      case 'task_assigned':
        return NotificationType.taskAssigned;
      case 'task_due_soon':
        return NotificationType.taskDueSoon;
      case 'task_overdue':
        return NotificationType.taskOverdue;
      case 'comment_added':
        return NotificationType.commentAdded;
      case 'member_joined':
        return NotificationType.memberJoined;
      case 'project_invite':
        return NotificationType.projectInvite;
      case 'task_moved':
        return NotificationType.taskMoved;
      case 'mention':
        return NotificationType.mention;
      default:
        return NotificationType.taskAssigned;
    }
  }

  String get typeString {
    switch (type) {
      case NotificationType.taskAssigned:
        return 'task_assigned';
      case NotificationType.taskDueSoon:
        return 'task_due_soon';
      case NotificationType.taskOverdue:
        return 'task_overdue';
      case NotificationType.commentAdded:
        return 'comment_added';
      case NotificationType.memberJoined:
        return 'member_joined';
      case NotificationType.projectInvite:
        return 'project_invite';
      case NotificationType.taskMoved:
        return 'task_moved';
      case NotificationType.mention:
        return 'mention';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': typeString,
      'title': title,
      'body': body,
      'data': data,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, type, title, body, data, isRead, createdAt];
}

