import 'package:equatable/equatable.dart';

class LabelModel extends Equatable {
  final String id;
  final String projectId;
  final String name;
  final String colorHex;
  final DateTime createdAt;

  const LabelModel({
    required this.id,
    required this.projectId,
    required this.name,
    required this.colorHex,
    required this.createdAt,
  });

  factory LabelModel.fromJson(Map<String, dynamic> json) {
    return LabelModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      name: json['name'] as String,
      colorHex: json['color_hex'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'name': name,
      'color_hex': colorHex,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'project_id': projectId,
      'name': name,
      'color_hex': colorHex,
    };
  }

  LabelModel copyWith({
    String? id,
    String? projectId,
    String? name,
    String? colorHex,
    DateTime? createdAt,
  }) {
    return LabelModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, projectId, name, colorHex, createdAt];
}

