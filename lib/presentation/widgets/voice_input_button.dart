import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voca_do/presentation/blocs/task_bloc.dart';
import 'package:voca_do/presentation/services/voice_command_handler.dart';
import 'dart:math' as math;

class VoiceInputButton extends StatefulWidget {
  const VoiceInputButton({super.key});

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _lastWords = '';
  late AnimationController _waveformController;
  late List<double> _waveformHeights;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initWaveformAnimation();
  }

  void _initWaveformAnimation() {
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    // Generate random waveform heights
    _waveformHeights =
        List.generate(5, (index) => math.Random().nextDouble() * 20 + 10);
  }

  @override
  void dispose() {
    _waveformController.dispose();
    super.dispose();
  }

  void _initSpeech() async {
    try {
      print('Initializing speech recognition...');
      final bool available = await _speechToText.initialize(
        onError: (error) {
          print('Speech recognition error: $error');
          setState(() {
            _isListening = false;
          });
        },
        onStatus: (status) {
          print('Speech recognition status: $status');
          if (status == 'done') {
            setState(() {
              _isListening = false;
            });
          }
        },
        debugLogging: true,
      );
      print('Speech recognition available: $available');
      if (!available) {
        print(
            'Speech recognition not available - Please check permissions and device capabilities');
      }
      setState(() {});
    } catch (e, stackTrace) {
      print('Failed to initialize speech recognition: $e');
      print('Stack trace: $stackTrace');
    }
  }

  void _startListening() async {
    if (!_speechToText.isAvailable) {
      print(
          'Speech recognition not available - Please check permissions and device capabilities');
      return;
    }

    try {
      print('Starting speech recognition...');
      await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: 'en_US',
        partialResults: true,
        cancelOnError: true,
      );
      setState(() {
        _isListening = true;
      });
      print('Speech recognition started successfully');
    } catch (e, stackTrace) {
      print('Error starting speech recognition: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isListening = false;
      });
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _onSpeechResult(result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });

    if (result.finalResult) {
      _processVoiceInput(_lastWords, context);
    }
  }

  void _processVoiceInput(String input, BuildContext context) {
    if (input.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No voice input detected. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // First try to handle as a command
    VoiceCommandHandler.handleCommand(input, context).then((_) {
      // If no command was handled, process as a task
      if (!input.toLowerCase().contains('open') &&
          !input.toLowerCase().contains('take picture') &&
          !input.toLowerCase().contains('open website') &&
          !input.toLowerCase().contains('set alarm')) {
        try {
          // Check for workout command
          if (input.toLowerCase().contains('workout')) {
            final muscleGroup = _extractMuscleGroup(input) ?? "Full Body";
            final taskTitle = _extractTaskTitle(input) ??
                "Workout ${DateTime.now().millisecondsSinceEpoch}";
            final dueDate = _extractDueDate(input);
            final reminderTime = DateTime.now().add(const Duration(hours: 1));

            if (taskTitle.isNotEmpty) {
              context.read<TaskBloc>().add(AddTask(
                    title: taskTitle,
                    dueDate: dueDate,
                    taskType: 'workout',
                    muscleGroup: muscleGroup,
                    reminderTime: reminderTime,
                  ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Workout task created successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
            return;
          }

          // Check for meeting command
          if (input.toLowerCase().contains('meeting') ||
              input.toLowerCase().contains('google meet') ||
              input.toLowerCase().contains('meet')) {
            final taskTitle = _extractTaskTitle(input) ??
                "Meeting ${DateTime.now().millisecondsSinceEpoch}";
            final dueDate = _extractDueDate(input);
            final description = _extractMeetingDescription(input);
            final reminderTime = DateTime.now().add(const Duration(hours: 1));

            if (taskTitle.isNotEmpty) {
              context.read<TaskBloc>().add(AddTask(
                    title: taskTitle,
                    dueDate: dueDate,
                    description: description,
                    reminderTime: reminderTime,
                  ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Meeting task created successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
            return;
          }

          // Handle as regular task
          final taskTitle = _extractTaskTitle(input) ??
              "Task ${DateTime.now().millisecondsSinceEpoch}";
          final dueDate = _extractDueDate(input);
          final reminderTime = DateTime.now().add(const Duration(hours: 1));

          if (taskTitle.isNotEmpty) {
            context.read<TaskBloc>().add(AddTask(
                  title: taskTitle,
                  dueDate: dueDate,
                  reminderTime: reminderTime,
                ));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task created successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create task: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing voice input: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  String? _extractMuscleGroup(String input) {
    final muscleGroups = {
      'chest': 'chest',
      'back': 'back',
      'legs': 'legs',
      'shoulders': 'shoulders',
      'arms': 'arms',
      'abs': 'abs',
      'full body': 'fullBody',
    };

    for (final entry in muscleGroups.entries) {
      if (input.toLowerCase().contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  String? _extractTaskTitle(String input) {
    final titleMatch = RegExp(
            r'(?:title|task|activity|event|meeting|workout|task|activity|event|meeting|workout)\s*"?([^"]+)"?')
        .firstMatch(input);
    return titleMatch?.group(1);
  }

  DateTime? _extractDueDate(String input) {
    final dateMatch = RegExp(
            r'(?:due|date|when|on|at)\s*(\d{1,2}(?:st|nd|rd|th)? [A-Za-z]+|\d{4}-\d{2}-\d{2})')
        .firstMatch(input);
    if (dateMatch == null) return null;
    try {
      return DateTime.parse(dateMatch.group(1)!);
    } catch (e) {
      return null;
    }
  }

  String? _extractMeetingDescription(String input) {
    final descMatch = RegExp(r'about ([^,\.]+)').firstMatch(input);
    return descMatch?.group(1);
  }

  DateTime? _extractTime(String input, DateTime baseDate) {
    final timeRegex =
        RegExp(r'(\d{1,2})(?::(\d{2}))?\s*(am|pm)?', caseSensitive: false);
    final match = timeRegex.firstMatch(input);

    if (match != null) {
      int hour = int.parse(match.group(1)!);
      int minute = match.group(2) != null ? int.parse(match.group(2)!) : 0;
      final period = match.group(3)?.toLowerCase();

      if (period == 'pm' && hour < 12) {
        hour += 12;
      } else if (period == 'am' && hour == 12) {
        hour = 0;
      }

      return DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        hour,
        minute,
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _startListening(),
      onTapUp: (_) => _stopListening(),
      onTapCancel: () => _stopListening(),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_isListening)
              AnimatedBuilder(
                animation: _waveformController,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => Container(
                        width: 4,
                        height: _waveformHeights[index] *
                            (0.5 +
                                0.5 *
                                    math.sin(_waveformController.value *
                                            math.pi *
                                            2 +
                                        index * 0.5)),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  );
                },
              ),
            Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: Colors.white,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}
