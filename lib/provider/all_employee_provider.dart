import 'package:flutter/material.dart';
import '../model/all_employee_model.dart';

import '../repo/all_employee_repository.dart';


class AllEmployeeProvider extends ChangeNotifier {
  final AllEmployeeRepository repository;

  AllEmployeeProvider(this.repository);

  bool isLoading = false;
  String? error;
  List<Employee> employees = [];

  Future<void> loadEmployees() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      employees = await repository.fetchAllEmployees();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
