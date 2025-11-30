import 'package:equatable/equatable.dart';

enum MemberRole {
  owner,
  admin,
  member,
  viewer,
}

class ProjectMemberModel extends Equatable {
  final String id;
  final String projectId;
  final String userId;
  final MemberRole role;
  final DateTime joinedAt;

  const ProjectMemberModel({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.role,
    required this.joinedAt,
  });

  factory ProjectMemberModel.fromJson(Map<String, dynamic> json) {
    return ProjectMemberModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      userId: json['user_id'] as String,
      role: _parseRole(json['role'] as String?),
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  static MemberRole _parseRole(String? role) {
    switch (role) {
      case 'owner':
        return MemberRole.owner;
      case 'admin':
        return MemberRole.admin;
      case 'viewer':
        return MemberRole.viewer;
      default:
        return MemberRole.member;
    }
  }

  String get roleString {
    switch (role) {
      case MemberRole.owner:
        return 'owner';
      case MemberRole.admin:
        return 'admin';
      case MemberRole.member:
        return 'member';
      case MemberRole.viewer:
        return 'viewer';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'user_id': userId,
      'role': roleString,
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'project_id': projectId,
      'user_id': userId,
      'role': roleString,
    };
  }

  ProjectMemberModel copyWith({
    String? id,
    String? projectId,
    String? userId,
    MemberRole? role,
    DateTime? joinedAt,
  }) {
    return ProjectMemberModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  List<Object?> get props => [id, projectId, userId, role, joinedAt];
}

