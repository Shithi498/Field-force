// class Leave {
//   final int id;
//   final String holidayStatus;
//   final String requestDateFrom;
//   final String requestDateTo;
//   final double numberOfDays;
//
//   Leave({
//     required this.id,
//     required this.holidayStatus,
//     required this.requestDateFrom,
//     required this.requestDateTo,
//     required this.numberOfDays,
//   });
//
//   factory Leave.fromJson(Map<String, dynamic> json) {
//     return Leave(
//       id: json['id'] ?? 0,
//       holidayStatus: json['holiday_status'] ?? '',
//       requestDateFrom: json['request_date_from'] ?? '',
//       requestDateTo: json['request_date_to'] ?? '',
//       numberOfDays: (json['number_of_days'] ?? 0).toDouble(),
//     );
//   }
// }
//
// class LeaveResponse {
//   final List<Leave> leaves;
//
//   LeaveResponse({required this.leaves});
//
//   factory LeaveResponse.fromJson(Map<String, dynamic> json) {
//     final result = json['result'] ?? {};
//     final list = (result['leave'] as List<dynamic>? ?? [])
//         .map((e) => Leave.fromJson(e))
//         .toList();
//     return LeaveResponse(leaves: list);
//   }
// }
class Leave {
  final int id;
  final String holidayStatus;
  final String requestDateFrom;
  final String requestDateTo;
  final double numberOfDays;
  final String state; // Added
  final int employeeId; // Added
  final String employeeName; // Added
  final String company; // Added

  Leave({
    required this.id,
    required this.holidayStatus,
    required this.requestDateFrom,
    required this.requestDateTo,
    required this.numberOfDays,
    required this.state,
    required this.employeeId,
    required this.employeeName,
    required this.company,
  });

  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      id: json['id'] ?? 0,
      holidayStatus: json['holiday_status'] ?? '',
      requestDateFrom: json['request_date_from'] ?? '',
      requestDateTo: json['request_date_to'] ?? '',
      numberOfDays: (json['number_of_days'] as num? ?? 0).toDouble(), // Use num to handle both int/double gracefully
      state: json['state'] ?? '', // Parsing added field
      employeeId: json['employee_id'] ?? 0, // Parsing added field
      employeeName: json['employee_name'] ?? '', // Parsing added field
      company: json['company'] ?? '', // Parsing added field
    );
  }
}

class LeaveResponse {
  final List<Leave> leaves;

  LeaveResponse({required this.leaves});

  factory LeaveResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'] ?? {};
    final list = (result['leave'] as List<dynamic>? ?? [])
        .map((e) => Leave.fromJson(e))
        .toList();
    return LeaveResponse(leaves: list);
  }
}