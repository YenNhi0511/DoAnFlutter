import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum TaskPriority { low, medium, high, urgent }

class TaskModel {
  final String id;
  final String columnId;
  final String? boardId;
  final String projectId;
  final String title;
  final String? description;
  final TaskPriority priority;
  final DateTime? dueDate;
  final List<String> attachmentUrls;
  final String createdById;
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompleted;

  // --- CÁC TRƯỜNG MỚI ĐƯỢC THÊM ---
  final List<String> labelIds; // Danh sách ID nhãn
  final String? assigneeId; // ID người được giao việc

  TaskModel({
    required this.id,
    required this.columnId,
    this.boardId,
    required this.projectId,
    required this.title,
    this.description,
    required this.priority,
    this.dueDate,
    required this.attachmentUrls,
    required this.createdById,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
    this.isCompleted = false,
    this.labelIds = const [], // Mặc định rỗng
    this.assigneeId, // Có thể null
  });

  // Chuyển đổi từ JSON (Database) sang Object
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      columnId: json['column_id'] ?? '',
      boardId: json['board_id'],
      projectId: json['project_id'] ?? '',
      title: json['title'] ?? 'No Title',
      description: json['description'],
      priority: _parsePriority(json['priority']),
      dueDate:
          json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      attachmentUrls: List<String>.from(json['attachment_urls'] ?? []),
      createdById: json['created_by_id'] ?? '',
      position: json['position'] ?? 0,
      createdAt:
          DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now(),
      isCompleted: json['is_completed'] ?? false,

      // Ánh xạ các trường mới từ JSON
      labelIds: List<String>.from(json['label_ids'] ?? []),
      assigneeId: json['assignee_id'],
    );
  }

  // Chuyển đổi từ Object sang JSON (để gửi lên Database)
  Map<String, dynamic> toJson() {
    return {
      'column_id': columnId,
      'board_id': boardId,
      'project_id': projectId,
      'title': title,
      'description': description,
      'priority': priority.name,
      'due_date': dueDate?.toIso8601String(),
      'attachment_urls': attachmentUrls,
      'created_by_id': createdById,
      'position': position,
      'is_completed': isCompleted,
      'updated_at': DateTime.now().toIso8601String(),

      // Gửi các trường mới lên Database
      'label_ids': labelIds,
      'assignee_id': assigneeId,
    };
  }

  TaskModel copyWith({
    String? title,
    String? description,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? updatedAt,
    List<String>? labelIds,
    String? assigneeId,
  }) {
    return TaskModel(
      id: id,
      columnId: columnId,
      boardId: boardId,
      projectId: projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      attachmentUrls: attachmentUrls,
      createdById: createdById,
      position: position,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      labelIds: labelIds ?? this.labelIds,
      assigneeId: assigneeId ?? this.assigneeId,
    );
  }

  static TaskPriority _parsePriority(String? value) {
    return TaskPriority.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskPriority.medium,
    );
  }
}
