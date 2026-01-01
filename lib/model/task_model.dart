class Task {
  final int id;
  final String name;
  final String description;
  final String status;        // e.g. 'todo', 'in_progress', 'done'
  final String priority;      // e.g. 'low', 'normal', 'high'
  final String deadline;      // ISO date string: '2025-02-01'
  final String projectName;   // optional
  final String assignedTo;    // optional

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.priority,
    required this.deadline,
    required this.projectName,
    required this.assignedTo,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      priority: (json['priority'] ?? '').toString(),
      deadline: (json['deadline'] ?? '').toString(),
      projectName: (json['project_name'] ?? '').toString(),
      assignedTo: (json['assigned_to'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'priority': priority,
      'deadline': deadline,
      'project_name': projectName,
      'assigned_to': assignedTo,
    };
  }

  Task copyWith({
    int? id,
    String? name,
    String? description,
    String? status,
    String? priority,
    String? deadline,
    String? projectName,
    String? assignedTo,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      projectName: projectName ?? this.projectName,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }
}
