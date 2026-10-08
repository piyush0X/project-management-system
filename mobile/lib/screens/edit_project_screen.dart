import 'package:flutter/material.dart';

import '../models/project_model.dart';
import '../services/auth_service.dart';
import '../services/project_service.dart';

class EditProjectScreen extends StatefulWidget {
  final Project project;

  const EditProjectScreen({
    super.key,
    required this.project,
  });

  @override
  State<EditProjectScreen> createState() =>
      _EditProjectScreenState();
}

class _EditProjectScreenState
    extends State<EditProjectScreen> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController startDateController;
  late final TextEditingController endDateController;

  late String status;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.project.name);

    descriptionController =
        TextEditingController(
      text: widget.project.description ?? '',
    );

    startDateController =
        TextEditingController(
      text: widget.project.startDate ?? '',
    );

    endDateController =
        TextEditingController(
      text: widget.project.endDate ?? '',
    );

    status = widget.project.status;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    startDateController.dispose();
    endDateController.dispose();

    super.dispose();
  }

  Future<void> selectDate(
    TextEditingController controller,
  ) async {
    DateTime initialDate = DateTime.now();

    if (controller.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(controller.text);
      } catch (_) {
        initialDate = DateTime.now();
      }
    }

    final selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: initialDate,
    );

    if (selectedDate == null) {
      return;
    }

    final month =
        selectedDate.month.toString().padLeft(2, '0');

    final day =
        selectedDate.day.toString().padLeft(2, '0');

    controller.text =
        '${selectedDate.year}-$month-$day';
  }

  Future<void> updateProject() async {
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

      await ProjectService.updateProject(
        projectId: widget.project.id,
        name: nameController.text.trim(),
        description:
            descriptionController.text.trim().isEmpty
                ? null
                : descriptionController.text.trim(),
        status: status,
        startDate:
            startDateController.text.trim().isEmpty
                ? null
                : startDateController.text.trim(),
        endDate:
            endDateController.text.trim().isEmpty
                ? null
                : endDateController.text.trim(),
        token: token,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Project updated successfully',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update project: $e',
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
        title: const Text('Edit Project'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: formKey,

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              TextFormField(
                controller: nameController,

                decoration:
                    const InputDecoration(
                  labelText: 'Project Name',
                  border:
                      OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Project name is required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                    descriptionController,

                maxLines: 4,

                decoration:
                    const InputDecoration(
                  labelText: 'Description',
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: status,

                decoration:
                    const InputDecoration(
                  labelText: 'Status',
                  border:
                      OutlineInputBorder(),
                ),

                items: const [
                  DropdownMenuItem(
                    value: 'Not Started',
                    child:
                        Text('Not Started'),
                  ),
                  DropdownMenuItem(
                    value: 'In Progress',
                    child:
                        Text('In Progress'),
                  ),
                  DropdownMenuItem(
                    value: 'Completed',
                    child:
                        Text('Completed'),
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
                controller:
                    startDateController,

                readOnly: true,

                decoration:
                    InputDecoration(
                  labelText: 'Start Date',
                  border:
                      const OutlineInputBorder(),

                  suffixIcon:
                      IconButton(
                    onPressed: () {
                      selectDate(
                        startDateController,
                      );
                    },
                    icon: const Icon(
                      Icons.calendar_month,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                    endDateController,

                readOnly: true,

                decoration:
                    InputDecoration(
                  labelText: 'End Date',
                  border:
                      const OutlineInputBorder(),

                  suffixIcon:
                      IconButton(
                    onPressed: () {
                      selectDate(
                        endDateController,
                      );
                    },
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
                      isLoading
                          ? null
                          : updateProject,

                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child:
                              CircularProgressIndicator(),
                        )
                      : const Text(
                          'Save Changes',
                          style:
                              TextStyle(
                            fontSize: 16,
                          ),
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