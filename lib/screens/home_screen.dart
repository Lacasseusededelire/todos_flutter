import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/database_service.dart';
import '../models/project.dart';
import 'project_form_screen.dart';
import 'project_detail_screen.dart';
import 'task_form_screen.dart';
import 'task_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _filterStatus;
  String? _filterCategory;
  Project? _selectedProject;
  final DatabaseService _dbService = DatabaseService();

  void _refresh() => setState(() {});

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_refresh);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedProject?.name ?? 'TeamTasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: const Center(
                child: Text(
                  'Projets',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            ListTile(
              title: const Text('Toutes les tâches'),
              selected: _selectedProject == null,
              onTap: () {
                setState(() {
                  _selectedProject = null;
                });
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: FutureBuilder<List<Project>>(
                future: _dbService.getProjects(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Erreur de chargement'));
                  }
                  final projects = snapshot.data ?? [];
                  if (projects.isEmpty) {
                    return const Center(child: Text('Aucun projet'));
                  }
                  return ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      return ListTile(
                        title: Text(project.name),
                        selected: _selectedProject?.id == project.id,
                        onTap: () {
                          setState(() {
                            _selectedProject = project;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProjectFormScreen()),
                  ).then((_) => setState(() {}));
                },
                child: const Text('Ajouter un projet'),
              ),
            ),
          ],
        ),
      ),
      body: _selectedProject == null
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Rechercher une tâche',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          hint: const Text('Statut'),
                          value: _filterStatus,
                          isExpanded: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          items: ['toDo', 'inProgress', 'done'].map((status) {
                            return DropdownMenuItem(value: status, child: Text(status));
                          }).toList(),
                          onChanged: (value) => setState(() => _filterStatus = value),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          hint: const Text('Catégorie'),
                          value: _filterCategory,
                          isExpanded: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          items: ['Urgent', 'Normal', 'Low'].map((category) {
                            return DropdownMenuItem(value: category, child: Text(category));
                          }).toList(),
                          onChanged: (value) => setState(() => _filterCategory = value),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TaskListScreen(
                    searchQuery: _searchController.text,
                    filterStatus: _filterStatus,
                    filterCategory: _filterCategory,
                  ),
                ),
              ],
            )
          : ProjectDetailScreen(project: _selectedProject!),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskFormScreen(
                onSave: _refresh,
                projectId: _selectedProject?.id,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}