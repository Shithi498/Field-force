

class Project {
  final int id;
  final String name;
  final String description;
  final String customerName;   // partner name
  final String managerName;    // project manager
  final String status;         // e.g. 'in_progress', 'done', 'cancelled'
  final String startDate;      // ISO string: '2025-02-01'
  final String endDate;        // ISO string
  final double progress;       // 0.0 – 100.0
  final int taskCount;         // number of related tasks
  final String color;          // hex or label, optional

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.customerName,
    required this.managerName,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.progress,
    required this.taskCount,
    required this.color,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return Project(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      customerName: (json['customer_name'] ?? '').toString(),
      managerName: (json['manager_name'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      startDate: (json['start_date'] ?? '').toString(),
      endDate: (json['end_date'] ?? '').toString(),
      progress: _toDouble(json['progress']),
      taskCount: (json['task_count'] as num?)?.toInt() ?? 0,
      color: (json['color'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'customer_name': customerName,
      'manager_name': managerName,
      'status': status,
      'start_date': startDate,
      'end_date': endDate,
      'progress': progress,
      'task_count': taskCount,
      'color': color,
    };
  }

  Project copyWith({
    int? id,
    String? name,
    String? description,
    String? customerName,
    String? managerName,
    String? status,
    String? startDate,
    String? endDate,
    double? progress,
    int? taskCount,
    String? color,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      customerName: customerName ?? this.customerName,
      managerName: managerName ?? this.managerName,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      progress: progress ?? this.progress,
      taskCount: taskCount ?? this.taskCount,
      color: color ?? this.color,
    );
  }
}
