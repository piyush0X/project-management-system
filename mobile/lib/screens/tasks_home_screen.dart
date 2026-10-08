import 'package:flutter/material.dart';

import '../models/project_model.dart';
import '../services/auth_service.dart';
import '../services/project_service.dart';
import 'tasks_screen.dart';

class TasksHomeScreen extends StatefulWidget {
  const TasksHomeScreen({
    super.key,
  });

  @override
  State<TasksHomeScreen> createState() =>
      _TasksHomeScreenState();
}

class _TasksHomeScreenState
    extends State<TasksHomeScreen> {
  List<Project> projects = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadProjects();
  }

  Future<void> loadProjects() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final token =
          await AuthService.getToken();

      if (token == null ||
          token.isEmpty) {
        throw Exception(
          'Authentication token not found',
        );
      }

      final result =
          await ProjectService.getProjects(
        token: token,
      );

      if (!mounted) return;

      setState(() {
        projects = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            onPressed: loadProjects,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
              ),

              const SizedBox(height: 20),

              const Text(
                'Failed to load projects',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                errorMessage!,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: loadProjects,
                child: const Text(
                  'Retry',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (projects.isEmpty) {
      return const Center(
        child: Text(
          'No projects available.\n'
          'Create a project first.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadProjects,

      child: ListView.builder(
        padding: const EdgeInsets.all(16),

        itemCount: projects.length,

        itemBuilder: (context, index) {
          final project =
              projects[index];

          return Card(
            margin:
                const EdgeInsets.only(
              bottom: 12,
            ),

            child: ListTile(
              leading:
                  const CircleAvatar(
                child: Icon(
                  Icons.folder,
                ),
              ),

              title: Text(
                project.name,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              subtitle: Text(
                project.description ??
                    'No description',
              ),

              trailing:
                  const Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TasksScreen(
                      projectId:
                          project.id,
                      projectName:
                          project.name,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}