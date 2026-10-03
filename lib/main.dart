import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/notifications/notification_service.dart';

import 'core/auth/auth_service.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'firebase_options.dart';
import 'core/database/app_database.dart';
import 'core/network/api_client.dart';
import 'core/network/connectivity_service.dart';
import 'core/sync/sync_service.dart';
import 'features/attachments/models/attachment.dart';
import 'features/comments/models/comment.dart';
import 'features/projects/models/project.dart';
import 'features/tasks/models/task.dart';
import 'core/cloud/firestore_service.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authService = AuthService();
  await NotificationService().initialize();

  runApp(
    WorkFlowApp(
      authService: authService,
    ),
  );
}

class WorkFlowApp extends StatelessWidget {
  const WorkFlowApp({
    super.key,
    required this.authService,
  });

  final AuthService authService;
  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF5B5FEF),
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WorkFlow',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFF7F8FC),
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: EdgeInsets.zero,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: colorScheme.primaryContainer,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 1.5,
            ),
          ),
        ),
      ),
      home: AuthGate(
        authService: authService,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.authService,
  });

  final AuthService authService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();

    screens = [
      const DashboardScreen(),
      const ProjectsScreen(),
      SettingsScreen(
        authService: widget.authService,
      ),
    ];
  }

  final List<String> titles = const [
    'Dashboard',
    'Projects',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[selectedIndex]),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: screens[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning 👋',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Let’s manage your work',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Total tasks',
                    value: '25',
                    icon: Icons.task_alt_rounded,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    title: 'Completed',
                    value: '12',
                    icon: Icons.check_circle_outline_rounded,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'In progress',
                    value: '8',
                    icon: Icons.timelapse_rounded,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    title: 'Overdue',
                    value: '5',
                    icon: Icons.warning_amber_rounded,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'Recent activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            const ActivityCard(
              icon: Icons.edit_note_rounded,
              title: 'Task updated',
              subtitle: 'Design login screen',
              time: '10 minutes ago',
              color: Colors.indigo,
            ),
            const SizedBox(height: 10),
            const ActivityCard(
              icon: Icons.comment_rounded,
              title: 'New comment added',
              subtitle: 'Create API service',
              time: '1 hour ago',
              color: Colors.teal,
            ),
            const SizedBox(height: 10),
            const ActivityCard(
              icon: Icons.check_circle_rounded,
              title: 'Task completed',
              subtitle: 'Fix dashboard layout',
              time: 'Yesterday',
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subtitle),
        trailing: Text(
          time,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  static const List<Project> projects = [
    Project(
      id: '1',
      name: 'Mobile App',
      description: 'WorkFlow mobile application',
      taskCount: 8,
    ),
    Project(
      id: '2',
      name: 'Frontend Dashboard',
      description: 'Admin dashboard project',
      taskCount: 5,
    ),
    Project(
      id: '3',
      name: 'Client Website',
      description: 'Company website improvements',
      taskCount: 12,
    ),
  ];

  static const List<Task> tasks = [
    Task(
      id: 'task-1',
      projectId: '1',
      title: 'Design login screen',
      description: 'Create the login screen UI and validation.',
      status: 'To Do',
      priority: 'High',
    ),
    Task(
      id: 'task-2',
      projectId: '1',
      title: 'Create API service',
      description: 'Prepare the API client for remote requests.',
      status: 'In Progress',
      priority: 'Medium',
    ),
    Task(
      id: 'task-3',
      projectId: '2',
      title: 'Fix dashboard layout',
      description: 'Improve dashboard layout for smaller screens.',
      status: 'Done',
      priority: 'Low',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Text(
          'Your workspace',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Projects',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          decoration: InputDecoration(
            hintText: 'Search projects',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.tune_rounded),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ...projects.map(
              (project) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ProjectCard(
              project: project,
              tasks: tasks,
            ),
          ),
        ),
      ],
    );
  }
}

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.tasks,
  });

  final Project project;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ProjectDetailsScreen(
                  project: project,
                  initialTasks: tasks,
                );
              },
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: Colors.indigo.withValues(alpha: 0.12),
                child: Text(
                  project.name[0],
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      project.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${project.taskCount} tasks',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 17),
            ],
          ),
        ),
      ),
    );
  }
}

