import 'package:voca_do/domain/models/task_type.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final TaskType type;
  final String? contactInfo;
  final String? appPackage;
  final String? location;
  final DateTime? reminderTime;
  final String? imagePath;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.type = TaskType.basic,
    this.contactInfo,
    this.appPackage,
    this.location,
    this.reminderTime,
    this.imagePath,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    TaskType? type,
    String? contactInfo,
    String? appPackage,
    String? location,
    DateTime? reminderTime,
    String? imagePath,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      type: type ?? this.type,
      contactInfo: contactInfo ?? this.contactInfo,
      appPackage: appPackage ?? this.appPackage,
      location: location ?? this.location,
      reminderTime: reminderTime ?? this.reminderTime,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'type': type.name,
      'contactInfo': contactInfo,
      'appPackage': appPackage,
      'location': location,
      'reminderTime': reminderTime?.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      type: TaskType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TaskType.basic,
      ),
      contactInfo: json['contactInfo'] as String?,
      appPackage: json['appPackage'] as String?,
      location: json['location'] as String?,
      reminderTime: json['reminderTime'] != null
          ? DateTime.parse(json['reminderTime'] as String)
          : null,
      imagePath: json['imagePath'] as String?,
    );
  }
}
