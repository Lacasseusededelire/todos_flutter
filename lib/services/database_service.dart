import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';
import '../models/project.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tasks.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE projects (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            status TEXT NOT NULL,
            category TEXT NOT NULL,
            deadline TEXT NOT NULL,
            project_id INTEGER,
            FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE projects ADD COLUMN description TEXT');
          await db.execute('''
            CREATE TABLE tasks_new (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              description TEXT,
              status TEXT NOT NULL,
              category TEXT NOT NULL,
              deadline TEXT NOT NULL,
              project_id INTEGER,
              FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
            )
          ''');
          await db.execute('''
            INSERT INTO tasks_new (id, title, description, status, category, deadline, project_id)
            SELECT id, title, description, status, category, deadline, project_id
            FROM tasks
          ''');
          await db.execute('DROP TABLE tasks');
          await db.execute('ALTER TABLE tasks_new RENAME TO tasks');
        }
      },
    );
  }

  // CRUD pour Tasks
  Future<void> createTask({
    required String title,
    required String description,
    required TaskStatus status,
    required String category,
    required DateTime deadline,
    int? projectId,
  }) async {
    final db = await database;
    await db.insert('tasks', {
      'title': title,
      'description': description,
      'status': status.toString().split('.').last,
      'category': category,
      'deadline': deadline.toIso8601String(),
      'project_id': projectId,
    });
  }

  Future<List<Task>> getTasks({int? projectId}) async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: projectId != null ? 'project_id = ?' : null,
      whereArgs: projectId != null ? [projectId] : null,
    );
    return maps.map(Task.fromMap).toList();
  }

  Future<void> updateTask(int id, {
    String? title,
    String? description,
    TaskStatus? status,
    String? category,
    DateTime? deadline,
    int? projectId,
  }) async {
    final db = await database;
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (status != null) data['status'] = status.toString().split('.').last;
    if (category != null) data['category'] = category;
    if (deadline != null) data['deadline'] = deadline.toIso8601String();
    if (projectId != null) data['project_id'] = projectId;
    if (data.isNotEmpty) {
      await db.update('tasks', data, where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Task>> searchTasks(String query) async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map(Task.fromMap).toList();
  }

  Future<List<Task>> filterTasks({
    String? status,
    String? category,
    int? projectId,
  }) async {
    final db = await database;
    String? where;
    List<dynamic> whereArgs = [];
    if (status != null) {
      where = 'status = ?';
      whereArgs.add(status);
    }
    if (category != null) {
      where = where == null ? 'category = ?' : '$where AND category = ?';
      whereArgs.add(category);
    }
    if (projectId != null) {
      where = where == null ? 'project_id = ?' : '$where AND project_id = ?';
      whereArgs.add(projectId);
    }
    final maps = await db.query('tasks', where: where, whereArgs: whereArgs);
    return maps.map(Task.fromMap).toList();
  }

  // CRUD pour Projects
  Future<int> createProject({required String name, String? description}) async {
    final db = await database;
    return await db.insert('projects', {
      'name': name,
      'description': description,
    });
  }

  Future<List<Project>> getProjects({String? searchQuery}) async {
    final db = await database;
    final maps = await db.query(
      'projects',
      where: searchQuery != null && searchQuery.isNotEmpty ? 'name LIKE ?' : null,
      whereArgs: searchQuery != null && searchQuery.isNotEmpty ? ['%$searchQuery%'] : null,
    );
    return maps.map(Project.fromMap).toList();
  }

  Future<void> updateProject(int id, {required String name, String? description}) async {
    final db = await database;
    await db.update(
      'projects',
      {'name': name, 'description': description},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteProject(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'project_id = ?', whereArgs: [id]);
    await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }
}