class ProjectDetailsScreen extends StatefulWidget {
  const ProjectDetailsScreen({
    super.key,
    required this.project,
    required this.initialTasks,
  });

  final Project project;
  final List<Task> initialTasks;

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final database = AppDatabase.instance;
  final apiClient = ApiClient();
  final searchController = TextEditingController();
  final syncService = SyncService();
  final connectivityService = ConnectivityService();

  StreamSubscription<bool>? connectivitySubscription;

  List<Task> projectTasks = [];

  bool isLoading = true;
  bool isRefreshing = false;
  String searchQuery = '';
  String selectedStatus = 'All';
  String selectedPriority = 'All';

  Future<void> processPendingSync() async {
    final isOnline = await connectivityService.isOnline;

    if (!isOnline) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You are offline. Changes will sync when internet returns.',
          ),
        ),
      );

      return;
    }

    try {
      final pendingOperations =
      await syncService.getPendingOperations();

      if (pendingOperations.isEmpty) {
        return;
      }

      await syncService.syncPendingOperations();
      await refreshTasks();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pending changes synchronized'),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Synchronization failed'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadTasks();
    startConnectivityListener();
  }

  @override
  void dispose() {
    connectivitySubscription?.cancel();
    apiClient.dispose();
    syncService.dispose();
    connectivityService;
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadTasks() async {
    try {
      final storedTasks = await database.getTasksByProject(
        widget.project.id,
      );

      if (!mounted) {
        return;
      }

      if (storedTasks.isEmpty) {
        for (final task in widget.initialTasks) {
          await database.insertTask(task);
        }

        projectTasks = await database.getTasksByProject(
          widget.project.id,
        );
      } else {
        projectTasks = storedTasks;
      }

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        projectTasks = [];
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load tasks'),
        ),
      );
    }
  }

  Future<void> refreshFromApi() async {
    setState(() {
      isRefreshing = true;
    });

    try {
      final remoteTasks = await apiClient.fetchTasks(
        projectId: widget.project.id,
      );

      await database.replaceTasksForProject(
        widget.project.id,
        remoteTasks,
      );

      await refreshTasks();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tasks refreshed from API'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to refresh tasks'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isRefreshing = false;
        });
      }
    }
  }

  void startConnectivityListener() {
    connectivitySubscription =
        connectivityService.onlineStatusStream.listen(
              (isOnline) {
            if (isOnline) {
              processPendingSync();
            }
          },
        );
  }

  Future<void> openCreateTaskScreen() async {
    final newTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return CreateTaskScreen(
            projectId: widget.project.id,
          );
        },
      ),
    );

    if (newTask == null) {
      return;
    }

    await syncService.queueTaskCreate(newTask);
    await refreshTasks();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task created locally and added to sync queue'),
      ),
    );
  }

  Future<void> openEditTaskScreen(Task task) async {
    final updatedTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return CreateTaskScreen(
            projectId: widget.project.id,
            existingTask: task,
          );
        },
      ),
    );

    if (updatedTask == null) {
      return;
    }

    await syncService.queueTaskUpdate(updatedTask);
    await refreshTasks();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task updated locally and added to sync queue'),
      ),
    );
  }

  Future<void> deleteTask(Task task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete task?'),
          content: Text(
            'Are you sure you want to delete "${task.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await database.deleteTask(task.id);
    await refreshTasks();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task deleted'),
      ),
    );
  }

  Future<void> refreshTasks() async {
    final storedTasks = await database.getTasksByProject(widget.project.id);

    if (!mounted) {
      return;
    }

    setState(() {
      projectTasks = storedTasks;
    });
  }

  Future<void> showPendingSyncOperations() async {
    final operations = await syncService.getPendingOperations();

    if (!mounted) {
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: operations.isEmpty
                ? const EmptyState(
              icon: Icons.cloud_done_outlined,
              title: 'Everything is synced',
              message: 'There are no pending changes.',
            )
                : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pending changes',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${operations.length} operation(s) waiting to sync.',
                ),
                const SizedBox(height: 16),
                ...operations.map(
                      (operation) => ListTile(
                    leading: const Icon(
                      Icons.cloud_upload_outlined,
                    ),
                    title: Text(
                      '${operation.operationType} ${operation.entityType}',
                    ),
                    subtitle: Text(
                      'Retry count: ${operation.retryCount}',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Task> get filteredTasks {
    return projectTasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );

      final matchesStatus =
          selectedStatus == 'All' || task.status == selectedStatus;

      final matchesPriority =
          selectedPriority == 'All' || task.priority == selectedPriority;

      return matchesSearch && matchesStatus && matchesPriority;
    }).toList();
  }

  void openTaskDetailsScreen(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return TaskDetailsScreen(task: task);
        },
      ),
    );
  }

  void clearFilters() {
    searchController.clear();

    setState(() {
      searchQuery = '';
      selectedStatus = 'All';
      selectedPriority = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleTasks = filteredTasks;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        actions: [
          IconButton(
            tooltip: 'Sync pending changes',
            onPressed: processPendingSync,
            icon: const Icon(Icons.cloud_sync_rounded),
          ),
          IconButton(
            tooltip: 'Refresh from API',
            onPressed: isRefreshing ? null : refreshFromApi,
            icon: isRefreshing
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : const Icon(Icons.sync_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isLoading ? null : openCreateTaskScreen,
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('Add task'),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        children: [
          ProjectHeader(project: widget.project),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tasks',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${visibleTasks.length} items',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search tasks',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searchQuery.isEmpty
                  ? null
                  : IconButton(
                onPressed: () {
                  searchController.clear();

                  setState(() {
                    searchQuery = '';
                  });
                },
                icon: const Icon(Icons.clear_rounded),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TaskFilters(
            selectedStatus: selectedStatus,
            selectedPriority: selectedPriority,
            onStatusChanged: (value) {
              setState(() {
                selectedStatus = value;
              });
            },
            onPriorityChanged: (value) {
              setState(() {
                selectedPriority = value;
              });
            },
            onClear: clearFilters,
          ),
          const SizedBox(height: 16),
          if (visibleTasks.isEmpty)
            const EmptyState(
              icon: Icons.search_off_rounded,
              title: 'No matching tasks',
              message: 'Try changing your search or filters.',
            )
          else
            ...visibleTasks.map(
                  (task) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TaskCard(
                  task: task,
                  onEdit: () => openEditTaskScreen(task),
                  onDelete: () => deleteTask(task),
                  onOpen: () => openTaskDetailsScreen(task),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ProjectHeader extends StatelessWidget {
  const ProjectHeader({
    super.key,
    required this.project,
  });

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.indigo.withValues(alpha: 0.12),
              child: Text(
                project.name[0],
                style: const TextStyle(
                  color: Colors.indigo,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(project.description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskFilters extends StatelessWidget {
  const TaskFilters({
    super.key,
    required this.selectedStatus,
    required this.selectedPriority,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onClear,
  });

  final String selectedStatus;
  final String selectedPriority;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onPriorityChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasFilters =
        selectedStatus != 'All' || selectedPriority != 'All';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'All',
                    child: Text('All'),
                  ),
                  DropdownMenuItem(
                    value: 'To Do',
                    child: Text('To Do'),
                  ),
                  DropdownMenuItem(
                    value: 'In Progress',
                    child: Text('In Progress'),
                  ),
                  DropdownMenuItem(
                    value: 'Done',
                    child: Text('Done'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onStatusChanged(value);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  prefixIcon: Icon(Icons.priority_high_rounded),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'All',
                    child: Text('All'),
                  ),
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
                    onPriorityChanged(value);
                  }
                },
              ),
            ),
          ],
        ),
        if (hasFilters)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.clear_all_rounded),
              label: const Text('Clear filters'),
            ),
          ),
      ],
    );
  }
}

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({
    super.key,
    required this.task,
  });

  final Task task;

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}
class TaskInformationCard extends StatelessWidget {
  const TaskInformationCard({
    super.key,
    required this.task,
  });

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(task.description),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusChip(
                  label: task.status,
                  color: Colors.indigo,
                ),
                StatusChip(
                  label: '${task.priority} priority',
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AttachmentsSection extends StatelessWidget {
  const AttachmentsSection({
    super.key,
    required this.attachments,
    required this.isUploading,
    required this.onAdd,
    required this.onDelete,
  });

  final List<Attachment> attachments;
  final bool isUploading;
  final VoidCallback onAdd;
  final ValueChanged<Attachment> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Attachments',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            IconButton.filledTonal(
              onPressed: isUploading ? null : onAdd,
              icon: isUploading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.attach_file_rounded),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (attachments.isEmpty)
          const EmptyState(
            icon: Icons.attach_file_rounded,
            title: 'No attachments',
            message: 'Add an image related to this task.',
          )
        else
          ...attachments.map(
                (attachment) => AttachmentCard(
              attachment: attachment,
              onDelete: () => onDelete(attachment),
            ),
          ),
      ],
    );
  }
}

