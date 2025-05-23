import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum MuscleGroup {
  chest(
    icon: FontAwesomeIcons.person,
    label: 'Chest',
    color: Colors.red,
  ),
  back(
    icon: FontAwesomeIcons.person,
    label: 'Back',
    color: Colors.blue,
  ),
  legs(
    icon: FontAwesomeIcons.person,
    label: 'Legs',
    color: Colors.green,
  ),
  shoulders(
    icon: FontAwesomeIcons.person,
    label: 'Shoulders',
    color: Colors.orange,
  ),
  arms(
    icon: FontAwesomeIcons.person,
    label: 'Arms',
    color: Colors.purple,
  ),
  core(
    icon: FontAwesomeIcons.person,
    label: 'Core',
    color: Colors.teal,
  ),
  fullBody(
    icon: FontAwesomeIcons.person,
    label: 'Full Body',
    color: Colors.deepPurple,
  );

  final IconData icon;
  final String label;
  final Color color;

  const MuscleGroup({
    required this.icon,
    required this.label,
    required this.color,
  });

  FaIcon get faIcon => FaIcon(icon, color: color);
  Icon get materialIcon => Icon(icon, color: color);
}
