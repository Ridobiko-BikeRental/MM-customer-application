import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Address.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _token; // Store JWT or session token
  String? get token => _token;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _token != null;

  bool _signupSuccess = false;
  bool get signupSuccess => _signupSuccess;

  // User profile fields
  String? _userFullName;
  String? _userEmail;
  String? _userMobile;
  String? _userCity;
  String? _userState;
  String? _userId;
  List<UserAddress> _deliveryAddresses = [];

  String? get userFullName => _userFullName;
  String? get userEmail => _userEmail;
  String? get userMobile => _userMobile;
  String? get userCity => _userCity;
  String? get userState => _userState;
  String? get userId => _userId;
  List<UserAddress> get deliveryAddresses => _deliveryAddresses;
  
  /// Constructor to load token from shared preferences on provider init
  AuthProvider() {
    _loadTokenFromPrefs();
  }

  // Load token from SharedPreferences
  Future<void> _loadTokenFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('authToken');
     if (_token != null && _token!.isNotEmpty) {
    // Fetch user details immediately after app restarts
    await getUserData();
  }
    notifyListeners();
  }

  // Save token to SharedPreferences
  Future<void> _saveTokenToPrefs(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

  // Remove token from SharedPreferences
  Future<void> _removeTokenFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
  }

  // LOGIN method
  Future<void> login(String email, String password) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  final url = Uri.parse('https://munchmartfoods.com/user/login.php');

  try {
    final request = http.MultipartRequest('POST', url);
    request.fields['email'] = email;
    request.fields['password'] = password;

    print('Sending login request with email: $email');

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // PHP payload shape:
      // {"status":"success","message":"Login successful","token":"<JWT>","user":{...}}
      final token = data['token']?.toString().trim();
      if (token == null || token.isEmpty) {
        _errorMessage = 'Login failed: token missing in response';
        notifyListeners();
        print('❌ Login token missing');
        return;
      }

      _token = token;
      await _saveTokenToPrefs(_token!);

      // Optionally hydrate user fields from the response to avoid a second call
      final user = data['user'];
      if (user is Map) {
        _userFullName = user['name']?.toString()?.trim();
        _userEmail = user['email']?.toString()?.trim();
        _userMobile = user['mobile']?.toString()?.trim();
      }

      notifyListeners();
      print('✅ Login successful for email: $email, token: $_token');

      // Fetch user profile data from server to stay source-of-truth
      await getUserData();
    } else {
      final data = jsonDecode(response.body);
      _errorMessage = data['message']?.toString() ?? 'Login failed';
      notifyListeners();
      print('❌ Login failed for email: $email');
      print('Error message from server: $_errorMessage');
    }
  } catch (e) {
    _errorMessage = 'An error occurred. Please try again.';
    notifyListeners();
    print('❌ Exception during login: $e');
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}


  // SIGNUP method
  Future<void> signup(String email, String password, String fullName, String mobile) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  // Update: PHP backend endpoint
  final url = Uri.parse('https://munchmartfoods.com/user/register.php');

  try {
    // PHP backend needs form data, not JSON
    final request = http.MultipartRequest('POST', url);
    request.fields['name'] = fullName;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['mobile'] = mobile;

    print('📤 Sending signup request with: fullName=$fullName, email=$email, mobile=$mobile');

    // Send request and get response
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      _signupSuccess = true;
      _token = data['token']?.toString()?.trim();
      if (_token != null) {
        await _saveTokenToPrefs(_token!);
      }
      notifyListeners();
      print('✅ Signup successful for email: $email, token: $_token');

      // Fetch user profile data
      await getUserData();
    } else {
      final data = jsonDecode(response.body);
      _errorMessage = data['message'] ?? 'Signup failed';
      notifyListeners();
      print('❌ Signup failed for email: $email');
      print('⚠️ Error: $_errorMessage');
    }
  } catch (e) {
    _errorMessage = 'Could not connect to the server';
    notifyListeners();
    print('❌ Exception during signup: $e');
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}


  
  //GET user data
  Future<void> getUserData() async {
  if (_token == null || _token!.isEmpty) {
    _errorMessage = "No token found.";
    notifyListeners();
    print('❌ getUserData aborted: No token found.');
    return;
  }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';

    if (token.isEmpty) {
      _errorMessage = "No token found.";
      _isLoading = false;
      notifyListeners();
      return;
    }

  _isLoading = true;
  notifyListeners();

  try {
    final response = await http.get(
      Uri.parse('https://mm-food-backend.onrender.com/api/users/profile'),
      headers: {'Authorization': 'Bearer ${_token!.trim()}'},
    );

    print('📥 User Data Response: ${response.statusCode} | ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _userId = data['_id'];
      _userFullName = data['fullName'] ?? '';
      _userEmail = data['email'] ?? '';
      _userMobile = data['mobile'] ?? '';
      _deliveryAddresses = ((data['deliveryAddresses'] ?? []) as List)
    .map((e) => UserAddress.fromJson(e as Map<String, dynamic>))
    .toList();
      _errorMessage = null;
    } else if (response.statusCode == 401) {
      _errorMessage = 'Unauthorized: token invalid or expired.';
    } else {
      _errorMessage = 'Failed to load user data: ${response.statusCode}';
    }
  } catch (e) {
    _errorMessage = 'Error loading user data: $e';
    print('❌ Exception during getUserData: $e');
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

void setUserData({required String fullName, required String email, required String mobile, required String city, required String state}) {
  _userFullName = fullName;
  _userEmail = email;
  _userMobile = mobile;
  _userCity = city;
  _userState = state;
  notifyListeners();
}


  // LOGOUT method
  Future<bool> logout() async {
    
  try {
    final response = await http.post(
      Uri.parse('https://mm-food-backend.onrender.com/api/users/logout'),
      // No headers argument at all!
    );
    print('Logout API response: ${response.statusCode} | ${response.body}');

    // Always clear local auth info after logout request
    _token = null;
    _userFullName = null;
    _userEmail = null;
    _userMobile = null;
    // Remove token from SharedPreferences as well
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    print('Token removed');
    notifyListeners();
   


    return response.statusCode == 200;
  } catch (e) {
    print('❌ Exception during logout: $e');
    _token = null;
    _userFullName = null;
    _userEmail = null;
    _userMobile = null;
    notifyListeners();
    return false;
  }
}


}
