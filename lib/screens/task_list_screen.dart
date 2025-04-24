import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_service.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  final String? searchQuery;
  final String? filterStatus;
  final String? filterCategory;
  final int? projectId;

  const TaskListScreen({
    super.key,
    this.searchQuery,
    this.filterStatus,
    this.filterCategory,
    this.projectId,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();
    return FutureBuilder<List<Task>>(
      future: widget.searchQuery != null && widget.searchQuery!.isNotEmpty
          ? dbService.searchTasks(widget.searchQuery!)
          : dbService.filterTasks(
              status: widget.filterStatus,
              category: widget.filterCategory,
              projectId: widget.projectId,
            ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Aucune tâche'));
        }
        final tasks = snapshot.data!;
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskCard(
              task: task.toMap(),
              onEdit: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskFormScreen(
                      projectId: task.projectId,
                      task: task,
                      onSave: _refresh, // Passer la fonction de rafraîchissement
                    ),
                  ),
                );
              },
              onDelete: () async {
                await dbService.deleteTask(task.id!);
                _refresh();
              },
            );
          },
        );
      },
    );
  }
}