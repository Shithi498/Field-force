import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/leave_model.dart';

class LeaveRepository {
  final String baseUrl;
  final String sessionCookie;

  LeaveRepository({
    required this.baseUrl,
    required this.sessionCookie,
  });

  Future<List<Leave>> fetchMyLeaves() async {
    final url = Uri.parse('$baseUrl/api/my/leave');

    try {
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Cookie': sessionCookie,
        },
        body: jsonEncode({"jsonrpc": "2.0", "params": {}}),
      );

      print('🔹 Leave API status: ${res.statusCode}');
      print('🔹 Leave API body: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final response = LeaveResponse.fromJson(data);
        if (response.leaves.isNotEmpty) {
          return response.leaves;
        }
      }

      // fallback
      return _demoLeaves();
    } catch (e) {
      print('⚠️ Error fetching leaves: $e');
      return _demoLeaves();
    }
  }

  // Modified to include new fields in the Leave constructor
  List<Leave> _demoLeaves() {
    return [
      Leave(
        id: 1,
        holidayStatus: 'Annual Leave',
        requestDateFrom: '2025-11-05',
        requestDateTo: '2025-11-07',
        numberOfDays: 3,
        state: 'validate', // Added new field
        employeeId: 101, // Added new field
        employeeName: 'Demo User', // Added new field
        company: 'Demo Corp Ltd', // Added new field
      ),
      Leave(
        id: 2,
        holidayStatus: 'Sick Leave',
        requestDateFrom: '2025-10-20',
        requestDateTo: '2025-10-22',
        numberOfDays: 3,
        state: 'confirm', // Added new field
        employeeId: 101, // Added new field
        employeeName: 'Demo User', // Added new field
        company: 'Demo Corp Ltd', // Added new field
      ),
      Leave(
        id: 3,
        holidayStatus: 'Casual Leave',
        requestDateFrom: '2025-09-10',
        requestDateTo: '2025-09-11',
        numberOfDays: 2,
        state: 'draft', // Added new field
        employeeId: 101, // Added new field
        employeeName: 'Demo User', // Added new field
        company: 'Demo Corp Ltd', // Added new field
      ),
    ];
  }
}