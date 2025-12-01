class ProjectModel {
  final String id;
  final String name;
  final String? description;
  final String colorHex;
  final String? iconName;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;

  ProjectModel({
    required this.id,
    required this.name,
    this.description,
    required this.colorHex,
    this.iconName,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      // Ánh xạ cột 'color' trong DB thành colorHex
      colorHex: json['color'] ?? '#3B82F6',
      // Ánh xạ cột 'icon' trong DB thành iconName
      iconName: json['icon'] ?? 'folder',
      ownerId: json['owner_id'] ?? '',
      createdAt:
          DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now(),
      isArchived: json['is_archived'] ?? false,
    );
  }
}
