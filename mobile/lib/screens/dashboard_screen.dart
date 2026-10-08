// ignore_for_file: unused_import

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/dashboard_service.dart';

import 'projects_screen.dart';
import 'tasks_home_screen.dart';

import '../widgets/error_view.dart';

class DashboardScreen extends StatefulWidget {
  // Theme controls
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const DashboardScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardStats? stats;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  // ============================================================
  // LOAD DASHBOARD
  // ============================================================

  Future<void> loadDashboard() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final token = await AuthService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final result = await DashboardService.getStats(
        token: token,
      );

      if (!mounted) return;

      setState(() {
        stats = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  // ============================================================
  // OPEN PROJECTS
  // ============================================================

  void openProjects() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProjectsScreen(),
      ),
    ).then((_) {
      loadDashboard();
    });
  }

  // ============================================================
  // OPEN TASKS
  // ============================================================

  void openTasks() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TasksHomeScreen(),
      ),
    ).then((_) {
      loadDashboard();
    });
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    // Clear authentication token
    await AuthService.logout();

    if (!mounted) return;

    // Go back to login and remove dashboard
    // and previous screens from navigation stack.
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,

        actions: [
          // ======================================================
          // REFRESH
          // ======================================================

          IconButton(
            onPressed: loadDashboard,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),

          // ======================================================
          // DARK / LIGHT MODE
          // ======================================================

          IconButton(
            onPressed: widget.onToggleTheme,
            icon: Icon(
              widget.isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            tooltip: widget.isDarkMode
                ? 'Light mode'
                : 'Dark mode',
          ),

          // ======================================================
          // LOGOUT
          // ======================================================

          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: RefreshIndicator(
        onRefresh: loadDashboard,

        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.all(20),

          children: [
            const SizedBox(height: 10),

            const Text(
              'Welcome!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Manage your projects and tasks',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            // ====================================================
            // LOADING
            // ====================================================

            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )

            // ====================================================
            // ERROR
            // ====================================================

            else if (errorMessage != null)
              _buildError()

            // ====================================================
            // STATISTICS
            // ====================================================

            else if (stats != null)
              _buildStatistics(),

            const SizedBox(height: 25),

            // ====================================================
            // PROJECTS CARD
            // ====================================================

            _DashboardCard(
              icon: Icons.folder,
              title: 'Projects',
              description:
                  'Create, edit and delete projects',
              onTap: openProjects,
            ),

            const SizedBox(height: 16),

            // ====================================================
            // TASKS CARD
            // ====================================================

            _DashboardCard(
              icon: Icons.task_alt,
              title: 'Tasks',
              description:
                  'View and manage project tasks',
              onTap: openTasks,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR VIEW
  // ============================================================

  Widget _buildError() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 45,
            ),

            const SizedBox(height: 10),

            Text(
              errorMessage ??
                  'Failed to load dashboard',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: loadDashboard,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  Widget _buildStatistics() {
    final data = stats!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 15),

        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.folder,
                title: 'Projects',
                value: data.totalProjects,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _StatCard(
                icon: Icons.task_alt,
                title: 'Tasks',
                value: data.totalTasks,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.check_circle,
                title: 'Completed',
                value:
                    data.completedProjects +
                    data.completedTasks,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _StatCard(
                icon: Icons.pending_actions,
                title: 'Pending',
                value:
                    data.pendingTasks +
                    data.notStartedProjects,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        const Text(
          'Project Status',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        _StatusRow(
          label: 'Not Started',
          value: data.notStartedProjects,
          icon: Icons.radio_button_unchecked,
        ),

        _StatusRow(
          label: 'In Progress',
          value: data.inProgressProjects,
          icon: Icons.timelapse,
        ),

        _StatusRow(
          label: 'Completed',
          value: data.completedProjects,
          icon: Icons.check_circle,
        ),

        const SizedBox(height: 20),

        const Text(
          'Task Status',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        _StatusRow(
          label: 'Pending',
          value: data.pendingTasks,
          icon: Icons.pending,
        ),

        _StatusRow(
          label: 'In Progress',
          value: data.inProgressTasks,
          icon: Icons.timelapse,
        ),

        _StatusRow(
          label: 'Completed',
          value: data.completedTasks,
          icon: Icons.check_circle,
        ),
      ],
    );
  }
}

// ================================================================
// STAT CARD
// ================================================================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color:
                  Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(height: 8),

            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// STATUS ROW
// ================================================================

class _StatusRow extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;

  const _StatusRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),

        title: Text(label),

        trailing: Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ================================================================
// DASHBOARD CARD
// ================================================================

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,

                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(12),

                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.12),
                ),

                child: Icon(
                  icon,
                  size: 30,
                  color: Theme.of(context)
                      .colorScheme
                      .primary,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}