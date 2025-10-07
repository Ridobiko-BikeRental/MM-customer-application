import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/MealBox_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MealBoxApi {

static Future<List<MealBox>> fetchMealboxes() async {
    // Updated PHP backend endpoint
    final url = Uri.parse("https://munchmartfoods.com/vendor/meal.php");

    // Optionally use auth if required by backend:
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token', // omit if auth not required
      },
    );

    print('MealBoxApi: Response status: ${response.statusCode}');
    print('MealBoxApi: Content-Type: ${response.headers['content-type']}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final mealboxList = (data['meals'] ?? []) as List;
      print("Meal Boxes fetched: $data");
      return mealboxList
          .map((e) => MealBox.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Server responded with status: ${response.statusCode}');
    }
  }


//Meal Box order
static Future<Map<String, dynamic>> placeMealBoxOrder({
  required String mealBoxId,
  required int quantity,
  required String vendorId,
  //required List<String> deliveryDays, // add this param based on API
}) async {
  final url = Uri.parse("https://munchmartfoods.com/vendor/mealbox.order.php");
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('authToken') ?? '';

  // PHP expects JSON body with vendor_id and array of items
  final body = jsonEncode({
    "vendor_id": int.parse(vendorId),
    "items": [
      {
        "mealbox": int.parse(mealBoxId),
        "quantity": quantity,
        //"deliveryDays": deliveryDays,
      }
    ]
  });

  print('MealBox Order Payload: $body');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: body,
  );

  print("MealBox API response: ${response.statusCode}, ${response.body}");

  if (response.statusCode == 200 || response.statusCode == 201) {
    final data = jsonDecode(response.body);

    // PHP returns order_id and other details at top-level
    final orderId = data['order_id'];
    return {
      ...data,
      'orderId': orderId,
    };
  } else {
    throw Exception('Failed to place mealbox order: ${response.body}');
  }
}
}