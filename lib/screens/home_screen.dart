import 'package:flutter/material.dart';
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
  final TextEditingController _projectSearchController = TextEditingController();
  String? _filterStatus;
  String? _filterCategory;
  Project? _selectedProject;
  final DatabaseService _dbService = DatabaseService();

  void _refresh() => setState(() {});

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_refresh);
    _projectSearchController.addListener(_refresh);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _projectSearchController.dispose();
    super.dispose();
  }

  void _deleteProject(int id, BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer ce projet ? Toutes les tâches associées seront également supprimées.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _dbService.deleteProject(id);
      if (_selectedProject?.id == id) {
        setState(() {
          _selectedProject = null;
        });
      } else {
        setState(() {});
      }
    }
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _projectSearchController,
                decoration: InputDecoration(
                  labelText: 'Rechercher un projet',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  filled: true,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
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
                future: _dbService.getProjects(searchQuery: _projectSearchController.text),
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProjectFormScreen(project: project),
                                  ),
                                ).then((_) => setState(() {}));
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              onPressed: () => _deleteProject(project.id, context),
                            ),
                          ],
                        ),
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
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      filled: true,
                      fillColor: Theme.of(context).inputDecorationTheme.fillColor,
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
                            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                            filled: true,
                            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
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
                            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                            filled: true,
                            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
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
        onPressed: () {
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