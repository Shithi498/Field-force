// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../model/customer_model.dart';
//
// class CustomerRepository {
//   final String baseUrl;
//   final String sessionCookie;
//
//   CustomerRepository({
//     required this.baseUrl,
//     required this.sessionCookie,
//   });
//
//   Future<List<Customer>> fetchAllCustomers() async {
//     final uri = Uri.parse('$baseUrl/api/all/customers');
//     final headers = <String, String>{
//       'Accept': 'application/json',
//       'Content-Type': 'application/json',
//       if (sessionCookie.isNotEmpty) 'Cookie': sessionCookie,
//     };
//
//     try {
//       final res = await http
//           .post(
//         uri,
//         headers: headers,
//         body: jsonEncode({"jsonrpc": "2.0", "params": {}}),
//     //    body: jsonEncode({}),
//       )
//           .timeout(const Duration(seconds: 15));
//
//       print('→ POST $uri');
//       print('🔹 Status: ${res.statusCode}');
//
//       final ct = res.headers['content-type'] ?? '';
//       final body = res.body.trimLeft();
//       final looksHtml =
//           body.startsWith('<!DOCTYPE') || body.startsWith('<html');
//
//       // Non-200, non-JSON, or HTML page ⇒ demo
//       if (res.statusCode != 200 || !ct.contains('application/json') || looksHtml) {
//         _printPreview(res.body);
//         print('⚠️ Non-JSON or error response. Using demo customers.');
//         final demo = _demoCustomersJson();
//         return CustomerResponse.fromJson(demo).customers;
//       }
//
//       // Try decode
//       Map<String, dynamic> decoded;
//       try {
//         decoded = jsonDecode(res.body) as Map<String, dynamic>;
//       } catch (e) {
//         print('⚠️ JSON parse failed: $e');
//         _printPreview(res.body);
//         final demo = _demoCustomersJson();
//         return CustomerResponse.fromJson(demo).customers;
//       }
//
//       final response = CustomerResponse.fromJson(decoded);
//       if (response.customers.isEmpty) {
//         print('ℹ️ API returned 0 customers. Using demo customers.');
//         final demo = _demoCustomersJson();
//         return CustomerResponse.fromJson(demo).customers;
//       }
//
//       return response.customers;
//     } catch (e, st) {
//       print('❌ fetchAllCustomers error: $e');
//       print(st);
//       final demo = _demoCustomersJson();
//       return CustomerResponse.fromJson(demo).customers;
//     }
//   }
//
//
//   void _printPreview(String body) {
//     final len = body.length > 400 ? 400 : body.length;
//     print('🔹 Body preview (${len} chars):\n${body.substring(0, len)}');
//   }
//
//
//   Map<String, dynamic> _demoCustomersJson() {
//     return {
//       "jsonrpc": "2.0",
//       "id": null,
//       "result": {
//         "status": 200,
//         "message": "Demo customers",
//         "count": 6,
//         "customers": [
//           {
//             "id": 101,
//             "name": "Mitchell Admin",
//             "email": "admin@example.com",
//             "phone": false,                      // bool false → model maps to null
//             "mobile": "(555) 010-1234",
//             "company_name": "Kendroo Limited",
//             "is_company": false,
//             "city": false,                       // bool false → model maps to ''
//             "country": "Bangladesh"
//           },
//           {
//             "id": 102,
//             "name": "Christine Spalding",
//             "email": "christine@corp.example",
//             "phone": "(555) 222-9988",
//             "mobile": false,                     // bool false
//             "company_name": "",
//             "is_company": false,
//             "city": "Dhaka",
//             "country": "Bangladesh"
//           },
//           {
//             "id": 103,
//             "name": "Vijesh TK",
//             "email": "",                         // empty string allowed
//             "phone": false,
//             "mobile": "(555) 777-1212",
//             "company_name": "TK Traders",
//             "is_company": true,
//             "city": "Chittagong",
//             "country": "Bangladesh"
//           },
//           {
//             "id": 104,
//             "name": "Aida A.",
//             "email": "aida@example.com",
//             "phone": "(555) 101-0101",
//             "mobile": false,
//             "company_name": "",
//             "is_company": false,
//             "city": false,
//             "country": ""
//           },
//           {
//             "id": 105,
//             "name": "Robertson Johnson",
//             "email": "robertson@client.io",
//             "phone": "(555) 303-3030",
//             "mobile": "(555) 404-4040",
//             "company_name": "RJ Holdings",
//             "is_company": true,
//             "city": "Sylhet",
//             "country": "Bangladesh"
//           },
//           {
//             "id": 106,
//             "name": "Demo Customer",
//             "email": false,                      // bool false → model maps to ''
//             "phone": false,
//             "mobile": false,
//             "company_name": "",
//             "is_company": false,
//             "city": "Khulna",
//             "country": ""
//           }
//         ]
//       }
//     };
//   }
//
//
//
// }


