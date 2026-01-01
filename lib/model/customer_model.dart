// class Customer {
//   final int id;
//   final String name;
//   final String email;
//   final String? phone;
//   final String? mobile;
//   final String companyName;
//   final bool isCompany;
//   final String city;
//   final String country;
//
//   Customer({
//     required this.id,
//     required this.name,
//     required this.email,
//     this.phone,
//     this.mobile,
//     required this.companyName,
//     required this.isCompany,
//     required this.city,
//     required this.country,
//   });
//
//   factory Customer.fromJson(Map<String, dynamic> json) {
//     return Customer(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       email: json['email'] is bool ? '' : (json['email'] ?? ''),
//       phone: json['phone'] is bool ? null : json['phone'],
//       mobile: json['mobile'] is bool ? null : json['mobile'],
//       companyName: json['company_name'] ?? '',
//       isCompany: json['is_company'] ?? false,
//       city: json['city'] is bool ? '' : (json['city'] ?? ''),
//       country: json['country'] ?? '',
//     );
//   }
// }
//
// class CustomerResponse {
//   final int status;
//   final String message;
//   final int count;
//   final List<Customer> customers;
//
//   CustomerResponse({
//     required this.status,
//     required this.message,
//     required this.count,
//     required this.customers,
//   });
//
//   factory CustomerResponse.fromJson(Map<String, dynamic> json) {
//     final result = json['result'] ?? {};
//     final customersList = (result['customers'] as List<dynamic>? ?? [])
//         .map((e) => Customer.fromJson(e))
//         .toList();
//
//     return CustomerResponse(
//       status: result['status'] ?? 0,
//       message: result['message'] ?? '',
//       count: result['count'] ?? 0,
//       customers: customersList,
//     );
//   }
// }


class Customer {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? mobile;
  final String companyName;
  final bool isCompany;
  final String city;
  final String country;
  final String image_base64;

  // NEW optional details
  final String? street;
  final String? street2;
  final String? state;
  final String? zip;
  final String? vat;
  final String? website;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.mobile,
    required this.companyName,
    required this.isCompany,
    required this.city,
    required this.country,
    this.street,
    this.street2,
    this.state,
    this.zip,
    this.vat,
    this.website, required this.image_base64,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    String _stringOrEmpty(dynamic v) =>
        v is bool ? '' : (v as String? ?? '');

    return Customer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: _stringOrEmpty(json['email']),
      phone: json['phone'] is bool ? null : json['phone'],
      mobile: json['mobile'] is bool ? null : json['mobile'],
      companyName: json['company_name'] ?? '',
      isCompany: json['is_company'] ?? false,
      city: _stringOrEmpty(json['city']),
      country: json['country'] ?? '',
      image_base64: _stringOrEmpty(
        json['image_1920'] ,
      ),

      street: _stringOrEmpty(json['street']),
      street2: _stringOrEmpty(json['street2']),
      state: _stringOrEmpty(json['state']),
      zip: _stringOrEmpty(json['zip']),
      vat: _stringOrEmpty(json['vat']),
      website: _stringOrEmpty(json['website']),
    //  image_base64: json['image_1920'] ?? '',
     // image_base64: "",
    );
  }
}

class CustomerResponse {
  final int status;
  final String message;

  /// For list endpoint (`/api/all/customers`)
  final int count;
  final List<Customer> customers;

  /// For create / update endpoints (`/api/customer/create`, `/api/customer/update`)
  final Customer? partner;

  CustomerResponse({
    required this.status,
    required this.message,
    required this.count,
    required this.customers,
    this.partner,
  });

  factory CustomerResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'] ?? {};

    // List of customers (for /api/all/customers`)
    final customersList = (result['customers'] as List<dynamic>? ?? [])
        .map((e) => Customer.fromJson(e))
        .toList();

    // Single partner (for create/update endpoints)
    Customer? partner;
    if (result['partner'] != null) {
      partner = Customer.fromJson(result['partner'] as Map<String, dynamic>);
    }

    final int count =
    result['count'] is int ? result['count'] as int : customersList.length;

    return CustomerResponse(
      status: result['status'] ?? 0,
      message: result['message'] ?? '',
      count: count,
      customers: customersList,
      partner: partner,
    );
  }
}
