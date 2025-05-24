import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:voca_do/data/models/task_model.dart';
import 'package:voca_do/presentation/blocs/task_bloc.dart';
import 'package:voca_do/presentation/screens/task_edit_screen.dart';
import 'package:voca_do/domain/models/task.dart';
import 'package:voca_do/domain/models/task_type.dart';
import 'package:voca_do/domain/models/muscle_group.dart';

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  String _searchQuery = '';
  String? _selectedTaskType;
  bool _showCompleted = true;
  String? _selectedDueDateFilter;
  String? _selectedMuscleGroup;
  String _sortBy = 'dueDate'; // 'dueDate', 'createdAt', 'title'

  List<TaskModel> _filterTasks(List<TaskModel> tasks) {
    return tasks.where((task) {
      // Filter by search query
      final matchesSearch =
          task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (task.description
                      ?.toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false);

      // Filter by task type
      final matchesType =
          _selectedTaskType == null || task.taskType == _selectedTaskType;

      // Filter by completion status
      final matchesCompletion = _showCompleted || !task.isCompleted;

      // Filter by muscle group
      final matchesMuscleGroup = _selectedMuscleGroup == null ||
          task.muscleGroup == _selectedMuscleGroup;

      // Filter by due date
      final matchesDueDate = _selectedDueDateFilter == null ||
          _matchesDueDateFilter(task.dueDate, _selectedDueDateFilter!);

      return matchesSearch &&
          matchesType &&
          matchesCompletion &&
          matchesMuscleGroup &&
          matchesDueDate;
    }).toList()
      ..sort((a, b) {
        switch (_sortBy) {
          case 'dueDate':
            if (a.dueDate == null && b.dueDate == null) return 0;
            if (a.dueDate == null) return 1;
            if (b.dueDate == null) return -1;
            return a.dueDate!.compareTo(b.dueDate!);
          case 'createdAt':
            return a.createdAt.compareTo(b.createdAt);
          case 'title':
            return a.title.compareTo(b.title);
          default:
            return 0;
        }
      });
  }

  bool _matchesDueDateFilter(DateTime? dueDate, String filter) {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 7));
    final nextMonth = DateTime(now.year, now.month + 1, now.day);

    switch (filter) {
      case 'today':
        return dueDate.year == today.year &&
            dueDate.month == today.month &&
            dueDate.day == today.day;
      case 'tomorrow':
        return dueDate.year == tomorrow.year &&
            dueDate.month == tomorrow.month &&
            dueDate.day == tomorrow.day;
      case 'thisWeek':
        return dueDate.isAfter(today) && dueDate.isBefore(nextWeek);
      case 'thisMonth':
        return dueDate.isAfter(today) && dueDate.isBefore(nextMonth);
      case 'overdue':
        return dueDate.isBefore(today);
      default:
        return true;
    }
  }

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
      child: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    context.read<TaskBloc>().add(UpdateSearchQuery(value));
                  },
                ),
                const SizedBox(height: 12),
                // Filter Options
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Task Type Filter
                    SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: 'Task Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        value: _selectedTaskType,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Types'),
                          ),
                          ...TaskType.values
                              .map((type) => DropdownMenuItem<String>(
                                    value: type.name,
                                    child: Text(type.label),
                                  )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedTaskType = value;
                          });
                          context
                              .read<TaskBloc>()
                              .add(UpdateTaskTypeFilter(value));
                        },
                      ),
                    ),
                    // Due Date Filter
                    SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: 'Due Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        value: _selectedDueDateFilter,
                        items: const [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text('Any Time'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'today',
                            child: Text('Today'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'tomorrow',
                            child: Text('Tomorrow'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'thisWeek',
                            child: Text('This Week'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'thisMonth',
                            child: Text('This Month'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'overdue',
                            child: Text('Overdue'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedDueDateFilter = value;
                          });
                          context
                              .read<TaskBloc>()
                              .add(UpdateDueDateFilter(value));
                        },
                      ),
                    ),
                    // Muscle Group Filter
                    SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: 'Muscle Group',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        value: _selectedMuscleGroup,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Groups'),
                          ),
                          ...MuscleGroup.values
                              .map((group) => DropdownMenuItem<String>(
                                    value: group.name,
                                    child: Text(group.label),
                                  )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedMuscleGroup = value;
                          });
                          context
                              .read<TaskBloc>()
                              .add(UpdateMuscleGroupFilter(value));
                        },
                      ),
                    ),
                    // Sort By
                    SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: 'Sort By',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        value: _sortBy,
                        items: const [
                          DropdownMenuItem<String>(
                            value: 'dueDate',
                            child: Text('Due Date'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'createdAt',
                            child: Text('Created Date'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'title',
                            child: Text('Title'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _sortBy = value;
                            });
                            context.read<TaskBloc>().add(UpdateSortBy(value));
                          }
                        },
                      ),
                    ),
                    // Show Completed Toggle
                    FilterChip(
                      label: const Text('Show Completed'),
                      selected: _showCompleted,
                      onSelected: (value) {
                        setState(() {
                          _showCompleted = value;
                        });
                        context
                            .read<TaskBloc>()
                            .add(UpdateShowCompletedFilter(value));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Task List
          Expanded(
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
                  // Use the state's filter values
                  _searchQuery = state.searchQuery;
                  _selectedTaskType = state.taskTypeFilter;
                  _showCompleted = state.showCompleted;
                  _selectedDueDateFilter = state.dueDateFilter;
                  _selectedMuscleGroup = state.muscleGroupFilter;
                  _sortBy = state.sortBy;

                  final filteredTasks = _filterTasks(state.tasks);

                  if (filteredTasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
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
          ),
        ],
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
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.task.taskType == 'workout' &&
                              widget.task.muscleGroup != null)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: MuscleGroup.values
                                    .firstWhere(
                                      (group) =>
                                          group.name == widget.task.muscleGroup,
                                      orElse: () => MuscleGroup.fullBody,
                                    )
                                    .color
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
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
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (widget.task.dueDate != null)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _isOverdue(widget.task.dueDate!)
                                    ? Colors.red.withOpacity(0.1)
                                    : Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.clock,
                                    size: 12,
                                    color: _isOverdue(widget.task.dueDate!)
                                        ? Colors.red
                                        : Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      _formatDateTime(widget.task.dueDate!),
                                      style: TextStyle(
                                        color: _isOverdue(widget.task.dueDate!)
                                            ? Colors.red
                                            : Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                    if (_isExpanded)
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            const SizedBox(height: 8),
                            if (widget.task.description != null &&
                                widget.task.description!.isNotEmpty) ...[
                              Text(
                                'Description',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.task.description!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            Text(
                              'Task Details',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  _buildDetailRow('Created At',
                                      _formatDateTime(widget.task.createdAt)),
                                  if (widget.task.dueDate != null)
                                    _buildDetailRow('Due Date',
                                        _formatDateTime(widget.task.dueDate!)),
                                  if (widget.task.reminderTime != null)
                                    _buildDetailRow(
                                        'Reminder Time',
                                        _formatDateTime(
                                            widget.task.reminderTime!)),
                                  if (widget.task.taskType != 'basic')
                                    _buildDetailRow(
                                        'Task Type', widget.task.taskType),
                                  if (widget.task.muscleGroup != null)
                                    _buildDetailRow('Muscle Group',
                                        widget.task.muscleGroup!),
                                  _buildDetailRow('Task ID', widget.task.id),
                                ],
                              ),
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
      prefix =
          '${_getMonthName(dateTime.month)} ${dateTime.day}, ${dateTime.year}';
    }

    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final timeStr =
        '$hour:${dateTime.minute.toString().padLeft(2, '0')} $period';

    return '$prefix at $timeStr';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  bool _isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now());
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
