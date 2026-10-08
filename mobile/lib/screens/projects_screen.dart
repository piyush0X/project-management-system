import 'package:flutter/material.dart';

import '../models/project_model.dart';
import '../services/auth_service.dart';
import '../services/project_service.dart';
import 'create_project_screen.dart';
import 'tasks_screen.dart';
import 'edit_project_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<Project> projects = [];

  bool isLoading = true;
  String? errorMessage;

  final TextEditingController searchController =
      TextEditingController();

  String searchQuery = '';

  // Project status filter
  String selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    loadProjects();

    searchController.addListener(() {
      setState(() {
        searchQuery =
            searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadProjects() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final token = await AuthService.getToken();

      if (token == null || token.isEmpty) {
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

  Color getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;

      case 'In Progress':
        return Colors.orange;

      case 'Not Started':
        return Colors.grey;

      default:
        return Colors.grey;
    }
  }

  Future<void> openCreateProject() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const CreateProjectScreen(),
      ),
    );

    if (result == true) {
      loadProjects();
    }
  }

  Future<void> deleteProject(
    Project project,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Project',
          ),
          content: Text(
            'Are you sure you want to delete '
            '"${project.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      final token =
          await AuthService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Authentication token not found',
        );
      }

      await ProjectService.deleteProject(
        project.id,
        token: token,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Project deleted successfully',
          ),
        ),
      );

      loadProjects();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete project: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Projects',
        ),
        actions: [
          IconButton(
            onPressed: loadProjects,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: loadProjects,
        child: _buildBody(),
      ),

      floatingActionButton:
          FloatingActionButton(
        onPressed:
            openCreateProject,
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return ListView(
        children: [
          const SizedBox(
            height: 150,
          ),

          const Icon(
            Icons.error_outline,
            size: 60,
          ),

          const SizedBox(
            height: 20,
          ),

          const Center(
            child: Text(
              'Failed to load projects',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Text(
              errorMessage!,
              textAlign:
                  TextAlign.center,
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          Center(
            child:
                ElevatedButton(
              onPressed:
                  loadProjects,
              child: const Text(
                'Retry',
              ),
            ),
          ),
        ],
      );
    }

    // Filter projects
    final filteredProjects =
        projects.where((project) {
      // Search filter
      final matchesSearch =
          searchQuery.isEmpty ||
              project.name
                  .toLowerCase()
                  .contains(searchQuery) ||
              (project.description ??
                      '')
                  .toLowerCase()
                  .contains(searchQuery);

      // Status filter
      final matchesStatus =
          selectedStatus == 'All' ||
              project.status ==
                  selectedStatus;

      return matchesSearch &&
          matchesStatus;
    }).toList();

    return ListView(
      padding:
          const EdgeInsets.all(16),
      children: [
        // SEARCH
        TextField(
          controller:
              searchController,
          decoration:
              InputDecoration(
            hintText:
                'Search projects...',
            prefixIcon:
                const Icon(
              Icons.search,
            ),
            suffixIcon:
                searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController
                              .clear();
                        },
                        icon:
                            const Icon(
                          Icons.clear,
                        ),
                      )
                    : null,
            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
          ),
        ),

        const SizedBox(
          height: 16,
        ),

        // STATUS FILTER
        DropdownButtonFormField<String>(
          initialValue: selectedStatus,
          decoration:
              InputDecoration(
            labelText:
                'Filter by status',
            prefixIcon:
                const Icon(
              Icons.filter_list,
            ),
            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
          ),
          items: const [
            DropdownMenuItem(
              value: 'All',
              child:
                  Text('All'),
            ),
            DropdownMenuItem(
              value:
                  'Not Started',
              child: Text(
                'Not Started',
              ),
            ),
            DropdownMenuItem(
              value:
                  'In Progress',
              child: Text(
                'In Progress',
              ),
            ),
            DropdownMenuItem(
              value:
                  'Completed',
              child: Text(
                'Completed',
              ),
            ),
          ],
          onChanged:
              (value) {
            if (value == null) {
              return;
            }

            setState(() {
              selectedStatus =
                  value;
            });
          },
        ),

        const SizedBox(
          height: 16,
        ),

        // NO PROJECTS
        if (projects.isEmpty)
          const Padding(
            padding:
                EdgeInsets.only(
              top: 120,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.folder_open,
                  size: 70,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'No projects found',
                  style:
                      TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Create your first '
                  'project using the + button.',
                  textAlign:
                      TextAlign.center,
                ),
              ],
            ),
          )

        // NO MATCHING PROJECTS
        else if (filteredProjects.isEmpty)
          const Padding(
            padding:
                EdgeInsets.only(
              top: 120,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.search_off,
                  size: 70,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'No matching projects',
                  style:
                      TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Try changing the '
                  'search or filter.',
                  textAlign:
                      TextAlign.center,
                ),
              ],
            ),
          )

        // PROJECT LIST
        else
          ...filteredProjects.map(
            (project) {
              final statusColor =
                  getStatusColor(
                project.status,
              );

              return Card(
                margin:
                    const EdgeInsets.only(
                  bottom: 12,
                ),
                child:
                    ListTile(
                  leading:
                      const CircleAvatar(
                    child:
                        Icon(
                      Icons.folder,
                    ),
                  ),

                  title:
                      Text(
                    project.name,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  subtitle:
                      Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      if (project
                                  .description !=
                              null &&
                          project
                              .description!
                              .isNotEmpty)
                        Text(
                          project
                              .description!,
                        ),

                      const SizedBox(
                        height: 6,
                      ),

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              statusColor
                                  .withValues(
                            alpha: 0.15,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            8,
                          ),
                        ),
                        child:
                            Text(
                          project.status,
                          style:
                              TextStyle(
                            color:
                                statusColor,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  trailing:
                      PopupMenuButton<
                          String>(
                    onSelected:
                        (value) async {
                      if (value ==
                          'edit') {
                        final result =
                            await Navigator
                                .push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    EditProjectScreen(
                              project:
                                  project,
                            ),
                          ),
                        );

                        if (result ==
                            true) {
                          loadProjects();
                        }
                      }

                      if (value ==
                          'delete') {
                        deleteProject(
                          project,
                        );
                      }
                    },
                    itemBuilder:
                        (context) =>
                            const [
                      PopupMenuItem(
                        value: 'edit',
                        child:
                            Text(
                          'Edit',
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child:
                            Text(
                          'Delete',
                        ),
                      ),
                    ],
                  ),

                  isThreeLine:
                      true,

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
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
      ],
    );
  }
}