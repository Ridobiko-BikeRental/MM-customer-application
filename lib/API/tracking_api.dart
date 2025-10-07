import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class TrackingApi {
  static const String baseUrl =
      'https://mm-food-backend.onrender.com/api/orders/tracking';

  static Future<List<OrderTrackingStatus>> fetchOrderTrackingById(String token, String orderId) async {
  final url = Uri.parse('$baseUrl/$orderId');
  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );
  print("response code: ${response.statusCode}");
  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    log("Order Tracking Data: $responseData");

    // Extract order object from response
    if (responseData['success'] == true && responseData['order'] != null) {
      return [OrderTrackingStatus.fromJson(responseData['order'])];
    } else {
      return [];
    }
  } else {
    throw Exception('Failed to fetch tracking. Code: ${response.statusCode}');
  }
}

  // For mealbox orders:
  static Future<List<OrderTrackingStatus>> fetchMealBoxTrackingById(
      String token, String mealBoxOrderId) async {
    final url = Uri.parse('https://mm-food-backend.onrender.com/api/mealbox/tracking/$mealBoxOrderId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    print("MealBox tracking response code: ${response.statusCode}");
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      // API response: { "success": true, "order": {...} }
      return [OrderTrackingStatus.fromMealBoxJson(responseData['order'])];
    } else {
      throw Exception('Failed to fetch mealbox tracking. Code: ${response.statusCode}');
    }
  }
}


class OrderTrackingStatus {
  final String status;
  final String? deliveryTime;
  final String? deliveryDate;
  final String? orderId;

  OrderTrackingStatus({
    required this.status,
    this.deliveryTime,
    this.deliveryDate,
    this.orderId
  });

  factory OrderTrackingStatus.fromJson(Map<String, dynamic> json) {
    return OrderTrackingStatus(
      status: json['status'] ?? '',
      deliveryTime: json['deliveryTime'],
      deliveryDate: json['deliveryDate'],
      orderId: json['orderId'],  
    );
  }
  // For normal orders tracking (/api/orders/tracking/:id)
  factory OrderTrackingStatus.fromOrderJson(Map<String, dynamic> json) {
    return OrderTrackingStatus(
      status: json['status'] ?? '',
      deliveryTime: json['deliveryTime'],
      deliveryDate: json['deliveryDate'],
      orderId: json['orderId'],
    );
  }

  // For meal box tracking (/api/mealbox/tracking/:id)
  factory OrderTrackingStatus.fromMealBoxJson(Map<String, dynamic> json) {
    return OrderTrackingStatus(
      status: json['status'] ?? '',
      deliveryTime: json['deliveryTime'],
      deliveryDate: json['deliveryDate'],
      orderId: json['orderId'],
    );
  }
}