class AttachmentCard extends StatelessWidget {
  const AttachmentCard({
    super.key,
    required this.attachment,
    required this.onDelete,
  });

  final Attachment attachment;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final localFile = File(attachment.filePath);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: localFile.existsSync()
            ? Image.file(
          localFile,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        )
            : const Icon(Icons.image_not_supported_outlined),
        title: Text(
          attachment.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: const Text('Stored locally'),
        trailing: IconButton(
          tooltip: 'Delete attachment',
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ),
    );
  }
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final database = AppDatabase.instance;
  final commentController = TextEditingController();
  final imagePicker = ImagePicker();
  final firestoreService = FirestoreService();

  List<Comment> comments = [];
  List<Attachment> attachments = [];

  bool isLoading = true;
  bool isSaving = false;
  bool isUploading = false;
  String? get currentUserId {
    return FirebaseAuth.instance.currentUser?.uid;
  }
  @override
  void initState() {
    super.initState();
    loadTaskData();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> loadTaskData() async {
    final storedComments = await database.getCommentsByTask(
      widget.task.id,
    );

    final userId = currentUserId;

    if (userId != null) {
      try {
        final cloudComments = await firestoreService.getComments(
          userId: userId,
          taskId: widget.task.id,
        );

        for (final comment in cloudComments) {
          await database.insertComment(comment);
        }
      } catch (_) {
        // Keep showing local comments if cloud loading fails.
      }
    }

    final storedAttachments =
    await database.getAttachmentsByTask(widget.task.id);

    if (!mounted) {
      return;
    }

    setState(() {
      comments = storedComments;
      attachments = storedAttachments;
      isLoading = false;
    });
  }
  Future<void> addComment() async {
    final text = commentController.text.trim();
    final userId = currentUserId;

    if (text.isEmpty || isSaving || userId == null) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    final comment = Comment(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      taskId: widget.task.id,
      text: text,
      createdAt: DateTime.now(),
    );

    try {
      await database.insertComment(comment);

      await firestoreService.saveComment(
        userId: userId,
        comment: comment,
      );

      commentController.clear();
      await loadTaskData();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment saved'),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save comment'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }

    FocusScope.of(context).unfocus();
  }
  Future<void> saveTaskToCloud() async {
    final userId = currentUserId;

    if (userId == null) {
      return;
    }

    try {
      await firestoreService.saveTask(
        userId: userId,
        task: widget.task,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task saved to cloud'),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save task to cloud'),
        ),
      );
    }
  }

  Future<void> deleteComment(Comment comment) async {
    await database.deleteComment(comment.id);
    await loadTaskData();
  }

  Future<void> pickAttachment() async {
    if (isUploading) {
      return;
    }

    final selectedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (selectedFile == null) {
      return;
    }

    setState(() {
      isUploading = true;
    });

    final attachment = Attachment(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      taskId: widget.task.id,
      fileName: selectedFile.name,
      filePath: selectedFile.path,
      createdAt: DateTime.now(),
    );

    try {
      await database.insertAttachment(attachment);
      await loadTaskData();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attachment saved locally'),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save attachment'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  Future<void> deleteAttachment(Attachment attachment) async {
    await database.deleteAttachment(attachment.id);
    await loadTaskData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task details'),
        actions: [
          IconButton(
            tooltip: 'Save to cloud',
            onPressed: saveTaskToCloud,
            icon: const Icon(Icons.cloud_upload_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                children: [
                  TaskInformationCard(task: widget.task),
                  const SizedBox(height: 24),
                  AttachmentsSection(
                    attachments: attachments,
                    isUploading: isUploading,
                    onAdd: pickAttachment,
                    onDelete: deleteAttachment,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Comments',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (comments.isEmpty)
                    const EmptyState(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'No comments yet',
                      message: 'Add the first comment for this task.',
                    )
                  else
                    ...comments.map(
                          (comment) => CommentCard(
                        comment: comment,
                        onDelete: () => deleteComment(comment),
                      ),
                    ),
                ],
              ),
            ),
            CommentInput(
              controller: commentController,
              isSaving: isSaving,
              onSubmit: addComment,
            ),
          ],
        ),
      ),
    );
  }
}
class CommentCard extends StatelessWidget {
  const CommentCard({
    super.key,
    required this.comment,
    required this.onDelete,
  });

