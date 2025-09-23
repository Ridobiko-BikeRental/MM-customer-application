import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:yumquick/models/category.dart';

class CategoryApi {
  Future<List<Category>> fetchAllCategoriesWithSubCategories() async {
    final url = Uri.parse('https://mm-food-backend.onrender.com/api/categories/all-with-subcategories');
    final response = await http.get(url);

    print('CategoryApi: Response status: ${response.statusCode}');
    print('CategoryApi: Content-Type: ${response.headers['content-type']}');

    if (response.statusCode != 200) {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }

    // Ensure we have JSON
    final contentType = response.headers['content-type'] ?? '';
    if (!contentType.contains('application/json')) {
      print('CategoryApi: Non-JSON body received: ${response.body.substring(0, 200)}');
      throw Exception('Expected JSON response for categories');
    }

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // ✅ Debug log for every sub-category
  final List categories = data['categories'] ?? [];
  for (final cat in categories) {
    final List subs = cat['subCategories'] ?? [];
    for (final sub in subs) {
      log('SubCategory: ${sub['name']} | Vendor: ${sub['vendor']}');
    }
  }
     
      final List<dynamic> list = (data['categories'] as List<dynamic>?) ?? [];
      print('CategoryApi: Number of categories: ${list.length}');
      return list.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      
      throw Exception('Malformed categories response: $e');
    }
  }
}