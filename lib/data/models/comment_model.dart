import 'package:equatable/equatable.dart';

class CommentModel extends Equatable {
  final String id;
  final String taskId;
  final String userId;
  final String content;
  final List<String> attachmentUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEdited;

  const CommentModel({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.content,
    this.attachmentUrls = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isEdited = false,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      attachmentUrls: (json['attachment_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isEdited: json['is_edited'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'user_id': userId,
      'content': content,
      'attachment_urls': attachmentUrls,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_edited': isEdited,
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'task_id': taskId,
      'user_id': userId,
      'content': content,
      'attachment_urls': attachmentUrls,
    };
  }

  CommentModel copyWith({
    String? id,
    String? taskId,
    String? userId,
    String? content,
    List<String>? attachmentUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEdited,
  }) {
    return CommentModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEdited: isEdited ?? this.isEdited,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        userId,
        content,
        attachmentUrls,
        createdAt,
        updatedAt,
        isEdited,
      ];
}

