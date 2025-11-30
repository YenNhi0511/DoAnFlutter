import 'package:equatable/equatable.dart';

class ProjectModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String ownerId;
  final String colorHex;
  final String? iconName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final List<String> memberIds;

  const ProjectModel({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    required this.colorHex,
    this.iconName,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
    this.memberIds = const [],
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      ownerId: json['owner_id'] as String,
      colorHex: json['color_hex'] as String? ?? '#1E3A5F',
      iconName: json['icon_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isArchived: json['is_archived'] as bool? ?? false,
      memberIds: (json['member_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'owner_id': ownerId,
      'color_hex': colorHex,
      'icon_name': iconName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_archived': isArchived,
      'member_ids': memberIds,
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'description': description,
      'owner_id': ownerId,
      'color_hex': colorHex,
      'icon_name': iconName,
      'is_archived': isArchived,
    };
  }

  ProjectModel copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    String? colorHex,
    String? iconName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
    List<String>? memberIds,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      memberIds: memberIds ?? this.memberIds,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        ownerId,
        colorHex,
        iconName,
        createdAt,
        updatedAt,
        isArchived,
        memberIds,
      ];
}

