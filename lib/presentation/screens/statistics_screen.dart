import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voca_do/presentation/blocs/task_bloc.dart';
import 'dart:math' as math;

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TaskLoaded) {
          final completedTasks =
              state.tasks.where((task) => task.isCompleted).length;
          final totalTasks = state.tasks.length;
          final completionRate =
              totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Task Statistics',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
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
                    (totalTasks - completedTasks) / math.max(totalTasks, 1),
                    context,
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
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
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
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
