import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_bloc/flutter_bloc.dart';

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

    // Request exact alarm permission
    if (await Permission.scheduleExactAlarm.request().isGranted) {
      // Initialize notifications
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initSettings =
          InitializationSettings(android: androidSettings);
      await _notifications.initialize(initSettings);

      _isInitialized = true;
    } else {
      throw Exception('Exact alarm permission not granted');
    }
  }

  static Future<void> handleCommand(
      String command, BuildContext context) async {
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
      await _handleAlarm(lowerCommand);
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

  static Future<void> _handleAlarm(String command) async {
    // Check if exact alarm permission is granted
    if (!await Permission.scheduleExactAlarm.isGranted) {
      final status = await Permission.scheduleExactAlarm.request();
      if (!status.isGranted) {
        throw Exception('Exact alarm permission is required to set alarms');
      }
    }

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

      await _notifications.zonedSchedule(
        0,
        'Reminder',
        'Time for your scheduled task!',
        scheduledTzTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminder_channel',
            'Reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  static Future<void> _handleMeeting(String lowerCommand) async {
    final meetingTitle = _extractMeetingTitle(lowerCommand);
    final meetingDate = _extractMeetingDate(lowerCommand);
    final meetingTime = _extractMeetingTime(lowerCommand);
    final meetingLocation = _extractMeetingLocation(lowerCommand);
    final meetingDescription = _extractMeetingDescription(lowerCommand);

    if (meetingTitle != null && meetingDate != null && meetingTime != null) {
      final meetingDateTime = DateTime(
        meetingDate.year,
        meetingDate.month,
        meetingDate.day,
        meetingTime.hour,
        meetingTime.minute,
      );

      final meetingTzTime = tz.TZDateTime.from(meetingDateTime, tz.local);
      await _notifications.zonedSchedule(
        0,
        meetingTitle,
        meetingDescription,
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
    }
  }

  static String _extractMeetingTitle(String command) {
    final titleMatch =
        RegExp(r'create meeting (?:called|about|for)?\s*"?([^"]+)"?')
            .firstMatch(command);
    return titleMatch?.group(1) ?? 'Untitled Meeting';
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
      SnackBar(content: Text(message)),
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
    final meetingDate = _extractMeetingDate(command);
    final meetingTime = _extractMeetingTime(command);

    if (meetingTitle != null && meetingDate != null && meetingTime != null) {
      // Format date and time for Google Meet URL
      final dateStr =
          '${meetingDate.year}-${meetingDate.month.toString().padLeft(2, '0')}-${meetingDate.day.toString().padLeft(2, '0')}';
      final timeStr =
          '${meetingTime.hour.toString().padLeft(2, '0')}${meetingTime.minute.toString().padLeft(2, '0')}';

      // Create Google Meet URL with meeting details
      final meetUrl =
          'https://meet.google.com/new?title=${Uri.encodeComponent(meetingTitle)}&date=$dateStr&time=$timeStr';

      if (await canLaunchUrl(Uri.parse(meetUrl))) {
        await launchUrl(Uri.parse(meetUrl));
      }
    }
  }

  static Future<void> _handleGallery(BuildContext context) async {
    // Request storage permission
    final status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        final XFile? image =
            await _picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          // Handle the selected image
          print('Selected image: ${image.path}');
        }
      } catch (e) {
        showSnackBar(context, 'Failed to open gallery: $e');
      }
    } else {
      showSnackBar(context, 'Storage permission is required to access gallery');
    }
  }

 
}
