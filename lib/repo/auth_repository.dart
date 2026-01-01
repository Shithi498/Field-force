import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/user_model.dart';


class AuthRepository {
  static const String _baseUrl = 'https://demo.kendroo.com';

  Future<OdooUser> login({
    required String db,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/web/session/authenticate');

    final body = {
      "jsonrpc": "2.0",
      "method": "call",
      "params": {"db": db, "login": email, "password": password}
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['result']?['uid'] != null) {
        return OdooUser.fromJson(data);
      } else {
        throw Exception('Invalid credentials');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}
