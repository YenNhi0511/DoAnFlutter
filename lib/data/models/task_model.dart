import 'package:equatable/equatable.dart';

enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

class TaskModel extends Equatable {
  final String id;
  final String columnId;
  final String boardId;
  final String projectId;
  final String title;
  final String? description;
  final int position;
  final TaskPriority priority;
  final DateTime? dueDate;
  final String? assigneeId;
  final String createdById;
  final List<String> labelIds;
  final List<String> attachmentUrls;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskModel({
    required this.id,
    required this.columnId,
    required this.boardId,
    required this.projectId,
    required this.title,
    this.description,
    required this.position,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.assigneeId,
    required this.createdById,
    this.labelIds = const [],
    this.attachmentUrls = const [],
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      columnId: json['column_id'] as String,
      boardId: json['board_id'] as String,
      projectId: json['project_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      position: json['position'] as int? ?? 0,
      priority: _parsePriority(json['priority'] as String?),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      assigneeId: json['assignee_id'] as String?,
      createdById: json['created_by_id'] as String,
      labelIds: (json['label_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      attachmentUrls: (json['attachment_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static TaskPriority _parsePriority(String? priority) {
    switch (priority) {
      case 'low':
        return TaskPriority.low;
      case 'high':
        return TaskPriority.high;
      case 'urgent':
        return TaskPriority.urgent;
      default:
        return TaskPriority.medium;
    }
  }

  String get priorityString {
    switch (priority) {
      case TaskPriority.low:
        return 'low';
      case TaskPriority.medium:
        return 'medium';
      case TaskPriority.high:
        return 'high';
      case TaskPriority.urgent:
        return 'urgent';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'column_id': columnId,
      'board_id': boardId,
      'project_id': projectId,
      'title': title,
      'description': description,
      'position': position,
      'priority': priorityString,
      'due_date': dueDate?.toIso8601String(),
      'assignee_id': assigneeId,
      'created_by_id': createdById,
      'label_ids': labelIds,
      'attachment_urls': attachmentUrls,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'column_id': columnId,
      'board_id': boardId,
      'project_id': projectId,
      'title': title,
      'description': description,
      'position': position,
      'priority': priorityString,
      'due_date': dueDate?.toIso8601String(),
      'assignee_id': assigneeId,
      'created_by_id': createdById,
      'label_ids': labelIds,
      'attachment_urls': attachmentUrls,
      'is_completed': isCompleted,
    };
  }

  TaskModel copyWith({
    String? id,
    String? columnId,
    String? boardId,
    String? projectId,
    String? title,
    String? description,
    int? position,
    TaskPriority? priority,
    DateTime? dueDate,
    String? assigneeId,
    String? createdById,
    List<String>? labelIds,
    List<String>? attachmentUrls,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      columnId: columnId ?? this.columnId,
      boardId: boardId ?? this.boardId,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      position: position ?? this.position,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      assigneeId: assigneeId ?? this.assigneeId,
      createdById: createdById ?? this.createdById,
      labelIds: labelIds ?? this.labelIds,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        columnId,
        boardId,
        projectId,
        title,
        description,
        position,
        priority,
        dueDate,
        assigneeId,
        createdById,
        labelIds,
        attachmentUrls,
        isCompleted,
        completedAt,
        createdAt,
        updatedAt,
      ];
}

