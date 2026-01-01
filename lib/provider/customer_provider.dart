// import 'package:flutter/material.dart';
// import '../model/customer_model.dart';
// import '../repo/customer_repository.dart';
//
//
// class CustomerProvider extends ChangeNotifier {
//   final CustomerRepository repository;
//
//   CustomerProvider(this.repository);
//
//   bool isLoading = false;
//   String? error;
//   List<Customer> customers = [];
//
//   Future<void> loadCustomers() async {
//     isLoading = true;
//     error = null;
//     notifyListeners();
//
//     try {
//       customers = await repository.fetchAllCustomers();
//     } catch (e) {
//       error = e.toString();
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
// }


import 'package:flutter/cupertino.dart';

import '../model/customer_model.dart';
import '../repo/customer_repository.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerRepository repository;

  CustomerProvider(this.repository);

  bool isLoading = false;
  String? error;
  List<Customer> customers = [];

  // Creation state
  bool isCreating = false;
  String? createError;
  Customer? lastCreatedCustomer;

  // NEW: update state
  bool isUpdating = false;
  String? updateError;
  Customer? lastUpdatedCustomer;

  Future<void> loadCustomers() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      customers = await repository.fetchAllCustomers();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // CREATE CUSTOMER
  Future<Customer?> createCustomer({
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
    isCreating = true;
    createError = null;
    notifyListeners();

    try {
      final created = await repository.createCustomer(
        name: name,
        isCompany: isCompany,
        email: email,
        phone: phone,
        country: country,
        mobile: mobile,
        companyName: companyName,
        city: city,
        imageBase64: imageBase64,
        street: street,
        street2: street2,
        vat: vat,
        website: website,
      );

      lastCreatedCustomer = created;
      customers.insert(0, created);
      notifyListeners();

      return created;
    } catch (e) {
      createError = e.toString();
      notifyListeners();
      return null;
    } finally {
      isCreating = false;
      notifyListeners();
    }
  }

  // NEW: UPDATE CUSTOMER
  Future<Customer?> updateCustomer({
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
    isUpdating = true;
    updateError = null;
    notifyListeners();

    try {
      final updated = await repository.updateCustomer(
        partnerId: partnerId,
        name: name,
        isCompany: isCompany,
        email: email,
        phone: phone,
        mobile: mobile,
        companyName: companyName,
        street: street,
        street2: street2,
        city: city,
        state: state,
        zip: zip,
        country: country,
        vat: vat,
        website: website,
        imageBase64: imageBase64,
        tags: tags,
      );

      lastUpdatedCustomer = updated;

      // Update in local list if present
      final idx = customers.indexWhere((c) => c.id == updated.id);
      if (idx != -1) {
        customers[idx] = updated;
      }

      notifyListeners();
      return updated;
    } catch (e) {
      updateError = e.toString();
      notifyListeners();
      return null;
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }
}
