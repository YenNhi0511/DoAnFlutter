import 'package:equatable/equatable.dart';

enum ColumnType {
  todo,
  inProgress,
  review,
  done,
  custom,
}

class BoardColumnModel extends Equatable {
  final String id;
  final String boardId;
  final String name;
  final int position;
  final String colorHex;
  final ColumnType type;
  final int? taskLimit;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BoardColumnModel({
    required this.id,
    required this.boardId,
    required this.name,
    required this.position,
    required this.colorHex,
    this.type = ColumnType.custom,
    this.taskLimit,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BoardColumnModel.fromJson(Map<String, dynamic> json) {
    return BoardColumnModel(
      id: json['id'] as String,
      boardId: json['board_id'] as String,
      name: json['name'] as String,
      position: json['position'] as int? ?? 0,
      colorHex: json['color_hex'] as String? ?? '#E2E8F0',
      type: _parseColumnType(json['type'] as String?),
      taskLimit: json['task_limit'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static ColumnType _parseColumnType(String? type) {
    switch (type) {
      case 'todo':
        return ColumnType.todo;
      case 'in_progress':
        return ColumnType.inProgress;
      case 'review':
        return ColumnType.review;
      case 'done':
        return ColumnType.done;
      default:
        return ColumnType.custom;
    }
  }

  String get typeString {
    switch (type) {
      case ColumnType.todo:
        return 'todo';
      case ColumnType.inProgress:
        return 'in_progress';
      case ColumnType.review:
        return 'review';
      case ColumnType.done:
        return 'done';
      case ColumnType.custom:
        return 'custom';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'board_id': boardId,
      'name': name,
      'position': position,
      'color_hex': colorHex,
      'type': typeString,
      'task_limit': taskLimit,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'board_id': boardId,
      'name': name,
      'position': position,
      'color_hex': colorHex,
      'type': typeString,
      'task_limit': taskLimit,
    };
  }

  BoardColumnModel copyWith({
    String? id,
    String? boardId,
    String? name,
    int? position,
    String? colorHex,
    ColumnType? type,
    int? taskLimit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BoardColumnModel(
      id: id ?? this.id,
      boardId: boardId ?? this.boardId,
      name: name ?? this.name,
      position: position ?? this.position,
      colorHex: colorHex ?? this.colorHex,
      type: type ?? this.type,
      taskLimit: taskLimit ?? this.taskLimit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        boardId,
        name,
        position,
        colorHex,
        type,
        taskLimit,
        createdAt,
        updatedAt,
      ];
}

