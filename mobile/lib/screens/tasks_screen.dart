import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import 'create_task_screen.dart';
import 'edit_task_screen.dart';

class TasksScreen extends StatefulWidget {
  final int projectId;
  final String projectName;

  const TasksScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task> tasks = [];

  bool isLoading = true;
  String? errorMessage;

  // Search
  final TextEditingController searchController =
      TextEditingController();

  String searchQuery = '';

  // Filters
  String selectedStatus = 'All';
  String selectedPriority = 'All';

  @override
  void initState() {
    super.initState();
    loadTasks();

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

  // =========================
  // LOAD TASKS
  // =========================

  Future<void> loadTasks() async {
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

      final result = await TaskService.getTasks(
        widget.projectId,
        token: token,
      );

      if (!mounted) return;

      setState(() {
        tasks = result;
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

  // =========================
  // DELETE TASK
  // =========================

  Future<void> deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: Text(
            'Are you sure you want to delete "${task.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      final token = await AuthService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Authentication token not found',
        );
      }

      await TaskService.deleteTask(
        task.id,
        token: token,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Task deleted successfully',
          ),
        ),
      );

      await loadTasks();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete task: $e',
          ),
        ),
      );
    }
  }

  // =========================
  // MARK TASK COMPLETED
  // =========================

  Future<void> completeTask(Task task) async {
    if (task.status == 'Completed') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Task is already completed',
          ),
        ),
      );

      return;
    }

    try {
      final token = await AuthService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Authentication token not found',
        );
      }

      await TaskService.updateTask(
        taskId: task.id,
        name: task.name,
        description: task.description,
        priority: task.priority,
        status: 'Completed',
        dueDate: task.dueDate,
        token: token,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Task marked as completed',
          ),
        ),
      );

      await loadTasks();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to complete task: $e',
          ),
        ),
      );
    }
  }

  // =========================
  // EDIT TASK
  // =========================

  Future<void> editTask(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTaskScreen(
          task: task,
        ),
      ),
    );

    if (result == true) {
      await loadTasks();
    }
  }

  // =========================
  // CREATE TASK
  // =========================

  Future<void> createTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTaskScreen(
          projectId: widget.projectId,
          projectName: widget.projectName,
        ),
      ),
    );

    if (result == true) {
      await loadTasks();
    }
  }

  // =========================
  // PRIORITY COLOR
  // =========================

  Color getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;

      case 'Medium':
        return Colors.orange;

      case 'Low':
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  // =========================
  // STATUS COLOR
  // =========================

  Color getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;

      case 'In Progress':
        return Colors.orange;

      case 'Pending':
        return Colors.blue;

      default:
        return Colors.grey;
    }
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName),
        actions: [
          IconButton(
            onPressed: loadTasks,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: loadTasks,
        child: _buildBody(),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: createTask,
        child: const Icon(Icons.add),
      ),
    );
  }

  // =========================
  // BODY
  // =========================

  Widget _buildBody() {
    // LOADING
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // ERROR
    if (errorMessage != null) {
      return ListView(
        children: [
          const SizedBox(height: 150),

          const Icon(
            Icons.error_outline,
            size: 60,
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              'Failed to load tasks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Text(
              errorMessage!,
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: ElevatedButton(
              onPressed: loadTasks,
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    // FILTER TASKS
    final filteredTasks = tasks.where((task) {
      // Search
      final matchesSearch =
          searchQuery.isEmpty ||
          task.name
              .toLowerCase()
              .contains(searchQuery) ||
          (task.description ?? '')
              .toLowerCase()
              .contains(searchQuery);

      // Status
      final matchesStatus =
          selectedStatus == 'All' ||
          task.status == selectedStatus;

      // Priority
      final matchesPriority =
          selectedPriority == 'All' ||
          task.priority == selectedPriority;

      return matchesSearch &&
          matchesStatus &&
          matchesPriority;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // =========================
        // SEARCH
        // =========================

        TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search tasks...',
            prefixIcon: const Icon(
              Icons.search,
            ),
            suffixIcon:
                searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();
                        },
                        icon: const Icon(
                          Icons.clear,
                        ),
                      )
                    : null,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // =========================
        // STATUS FILTER
        // =========================

        DropdownButtonFormField<String>(
          initialValue: selectedStatus,
          decoration: InputDecoration(
            labelText: 'Filter by status',
            prefixIcon: const Icon(
              Icons.filter_list,
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
            ),
          ),
          items: const [
            DropdownMenuItem(
              value: 'All',
              child: Text('All'),
            ),
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
            if (value == null) {
              return;
            }

            setState(() {
              selectedStatus = value;
            });
          },
        ),

        const SizedBox(height: 12),

        // =========================
        // PRIORITY FILTER
        // =========================

        DropdownButtonFormField<String>(
          initialValue: selectedPriority,
          decoration: InputDecoration(
            labelText: 'Filter by priority',
            prefixIcon: const Icon(
              Icons.priority_high,
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
            ),
          ),
          items: const [
            DropdownMenuItem(
              value: 'All',
              child: Text('All'),
            ),
            DropdownMenuItem(
              value: 'High',
              child: Text('High'),
            ),
            DropdownMenuItem(
              value: 'Medium',
              child: Text('Medium'),
            ),
            DropdownMenuItem(
              value: 'Low',
              child: Text('Low'),
            ),
          ],
          onChanged: (value) {
            if (value == null) {
              return;
            }

            setState(() {
              selectedPriority = value;
            });
          },
        ),

        const SizedBox(height: 16),

        // =========================
        // NO TASKS
        // =========================

        if (tasks.isEmpty)
          const Padding(
            padding: EdgeInsets.only(
              top: 150,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.task_alt,
                  size: 70,
                ),

                SizedBox(height: 20),

                Text(
                  'No tasks found',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  'Create your first task '
                  'using the + button.',
                  textAlign:
                      TextAlign.center,
                ),
              ],
            ),
          )

        // =========================
        // NO FILTER MATCH
        // =========================

        else if (filteredTasks.isEmpty)
          const Padding(
            padding: EdgeInsets.only(
              top: 120,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.search_off,
                  size: 70,
                ),

                SizedBox(height: 20),

                Text(
                  'No matching tasks',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  'Try changing the '
                  'search or filters.',
                  textAlign:
                      TextAlign.center,
                ),
              ],
            ),
          )

        // =========================
        // TASK LIST
        // =========================

        else
          ...filteredTasks.map(
            (task) {
              final priorityColor =
                  getPriorityColor(
                task.priority,
              );

              final statusColor =
                  getStatusColor(
                task.status,
              );

              final isCompleted =
                  task.status == 'Completed';

              return Card(
                margin:
                    const EdgeInsets.only(
                  bottom: 12,
                ),

                child: ListTile(
                  // =========================
                  // TASK ICON
                  // =========================

                  leading: Icon(
                    isCompleted
                        ? Icons.check_circle
                        : Icons
                            .radio_button_unchecked,
                    color: isCompleted
                        ? Colors.green
                        : Colors.grey,
                    size: 30,
                  ),

                  // =========================
                  // TASK NAME
                  // =========================

                  title: Text(
                    task.name,
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      decoration: isCompleted
                          ? TextDecoration
                              .lineThrough
                          : null,
                    ),
                  ),

                  // =========================
                  // TASK DETAILS
                  // =========================

                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      if (task.description !=
                              null &&
                          task.description!
                              .isNotEmpty)
                        Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                            top: 4,
                          ),
                          child: Text(
                            task.description!,
                          ),
                        ),

                      const SizedBox(
                        height: 8,
                      ),

                      // PRIORITY + STATUS
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
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
                                  priorityColor
                                      .withValues(
                                alpha: 0.15,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                8,
                              ),
                            ),
                            child: Text(
                              task.priority,
                              style: TextStyle(
                                color:
                                    priorityColor,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
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
                            child: Text(
                              task.status,
                              style: TextStyle(
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

                      // DUE DATE
                      if (task.dueDate !=
                              null &&
                          task.dueDate!
                              .isNotEmpty)
                        Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                            top: 6,
                          ),
                          child: Text(
                            'Due: ${task.dueDate}',
                            style:
                                const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),

                  // =========================
                  // MENU
                  // =========================

                  trailing:
                      PopupMenuButton<String>(
                    onSelected:
                        (value) async {
                      switch (value) {
                        case 'edit':
                          await editTask(
                            task,
                          );
                          break;

                        case 'complete':
                          await completeTask(
                            task,
                          );
                          break;

                        case 'delete':
                          await deleteTask(
                            task,
                          );
                          break;
                      }
                    },

                    itemBuilder:
                        (context) {
                      return [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text('Edit'),
                            ],
                          ),
                        ),

                        if (!isCompleted)
                          const PopupMenuItem(
                            value:
                                'complete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons
                                      .check_circle,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Mark Completed',
                                ),
                              ],
                            ),
                          ),

                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),

                  // TAP TASK = EDIT
                  onTap: () async {
                    await editTask(task);
                  },

                  isThreeLine: true,
                ),
              );
            },
          ),
      ],
    );
  }
}