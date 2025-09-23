import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateProfileProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _updateSuccess = false;
  bool get updateSuccess => _updateSuccess;

  // Call this when the user presses the "Update Profile" button
  Future<void> updateProfile({
    required String fullName,
    required String email,
    required String mobile,
    required String city,
    required String state,
    required String company,
    required String image, // Must be image URL (not file)
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _updateSuccess = false;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';

    if (token.isEmpty) {
      _errorMessage = "You are not logged in!";
      _isLoading = false;
      notifyListeners();
      return;
    }

    final url = Uri.parse('https://mm-food-backend.onrender.com/api/users/profile');
    final Map<String, dynamic> body = {
      'fullName': fullName,
      'email': email,
      'mobile': mobile,
      'city': city,
      'state': state,
      'company': company,
      'image': image,
    };

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      //print('PUT /users/profile: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        _updateSuccess = true;
        _errorMessage = null;
      } else {
        final data = jsonDecode(response.body);
        _errorMessage = data['message'] ?? 'Profile update failed';
      }
    } catch (e) {
      _errorMessage = 'Profile update failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _updateSuccess = false;
    notifyListeners();
  }
}
