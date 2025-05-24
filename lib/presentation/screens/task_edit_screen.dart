import 'package:flutter/material.dart';
import 'package:voca_do/domain/models/task.dart';
import 'package:voca_do/domain/models/task_type.dart';
import 'package:voca_do/domain/models/muscle_group.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';

import 'package:permission_handler/permission_handler.dart';

class TaskEditScreen extends StatefulWidget {
  final Task? task;

  const TaskEditScreen({super.key, this.task});

  @override
  State<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TaskType _selectedType;
  String? _contactInfo;
  String? _appPackage;
  String? _location;
  DateTime? _reminderTime;
  String? _imagePath;
  MuscleGroup? _selectedMuscleGroup;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    _selectedType = widget.task?.type ?? TaskType.basic;
    _contactInfo = widget.task?.contactInfo;
    _appPackage = widget.task?.appPackage;
    _location = widget.task?.location;
    _reminderTime = widget.task?.reminderTime;
    _imagePath = widget.task?.imagePath;
    _selectedMuscleGroup = widget.task?.muscleGroup;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickContact() async {
    final status = await Permission.phone.request();
    if (status.isGranted) {
      final TextEditingController phoneController = TextEditingController();
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enter Phone Number'),
          content: TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: 'Enter phone number',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, phoneController.text),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (result != null && result.isNotEmpty) {
        setState(() {
          _contactInfo = result;
        });
      }
    }
  }

  Future<void> _makePhoneCall() async {
    if (_contactInfo != null) {
      final Uri phoneUri = Uri(
        scheme: 'tel',
        path: _contactInfo,
      );
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not make phone call')),
          );
        }
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        final now = DateTime.now();
        _reminderTime = DateTime(
          now.year,
          now.month,
          now.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _selectApp() async {
    // TODO: Implement app selection logic
    // For now, we'll just set a dummy value
    setState(() {
      _appPackage = 'com.example.app';
    });
  }

  void _selectLocation() async {
    // TODO: Implement location selection logic
    // For now, we'll just set a dummy value
    setState(() {
      _location = 'Current Location';
    });
  }

  Future<void> _selectMuscleGroup() async {
    final result = await showDialog<MuscleGroup>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Muscle Group'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: MuscleGroup.values.map((group) {
              return ListTile(
                leading: Icon(group.icon, color: group.color),
                title: Text(group.label),
                onTap: () => Navigator.pop(context, group),
              );
            }).toList(),
          ),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedMuscleGroup = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'New Task' : 'Edit Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTask,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Task Type',
                border: OutlineInputBorder(),
              ),
              items: TaskType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(type.icon, color: type.color),
                      const SizedBox(width: 8),
                      Text(type.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(_reminderTime?.toString() ?? 'Set Reminder Time'),
              trailing: const Icon(Icons.access_time),
              onTap: _selectTime,
            ),
            const SizedBox(height: 16),
            if (_selectedType.requiresMuscleGroup) ...[
              ListTile(
                title:
                    Text(_selectedMuscleGroup?.label ?? 'Select Muscle Group'),
                leading: Icon(
                  _selectedMuscleGroup?.icon ?? Icons.fitness_center,
                  color: _selectedMuscleGroup?.color ?? Colors.grey,
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _selectMuscleGroup,
              ),
            ],
            if (_selectedType.requiresContact) ...[
              ListTile(
                title: Text(_contactInfo ?? 'Select Contact'),
                trailing: const Icon(Icons.contacts),
                onTap: _pickContact,
              ),
            ],
            if (_selectedType.requiresAppPackage) ...[
              ListTile(
                title: Text(_appPackage ?? 'Select App'),
                trailing: const Icon(Icons.apps),
                onTap: _selectApp,
              ),
            ],
            if (_selectedType.requiresLocation) ...[
              ListTile(
                title: Text(_location ?? 'Select Location'),
                trailing: const Icon(Icons.location_on),
                onTap: _selectLocation,
              ),
            ],
            const SizedBox(height: 16),
            if (widget.task != null) ...[
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Task Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Created At'),
                subtitle: Text(_formatDateTime(widget.task!.createdAt)),
              ),
              if (widget.task!.completedAt != null)
                ListTile(
                  title: const Text('Completed At'),
                  subtitle: Text(_formatDateTime(widget.task!.completedAt!)),
                ),
              ListTile(
                title: const Text('Task ID'),
                subtitle: Text(widget.task!.id),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$month/$day $hour:$minute';
  }

  void _saveTask() {
    if (_formKey.currentState?.validate() ?? false) {
      final task = Task(
        id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        type: _selectedType,
        createdAt: widget.task?.createdAt ?? DateTime.now(),
        contactInfo: _contactInfo,
        appPackage: _appPackage,
        location: _location,
        reminderTime: _reminderTime,
        imagePath: _imagePath,
        muscleGroup: _selectedMuscleGroup,
      );
      Navigator.pop(context, task);
    }
  }
}
