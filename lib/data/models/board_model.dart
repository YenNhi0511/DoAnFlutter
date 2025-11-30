import 'package:equatable/equatable.dart';

class BoardModel extends Equatable {
  final String id;
  final String projectId;
  final String name;
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BoardModel({
    required this.id,
    required this.projectId,
    required this.name,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BoardModel.fromJson(Map<String, dynamic> json) {
    return BoardModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      name: json['name'] as String,
      position: json['position'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'name': name,
      'position': position,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'project_id': projectId,
      'name': name,
      'position': position,
    };
  }

  BoardModel copyWith({
    String? id,
    String? projectId,
    String? name,
    int? position,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BoardModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, projectId, name, position, createdAt, updatedAt];
}

