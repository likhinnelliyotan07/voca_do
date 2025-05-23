import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voca_do/presentation/blocs/task_bloc.dart';

class VoiceInputButton extends StatefulWidget {
  const VoiceInputButton({super.key});

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: 'en_US',
    );
    setState(() {
      _isListening = true;
    });
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
    // Extract task title and due date
    final taskTitle = _extractTaskTitle(input);
    final dueDate = _extractDueDate(input);

    if (taskTitle.isNotEmpty) {
      context.read<TaskBloc>().add(AddTask(
            title: taskTitle,
            dueDate: dueDate,
          ));
    }
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
    return FloatingActionButton(
      onPressed: _isListening ? _stopListening : _startListening,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _isListening
            ? const FaIcon(FontAwesomeIcons.stop)
            : const FaIcon(FontAwesomeIcons.microphone),
      ),
    );
  }
}
