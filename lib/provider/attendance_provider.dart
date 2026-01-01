import 'package:flutter/material.dart';
import '../model/attendance_model.dart';
import '../repo/attendance_repository.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceRepository repository;
  AttendanceProvider(this.repository);

  bool _isLoading = false;
  String? _error;
  Attendance? _attendance;
  DateTime _selectedDate = _today();

  // Getters for the UI
  bool get isLoading => _isLoading;
  String? get error => _error;
  Attendance? get attendance => _attendance;
  DateTime get selectedDate => _selectedDate;

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day); // normalized
  }


  Future<void> loadTodayAttendance() => loadForDate(_today());


  Future<void> loadForDate(DateTime date) async {
    _selectedDate = DateTime(date.year, date.month, date.day);
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {

      _attendance = await repository.fetchAttendanceForDate(_selectedDate);
    } catch (e) {
      _error = e.toString();
      _attendance = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> refresh() => loadForDate(_selectedDate);
}