  final Comment comment;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDate(comment.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        leading: CircleAvatar(
          backgroundColor:
          Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.person_outline_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(comment.text),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(formattedDate),
        ),
        trailing: IconButton(
          tooltip: 'Delete comment',
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();

    return '${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year} '
        '${localDate.hour.toString().padLeft(2, '0')}:'
        '${localDate.minute.toString().padLeft(2, '0')}';
  }
}

class CommentInput extends StatelessWidget {
  const CommentInput({
    super.key,
    required this.controller,
    required this.isSaving,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool isSaving;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 8,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          12 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Write a comment...',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: isSaving ? null : onSubmit,
              icon: isSaving
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}


class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({
    super.key,
    required this.projectId,
    this.existingTask,
  });

  final String projectId;
  final Task? existingTask;

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;

  late String selectedStatus;
  late String selectedPriority;

  bool get isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();

    final task = widget.existingTask;

    titleController = TextEditingController(
      text: task?.title ?? '',
    );

    descriptionController = TextEditingController(
      text: task?.description ?? '',
    );

    selectedStatus = task?.status ?? 'To Do';
    selectedPriority = task?.priority ?? 'Medium';
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void saveTask() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final task = Task(
      id: widget.existingTask?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      projectId: widget.projectId,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      status: selectedStatus,
      priority: selectedPriority,
    );

    Navigator.pop(context, task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit task' : 'Create task'),
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Text(
                isEditing ? 'Update task' : 'Task information',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isEditing
                    ? 'Change the details of this task.'
                    : 'Add the details needed to track this task.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Task title',
                  hintText: 'Example: Design login screen',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }

                  if (value.trim().length < 3) {
                    return 'Title must contain at least 3 characters';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                minLines: 4,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Explain what needs to be done',
                  prefixIcon: Icon(Icons.notes_rounded),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'To Do',
                    child: Text('To Do'),
                  ),
                  DropdownMenuItem(
                    value: 'In Progress',
                    child: Text('In Progress'),
                  ),
                  DropdownMenuItem(
                    value: 'Done',
                    child: Text('Done'),
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
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  prefixIcon: Icon(Icons.priority_high_rounded),
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
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    selectedPriority = value;
                  });
                },
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: saveTask,
                icon: Icon(
                  isEditing ? Icons.check_rounded : Icons.save_rounded,
                ),
                label: Text(
                  isEditing ? 'Save changes' : 'Save task',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onOpen,
  });

  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(task.status);
    final priorityColor = _priorityColor(task.priority);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) {
                      return const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ];
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(task.description),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusChip(
                      label: task.status,
                      color: statusColor,
                    ),
                    StatusChip(
                      label: '${task.priority} priority',
                      color: priorityColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 16,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Tap to view comments',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              // Add the sync-status UI here.
              if (task.syncStatus != 'synced') ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      task.syncStatus == 'failed'
                          ? Icons.sync_problem_rounded
                          : Icons.cloud_upload_outlined,
                      size: 16,
                      color: task.syncStatus == 'failed'
                          ? Colors.redAccent
                          : Colors.orange,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      task.syncStatus == 'failed'
                          ? 'Sync failed'
                          : 'Pending sync',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: task.syncStatus == 'failed'
                            ? Colors.redAccent
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Done':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      default:
        return Colors.indigo;
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.redAccent;
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.authService,
  });

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Text(
          'Preferences',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline_rounded),
                title: const Text('Profile'),
                subtitle: const Text('Manage your profile'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: const Text('Appearance'),
                subtitle: const Text('Light mode'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.notifications_none_rounded),
                title: const Text('Notifications'),
                subtitle: const Text('Manage notifications'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('Sign out'),
                subtitle: const Text('Sign out from this device'),
                onTap: () async {
                  await authService.logout();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}