import 'package:flutter/foundation.dart';
import '../model/project_model.dart';
import '../repo/project_repository.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectRepository repository;

  ProjectProvider({required this.repository});

  List<Project> _projects = [];
  bool _isLoading = false;
  String? _error;

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProjects() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final list = await repository.fetchProjects();
      _projects = list;
    } catch (e, st) {
      debugPrint('[ProjectProvider] loadProjects error: $e\n$st');
      _error = 'Failed to load projects';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadProjects();

  Future<bool> createProject({
    required String name,
    String description = '',
    String customerName = '',
    String managerName = '',
    String status = 'in_progress',
    String startDate = '',
    String endDate = '',
    String color = '',
  }) async {
    try {
      final project = await repository.createProject(
        name: name,
        description: description,
        customerName: customerName,
        managerName: managerName,
        status: status,
        startDate: startDate,
        endDate: endDate,
        color: color,
      );

      if (project != null) {
        _projects = [project, ..._projects];
        notifyListeners();
        return true;
      }
      return false;
    } catch (e, st) {
      debugPrint('[ProjectProvider] createProject error: $e\n$st');
      return false;
    }
  }

  Future<bool> updateProjectStatus(int projectId, String status) async {
    final ok = await repository.updateProjectStatus(
      projectId: projectId,
      status: status,
    );

    if (ok) {
      _projects = _projects
          .map((p) => p.id == projectId ? p.copyWith(status: status) : p)
          .toList();
      notifyListeners();
    }

    return ok;
  }
}
