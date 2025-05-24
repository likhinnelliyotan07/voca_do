import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voca_do/domain/models/task_type.dart';

import 'package:voca_do/presentation/blocs/task_bloc.dart';

class VoiceCommandHandler {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static final ImagePicker _picker = ImagePicker();
  static bool _isInitialized = false;

  static Future<void> _initializeNotifications() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Request notification permission for Android 13+
    if (await Permission.notification.request().isGranted) {
      // Request exact alarm permission
      if (await Permission.scheduleExactAlarm.request().isGranted) {
        // Initialize notifications
        const AndroidInitializationSettings androidSettings =
            AndroidInitializationSettings('@mipmap/ic_launcher');
        const InitializationSettings initSettings =
            InitializationSettings(android: androidSettings);
        await _notifications.initialize(initSettings);

        // Create notification channels
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'reminder_channel',
          'Reminders',
          description: 'Channel for reminder notifications',
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
        );

        await _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);

        _isInitialized = true;
      } else {
        throw Exception('Exact alarm permission not granted');
      }
    } else {
      throw Exception('Notification permission not granted');
    }
  }

  static Future<void> handleCommand(
      String command, BuildContext context) async {
    try {
      // Initialize notifications if not already done
      await _initializeNotifications();

      final lowerCommand = command.toLowerCase();

      // Handle app launch commands
      if (lowerCommand.contains('open') || lowerCommand.contains('launch')) {
        await _handleAppLaunch(lowerCommand, context);
      }
      // Handle camera commands
      else if (lowerCommand.contains('take picture') ||
          lowerCommand.contains('take photo')) {
        await _handleCameraAction(context);
      }
      // Handle URL launch commands
      else if (lowerCommand.contains('open website') ||
          lowerCommand.contains('go to')) {
        await _handleUrlLaunch(lowerCommand);
      }
      // Handle alarm/reminder commands
      else if (lowerCommand.contains('set alarm') ||
          lowerCommand.contains('remind me')) {
        await _handleAlarm(lowerCommand, context);
      }
      // Handle meeting commands
      else if (lowerCommand.contains('create meeting')) {
        await _handleMeeting(lowerCommand);
      }
      // Handle call commands
      else if (lowerCommand.contains('call')) {
        await _handleCall(lowerCommand);
      }
      // Handle Google Meet commands
      else if (lowerCommand.contains('google meet') ||
          lowerCommand.contains('meet')) {
        await _handleGoogleMeet(lowerCommand);
      }
      // Handle gallery commands
      else if (lowerCommand.contains('open gallery') ||
          lowerCommand.contains('show photos')) {
        await _handleGallery(context);
      }
      // Handle DND commands
      else if (lowerCommand.contains('do not disturb') ||
          lowerCommand.contains('dnd')) {
        await _handleDND(context);
      }
      // Handle message commands
      else if (lowerCommand.contains('send message')) {
        await _handleSendMessage(lowerCommand, context);
      }
      // Handle mail commands
      else if (lowerCommand.contains('check mail') ||
          lowerCommand.contains('check email')) {
        await _handleCheckMail(context);
      }
      // Handle contacts commands
      else if (lowerCommand.contains('show contacts')) {
        await _handleShowContacts(context);
      }
      // Handle show alarms command
      else if (lowerCommand.contains('show all alarms')) {
        await _handleShowAlarms(context);
      }
      // Handle mark as complete command
      else if (lowerCommand.contains('mark as complete') ||
          lowerCommand.contains('mark task as complete')) {
        await _handleMarkAsComplete(lowerCommand, context);
      }
      // Handle search commands
      else if (lowerCommand.contains('search') ||
          lowerCommand.contains('find')) {
        await _handleSearch(lowerCommand, context);
      }
      // Handle filter commands
      else if (lowerCommand.contains('filter') ||
          lowerCommand.contains('show only')) {
        await _handleFilter(lowerCommand, context);
      }
      // Handle show/hide completed tasks
      else if (lowerCommand.contains('show completed') ||
          lowerCommand.contains('hide completed')) {
        await _handleShowHideCompleted(lowerCommand, context);
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  static Future<void> _handleAppLaunch(
      String command, BuildContext context) async {
    final apps = {
      'whatsapp': 'com.whatsapp',
      'facebook': 'com.facebook.katana',
      'instagram': 'com.instagram.android',
      'twitter': 'com.twitter.android',
      'youtube': 'com.google.android.youtube',
      'gmail': 'com.google.android.gm',
      'maps': 'com.google.android.apps.maps',
      'chrome': 'com.android.chrome',
    };

    for (final entry in apps.entries) {
      if (command.contains(entry.key)) {
        try {
          final uri = Uri.parse('android-app://${entry.value}');
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        } catch (e) {
          showSnackBar(context, 'Failed to launch app: $e');
        }
      }
    }
  }

  static Future<void> _handleCameraAction(BuildContext context) async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      try {
        final XFile? photo =
            await _picker.pickImage(source: ImageSource.camera);
        if (photo != null) {
          // Handle the captured photo
          print('Photo captured: ${photo.path}');
        }
      } catch (e) {
        print('Failed to capture photo: $e');
      }
    }
  }

  static Future<void> _handleUrlLaunch(String command) async {
    String? url;
    if (command.contains('open website')) {
      url = command.split('open website').last.trim();
    } else if (command.contains('go to')) {
      url = command.split('go to').last.trim();
    }

    if (url != null) {
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      } catch (e) {
        print('Failed to launch URL: $e');
      }
    }
  }

  static Future<void> _handleAlarm(String command, BuildContext context) async {
    try {
      // Check if exact alarm permission is granted
      if (!await Permission.scheduleExactAlarm.isGranted) {
        final status = await Permission.scheduleExactAlarm.request();
        if (!status.isGranted) {
          showSnackBar(
              context, 'Exact alarm permission is required to set alarms');
          return;
        }
      }

      // Extract title from command
      final titleMatch =
          RegExp(r'(?:set alarm|remind me) (?:for|about|to)?\s*"?([^"]+)"?')
              .firstMatch(command);
      final alarmTitle = titleMatch?.group(1) ?? 'Reminder';

      // Extract time from command
      final timeRegex =
          RegExp(r'(\d{1,2})(?::(\d{2}))?\s*(am|pm)?', caseSensitive: false);
      final match = timeRegex.firstMatch(command);

      if (match != null) {
        int hour = int.parse(match.group(1)!);
        int minute = match.group(2) != null ? int.parse(match.group(2)!) : 0;
        final period = match.group(3)?.toLowerCase();

        if (period == 'pm' && hour < 12) {
          hour += 12;
        } else if (period == 'am' && hour == 12) {
          hour = 0;
        }

        final now = DateTime.now();
        var scheduledTime = DateTime(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );

        // If the time has already passed today, schedule for tomorrow
        if (scheduledTime.isBefore(now)) {
          scheduledTime = scheduledTime.add(const Duration(days: 1));
        }

        final scheduledTzTime = tz.TZDateTime.from(scheduledTime, tz.local);

        // Get the Android implementation
        final androidImplementation =
            _notifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidImplementation != null) {
          // Create notification channel if it doesn't exist
          await androidImplementation.createNotificationChannel(
            const AndroidNotificationChannel(
              'reminder_channel',
              'Reminders',
              description: 'Channel for reminder notifications',
              importance: Importance.high,
              enableVibration: true,
              playSound: true,
            ),
          );

          // Schedule the notification
          await androidImplementation.zonedSchedule(
            0,
            alarmTitle,
            'Time for your scheduled task!',
            scheduledTzTime,
            const AndroidNotificationDetails(
              'reminder_channel',
              'Reminders',
              importance: Importance.high,
              priority: Priority.high,
              enableVibration: true,
              playSound: true,
            ),
            scheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );

          showSnackBar(
            context,
            'Alarm "$alarmTitle" set for ${scheduledTime.hour}:${scheduledTime.minute.toString().padLeft(2, '0')}',
          );
        } else {
          showSnackBar(
              context, 'Failed to initialize notifications on this device');
        }
      } else {
        showSnackBar(context,
            'Could not understand the time. Please try again with a format like "set alarm for 3 PM" or "remind me at 3:30 PM"');
      }
    } catch (e) {
      showSnackBar(context, 'Failed to set alarm: $e');
    }
  }

  static Future<void> _handleMeeting(String lowerCommand) async {
    final meetingTitle = _extractMeetingTitle(lowerCommand);
    final meetingDate = _extractMeetingDate(lowerCommand);
    final meetingTime = _extractMeetingTime(lowerCommand);
    final meetingLocation = _extractMeetingLocation(lowerCommand);
    final meetingDescription = _extractMeetingDescription(lowerCommand);

    if (meetingDate != null && meetingTime != null) {
      final meetingDateTime = DateTime(
        meetingDate.year,
        meetingDate.month,
        meetingDate.day,
        meetingTime.hour,
        meetingTime.minute,
      );

      // Create Google Meet link
      final meetLink = 'https://meet.google.com/${_generateMeetCode()}';

      // Schedule the notification
      final meetingTzTime = tz.TZDateTime.from(meetingDateTime, tz.local);
      await _notifications.zonedSchedule(
        0,
        'Meeting: $meetingTitle',
        'Meeting Link: $meetLink\n${meetingDescription ?? ''}',
        meetingTzTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'meeting_channel',
            'Meetings',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      // Launch Google Meet
      final uri = Uri.parse(meetLink);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  static String _generateMeetCode() {
    // Generate a random 10-character code for Google Meet
    const chars = 'abcdefghijklmnopqrstuvwxyz';
    final random = DateTime.now().millisecondsSinceEpoch;
    final code = List.generate(10, (index) {
      final charIndex = (random + index) % chars.length;
      return chars[charIndex];
    }).join();
    return code;
  }

  static String _extractMeetingTitle(String command) {
    // Try different patterns to extract meeting title
    final patterns = [
      r'create meeting (?:called|about|for|with)?\s*"?([^"]+)"?', // create meeting with client
      r'schedule meeting (?:called|about|for|with)?\s*"?([^"]+)"?', // schedule meeting with client
      r'meeting (?:called|about|for|with)?\s*"?([^"]+)"?', // meeting with client
      r'(?:with|about|for)\s*"?([^"]+)"?\s*(?:meeting|at|on)', // with client meeting
    ];

    for (final pattern in patterns) {
      final match = RegExp(pattern, caseSensitive: false).firstMatch(command);
      if (match != null && match.group(1) != null) {
        return match.group(1)!.trim();
      }
    }

    // If no specific title found, try to extract any meaningful phrase
    final words = command.split(' ');
    final meetingIndex = words.indexWhere((word) =>
        word.toLowerCase() == 'meeting' ||
        word.toLowerCase() == 'schedule' ||
        word.toLowerCase() == 'create');

    if (meetingIndex != -1 && meetingIndex < words.length - 1) {
      // Get the next word after "meeting" as the title
      return words[meetingIndex + 1].trim();
    }

    return 'Untitled Meeting';
  }

  static DateTime? _extractMeetingDate(String command) {
    final dateMatch =
        RegExp(r'on (\d{1,2}(?:st|nd|rd|th)? [A-Za-z]+|\d{4}-\d{2}-\d{2})')
            .firstMatch(command);
    if (dateMatch == null) return null;
    try {
      return DateTime.parse(dateMatch.group(1)!);
    } catch (e) {
      return null;
    }
  }

  static DateTime? _extractMeetingTime(String command) {
    final timeMatch =
        RegExp(r'at (\d{1,2})(?::(\d{2}))?\s*(am|pm)?').firstMatch(command);
    if (timeMatch == null) return null;

    int hour = int.parse(timeMatch.group(1)!);
    int minute =
        timeMatch.group(2) != null ? int.parse(timeMatch.group(2)!) : 0;
    final period = timeMatch.group(3)?.toLowerCase();

    if (period == 'pm' && hour < 12) hour += 12;
    if (period == 'am' && hour == 12) hour = 0;

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  static String? _extractMeetingLocation(String command) {
    final locationMatch =
        RegExp(r'(?:in|at|location) ([^,\.]+)').firstMatch(command);
    return locationMatch?.group(1);
  }

  static String? _extractMeetingDescription(String command) {
    final descMatch = RegExp(r'about ([^,\.]+)').firstMatch(command);
    return descMatch?.group(1);
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static Future<void> _handleCall(String command) async {
    final phoneMatch = RegExp(r'call\s+(\d+)').firstMatch(command);
    if (phoneMatch != null) {
      final phoneNumber = phoneMatch.group(1);
      final uri = Uri.parse('tel:$phoneNumber');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  static Future<void> _handleGoogleMeet(String command) async {
    // Extract meeting details
    final meetingTitle = _extractMeetingTitle(command);
    final meetLink = 'https://meet.google.com/${_generateMeetCode()}';

    // Launch Google Meet
    final uri = Uri.parse(meetLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> _handleGallery(BuildContext context) async {
    try {
      // Request storage permission for Android 13+
      if (await Permission.photos.request().isGranted) {
        final XFile? image =
            await _picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          // Handle the selected image
          print('Selected image: ${image.path}');
        }
      } else {
        showSnackBar(
            context, 'Storage permission is required to access gallery');
      }
    } catch (e) {
      showSnackBar(context, 'Failed to open gallery: $e');
    }
  }

  static Future<void> _handleDND(BuildContext context) async {
    try {
      // Launch system DND settings
      final uri = Uri.parse('android.settings.NOTIFICATION_SETTINGS');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        showSnackBar(context, 'Could not open DND settings');
      }
    } catch (e) {
      showSnackBar(context, 'Failed to handle DND: $e');
    }
  }

  static Future<void> _handleSendMessage(
      String command, BuildContext context) async {
    try {
      // Extract recipient and message content
      final recipientMatch = RegExp(r'to\s+([^,\.]+)').firstMatch(command);
      final messageMatch = RegExp(r'say\s+"?([^"]+)"?').firstMatch(command);

      if (recipientMatch != null && messageMatch != null) {
        final recipient = recipientMatch.group(1)!.trim();
        final message = messageMatch.group(1)!.trim();

        // Launch default SMS app
        final uri = Uri.parse('sms:$recipient?body=$message');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          showSnackBar(context, 'Could not launch messaging app');
        }
      } else {
        showSnackBar(context, 'Please specify recipient and message content');
      }
    } catch (e) {
      showSnackBar(context, 'Failed to send message: $e');
    }
  }

  static Future<void> _handleCheckMail(BuildContext context) async {
    try {
      // Launch Gmail app
      final uri = Uri.parse('android-app://com.google.android.gm');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        showSnackBar(context, 'Could not launch Gmail');
      }
    } catch (e) {
      showSnackBar(context, 'Failed to check mail: $e');
    }
  }

  static Future<void> _handleShowContacts(BuildContext context) async {
    try {
      // Launch contacts app
      final uri = Uri.parse('android-app://com.android.contacts');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        showSnackBar(context, 'Could not launch contacts');
      }
    } catch (e) {
      showSnackBar(context, 'Failed to show contacts: $e');
    }
  }

  static Future<void> _handleShowAlarms(BuildContext context) async {
    try {
      // Launch clock app
      final uri = Uri.parse('android-app://com.android.deskclock');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        showSnackBar(context, 'Could not launch clock app');
      }
    } catch (e) {
      showSnackBar(context, 'Failed to show alarms: $e');
    }
  }

  static Future<void> _handleMarkAsComplete(
      String command, BuildContext context) async {
    try {
      // Extract task title
      final taskMatch = RegExp(r'(?:mark|complete)\s+"?([^"]+)"?\s+as complete')
          .firstMatch(command);
      if (taskMatch != null) {
        final taskTitle = taskMatch.group(1)!.trim();
        // Add task completion logic here
        context.read<TaskBloc>().add(MarkTaskComplete(taskTitle: taskTitle));
        showSnackBar(context, 'Task marked as complete: $taskTitle');
      } else {
        showSnackBar(context, 'Please specify which task to mark as complete');
      }
    } catch (e) {
      showSnackBar(context, 'Failed to mark task as complete: $e');
    }
  }

  static Future<void> _handleSearch(
      String command, BuildContext context) async {
    try {
      // Extract search query
      final searchMatch =
          RegExp(r'(?:search|find)\s+"?([^"]+)"?').firstMatch(command);
      if (searchMatch != null) {
        final searchQuery = searchMatch.group(1)!.trim();
        // Update search query in TaskList
        context.read<TaskBloc>().add(UpdateSearchQuery(searchQuery));
        showSnackBar(context, 'Searching for: $searchQuery');
      } else {
        showSnackBar(context, 'Please specify what to search for');
      }
    } catch (e) {
      showSnackBar(context, 'Failed to perform search: $e');
    }
  }

  static Future<void> _handleFilter(
      String command, BuildContext context) async {
    try {
      // Extract task type
      final taskTypeMatch =
          RegExp(r'(?:filter|show only)\s+"?([^"]+)"?').firstMatch(command);
      if (taskTypeMatch != null) {
        final taskType = taskTypeMatch.group(1)!.trim().toLowerCase();
        // Map voice command to task type
        String? selectedType;
        for (final type in TaskType.values) {
          if (taskType.contains(type.name.toLowerCase()) ||
              taskType.contains(type.label.toLowerCase())) {
            selectedType = type.name;
            break;
          }
        }
        if (selectedType != null) {
          // Update task type filter in TaskList
          context.read<TaskBloc>().add(UpdateTaskTypeFilter(selectedType));
          showSnackBar(context, 'Filtering by task type: $selectedType');
        } else {
          showSnackBar(context, 'Invalid task type. Please try again.');
        }
      } else {
        showSnackBar(context, 'Please specify what to filter by');
      }
    } catch (e) {
      showSnackBar(context, 'Failed to apply filter: $e');
    }
  }

  static Future<void> _handleShowHideCompleted(
      String command, BuildContext context) async {
    try {
      final showCompleted = command.contains('show completed');
      // Update show completed filter in TaskList
      context.read<TaskBloc>().add(UpdateShowCompletedFilter(showCompleted));
      showSnackBar(
        context,
        showCompleted ? 'Showing completed tasks' : 'Hiding completed tasks',
      );
    } catch (e) {
      showSnackBar(context, 'Failed to update completed tasks visibility: $e');
    }
  }
}
