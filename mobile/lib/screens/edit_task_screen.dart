import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({
    super.key,
    required this.task,
  });

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController dueDateController;

  late String priority;
  late String status;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.task.name);

    descriptionController =
        TextEditingController(
      text: widget.task.description ?? '',
    );

    dueDateController =
        TextEditingController(
      text: widget.task.dueDate ?? '',
    );

    priority = widget.task.priority;
    status = widget.task.status;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    dueDateController.dispose();
    super.dispose();
  }

  Future<void> selectDueDate() async {
    DateTime initialDate = DateTime.now();

    if (dueDateController.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(
          dueDateController.text,
        );
      } catch (_) {}
    }

    final selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: initialDate,
    );

    if (selectedDate == null) return;

    final month =
        selectedDate.month.toString().padLeft(2, '0');

    final day =
        selectedDate.day.toString().padLeft(2, '0');

    setState(() {
      dueDateController.text =
          '${selectedDate.year}-$month-$day';
    });
  }

  Future<void> updateTask() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final token = await AuthService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Authentication token not found',
        );
      }

      await TaskService.updateTask(
        taskId: widget.task.id,
        name: nameController.text.trim(),
        description:
            descriptionController.text.trim().isEmpty
                ? null
                : descriptionController.text.trim(),
        priority: priority,
        status: status,
        dueDate:
            dueDateController.text.trim().isEmpty
                ? null
                : dueDateController.text.trim(),
        token: token,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Task updated successfully',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update task: $e',
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
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
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: selectDueDate,
                    icon: const Icon(
                      Icons.calendar_month,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      isLoading ? null : updateTask,
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child:
                              CircularProgressIndicator(),
                        )
                      : const Text(
                          'Save Changes',
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