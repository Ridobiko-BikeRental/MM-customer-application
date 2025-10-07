import 'dart:developer';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OrdersApi {
  static const String _baseUrl = 'https://mm-food-backend.onrender.com/api/orders';

  // Fetch all orders for an authenticated user
  static Future<List<dynamic>?> fetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';

    final response = await http.get(
      Uri.parse('$_baseUrl/all-orders'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['orders'] as List<dynamic>;
    } else {
      throw Exception('Failed to fetch orders: ${response.statusCode}');
    }
  }

  // Place order
  static Future<Map<String, dynamic>> placeOrder({
    //required String? customerName,
    //required String? customerEmail,
    required List<Map<String, dynamic>> items,
    required String? vendorId,
  }) async {
    final url = Uri.parse('https://mm-food-backend.onrender.com/api/orders/create');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';
    final body = jsonEncode({
      //"customerName": customerName,
      //"customerEmail": customerEmail,
      "items": items,
      "vendorId": vendorId,
    });
    print('Place Order Payload: $body');

    final response = await http.post(
      url,
      headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
       print('Place Order response: $data');

    // Safely extract the order _id, handling any missing field scenario
    final order = data['order'];
    final orderId = order != null && order['_id'] != null ? order['_id'] : null;
    final customerOrderId = order != null && order['orderId'] != null ? order['orderId'] : null;
    log('Extracted orderId: $orderId, customerOrderId: $customerOrderId');

    // Return the full response with orderId added
    return {
      ...data,
      'orderId': orderId, 
      'customerOrderId':  customerOrderId,  // You can now use this easily in your UI/logic
    };
      
    } else {
      throw Exception('Failed to place order: ${response.body}');
    }
  }

// Cancel order
static Future<Map<String, dynamic>> cancelOrder({
  required String orderId,
  required String reason,
}) async {
  final url = Uri.parse('https://mm-food-backend.onrender.com/api/orders/cancel/$orderId');
  final body = jsonEncode({
    "reason": reason,
  });

  final response = await http.put(
    url,
    headers: {
      'Content-Type': 'application/json',
      // 'Authorization': 'Bearer your_token_here', // Uncomment if needed
    },
    body: body,
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to cancel order: ${response.body}');
  }
}

  

}


