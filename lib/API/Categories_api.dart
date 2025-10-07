import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:yumquick/models/category.dart';

class CategoryApi {
  // Option A: pass token in call; keeps this class stateless
  Future<List<Category>> fetchAllCategoriesWithSubCategories({required String token}) async {
    final url = Uri.parse('https://munchmartfoods.com/vendor/subcategory.php');

    final response = await http.get(
      url,
      headers: {
        //'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    log('RAW BODY: ${response.body}');
    log('STATUS: ${response.statusCode}');
    print('CategoryApi: Response status: ${response.statusCode}');
    print('CategoryApi: Content-Type: ${response.headers['content-type']}');

    if (response.statusCode != 200) {
      // Optional: print a small preview to help debugging
      final preview = response.body.length > 200 ? response.body.substring(0, 200) : response.body;
      print('CategoryApi: Non-200 body preview: $preview');
      throw Exception('Failed to load categories: ${response.statusCode}');
    }

    final contentType = response.headers['content-type'] ?? '';
    if (!contentType.toLowerCase().contains('application/json')) {
      print('CategoryApi: Non-JSON body received: ${response.body.substring(0, response.body.length.clamp(0, 200))}');
      throw Exception('Expected JSON response for categories');
    }

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // The PHP payload structure:
      // {
      //   "status": "success",
      //   "categories": [
      //     { "id": 11, "name": "Pizza", "subcategories": [ {...}, ... ] }
      //   ]
      // }

      final List categories = (data['categories'] as List?) ?? [];

      // Keep your debug loop but adapt keys; PHP uses "subcategories"
      for (final cat in categories) {
        final List subs = (cat is Map) ? (cat['subcategories'] as List? ?? []) : const [];
        for (final sub in subs) {
          // Vendor name key may not exist; show id instead
          final vendorInfo = (sub is Map && sub.containsKey('vendor')) ? sub['vendor'] : sub['vendor_id'];
          log('SubCategory: ${(sub is Map) ? (sub['name'] ?? '') : ''} | Vendor: $vendorInfo');
        }
      }

      // Map to your Category model
      final List<dynamic> list = categories;
      print('CategoryApi: Number of categories: ${list.length}');

      // If your Category.fromJson expects "subCategories" camelCase, normalize here:
      final normalized = list.map<Map<String, dynamic>>((e) {
        final m = Map<String, dynamic>.from(e as Map);
        // Normalize "subcategories" -> "subCategories"
        final subs = (m['subcategories'] as List?) ?? [];
        m['subCategories'] = subs;
        return m;
      }).toList();

      return normalized.map((e) => Category.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Malformed categories response: $e');
    }
  }
}
