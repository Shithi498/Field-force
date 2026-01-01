import 'package:flutter/material.dart';
import '../model/leave_model.dart';
import '../repo/leave_repository.dart';

class LeaveProvider extends ChangeNotifier {
  final LeaveRepository repository;

  LeaveProvider(this.repository);

  bool isLoading = false;
  String? error;
  List<Leave> leaves = [];

  Future<void> loadMyLeaves() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      leaves = await repository.fetchMyLeaves();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
