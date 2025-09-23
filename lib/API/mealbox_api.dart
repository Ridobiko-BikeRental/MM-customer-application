import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/MealBox_model.dart';

class MealBoxApi {

static Future<List<MealBox>> fetchMealboxes() async {

final url = Uri.parse("https://mm-food-backend.onrender.com/api/mealbox");
final response = await http.get(url);

  if(response.statusCode == 200){
    final data = jsonDecode(response.body);
    final mealboxList = (data['mealBoxes'] ?? []) as List;
    print("Meal Boxes fetched: $data");
    return mealboxList
        .map((e) => MealBox.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  else{
    throw Exception('Server responded with status: ${response.statusCode}');
  }
}

}