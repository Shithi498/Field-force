// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../model/attendance_model.dart';
//
// class AttendanceRepository {
//   final String baseUrl;
//   final String sessionCookie;
//
//   AttendanceRepository({
//     required this.baseUrl,
//     required this.sessionCookie,
//   });
//
//   Future<Attendance> fetchTodayAttendance() async {
//     final url = Uri.parse('$baseUrl/api/my/today/attendance');
//
//     try {
//       final res = await http
//           .post(
//         url,
//         headers: {
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//           if (sessionCookie.isNotEmpty) 'Cookie': sessionCookie,
//         },
//         body: jsonEncode({"jsonrpc": "2.0", "params": {}}),
//       )
//           .timeout(const Duration(seconds: 15));
//
//       print('→ POST $url');
//       print('🔹 Response status: ${res.statusCode}');
//
//       final ct = res.headers['content-type'] ?? '';
//       final body = res.body;
//       final looksHtml = body.trimLeft().startsWith('<!DOCTYPE') || body.trimLeft().startsWith('<html');
//
//       // Non-200, non-JSON, or HTML response -> demo
//       if (res.statusCode != 200 || !ct.contains('application/json') || looksHtml) {
//         _printPreview(body);
//         print('⚠️ Non-JSON or error response. Using demo data.');
//         final demo = _demoAttendanceJson();
//         print('🧪 Demo data:\n${jsonEncode(demo)}');
//         return Attendance.fromJson(demo);
//       }
//
//       // Try decode
//       Map<String, dynamic> decoded;
//       try {
//         decoded = jsonDecode(body) as Map<String, dynamic>;
//       } catch (e) {
//         print('⚠️ JSON parse failed: $e');
//         _printPreview(body);
//         final demo = _demoAttendanceJson();
//         print('🧪 Demo data:\n${jsonEncode(demo)}');
//         return Attendance.fromJson(demo);
//       }
//
//       // If attendances empty -> demo
//       final root = (decoded['result'] is Map) ? decoded['result'] as Map<String, dynamic> : decoded;
//       final List atts = (root['attendances'] as List?) ?? const [];
//       if (atts.isEmpty) {
//         print('ℹ️ API returned empty attendances. Using demo data.');
//         final demo = _demoAttendanceJson();
//         print('🧪 Demo data:\n${jsonEncode(demo)}');
//         return Attendance.fromJson(demo);
//       }
//
//       // OK
//       return Attendance.fromJson(decoded);
//     } catch (e, st) {
//       print('❌ fetchTodayAttendance error: $e');
//       print(st);
//       final demo = _demoAttendanceJson();
//       print('🧪 Demo data:\n${jsonEncode(demo)}');
//       return Attendance.fromJson(demo);
//     }
//   }
//
//
//
//   void _printPreview(String body) {
//     final len = body.length > 400 ? 400 : body.length;
//     print('🔹 Body preview (${len} chars):\n${body.substring(0, len)}');
//   }
//
//   Map<String, dynamic> _demoAttendanceJson() {
//     String two(int n) => n.toString().padLeft(2, '0');
//     final now = DateTime.now();
//     String d(int minusDays) {
//       final t = now.subtract(Duration(days: minusDays));
//       return '${t.year}-${two(t.month)}-${two(t.day)}';
//     }
//
//     return {
//       "jsonrpc": "2.0",
//       "id": null,
//       "result": {
//         // Root date kept as "today" for compatibility with your model
//         "date": d(0),
//         "employee_id": 0,
//         "employee_name": "Demo Employee",
//         "attendances": [
//           {
//             "date": d(0),
//             "check_in": "${d(0)} 09:30:00",
//             "check_out": "${d(0)} 17:45:00",
//             "worked_hours": 8.25,
//             "status": "Present"
//           },
//           {
//             "date": d(1),
//             "check_in": "${d(1)} 10:10:00",
//             "check_out": "${d(1)} 18:05:00",
//             "worked_hours": 7.92,
//             "status": "Late"
//           },
//           {
//             "date": d(2),
//             "check_in": "${d(2)} 09:00:00",
//             "check_out": "${d(2)} 17:00:00",
//             "worked_hours": 8.00,
//             "status": "Present"
//           },
//           {
//             "date": d(3),
//             "check_in": "${d(3)} 09:30:00",
//             "check_out": "${d(3)} 13:30:00",
//             "worked_hours": 4.00,
//             "status": "Half Day"
//           },
//           {
//             "date": d(4),
//             "check_in": "",
//             "check_out": "",
//             "worked_hours": 0.0,
//             "status": "Absent"
//           },
//         ]
//       }
//     };
//   }
//
// }
// attendance_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/attendance_model.dart';


class AttendanceRepository {
  final String baseUrl;
  final String sessionCookie;

  AttendanceRepository({
    required this.baseUrl,
    required this.sessionCookie,
  });


  Future<Attendance> fetchTodayAttendance() =>
      fetchAttendanceForDate(DateTime.now());


  Future<Attendance> fetchAttendanceForDate(DateTime date) async {
    final url = Uri.parse('$baseUrl/api/my/today/attendance');
    final dateStr = _fmtDate(date);

    try {
      final res = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (sessionCookie.isNotEmpty) 'Cookie': sessionCookie,
        },
        body: jsonEncode({
          "jsonrpc": "2.0",
          "params": {"date": dateStr},
        }),
      ).timeout(const Duration(seconds: 2));

      final contentType = res.headers['content-type'] ?? '';
      final body = res.body.trimLeft();
      final looksHtml = body.startsWith('<!DOCTYPE') || body.startsWith('<html');

      // If API fails or returns HTML instead of JSON, use demo data
      if (res.statusCode != 200 || !contentType.contains('application/json') || looksHtml) {
        return Attendance.fromJson(_demoAttendanceJsonFor(date));
      }

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;

      // If server returns empty or malformed, fallback to demo
      final result = decoded['result'] as Map<String, dynamic>? ?? {};
      if ((result['employee_name'] ?? '').toString().isEmpty) {
        return Attendance.fromJson(_demoAttendanceJsonFor(date));
      }

      return Attendance.fromJson(decoded);
    } catch (_) {
      // Fallback to demo data on network error
      return Attendance.fromJson(_demoAttendanceJsonFor(date));
    }
  }


  String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';


  Map<String, dynamic> _demoAttendanceJsonFor(DateTime date) {
    final d = _fmtDate(date);
    final w = date.weekday; // 1=Mon ... 7=Sun
    final empId = (1000 + w);
    final empName = [
      'Mitchell Admin', 'Christine Spalding', 'Vijesh TK', 'Aida A.',
      'Robertson Johnson', 'Emily Clark', 'Demo Employee'
    ][(w - 1) % 7];

    return {
      "jsonrpc": "2.0",
      "id": null,
      "result": {
        "date": d,
        "employee_id": empId,
        "employee_name": empName,
        "attendances": [
          if (w == DateTime.sunday)
            {
              "id": 0,
              "check_in": "",
              "check_out": "",
              "worked_hours": 0.0,
              "status": "Absent"
            }
          else
            {
              "id": w,
              "check_in": "$d 09:${(10 + w).toString().padLeft(2, '0')}:00",
              "check_out": "$d 17:${(35 + w).toString().padLeft(2, '0')}:00",
              "worked_hours": 8.0 + (w % 3) * 0.25,
              "status": (w % 3 == 0) ? "Present" : (w % 3 == 1) ? "Late" : "Present"
            }
        ]
      }
    };
  }
}

