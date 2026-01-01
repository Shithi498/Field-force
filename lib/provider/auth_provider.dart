import 'dart:convert';
import 'package:field_force_2/view/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';
import 'package:field_force_2/view/dashboard.dart';


class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? sessionCookie;
  OdooUser? user;

  Future<void> tryAutoLogin(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    sessionCookie = prefs.getString('sessionCookie');

    if (sessionCookie == null) {
      debugPrint("❗ No session found, login needed");
      _isLoading = false;
      notifyListeners();
      return; // Stay on login page
    }

    debugPrint("✅ Found stored cookie: $sessionCookie");

    final res = await http.post(
      Uri.parse("https://demo.kendroo.com/web/session/get_session_info"),
      headers: {
        "Content-Type": "application/json",
        "Cookie": sessionCookie!,        // ← send same cookie back
      },
      body: jsonEncode({
        "jsonrpc": "2.0",
        "params": {},
      }),
    );

    debugPrint("🔹 AutoLogin Status: ${res.statusCode}");
    debugPrint("🔹 AutoLogin Body: ${res.body}");

    try {
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final result = data['result'];

        if (result != null && result['uid'] != null) {
          user = OdooUser.fromJson(result);
          debugPrint("✅ AutoLogin successful → Dashboard");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        } else {
          debugPrint("⚠ Cookie invalid → Login required");
        }
      } else {
        debugPrint("⚠ Session expired → Login required");
      }
    } catch (e) {
      debugPrint("❌ Error parsing auto login response: $e");
    }

    _isLoading = false;
    notifyListeners();
  }



  Future<void> login(String db, String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
    //  final url = Uri.parse('http://127.0.0.1:8069//web/session/authenticate');
      final url = Uri.parse('https://demo.kendroo.com/web/session/authenticate');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "jsonrpc": "2.0",
          "params": {"db": db, "login": username, "password": password}
        }),
      );



      debugPrint("🔹 Login Status: ${res.statusCode}");
      debugPrint("🔹 Raw Response Body:\n${res.body}");
      debugPrint("🔹 Response Headers:\n${res.headers}");
      if (res.statusCode != 200) {
        throw Exception('Login failed (${res.statusCode})');
      }

      final data = jsonDecode(res.body);
      user = OdooUser.fromJson(data['result'] ?? {});


      final setCookie = res.headers['set-cookie'];
      if (setCookie != null && setCookie.contains('session_id')) {
        sessionCookie = setCookie.split(';').first;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('sessionCookie', sessionCookie!);
        debugPrint("Session cookie: $sessionCookie");

      } else {
        throw Exception('Missing session cookie');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Clear local session
      sessionCookie = null;
      user = null;

      // Clear saved credentials
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const OdooLoginPage()),
            (route) => false,
      );

    } catch (e) {
      debugPrint("Logout error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
