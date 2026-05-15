// screens/home_screen.dart
// Main dashboard — shows the daily quote, task stats, and the task list

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/quote_model.dart';
import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/quote_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/quote_card.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _quoteService = QuoteService();

  QuoteModel? _quote;
  bool _quoteLoading = true;
  String _filterStatus = 'All'; // All | Pending | Done

  @override
  void initState() {
    super.initState();
    _loadQuote();
  }

  Future<void> _loadQuote() async {
    setState(() => _quoteLoading = true);
    final q = await _quoteService.fetchRandomQuote();
    if (mounted) {
      setState(() {
        _quote = q;
        _quoteLoading = false;
      });
    }
  }

  void _showDeleteDialog(String taskId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Delete Task?',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        content: const Text(
          "This can't be undone. Are you sure you want to remove this task?",
          style: TextStyle(color: AppColors.textMid, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMid),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _firestoreService.deleteTask(taskId);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _openAddTask() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TaskFormScreen()),
    );
  }

  void _openEditTask(TaskModel task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );
  }

  List<TaskModel> _applyFilter(List<TaskModel> tasks) {
    switch (_filterStatus) {
      case 'Pending':
        return tasks.where((t) => !t.isDone).toList();
      case 'Done':
        return tasks.where((t) => t.isDone).toList();
      default:
        return tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<TaskModel>>(
          stream: _firestoreService.getUserTasks(user!.uid),
          builder: (context, snapshot) {
            final allTasks = snapshot.data ?? [];
            final doneTasks = allTasks.where((t) => t.isDone).length;
            final filteredTasks = _applyFilter(allTasks);

            return CustomScrollView(
              slivers: [
                // Top app bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _greeting(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMid,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'My Tasks',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Logout button
                        GestureDetector(
                          onTap: () async {
                            await _authService.logOut();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.logout_rounded,
                              color: AppColors.textMid,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Stats row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                    child: Row(
                      children: [
                        _StatChip(
                          label: 'Total',
                          value: allTasks.length,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        _StatChip(
                          label: 'Done',
                          value: doneTasks,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 10),
                        _StatChip(
                          label: 'Pending',
                          value: allTasks.length - doneTasks,
                          color: AppColors.warning,
                        ),
                      ],
                    ),
                  ),
                ),

                // Quote card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                    child: QuoteCard(
                      quote: _quote,
                      isLoading: _quoteLoading,
                      onRefresh: _loadQuote,
                    ),
                  ),
                ),

                // Filter chips
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
                    child: Row(
                      children: ['All', 'Pending', 'Done'].map((filter) {
                        final isSelected = _filterStatus == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _filterStatus = filter),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.divider,
                                ),
                              ),
                              child: Text(
                                filter,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textMid,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Task list or empty state
                if (snapshot.connectionState == ConnectionState.waiting)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )
                else if (filteredTasks.isEmpty)
                  SliverToBoxAdapter(child: _EmptyState(filter: _filterStatus))
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final task = filteredTasks[index];
                        return TaskCard(
                          task: task,
                          onToggle: () => _firestoreService.toggleTaskStatus(
                            task.id,
                            task.isDone,
                          ),
                          onEdit: () => _openEditTask(task),
                          onDelete: () => _showDeleteDialog(task.id),
                        );
                      }, childCount: filteredTasks.length),
                    ),
                  ),
              ],
            );
          },
        ),
      ),

      // Floating add button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTask,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Task',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning ☀️';
    if (hour < 17) return 'Good afternoon 🌤️';
    return 'Good evening 🌙';
  }
}

// Small rounded stat chip
class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Shown when there are no tasks
class _EmptyState extends StatelessWidget {
  final String filter;

  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.checklist_rounded,
              size: 44,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            filter == 'All' ? 'No tasks yet!' : 'No $filter tasks',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hit the button below to add your first task and start getting things done.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMid,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
