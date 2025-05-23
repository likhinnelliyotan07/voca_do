import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:voca_do/data/models/task_model.dart';
import 'package:voca_do/presentation/blocs/task_bloc.dart';
import 'package:voca_do/presentation/screens/task_edit_screen.dart';
import 'package:voca_do/domain/models/task.dart';
import 'package:voca_do/domain/models/task_type.dart';
import 'package:voca_do/domain/models/muscle_group.dart';

class TaskList extends StatelessWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading tasks...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          if (state is TaskError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.triangleExclamation,
                    size: 48,
                    color: Colors.red.withOpacity(0.7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          if (state is TaskLoaded) {
            if (state.tasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.listCheck,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tasks yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the microphone to add a task',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.tasks.length,
              itemBuilder: (context, index) {
                final task = state.tasks[index];
                return AnimatedTaskCard(
                  task: task,
                  index: index,
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class AnimatedTaskCard extends StatefulWidget {
  final TaskModel task;
  final int index;

  const AnimatedTaskCard({
    super.key,
    required this.task,
    required this.index,
  });

  @override
  State<AnimatedTaskCard> createState() => _AnimatedTaskCardState();
}

class _AnimatedTaskCardState extends State<AnimatedTaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Column(
                  children: [
                    ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: widget.task.isCompleted,
                            onChanged: (value) {
                              context
                                  .read<TaskBloc>()
                                  .add(ToggleTaskCompletion(widget.task.id));
                            },
                          ),
                          Icon(
                            TaskType.values
                                .firstWhere(
                                  (type) => type.name == widget.task.taskType,
                                  orElse: () => TaskType.basic,
                                )
                                .icon,
                            color: TaskType.values
                                .firstWhere(
                                  (type) => type.name == widget.task.taskType,
                                  orElse: () => TaskType.basic,
                                )
                                .color,
                          ),
                        ],
                      ),
                      title: Text(
                        widget.task.title,
                        style: TextStyle(
                          decoration: widget.task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.task.taskType == 'workout' &&
                              widget.task.muscleGroup != null)
                            Row(
                              children: [
                                Icon(
                                  MuscleGroup.values
                                      .firstWhere(
                                        (group) =>
                                            group.name ==
                                            widget.task.muscleGroup,
                                        orElse: () => MuscleGroup.fullBody,
                                      )
                                      .icon,
                                  size: 12,
                                  color: MuscleGroup.values
                                      .firstWhere(
                                        (group) =>
                                            group.name ==
                                            widget.task.muscleGroup,
                                        orElse: () => MuscleGroup.fullBody,
                                      )
                                      .color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  MuscleGroup.values
                                      .firstWhere(
                                        (group) =>
                                            group.name ==
                                            widget.task.muscleGroup,
                                        orElse: () => MuscleGroup.fullBody,
                                      )
                                      .label,
                                  style: TextStyle(
                                    color: MuscleGroup.values
                                        .firstWhere(
                                          (group) =>
                                              group.name ==
                                              widget.task.muscleGroup,
                                          orElse: () => MuscleGroup.fullBody,
                                        )
                                        .color,
                                  ),
                                ),
                              ],
                            ),
                          if (widget.task.dueDate != null)
                            Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.clock,
                                  size: 12,
                                  color: _isOverdue(widget.task.dueDate!)
                                      ? Colors.red
                                      : Theme.of(context).colorScheme.secondary,
                                ),
                                const SizedBox(width: 4),
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    'Due: ${_formatDateTime(widget.task.dueDate!)}',
                                    style: TextStyle(
                                      color: _isOverdue(widget.task.dueDate!)
                                          ? Colors.red
                                          : Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: FaIcon(
                              FontAwesomeIcons.penToSquare,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TaskEditScreen(
                                    task: Task(
                                      id: widget.task.id,
                                      title: widget.task.title,
                                      description:
                                          widget.task.description ?? '',
                                      createdAt: widget.task.createdAt,
                                      type: TaskType.basic,
                                    ),
                                  ),
                                ),
                              );
                              if (result != null) {
                                context.read<TaskBloc>().add(
                                      UpdateTask(
                                        TaskModel(
                                          id: result.id,
                                          title: result.title,
                                          description: result.description,
                                          dueDate: widget.task.dueDate,
                                          isCompleted: widget.task.isCompleted,
                                          createdAt: result.createdAt,
                                        ),
                                      ),
                                    );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Task updated successfully'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: FaIcon(
                              FontAwesomeIcons.trash,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            onPressed: () {
                              context
                                  .read<TaskBloc>()
                                  .add(DeleteTask(widget.task.id));
                            },
                          ),
                        ],
                      ),
                    ),
                    if (_isExpanded &&
                        widget.task.description != null &&
                        widget.task.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            const SizedBox(height: 8),
                            Text(
                              'Description:',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.task.description!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String prefix = '';
    if (taskDate == today) {
      prefix = 'Today';
    } else if (taskDate == tomorrow) {
      prefix = 'Tomorrow';
    } else {
      prefix = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    return '$prefix at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  bool _isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now());
  }
}
