import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/all_employee_model.dart';
import '../model/employee_model.dart' hide Employee; // adjust the path if different

class AllEmployeeRepository {
  final String baseUrl;
  final String sessionCookie;

  AllEmployeeRepository({
    required this.baseUrl,
    required this.sessionCookie,
  });

  Future<List<Employee>> fetchAllEmployees() async {
    final uri = Uri.parse('$baseUrl/api/all/employees');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (sessionCookie.isNotEmpty) 'Cookie': sessionCookie,
    };

    try {
      final res = await http
          .post(
        uri,
        headers: headers,
        body: jsonEncode({"jsonrpc": "2.0", "params": {}}),
      )
          .timeout(const Duration(seconds: 15));

      print('→ POST $uri');
      print('🔹 Status: ${res.statusCode}');

      final ct = res.headers['content-type'] ?? '';
      final body = res.body.trimLeft();
      final looksHtml = body.startsWith('<!DOCTYPE') || body.startsWith('<html');

      // Non-200, non-JSON, or HTML page ⇒ demo
      if (res.statusCode != 200 || !ct.contains('application/json') || looksHtml) {
        _printPreview(res.body);
        print('⚠️ Non-JSON or error response. Using demo employees.');
        return AllEmployeeResponse.fromJson(_demoEmployeesJson()).employees;
      }

      // Decode
      Map<String, dynamic> decoded;
      try {
        decoded = jsonDecode(res.body) as Map<String, dynamic>;
        _printPreview(res.body);
      } catch (e) {
        print('⚠️ JSON parse failed: $e');
        _printPreview(res.body);
        return AllEmployeeResponse.fromJson(_demoEmployeesJson()).employees;
      }

      final response = AllEmployeeResponse.fromJson(decoded);
      if (response.employees.isEmpty) {
        print('ℹ️ API returned 0 employees. Using demo employees.');
        return AllEmployeeResponse.fromJson(_demoEmployeesJson()).employees;
      }

      return response.employees;
    } catch (e, st) {
      print('❌ fetchAllEmployees error: $e');
      print(st);
      return AllEmployeeResponse.fromJson(_demoEmployeesJson()).employees;
    }
  }

  // ----- helpers -----

  void _printPreview(String body) {
    final len = body.length > 400 ? 400 : body.length;
    print('🔹 Body preview (${len} chars):\n${body.substring(0, len)}');
  }

  /// Demo payload that matches your JSON-RPC envelope + model.
  /// (All string fields are strings — no `false` booleans — so it fits your current model.)
  Map<String, dynamic> _demoEmployeesJson() {
    return {
      "jsonrpc": "2.0",
      "id": null,
      "result": {
        "status": 200,
        "message": "Demo employees",
        "count": 6,
        "employees": [
          {
            "id": 1,
            "name": "Mitchell Admin",
            "job_title": "CTO",
            "work_email": "mitchell.admin@example.com",
            "work_phone": "+880 1300-000001",
            "department": "Technology",
            "manager": "—",
            "company": "Kendroo Limited",
            "image_url": ""
          },
          {
            "id": 2,
            "name": "Christine Spalding",
            "job_title": "Project Manager",
            "work_email": "christine@kendroo.io",
            "work_phone": "+880 1300-000002",
            "department": "PMO",
            "manager": "Mitchell Admin",
            "company": "Kendroo Limited",
            "image_url": ""
          },
          {
            "id": 3,
            "name": "Vijesh TK",
            "job_title": "Senior Developer",
            "work_email": "vijesh@kendroo.io",
            "work_phone": "+880 1300-000003",
            "department": "Engineering",
            "manager": "Christine Spalding",
            "company": "Kendroo Limited",
            "image_url": ""
          },
          {
            "id": 4,
            "name": "Aida A.",
            "job_title": "UI/UX Designer",
            "work_email": "aida@kendroo.io",
            "work_phone": "+880 1300-000004",
            "department": "Design",
            "manager": "Christine Spalding",
            "company": "Kendroo Limited",
            "image_url": ""
          },
          {
            "id": 5,
            "name": "Robertson Johnson",
            "job_title": "QA Engineer",
            "work_email": "robertson@kendroo.io",
            "work_phone": "+880 1300-000005",
            "department": "Quality Assurance",
            "manager": "Vijesh TK",
            "company": "Kendroo Limited",
            "image_url": ""
          },
          {
            "id": 6,
            "name": "Demo Employee",
            "job_title": "Support Specialist",
            "work_email": "support@kendroo.io",
            "work_phone": "+880 1300-000006",
            "department": "Support",
            "manager": "Robertson Johnson",
            "company": "Kendroo Limited",
            "image_url": ""
          }
        ]
      }
    };
  }
}