import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/customer_model.dart';

class CustomerRepository {
  final String baseUrl;
  final String sessionCookie;

  CustomerRepository({
    required this.baseUrl,
    required this.sessionCookie,
  });

  Map<String, String> _buildHeaders() {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (sessionCookie.isNotEmpty) 'Cookie': sessionCookie,
    };
  }

  // -------------------- FETCH ALL CUSTOMERS --------------------
  Future<List<Customer>> fetchAllCustomers() async {
    final uri = Uri.parse('$baseUrl/api/all/customers');
    final headers = _buildHeaders();

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
      final looksHtml =
          body.startsWith('<!DOCTYPE') || body.startsWith('<html');
      _printPreview(res.body);
      // Non-200, non-JSON, or HTML page ⇒ demo
      if (res.statusCode != 200 ||
          !ct.contains('application/json') ||
          looksHtml) {
        _printPreview(res.body);
        print('⚠️ Non-JSON or error response. Using demo customers.');
        final demo = _demoCustomersJson();
        return CustomerResponse.fromJson(demo).customers;
      }

      // Try decode
      Map<String, dynamic> decoded;
      try {
        decoded = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (e) {
        print('⚠️ JSON parse failed: $e');
        _printPreview(res.body);
        final demo = _demoCustomersJson();
        return CustomerResponse.fromJson(demo).customers;
      }

      final response = CustomerResponse.fromJson(decoded);
      if (response.customers.isEmpty) {
        print('ℹ️ API returned 0 customers. Using demo customers.');
        final demo = _demoCustomersJson();
        return CustomerResponse.fromJson(demo).customers;
      }

      return response.customers;
    } catch (e, st) {
      print('❌ fetchAllCustomers error: $e');
      print(st);
      final demo = _demoCustomersJson();
      return CustomerResponse.fromJson(demo).customers;
    }
  }

  // -------------------- CREATE CUSTOMER --------------------
  Future<Customer> createCustomer({
    required String name,
    required bool isCompany,
    required String email,
    required String phone,
    String country = 'Bangladesh',
    String? mobile,
    String? companyName,
    String? city,
    String? imageBase64,
    String? street,
    String? street2,
    String? vat,
    String? website,

  }) async {
    final uri = Uri.parse('$baseUrl/api/customer/create');
    final headers = _buildHeaders();

    final Map<String, dynamic> params = {
      "name": name,
      "is_company": isCompany,
      "email": email,
      "phone": phone,
      "country": country,
      if (mobile != null && mobile.isNotEmpty) "mobile": mobile,
      if (companyName != null && companyName.isNotEmpty)
        "company_name": companyName,
      if (city != null && city.isNotEmpty) "city": city,
      if (street != null && street.isNotEmpty) "street": street,
      if (street2 != null && street2.isNotEmpty) "street2": street2,
      if (vat != null && vat.isNotEmpty) "vat": vat,
      if (website != null && website.isNotEmpty) "website": website,
      if (imageBase64 != null && imageBase64.isNotEmpty)
        "image_base64": imageBase64,
    };

    final body = jsonEncode({
      "jsonrpc": "2.0",
      "method": "call",
      "params": params,
    });

    final res = await http
        .post(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 20));

    print('→ POST $uri (createCustomer)');
    print('🔹 Status: ${res.statusCode}');
    _printPreview(res.body);

    if (res.statusCode != 200) {
      throw Exception(
          'Failed to create customer. HTTP ${res.statusCode}: ${res.body}');
    }

    final ct = res.headers['content-type'] ?? '';
    if (!ct.contains('application/json')) {
      throw Exception('Expected JSON response but got "$ct"');
    }

    final Map<String, dynamic> decoded =
    jsonDecode(res.body) as Map<String, dynamic>;

    final response = CustomerResponse.fromJson(decoded);

    if (response.status != 200) {
      throw Exception(
          'API error while creating customer: ${response.message}');
    }

    final created =
        response.partner ??
            (response.customers.isNotEmpty ? response.customers.first : null);

    if (created == null) {
      throw Exception('API did not return created customer data.');
    }

    return created;
  }


  Future<Customer> updateCustomer({
    required int partnerId,
    String? name,
    bool? isCompany,
    String? email,
    String? phone,
    String? mobile,
    String? companyName,
    String? street,
    String? street2,
    String? city,
    String? state,
    String? zip,
    String? country,
    String? vat,
    String? website,
    String? imageBase64,
    List<String>? tags,
  }) async {
    final uri = Uri.parse('$baseUrl/api/customer/update');
    final headers = _buildHeaders();

    final Map<String, dynamic> params = {
      "partner_id": partnerId,
    };

    void addIfNotEmpty(String key, String? value) {
      if (value != null && value.isNotEmpty) {
        params[key] = value;
      }
    }

    if (isCompany != null) params["is_company"] = isCompany;

    addIfNotEmpty("name", name);
    addIfNotEmpty("email", email);
    addIfNotEmpty("phone", phone);
    addIfNotEmpty("mobile", mobile);
    addIfNotEmpty("company_name", companyName);
    addIfNotEmpty("street", street);
    addIfNotEmpty("street2", street2);
    addIfNotEmpty("city", city);
    addIfNotEmpty("state", state);
    addIfNotEmpty("zip", zip);
    addIfNotEmpty("country", country);
    addIfNotEmpty("vat", vat);
    addIfNotEmpty("website", website);
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      params["image_base64"] = imageBase64;
    }
    if (tags != null && tags.isNotEmpty) {
      params["tags"] = tags;
    }

    final body = jsonEncode({
      "jsonrpc": "2.0",
      "method": "call",
      "params": params,
    });

    final res = await http
        .post(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 20));

    print('→ POST $uri (updateCustomer)');
    print('🔹 Status: ${res.statusCode}');
    _printPreview(res.body);

    if (res.statusCode != 200) {
      throw Exception(
          'Failed to update customer. HTTP ${res.statusCode}: ${res.body}');
    }

    final ct = res.headers['content-type'] ?? '';
    if (!ct.contains('application/json')) {
      throw Exception('Expected JSON response but got "$ct"');
    }

    final Map<String, dynamic> decoded =
    jsonDecode(res.body) as Map<String, dynamic>;

    final response = CustomerResponse.fromJson(decoded);

    if (response.status != 200) {
      throw Exception(
          'API error while updating customer: ${response.message}');
    }

    final updated =
        response.partner ??
            (response.customers.isNotEmpty ? response.customers.first : null);

    if (updated == null) {
      throw Exception('API did not return updated customer data.');
    }

    return updated;
  }

  // -------------------- Helpers --------------------
  void _printPreview(String body) {
    final len = body.length > 400 ? 400 : body.length;
    print('🔹 Body preview (${len} chars):\n${body.substring(0, len)}');
  }

  Map<String, dynamic> _demoCustomersJson() {
    return {
      "jsonrpc": "2.0",
      "id": null,
      "result": {
        "status": 200,
        "message": "Demo customers",
        "count": 6,
        "customers": [
          {
            "id": 101,
            "name": "Mitchell Admin",
            "email": "admin@example.com",
            "phone": false,
            "mobile": "(555) 010-1234",
            "company_name": "Kendroo Limited",
            "is_company": false,
            "city": false,
            "country": "Bangladesh"
          },
          {
            "id": 102,
            "name": "Christine Spalding",
            "email": "christine@corp.example",
            "phone": "(555) 222-9988",
            "mobile": false,
            "company_name": "",
            "is_company": false,
            "city": "Dhaka",
            "country": "Bangladesh"
          },
          {
            "id": 103,
            "name": "Vijesh TK",
            "email": "",
            "phone": false,
            "mobile": "(555) 777-1212",
            "company_name": "TK Traders",
            "is_company": true,
            "city": "Chittagong",
            "country": "Bangladesh"
          },
          {
            "id": 104,
            "name": "Aida A.",
            "email": "aida@example.com",
            "phone": "(555) 101-0101",
            "mobile": false,
            "company_name": "",
            "is_company": false,
            "city": false,
            "country": ""
          },
          {
            "id": 105,
            "name": "Robertson Johnson",
            "email": "robertson@client.io",
            "phone": "(555) 303-3030",
            "mobile": "(555) 404-4040",
            "company_name": "RJ Holdings",
            "is_company": true,
            "city": "Sylhet",
            "country": "Bangladesh"
          },
          {
            "id": 106,
            "name": "Demo Customer",
            "email": false,
            "phone": false,
            "mobile": false,
            "company_name": "",
            "is_company": false,
            "city": "Khulna",
            "country": ""
          }
        ]
      }
    };
  }
}

