import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/project_service.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() =>
      _CreateProjectScreenState();
}

class _CreateProjectScreenState
    extends State<CreateProjectScreen> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  String status = 'Not Started';

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    startDateController.dispose();
    endDateController.dispose();

    super.dispose();
  }

  Future<String?> selectDate(
    TextEditingController controller,
  ) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (date == null) {
      return null;
    }

    final month =
        date.month.toString().padLeft(2, '0');

    final day =
        date.day.toString().padLeft(2, '0');

    final formatted =
        '${date.year}-$month-$day';

    controller.text = formatted;

    return formatted;
  }

  Future<void> createProject() async {
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

      await ProjectService.createProject(
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
            'Project created successfully',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to create project: $e',
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
        title: const Text('Create Project'),
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
                  hintText:
                      'Enter project name',
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
                  hintText:
                      'Enter project description',
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
                          : createProject,

                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child:
                              CircularProgressIndicator(),
                        )
                      : const Text(
                          'Create Project',
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