import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          task['title'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task['description'] ?? ''),
            const SizedBox(height: 4),
            Chip(
              label: Text(
                task['status'],
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: task['status'] == 'toDo'
                  ? Colors.blue[700]
                  : task['status'] == 'inProgress'
                      ? Colors.orange[600]
                      : Colors.green[600],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              task['deadline'].toString().substring(0, 10),
              style: TextStyle(color: Colors.grey[600]),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              color: Theme.of(context).primaryColor,
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red[400],
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}