// lib/provider/task_provider.dart
import 'package:flutter/foundation.dart';

import '../model/task_model.dart';
import '../repo/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository repository;

  TaskProvider({required this.repository});

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final list = await repository.fetchTasks();
      _tasks = list;
    } catch (e, st) {
      debugPrint('[TaskProvider] loadTasks error: $e\n$st');
      _error = 'Failed to load tasks';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadTasks();

  Future<bool> createTask({
    required String name,
    String description = '',
    String priority = 'normal',
    String deadline = '',
  }) async {
    try {
      final task = await repository.createTask(
        name: name,
        description: description,
        priority: priority,
        deadline: deadline,
      );

      if (task != null) {
        _tasks = [task, ..._tasks];
        notifyListeners();
        return true;
      }
      return false;
    } catch (e, st) {
      debugPrint('[TaskProvider] createTask error: $e\n$st');
      return false;
    }
  }

  Future<bool> updateTaskStatus(int taskId, String status) async {
    final ok = await repository.updateTaskStatus(
      taskId: taskId,
      status: status,
    );

    if (ok) {
      _tasks = _tasks
          .map((t) => t.id == taskId ? t.copyWith(status: status) : t)
          .toList();
      notifyListeners();
    }

    return ok;
  }
}
