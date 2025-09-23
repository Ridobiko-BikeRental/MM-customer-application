import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class TrackingApi {
  static const String baseUrl =
      'https://mm-food-backend.onrender.com/api/orders/tracking';

  static Future<List<OrderTrackingStatus>> fetchOrderTrackings(
      String token) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    print("response code: ${response.statusCode}");
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final List<dynamic> data = responseData['orders'] ?? [];
       log("Order Status: $data");
      return data
          .map((item) => OrderTrackingStatus.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to fetch tracking. Code: ${response.statusCode}');
    }
  }
}


class OrderTrackingStatus {
  final String status;
  final String deliveryTime;
  final String deliveryDate;

  OrderTrackingStatus({
    required this.status,
    required this.deliveryTime,
    required this.deliveryDate,
  });

  factory OrderTrackingStatus.fromJson(Map<String, dynamic> json) {
    return OrderTrackingStatus(
      status: json['status'] ?? '',
      deliveryTime: json['deliveryTime'] ?? '',
      deliveryDate: json['deliveryDate'] ?? '',
    );
  }
}
