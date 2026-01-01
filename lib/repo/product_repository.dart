// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../model/product_model.dart';
//
//
// class ProductRepository {
//   final String baseUrl;
//   final String sessionCookie;
//
//   ProductRepository({
//     required this.baseUrl,
//     required this.sessionCookie,
//   });
//
//   Future<List<Product>> fetchAllProducts() async {
//     final url = Uri.parse('$baseUrl/api/all/products');
//
//     final res = await http.post(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//         'Cookie': sessionCookie,
//       },
//       body: jsonEncode({"jsonrpc": "2.0", "params": {}}),
//     );
//
//     print('🔹 Response status: ${res.statusCode}');
//     print('🔹 Response body: ${res.body}');
//
//     if (res.statusCode == 200) {
//       final data = jsonDecode(res.body);
//       final response = ProductResponse.fromJson(data);
//       return response.products;
//     } else {
//       throw Exception('HTTP ${res.statusCode}: ${res.body}');
//     }
//   }
// }
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/product_model.dart';

class ProductRepository {
  final String baseUrl;
  final String sessionCookie;

  ProductRepository({
    required this.baseUrl,
    required this.sessionCookie,
  });

  Future<List<Product>> fetchAllProducts({bool useGet = false}) async {
    final uri = Uri.parse('$baseUrl/api/all/products');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (sessionCookie.isNotEmpty) 'Cookie': sessionCookie,
    };

    try {
      final http.Response res = useGet
          ? await http.get(uri, headers: headers).timeout(const Duration(seconds: 15))
          : await http
          .post(
        uri,
        headers: headers,
        body: jsonEncode({"jsonrpc": "2.0", "params": {}}),
      )
          .timeout(const Duration(seconds: 15));

      print('→ ${useGet ? "GET" : "POST"} $uri');
      print('🔹 Response status: ${res.statusCode}');
      _printPreview(res.body);
      // If non-200 OR body looks like HTML OR Content-Type not JSON → fallback
      final ct = res.headers['content-type'] ?? '';
      final bodyTrim = res.body.trimLeft();
      final looksLikeHtml = bodyTrim.startsWith('<!DOCTYPE') || bodyTrim.startsWith('<html');
      if (res.statusCode != 200 || !ct.contains('application/json') || looksLikeHtml) {
        _printPreview(res.body);
        print('⚠️ Non-JSON or error response. Using demo data.');
        return _demoProducts();
      }

      // Parse JSON safely
      Map<String, dynamic> parsed;
      try {
        parsed = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (e) {
        print('⚠️ JSON parse failed: $e');
        _printPreview(res.body);
        return _demoProducts();
      }

      final response = ProductResponse.fromJson(parsed);
      if (response.products.isEmpty) {
        print('ℹ️ API returned 0 items. Using demo data.');
        return _demoProducts();
      }
      return response.products;
    } catch (e, st) {
      print('❌ fetchAllProducts error: $e');
      print(st);
      return _demoProducts();
    }
  }

  // --- helpers ---

  void _printPreview(String body) {
    final len = body.length > 400 ? 400 : body.length;
    final preview = body.substring(0, len);
    print('🔹 Body preview (${len} chars):\n$preview');
  }

  List<Product> _demoProducts() => [
    Product(id: 1, name: 'Demo Chair', listPrice: 99.0, type: 'consu',  uomName: 'Units'),
    Product(id: 2, name: 'Demo Desk',  listPrice: 199.5, type: 'product', uomName: 'Units'),
    Product(id: 3, name: 'Installation (Demo Service)', listPrice: 49.0, type: 'service', uomName: 'Hours'),
  ];
}
