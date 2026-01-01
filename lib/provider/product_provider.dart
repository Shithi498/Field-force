import 'package:flutter/material.dart';
import '../model/product_model.dart';
import '../repo/product_repository.dart';


class ProductProvider extends ChangeNotifier {
  final ProductRepository repository;

  ProductProvider(this.repository);

  bool isLoading = false;
  String? error;
  List<Product> products = [];

  Future<void> loadProducts() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      products = await repository.fetchAllProducts();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
