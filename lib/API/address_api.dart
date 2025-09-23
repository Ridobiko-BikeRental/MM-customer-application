import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddressModel {
  final String id;
  final String label;
  final String addressLine;
  final String city;
  final String state;
  final String pincode;

  AddressModel({
    required this.id,
    required this.label,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.pincode,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id'] ?? '', // <-- Add id for Edit/Delete!
      label: json['label'] ?? '',
      addressLine: json['addressLine'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "label": label,
    "addressLine": addressLine,
    "city": city,
    "state": state,
    "pincode": pincode,
    "_id": id, // Include id for update
  };
}

class AddressProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<AddressModel>? _addresses;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AddressModel>? get addresses => _addresses;

  Future<AddressModel?> getAddressById(String id) async {
  if (addresses == null) return null;
  try {
    return addresses!.firstWhere((address) => address.id == id);
  } catch (e) {
    return null;
  }
}


  // Fetch all addresses
  Future<void> fetchAddresses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken') ?? '';

      final response = await http.get(
        Uri.parse('https://mm-food-backend.onrender.com/api/users/address'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final addressList = data['addresses'] as List;
        _addresses = addressList
            .map((json) => AddressModel.fromJson(json))
            .toList();
        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to load addresses!';
        _addresses = null;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _addresses = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new address
  Future<bool> addAddress({
    required String label,
    required String addressLine,
    required String city,
    required String state,
    required String pincode,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken') ?? '';

      final response = await http.post(
        Uri.parse('https://mm-food-backend.onrender.com/api/users/address'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "addressLine": addressLine,
          "city": city,
          "state": state,
          "pincode": pincode,
          "label": label,
        }),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final addressList = data['addresses'] as List;
        _addresses = addressList
            .map((json) => AddressModel.fromJson(json))
            .toList();
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['message'] ?? 'Failed to add address!';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Edit/Update address
  Future<bool> updateAddress(AddressModel address) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken') ?? '';

      // Only send params backend actually accepts:
      final body = {
        "addressLine": address.addressLine,
        "city": address.city,
        "state": address.state,
        "pincode": address.pincode,
        "label": address.label,
      };

      final response = await http.put(
        Uri.parse('https://mm-food-backend.onrender.com/api/users/address'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print("PUT response: ${response.body}");

      if (response.statusCode == 200) {
        // If you want to reload addresses, fetch them here
        await fetchAddresses();
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Update failed!';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
