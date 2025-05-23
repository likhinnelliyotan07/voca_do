import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HelperScreen extends StatefulWidget {
  const HelperScreen({super.key});

  @override
  State<HelperScreen> createState() => _HelperScreenState();
}

class _HelperScreenState extends State<HelperScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Features'),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildFeatureCard(
              context,
              'Voice Commands',
              'Use your voice to create and manage tasks',
              FontAwesomeIcons.microphone,
              [
                'Say "Create a task" followed by your task description',
                'Add due dates by saying "due tomorrow" or "due next week"',
                'Set reminders by saying "remind me at 3 PM"',
              ],
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              'Task Management',
              'Organize and track your tasks efficiently',
              FontAwesomeIcons.listCheck,
              [
                'Create, edit, and delete tasks',
                'Mark tasks as complete',
                'Set priorities and due dates',
                'Add descriptions and notes',
              ],
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              'Calendar View',
              'View your tasks in a calendar format',
              FontAwesomeIcons.calendar,
              [
                'See tasks organized by date',
                'Quickly navigate between months',
                'View task details in calendar',
              ],
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              'Statistics',
              'Track your productivity and progress',
              FontAwesomeIcons.chartBar,
              [
                'View task completion rates',
                'Track your daily streak',
                'Monitor active tasks',
              ],
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              'Dark Mode',
              'Switch between light and dark themes',
              FontAwesomeIcons.palette,
              [
                'Toggle dark mode in settings',
                'Automatic system theme detection',
                'Eye-friendly interface',
              ],
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              'Profile',
              'Personalize your experience',
              FontAwesomeIcons.user,
              [
                'Set your name',
                'Customize your preferences',
                'Manage your account',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    List<String> features,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FaIcon(
                  icon,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
