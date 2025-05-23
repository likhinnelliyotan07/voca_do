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
      _processVoiceInput(_lastWords);
    }
  }

  void _processVoiceInput(String input) {
    // First try to handle as a command
    VoiceCommandHandler.handleCommand(input, context).then((_) {
      // If no command was handled, process as a task
      if (!input.toLowerCase().contains('open') &&
          !input.toLowerCase().contains('take picture') &&
          !input.toLowerCase().contains('open website') &&
          !input.toLowerCase().contains('set alarm')) {
        final taskTitle = _extractTaskTitle(input);
        final dueDate = _extractDueDate(input);

        if (taskTitle.isNotEmpty) {
          context.read<TaskBloc>().add(AddTask(
                title: taskTitle,
                dueDate: dueDate,
              ));
        }
      }
    });
  }

  String _extractTaskTitle(String input) {
    // Remove time-related phrases
    final timePhrases = [
      'by',
      'at',
      'tomorrow',
      'today',
      'next week',
      'next month',
    ];

    String title = input;
    for (final phrase in timePhrases) {
      final index = title.toLowerCase().indexOf(phrase);
      if (index != -1) {
        title = title.substring(0, index).trim();
      }
    }

    return title;
  }

  DateTime? _extractDueDate(String input) {
    final now = DateTime.now();
    final inputLower = input.toLowerCase();

    // Check for "tomorrow"
    if (inputLower.contains('tomorrow')) {
      final tomorrow = now.add(const Duration(days: 1));
      return _extractTime(inputLower, tomorrow);
    }

    // Check for "today"
    if (inputLower.contains('today')) {
      return _extractTime(inputLower, now);
    }

    // Check for time only
    return _extractTime(inputLower, now);
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
    return Stack(
      alignment: Alignment.center,
      children: [
        if (_isListening)
          AnimatedBuilder(
            animation: _waveformController,
            builder: (context, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final height = _waveformHeights[index] *
                      (0.5 +
                          0.5 *
                              math.sin(_waveformController.value * 2 * math.pi +
                                  index * 0.5));
                  return Container(
                    width: 4,
                    height: height,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              );
            },
          ),
        FloatingActionButton(
          onPressed: _isListening ? _stopListening : _startListening,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isListening
                ? const FaIcon(FontAwesomeIcons.stop)
                : const FaIcon(FontAwesomeIcons.microphone),
          ),
        ),
      ],
    );
  }
}
