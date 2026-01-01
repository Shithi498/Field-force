class AllEmployeeResponse {
  final List<Employee> employees;

  AllEmployeeResponse({required this.employees});

  factory AllEmployeeResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'] ?? {};
    final list = (result['employees'] as List? ?? [])
        .map((e) => Employee.fromJson(e))
        .toList();
    return AllEmployeeResponse(employees: list);
  }
}

class Employee {
  final int id;
  final String name;
  final String jobTitle;
  final String workEmail;
  final String workPhone;
  final String department;
  final String manager;
  final String company;
  final String imageUrl;

  Employee({
    required this.id,
    required this.name,
    required this.jobTitle,
    required this.workEmail,
    required this.workPhone,
    required this.department,
    required this.manager,
    required this.company,
    required this.imageUrl,
  });

  // helper
  static String _toString(dynamic value) {
    if (value == null || value == false) return '';
    return value.toString();
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: _toString(json['name']),
      jobTitle: _toString(json['job_title']),
      workEmail: _toString(json['work_email']),
      workPhone: _toString(json['work_phone']),
      department: _toString(json['department']),
      manager: _toString(json['manager']),
      company: _toString(json['company']),
      // adapt this key name to your API: image_url vs image_1920
      imageUrl: _toString(json['image_url']),
    );
  }
}

