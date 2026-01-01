// class Attendance {
//   final String date;
//   final int employeeId;
//   final String employeeName;
//
//
//   Attendance({
//     required this.date,
//     required this.employeeId,
//     required this.employeeName,
//
//   });
//
//   factory Attendance.fromJson(Map<String, dynamic> json) {
//     final result = json['result'] ?? {};
//
//
//     return Attendance(
//       date: result['date'] ?? '',
//       employeeId: result['employee_id'] ?? 0,
//       employeeName: result['employee_name'] ?? '',
//
//     );
//   }
// }
//
//
class Attendance {
  final String date;
  final int employeeId;
  final String employeeName;
  final List<AttendanceEntry> attendances;

  Attendance({
    required this.date,
    required this.employeeId,
    required this.employeeName,
    required this.attendances,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    final result = json['result'] ?? {};

    // Parse attendances list
    final attendanceList = (result['attendances'] as List<dynamic>?)
        ?.map((e) => AttendanceEntry.fromJson(e))
        .toList() ??
        [];

    return Attendance(
      date: result['date'] ?? '',
      employeeId: result['employee_id'] ?? 0,
      employeeName: result['employee_name'] ?? '',
      attendances: attendanceList,
    );
  }
}

class AttendanceEntry {
  final int id;
  final String checkIn;
  final String checkOut;
  final double workedHours;

  AttendanceEntry({
    required this.id,
    required this.checkIn,
    required this.checkOut,
    required this.workedHours,
  });

  factory AttendanceEntry.fromJson(Map<String, dynamic> json) {
    return AttendanceEntry(
      id: json['id'] ?? 0,
      checkIn: json['check_in'] ?? '',
      checkOut: json['check_out'] ?? '',
      workedHours: (json['worked_hours'] ?? 0).toDouble(),
    );
  }
}
