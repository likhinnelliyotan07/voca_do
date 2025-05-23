import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime? dueDate;

  @HiveField(3)
  final bool isCompleted;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final String? relatedTaskId;

  @HiveField(6)
  final String taskType;

  TaskModel({
    required this.id,
    required this.title,
    this.dueDate,
    this.isCompleted = false,
    DateTime? createdAt,
    this.relatedTaskId,
    this.taskType = 'basic',
  }) : createdAt = createdAt ?? DateTime.now();

  TaskModel copyWith({
    String? id,
    String? title,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdAt,
    String? relatedTaskId,
    String? taskType,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      relatedTaskId: relatedTaskId ?? this.relatedTaskId,
      taskType: taskType ?? this.taskType,
    );
  }
}
