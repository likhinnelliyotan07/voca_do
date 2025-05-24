import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voca_do/data/models/task_model.dart';
import 'package:voca_do/data/repositories/task_repository.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

// Events
abstract class TaskEvent {}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final String title;
  final DateTime? dueDate;
  final String? description;
  final String? taskType;
  final String? muscleGroup;
  final DateTime? reminderTime;

  AddTask({
    required this.title,
    this.dueDate,
    this.description,
    this.taskType,
    this.muscleGroup,
    this.reminderTime,
  });
}

class UpdateTask extends TaskEvent {
  final TaskModel task;

  UpdateTask(this.task);
}

class DeleteTask extends TaskEvent {
  final String id;

  DeleteTask(this.id);
}

class ToggleTaskCompletion extends TaskEvent {
  final String id;

  ToggleTaskCompletion(this.id);
}

// States
abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskModel> tasks;

  TaskLoaded(this.tasks);
}

class TaskError extends TaskState {
  final String message;

  TaskError(this.message);
}

class TaskMessage extends TaskState {
  final String message;

  TaskMessage(this.message);
}

// Bloc
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository;

  TaskBloc({required this.taskRepository}) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskCompletion>(_onToggleTaskCompletion);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    try {
      emit(TaskLoading());
      final tasks = await taskRepository.getAllTasks();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      final now = DateTime.now();
      final defaultDueDate = event.dueDate ?? now.add(const Duration(hours: 1));

      // Set reminder time 5 minutes before due time
      final reminderTime = defaultDueDate.subtract(const Duration(minutes: 5));

      // Format title based on task type
      String formattedTitle = event.title;
      if (event.taskType == 'workout') {
        // For workout tasks, format as "Workout - {Muscle Group}"
        final muscleGroup =
            event.muscleGroup?.toString().split('.').last ?? 'Full Body';
        formattedTitle = 'Workout - $muscleGroup';
      } else if (event.taskType == 'meeting') {
        // For meeting tasks, format as "{Title} Meeting"
        formattedTitle = '${event.title} Meeting';
      }

      final task = TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: formattedTitle,
        dueDate: defaultDueDate,
        description: event.description,
        taskType: event.taskType ?? 'basic',
        muscleGroup: event.muscleGroup,
        reminderTime: reminderTime,
      );

      // Schedule notification for the task
      final FlutterLocalNotificationsPlugin notifications =
          FlutterLocalNotificationsPlugin();
      final scheduledTzTime = tz.TZDateTime.from(reminderTime, tz.local);

      await notifications.zonedSchedule(
        task.id.hashCode, // Use task ID as notification ID
        formattedTitle,
        event.description ?? 'Time for your scheduled task!',
        scheduledTzTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel',
            'Tasks',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      await taskRepository.addTask(task);
      add(LoadTasks());
      emit(TaskMessage('Task added successfully'));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$month/$day $hour:$minute';
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.updateTask(event.task);
      add(LoadTasks());
      emit(TaskMessage('Task updated successfully'));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.deleteTask(event.id);
      add(LoadTasks());
      emit(TaskMessage('Task deleted successfully'));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onToggleTaskCompletion(
      ToggleTaskCompletion event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.toggleTaskCompletion(event.id);
      add(LoadTasks());
      emit(TaskMessage('Task status updated'));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
}
