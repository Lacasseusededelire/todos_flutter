import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/project.dart';
import '../services/database_service.dart';

class TaskFormScreen extends StatefulWidget {
  final int? projectId;
  final Task? task;
  final VoidCallback? onSave;

  const TaskFormScreen({super.key, this.projectId, this.task, this.onSave});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  TaskStatus _status = TaskStatus.toDo;
  String _category = 'Urgent';
  DateTime _deadline = DateTime.now().add(const Duration(days: 1));
  int? _selectedProjectId;
  final _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    if (widget.task != null) {
      _status = widget.task!.status;
      _category = widget.task!.category;
      _deadline = widget.task!.deadline;
      _selectedProjectId = widget.task!.projectId;
    } else {
      _selectedProjectId = widget.projectId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Ajouter une tâche' : 'Modifier la tâche'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Titre',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  validator: (value) => value!.isEmpty ? 'Veuillez entrer un titre' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TaskStatus>(
                  decoration: InputDecoration(
                    labelText: 'Statut',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  value: _status,
                  items: TaskStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _status = value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Catégorie',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  value: _category,
                  items: ['Urgent', 'Normal', 'Low'].map((category) {
                    return DropdownMenuItem(value: category, child: Text(category));
                  }).toList(),
                  onChanged: (value) => setState(() => _category = value!),
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<Project>>(
                  future: _dbService.getProjects(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    final projects = snapshot.data ?? [];
                    return DropdownButtonFormField<int?>(
                      decoration: InputDecoration(
                        labelText: 'Projet',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      value: _selectedProjectId,
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Aucun projet'),
                        ),
                        ...projects.map((project) {
                          return DropdownMenuItem<int?>(
                            value: project.id,
                            child: Text(project.name),
                          );
                        }),
                      ],
                      onChanged: (value) => setState(() => _selectedProjectId = value),
                    );
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text('Délai: ${_deadline.toString().substring(0, 10)}'),
                  trailing: const Icon(Icons.calendar_today),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _deadline,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => _deadline = picked);
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (widget.task == null) {
                        await _dbService.createTask(
                          title: _titleController.text,
                          description: _descriptionController.text,
                          status: _status,
                          category: _category,
                          deadline: _deadline,
                          projectId: _selectedProjectId,
                        );
                      } else {
                        await _dbService.updateTask(
                          widget.task!.id!,
                          title: _titleController.text,
                          description: _descriptionController.text,
                          status: _status,
                          category: _category,
                          deadline: _deadline,
                          projectId: _selectedProjectId,
                        );
                      }
                      widget.onSave?.call();
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Enregistrer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}