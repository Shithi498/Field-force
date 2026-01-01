import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/project_model.dart';

class ProjectRepository {
  final String baseUrl;
  final String sessionCookie;

  ProjectRepository({
    required this.baseUrl,
    required this.sessionCookie,
  });

  Future<List<Project>> fetchProjects() async {
    final url = Uri.parse('$baseUrl/api/my/projects');

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

      if (res.statusCode != 200 ||
          !contentType.contains('application/json') ||
          looksHtml) {
        debugPrint(
            '[ProjectRepository] Using demo projects (bad response: ${res.statusCode})');
        return _demoProjects();
      }

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      final result = decoded['result'] ?? decoded;

      final rawList = (result['projects'] as List<dynamic>?) ??
          (result['records'] as List<dynamic>?) ??
          [];

      if (rawList.isEmpty) {
        debugPrint('[ProjectRepository] Empty project list, using demo');
        return _demoProjects();
      }

      return rawList
          .map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      debugPrint('[ProjectRepository] fetchProjects error: $e\n$st');
      return _demoProjects();
    }
  }


  Future<Project?> createProject({
    required String name,
    String description = '',
    String customerName = '',
    String managerName = '',
    String status = 'in_progress',
    String startDate = '',
    String endDate = '',
    String color = '',
  }) async {
    final url = Uri.parse('$baseUrl/api/my/project/create');

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
            "customer_name": customerName,
            "manager_name": managerName,
            "status": status,
            "start_date": startDate,
            "end_date": endDate,
            "color": color,
          },
        }),
      )
          .timeout(const Duration(seconds: 5));

      if (res.statusCode != 200) {
        debugPrint('[ProjectRepository] createProject HTTP ${res.statusCode}');
        return null;
      }

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      final result = decoded['result'] ?? decoded;
      final projectJson =
      (result is Map<String, dynamic> && result['project'] != null)
          ? result['project']
          : result;

      return Project.fromJson(projectJson as Map<String, dynamic>);
    } catch (e, st) {
      debugPrint('[ProjectRepository] createProject error: $e\n$st');
      return null;
    }
  }

  /// Update project status (e.g. to 'done', 'cancelled', etc.)
  Future<bool> updateProjectStatus({
    required int projectId,
    required String status,
  }) async {
    final url = Uri.parse('$baseUrl/api/my/project/update_status');

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
            "project_id": projectId,
            "status": status,
          },
        }),
      )
          .timeout(const Duration(seconds: 5));

      if (res.statusCode != 200) {
        debugPrint(
            '[ProjectRepository] updateProjectStatus HTTP ${res.statusCode}');
        return false;
      }

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      final result = decoded['result'] ?? decoded;

      return (result['success'] ?? true) == true;
    } catch (e, st) {
      debugPrint('[ProjectRepository] updateProjectStatus error: $e\n$st');
      return false;
    }
  }

  /// Local demo projects (for offline / dev / fallback)
  List<Project> _demoProjects() {
    return [
      Project(
        id: 101,
        name: 'Retail Coverage – Dhaka North',
        description:
        'Field force coverage plan for Dhaka North region – Phase 1.',
        customerName: 'YourCompany',
        managerName: 'Mitchell Admin',
        status: 'in_progress',
        startDate: '2025-01-20',
        endDate: '2025-03-31',
        progress: 42.5,
        taskCount: 18,
        color: '#42A5F5',
      ),
      Project(
        id: 102,
        name: 'New Distributor Onboarding – Chattogram',
        description: 'Onboarding and activation of new Chattogram distributor.',
        customerName: 'Chattogram Distributor Ltd.',
        managerName: 'Emily Clark',
        status: 'todo',
        startDate: '2025-02-01',
        endDate: '2025-04-15',
        progress: 0.0,
        taskCount: 9,
        color: '#AB47BC',
      ),
      Project(
        id: 103,
        name: 'Q1 Visibility & Branding Audit',
        description:
        'Audit POSM, branding & visibility in key outlets nationwide.',
        customerName: 'YourCompany',
        managerName: 'Robertson Johnson',
        status: 'done',
        startDate: '2024-12-01',
        endDate: '2025-01-15',
        progress: 100.0,
        taskCount: 24,
        color: '#26A69A',
      ),
    ];
  }
}
