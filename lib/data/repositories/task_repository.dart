import 'package:hive/hive.dart';
import 'package:voca_do/data/models/task_model.dart';

class TaskRepository {
  final Box<TaskModel> _taskBox;

  TaskRepository() : _taskBox = Hive.box<TaskModel>('tasks');

  Future<List<TaskModel>> getAllTasks() async {
    return _taskBox.values.toList();
  }

  Future<void> addTask(TaskModel task) async {
    await _taskBox.put(task.id, task);
  }

  Future<void> updateTask(TaskModel task) async {
    await _taskBox.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await _taskBox.delete(id);
  }

  Future<void> toggleTaskCompletion(String id) async {
    final task = _taskBox.get(id);
    if (task != null) {
      await _taskBox.put(
        id,
        task.copyWith(isCompleted: !task.isCompleted),
      );
    }
  }

  Future<List<TaskModel>> getTasksByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _taskBox.values
        .where((task) =>
            task.dueDate != null &&
            task.dueDate!.isAfter(startOfDay) &&
            task.dueDate!.isBefore(endOfDay))
        .toList()
      ..sort((a, b) {
        if (a.dueDate == null || b.dueDate == null) return 0;
        return a.dueDate!.compareTo(b.dueDate!);
      });
  }
}
