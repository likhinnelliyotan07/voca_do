import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum TaskType {
  basic(
    icon: Icons.task_alt,
    label: 'Basic Task',
    color: Colors.blue,
  ),
  call(
    icon: Icons.phone,
    label: 'Phone Call',
    color: Colors.green,
    requiresContact: true,
  ),
  app(
    icon: Icons.apps,
    label: 'Open App',
    color: Colors.purple,
    requiresAppPackage: true,
  ),
  gallery(
    icon: Icons.photo_library,
    label: 'Open Gallery',
    color: Colors.orange,
  ),
  camera(
    icon: Icons.camera_alt,
    label: 'Take Photo',
    color: Colors.red,
  ),
  location(
    icon: Icons.location_on,
    label: 'Location',
    color: Colors.teal,
    requiresLocation: true,
  ),
  reminder(
    icon: Icons.notifications,
    label: 'Reminder',
    color: Colors.amber,
    requiresTime: true,
  );

  final IconData icon;
  final String label;
  final Color color;
  final bool requiresContact;
  final bool requiresAppPackage;
  final bool requiresLocation;
  final bool requiresTime;

  const TaskType({
    required this.icon,
    required this.label,
    required this.color,
    this.requiresContact = false,
    this.requiresAppPackage = false,
    this.requiresLocation = false,
    this.requiresTime = false,
  });

  FaIcon get faIcon => FaIcon(icon, color: color);
  Icon get materialIcon => Icon(icon, color: color);
}
