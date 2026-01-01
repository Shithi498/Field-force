class Product {
  final int id;
  final String name;
  final double listPrice;
  final String type;
  final String uomName;

  Product({
    required this.id,
    required this.name,
    required this.listPrice,
    required this.type,
    required this.uomName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      listPrice: (json['list_price'] ?? 0).toDouble(),
      type: json['type'] ?? '',
      uomName: json['uom_name'] ?? '',
    );
  }
}

class ProductResponse {
  final int status;
  final String message;
  final int count;
  final List<Product> products;

  ProductResponse({
    required this.status,
    required this.message,
    required this.count,
    required this.products,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'] ?? {};
    final productsList = (result['products'] as List<dynamic>? ?? [])
        .map((e) => Product.fromJson(e))
        .toList();

    return ProductResponse(
      status: result['status'] ?? 0,
      message: result['message'] ?? '',
      count: result['count'] ?? 0,
      products: productsList,
    );
  }
}
