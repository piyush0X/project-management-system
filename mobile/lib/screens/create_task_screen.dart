import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/task_service.dart';

class CreateTaskScreen extends StatefulWidget {
  final int projectId;
  final String projectName;

  const CreateTaskScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final dueDateController = TextEditingController();

  String priority = 'Medium';
  String status = 'Pending';

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    dueDateController.dispose();
    super.dispose();
  }

  Future<void> createTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final token = await AuthService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      await TaskService.createTask(
        projectId: widget.projectId,
        name: nameController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        priority: priority,
        status: status,
        dueDate: dueDateController.text.trim().isEmpty
            ? null
            : dueDateController.text.trim(),
        token: token,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task created successfully'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create task: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> selectDueDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (selectedDate != null) {
      final month = selectedDate.month.toString().padLeft(2, '0');
      final day = selectedDate.day.toString().padLeft(2, '0');

      setState(() {
        dueDateController.text =
            '${selectedDate.year}-$month-$day';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Project: ${widget.projectName}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                  hintText: 'Enter task name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Task name is required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter task description',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Low',
                    child: Text('Low'),
                  ),
                  DropdownMenuItem(
                    value: 'Medium',
                    child: Text('Medium'),
                  ),
                  DropdownMenuItem(
                    value: 'High',
                    child: Text('High'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      priority = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Pending',
                    child: Text('Pending'),
                  ),
                  DropdownMenuItem(
                    value: 'In Progress',
                    child: Text('In Progress'),
                  ),
                  DropdownMenuItem(
                    value: 'Completed',
                    child: Text('Completed'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      status = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: dueDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Due Date',
                  hintText: 'Select due date',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: selectDueDate,
                    icon: const Icon(Icons.calendar_month),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : createTask,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Create Task',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}