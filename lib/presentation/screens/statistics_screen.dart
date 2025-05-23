import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voca_do/presentation/blocs/task_bloc.dart';
import 'package:voca_do/data/models/task_model.dart';
import 'dart:math' as math;

enum DateFilter {
  today,
  thisWeek,
  thisMonth,
  allTime,
}

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  DateFilter _selectedFilter = DateFilter.allTime;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TaskLoaded) {
          final tasks = _filterTasksByDate(state.tasks, _selectedFilter);
          final completedTasks = tasks.where((task) => task.isCompleted).length;
          final totalTasks = tasks.length;
          final completionRate =
              totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0;
          final streakDays = _calculateStreak(tasks);

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Task Statistics',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    ],
                  ),
                  _buildDateFilterChips(),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _animationController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(_animationController),
                      child: Column(
                        children: [
                          _buildStatCard(
                            'Task Completion',
                            '${completedTasks.toString()} / ${totalTasks.toString()}',
                            '${completionRate.toStringAsFixed(1)}%',
                            Icons.check_circle_outline,
                            completionRate / 100,
                            context,
                          ),
                          const SizedBox(height: 16),
                          _buildStatCard(
                            'Active Tasks',
                            '${(totalTasks - completedTasks).toString()} tasks',
                            'In Progress',
                            Icons.pending_actions,
                            (totalTasks - completedTasks) /
                                math.max(totalTasks, 1),
                            context,
                          ),
                          const SizedBox(height: 16),
                          _buildStatCard(
                            'Current Streak',
                            '$streakDays days',
                            'Keep it up!',
                            Icons.local_fire_department,
                            math.min(streakDays / 7, 1),
                            context,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const Center(child: Text('No data available'));
      },
    );
  }

  Widget _buildDateFilterChips() {
    return Wrap(
      spacing: 8,
      children: DateFilter.values.map((filter) {
        final isSelected = _selectedFilter == filter;
        return FilterChip(
          selected: isSelected,
          label: Text(_getFilterLabel(filter)),
          onSelected: (selected) {
            setState(() {
              _selectedFilter = filter;
            });
          },
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          checkmarkColor: Theme.of(context).colorScheme.primary,
          labelStyle: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
        );
      }).toList(),
    );
  }

  String _getFilterLabel(DateFilter filter) {
    switch (filter) {
      case DateFilter.today:
        return 'Today';
      case DateFilter.thisWeek:
        return 'This Week';
      case DateFilter.thisMonth:
        return 'This Month';
      case DateFilter.allTime:
        return 'All Time';
    }
  }

  List<TaskModel> _filterTasksByDate(List<TaskModel> tasks, DateFilter filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (filter) {
      case DateFilter.today:
        return tasks.where((task) => task.createdAt.isAfter(today)).toList();
      case DateFilter.thisWeek:
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        return tasks
            .where((task) => task.createdAt.isAfter(weekStart))
            .toList();
      case DateFilter.thisMonth:
        final monthStart = DateTime(now.year, now.month, 1);
        return tasks
            .where((task) => task.createdAt.isAfter(monthStart))
            .toList();
      case DateFilter.allTime:
        return tasks;
    }
  }

  int _calculateStreak(List<TaskModel> tasks) {
    // Implement streak calculation logic here
    // This is a placeholder implementation
    return tasks.where((task) => task.isCompleted).length;
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    double progress,
    BuildContext context,
  ) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    size: 36,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: _WaveProgressIndicator(
                progress: progress,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveProgressIndicator extends StatefulWidget {
  final double progress;
  final Color color;

  const _WaveProgressIndicator({
    required this.progress,
    required this.color,
  });

  @override
  State<_WaveProgressIndicator> createState() => _WaveProgressIndicatorState();
}

class _WaveProgressIndicatorState extends State<_WaveProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
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
        return CustomPaint(
          painter: _WavePainter(
            progress: widget.progress,
            color: widget.color,
            animation: _controller,
          ),
          size: const Size(double.infinity, 4),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Animation<double> animation;

  _WavePainter({
    required this.progress,
    required this.color,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    final height = size.height;
    final width = size.width;

    path.moveTo(0, height);
    for (double i = 0; i <= width; i++) {
      path.lineTo(
        i,
        height * (1 - progress) +
            math.sin((i / width * 2 * math.pi) +
                    (animation.value * 2 * math.pi)) *
                height *
                0.2,
      );
    }
    path.lineTo(width, height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.animation.value != animation.value;
  }
}
