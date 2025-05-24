import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:voca_do/presentation/screens/home_screen.dart';
import 'package:voca_do/presentation/screens/voice_screen.dart';
import 'package:voca_do/presentation/screens/calendar_screen.dart';
import 'package:voca_do/presentation/screens/statistics_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
   
    const VoiceScreen(),
     const HomeScreen(),
    const CalendarScreen(),
    const StatisticsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
            NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.microphone),
            label: 'Voice',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_alt),
            label: 'Tasks',
          ),
        
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}
