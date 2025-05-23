import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:voca_do/presentation/blocs/task_bloc.dart';
import 'package:voca_do/presentation/widgets/task_list.dart';
import 'package:voca_do/presentation/widgets/voice_input_button.dart';
import 'package:voca_do/presentation/screens/settings_screen.dart';
import 'package:voca_do/presentation/screens/calendar_screen.dart';
import 'package:voca_do/presentation/screens/statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTasks());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VocaDO'),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.gear),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          TaskList(),
          CalendarScreen(),
          StatisticsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        height: 65,
        elevation: 8,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        animationDuration: const Duration(milliseconds: 500),
        destinations: [
          NavigationDestination(
            icon: FaIcon(
              FontAwesomeIcons.listCheck,
              color: Colors.grey,
            ),
            selectedIcon: FaIcon(
              FontAwesomeIcons.listCheck,
              color: Colors.blue,
            ),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: FaIcon(
              FontAwesomeIcons.calendar,
              color: Colors.grey,
            ),
            selectedIcon: FaIcon(
              FontAwesomeIcons.calendar,
              color: Colors.blue,
            ),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: FaIcon(
              FontAwesomeIcons.chartBar,
              color: Colors.grey,
            ),
            selectedIcon: FaIcon(
              FontAwesomeIcons.chartBar,
              color: Colors.blue,
            ),
            label: 'Stats',
          ),
        ],
      ),
      floatingActionButton: const VoiceInputButton(),
    );
  }
}
