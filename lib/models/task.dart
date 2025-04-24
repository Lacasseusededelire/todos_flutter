enum TaskStatus { toDo, inProgress, done }

class Task {
  final int? id;
  final String title;
  final String description;
  final TaskStatus status;
  final String category;
  final DateTime deadline;
  final int? projectId;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.category,
    required this.deadline,
    this.projectId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.toString().split('.').last,
      'category': category,
      'deadline': deadline.toIso8601String(),
      'project_id': projectId,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      status: TaskStatus.values.firstWhere((e) => e.toString().split('.').last == map['status']),
      category: map['category'],
      deadline: DateTime.parse(map['deadline']),
      projectId: map['project_id'],
    );
  }
}