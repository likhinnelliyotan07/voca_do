import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:voca_do/presentation/blocs/task_bloc.dart';
import 'package:voca_do/presentation/widgets/task_list.dart';
import 'package:voca_do/presentation/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTasks());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 40,
                ),
                const SizedBox(width: 8),
                const Text(
                  'VocaDO',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.gear),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
          body: const TaskList(),
        ),
      ),
    );
  }
}
