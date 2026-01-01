import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/task_model.dart';


class TaskRepository {
  final String baseUrl;
  final String sessionCookie;

  TaskRepository({
    required this.baseUrl,
    required this.sessionCookie,
  });


  Future<List<Task>> fetchTasks() async {
    final url = Uri.parse('$baseUrl/api/my/tasks');

    try {
      final res = await http
          .post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (sessionCookie.isNotEmpty) 'Cookie': sessionCookie,
        },
        body: jsonEncode({
          "jsonrpc": "2.0",
          "params": {},
        }),
      )
          .timeout(const Duration(seconds: 5));

      final contentType = res.headers['content-type'] ?? '';
      final body = res.body.trimLeft();
      final looksHtml =
          body.startsWith('<!DOCTYPE') || body.startsWith('<html');

      // Fallback to demo tasks if server returns HTML or non-JSON
      if (res.statusCode != 200 ||
          !contentType.contains('application/json') ||
          looksHtml) {
        debugPrint(
            '[TaskRepository] Using demo tasks because API returned non-JSON or error: ${res.statusCode}');
        return _demoTasks();
      }

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      final result = decoded['result'] ?? decoded; // in case no 'result' wrapper
      final list = (result['tasks'] as List<dynamic>? ?? result['records'] as List<dynamic>? ?? []);

      if (list.isEmpty) {
        debugPrint('[TaskRepository] Empty task list from server, using demo');
        return _demoTasks();
      }

      return list.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e, st) {
      debugPrint('[TaskRepository] Exception fetchTasks: $e\n$st');
      return _demoTasks();
    }
  }


  Future<Task?> createTask({
    required String name,
    String description = '',
    String priority = 'normal',
    String deadline = '',
  }) async {
    final url = Uri.parse('$baseUrl/api/my/task/create');

    try {
      final res = await http
          .post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (sessionCookie.isNotEmpty) 'Cookie': sessionCookie,
        },
        body: jsonEncode({
          "jsonrpc": "2.0",
          "params": {
            "name": name,
            "description": description,
            "priority": priority,
            "deadline": deadline,
          },
        }),
      )
          .timeout(const Duration(seconds: 5));

      if (res.statusCode != 200) {
        debugPrint('[TaskRepository] createTask HTTP ${res.statusCode}');
        return null;
      }

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      final result = decoded['result'] ?? decoded;
      final taskJson =
      (result is Map<String, dynamic> && result['task'] != null)
          ? result['task']
          : result;

      return Task.fromJson(taskJson as Map<String, dynamic>);
    } catch (e, st) {
      debugPrint('[TaskRepository] Exception createTask: $e\n$st');
      return null;
    }
  }

  /// Update status (e.g. mark done)
  Future<bool> updateTaskStatus({
    required int taskId,
    required String status,
  }) async {
    final url = Uri.parse('$baseUrl/api/my/task/update_status');

    try {
      final res = await http
          .post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (sessionCookie.isNotEmpty) 'Cookie': sessionCookie,
        },
        body: jsonEncode({
          "jsonrpc": "2.0",
          "params": {
            "task_id": taskId,
            "status": status,
          },
        }),
      )
          .timeout(const Duration(seconds: 5));

      if (res.statusCode != 200) {
        debugPrint('[TaskRepository] updateTaskStatus HTTP ${res.statusCode}');
        return false;
      }

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      final result = decoded['result'] ?? decoded;
      return (result['success'] ?? true) == true;
    } catch (e, st) {
      debugPrint('[TaskRepository] Exception updateTaskStatus: $e\n$st');
      return false;
    }
  }

  /// Local demo tasks – used when backend fails / during UI dev
  List<Task> _demoTasks() {
    return [
      Task(
        id: 1,
        name: 'Visit customer outlet',
        description: 'Check branding and stock level at outlet #123.',
        status: 'in_progress',
        priority: 'high',
        deadline: '2025-02-01',
        projectName: 'Field Force',
        assignedTo: 'Mitchell Admin',
      ),
      Task(
        id: 2,
        name: 'Submit daily report',
        description: 'Upload visit details & orders before 8 PM.',
        status: 'todo',
        priority: 'normal',
        deadline: '2025-02-01',
        projectName: 'Daily Routine',
        assignedTo: 'Mitchell Admin',
      ),
      Task(
        id: 3,
        name: 'Follow up with distributor',
        description: 'Call Jessore distributor about payment & stock.',
        status: 'done',
        priority: 'low',
        deadline: '2025-01-30',
        projectName: 'Collections',
        assignedTo: 'Mitchell Admin',
      ),
    ];
  }
}
