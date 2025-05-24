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
                'Say "Mark task as complete" to finish a task',
                'Use "Delete task" to remove a task',
                'Say "Show my tasks" to view all tasks',
                'Use "Set priority high/medium/low" to set task priority',
                'Say "Add note" followed by your note text',
                'Use "Search tasks" followed by keywords',
                'Say "Show statistics" to view your progress',
                'Use "Filter tasks" followed by task type',
                'Say "Show completed" or "Hide completed" to toggle completed tasks',
                'Use "Set DND" to enable Do Not Disturb',
                'Say "Send message" followed by recipient and message',
                'Use "Check mail" to open Gmail',
                'Say "Show contacts" to view address book',
                'Use "Show all alarms" to view scheduled alarms',
              ],
              [Colors.blue, Colors.purple],
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              'App Controls',
              'Control the app with voice commands',
              FontAwesomeIcons.mobileScreen,
              [
                'Say "Open app" to launch the application',
                'Use "Go to home" to return to main screen',
                'Say "Open settings" to access app settings',
                'Use "Switch to dark mode" to change theme',
                'Say "Show help" to open this guide',
                'Use "Enable notifications" to turn on alerts',
                'Say "Sync data" to update your information',
              ],
              [Colors.cyan, Colors.blue],
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              'Meeting Management',
              'Schedule and manage meetings',
              FontAwesomeIcons.video,
              [
                'Say "Create meeting" followed by meeting details',
                'Use "Schedule meeting with [name]" to set up a meeting',
                'Say "Join Google Meet" to start a video call',
                'Use "Set meeting reminder" to get notified',
                'Say "Cancel meeting" to remove a scheduled meeting',
                'Use "Show upcoming meetings" to view schedule',
                'Say "Add meeting notes" to record details',
              ],
              [Colors.green, Colors.teal],
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              'Camera & Media',
              'Control camera and media features',
              FontAwesomeIcons.camera,
              [
                'Say "Take picture" to capture photo',
                'Use "Start recording" to begin video',
                'Say "Switch camera" to change lens',
                'Use "Enable flash" to turn on light',
                'Say "Show gallery" to view media',
                'Use "Share photo" to send images',
                'Say "Delete media" to remove files',
              ],
              [Colors.orange, Colors.red],
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              'Alarms & Reminders',
              'Set and manage alarms',
              FontAwesomeIcons.bell,
              [
                'Say "Set alarm" followed by time',
                'Use "Remind me at [time]" to set reminder',
                'Say "Cancel alarm" to remove scheduled alarm',
                'Use "Show all alarms" to view list',
                'Say "Snooze alarm" to delay notification',
                'Use "Set recurring alarm" for daily reminders',
                'Say "Check alarm status" to verify settings',
              ],
              [Colors.purple, Colors.indigo],
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              'Phone & Communication',
              'Make calls and send messages',
              FontAwesomeIcons.phone,
              [
                'Say "Call [number]" to make a phone call',
                'Use "Open WhatsApp" to launch messaging',
                'Say "Send message" to compose text',
                'Use "Check voicemail" to listen to messages',
                'Say "Show contacts" to view address book',
                'Use "Block number" to prevent calls',
                'Say "Set do not disturb" to silence notifications',
              ],
              [Colors.pink, Colors.purple],
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
    List<Color> gradientColors,
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: FaIcon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
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
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: colorScheme.primary,
                        ),
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
