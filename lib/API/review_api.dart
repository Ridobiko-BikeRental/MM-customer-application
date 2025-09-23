import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReviewApi {
  static Future<bool> postReview({
    required String subCategoryId,
    required int rating,
    required String comment,
  }) async {
   final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';

    print('Sending review for subCategoryId: $subCategoryId with token: $token');

    final url = 'https://mm-food-backend.onrender.com/api/categories/add-review/$subCategoryId';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'rating': rating,
        'comment': comment,
      }),
    );

    print('Login success, token saved: $token');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to submit review: ${response.statusCode} ${response.body}');
    }
  }
}
