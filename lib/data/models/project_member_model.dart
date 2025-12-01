// Enum quan trọng bị thiếu gây lỗi
enum MemberRole { owner, admin, member, viewer }

class ProjectMemberModel {
  final String id;
  final String projectId;
  final String userId;
  final MemberRole role;
  // Các trường bổ sung để hiển thị UI (name, avatar, email...)
  // Trong thực tế cần join bảng profiles, ở đây tạm thời dùng giả lập hoặc null
  final String name;
  final String email;
  final String? avatarUrl;
  final bool isOnline;

  const ProjectMemberModel({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.role,
    this.name = 'Unknown',
    this.email = '',
    this.avatarUrl,
    this.isOnline = false,
  });

  factory ProjectMemberModel.fromJson(Map<String, dynamic> json) {
    return ProjectMemberModel(
      id: json['id'] ?? '',
      projectId: json['project_id'] ?? '',
      userId: json['user_id'] ?? '',
      role: _parseRole(json['role']),
      // Giả lập tên từ ID nếu không có thông tin user
      name: 'User ' + (json['user_id'] as String).substring(0, 4),
      email: 'user@example.com',
    );
  }

  static MemberRole _parseRole(String? role) {
    return MemberRole.values.firstWhere(
      (e) => e.name == role,
      orElse: () => MemberRole.viewer,
    );
  }
}
