import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voca_do/presentation/blocs/task_bloc.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    context.read<TaskBloc>().add(LoadTasks());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
                outsideDaysVisible: false,
                markersMaxCount: 1,
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                formatButtonTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
                titleCentered: true,
                titleTextStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is TaskLoaded) {
                  final tasksForSelectedDay = state.tasks.where((task) {
                    final taskDate = task.dueDate;
                    return taskDate != null &&
                        isSameDay(taskDate, _selectedDay);
                  }).toList();

                  if (tasksForSelectedDay.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks for selected date',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tasksForSelectedDay.length,
                    itemBuilder: (context, index) {
                      final task = tasksForSelectedDay[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.task_alt,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.isCompleted
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6)
                                  : null,
                            ),
                          ),
                          trailing: Checkbox(
                            value: task.isCompleted,
                            onChanged: (bool? value) {
                              if (value != null) {
                                context.read<TaskBloc>().add(
                                      UpdateTask(
                                        task.copyWith(isCompleted: value),
                                      ),
                                    );
                              }
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Something went wrong',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
