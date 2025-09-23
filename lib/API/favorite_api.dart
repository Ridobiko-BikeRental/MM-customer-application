import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProvider extends ChangeNotifier {
  // Separate sets to avoid ID collisions and handle each type independently
  final Set<String> _subCategoryFavoriteIds = {};
  final Set<String> _mealBoxFavoriteIds = {};

  Set<String> get subCategoryFavoriteIds => _subCategoryFavoriteIds;
  Set<String> get mealBoxFavoriteIds => _mealBoxFavoriteIds;

  // Helper to get auth headers
  
  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null || token.isEmpty) throw Exception('No auth token found');
    return {
      'Authorization': 'Bearer $token',
      //'Content-Type': 'application/json',
    };
  }

  // Combined fetch of both favorites
  Future<void> fetchFavorites() async {
    final headers = await _getAuthHeaders();

    // Fetch subcategory favorites
    final subcategoryUrl = Uri.parse('http://mm-food-backend.onrender.com/api/users/favorite-subcategories');
    final subResp = await http.get(subcategoryUrl, headers: headers);
    Set<String> newSubIds = {};
    if (subResp.statusCode == 200) {
      final data = jsonDecode(subResp.body);
      newSubIds = (data['favoriteSubCategories'] as List).map((e) => e.toString()).toSet();
    } else {
      throw Exception('Failed to fetch subcategory favorites');
    }

    // Fetch mealbox favorites
    final mealboxUrl = Uri.parse('https://yourapi.com/api/mealbox/favorites');
    final mealResp = await http.get(mealboxUrl, headers: headers);
    Set<String> newMealIds = {};
    if (mealResp.statusCode == 200) {
      final data = jsonDecode(mealResp.body);
      newMealIds = (data['mealboxes'] as List).map((e) => e['_id'].toString()).toSet();
    } else {
      throw Exception('Failed to fetch mealbox favorites');
    }

    _subCategoryFavoriteIds
      ..clear()
      ..addAll(newSubIds);

    _mealBoxFavoriteIds
      ..clear()
      ..addAll(newMealIds);

    notifyListeners();
  }

  // Optimistic UI toggle - only changes local state
  void toggleLocalFavorite(String id, {bool isMealBox = false}) {
    if (isMealBox) {
      if (_mealBoxFavoriteIds.contains(id)) {
        _mealBoxFavoriteIds.remove(id);
      } else {
        _mealBoxFavoriteIds.add(id);
      }
    } else {
      if (_subCategoryFavoriteIds.contains(id)) {
        _subCategoryFavoriteIds.remove(id);
      } else {
        _subCategoryFavoriteIds.add(id);
      }
    }
    notifyListeners();
  }

  // Synchronous favorite check
  bool isFavorite(String id, {bool isMealBox = false}) {
    return isMealBox
      ? _mealBoxFavoriteIds.contains(id)
      : _subCategoryFavoriteIds.contains(id);
  }

  // Toggle favorite async with optimistic UI update and rollback on failure
  Future<void> toggleFavorite(String id, {bool isMealBox = false}) async {
    final currentlyFav = isFavorite(id, isMealBox: isMealBox);

    // optimistic update
    toggleLocalFavorite(id, isMealBox: isMealBox);

    try {
      if (currentlyFav) {
        if (isMealBox) {
          await unfavoriteMealBox(id: id);
        } else {
          await unfavoriteSubCategory(id);
        }
      } else {
        if (isMealBox) {
          await favoriteMealBox(id: id);
        } else {
          await favoriteSubCategory(id);
        }
      }
    } catch (e) {
      // rollback on error
      toggleLocalFavorite(id, isMealBox: isMealBox);
      rethrow;
    }
  }

  
  /// POST to favorite a subcategory (add to favorites)
  Future<void> favoriteSubCategory(String id) async {
    final url = Uri.parse('https://mm-food-backend.onrender.com/api/users/favorite-subcategories');
    final headers = await _getAuthHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'subCategoryIds': [id]}),
    );
    print("favorite status: ${response.statusCode}");
  print("favorite body: ${response.body}");
    if (response.statusCode == 200) {
      _subCategoryFavoriteIds.add(id);
      notifyListeners();
    } else {
      throw Exception('Failed to favorite subcategory');
    }
  }

  /// POST to unfavorite a subcategory (remove from favorites)
  Future<void> unfavoriteSubCategory(String id) async {
    final url = Uri.parse('https://mm-food-backend.onrender.com/api/users/unfavorite-subcategory');
    final headers = await _getAuthHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'subcategoryId': id}),
    );
  print("Unfavorite status: ${response.statusCode}");
  print("Unfavorite body: ${response.body}");
    if (response.statusCode == 200) {
      _subCategoryFavoriteIds.remove(id);
      notifyListeners();
    } else {
      throw Exception('Failed to unfavorite subcategory');
    }
  }

  ///  POST to favorite a MealBox (add to favorites)
  Future<void> favoriteMealBox ({
    required String id,
  }) async {
    final url = Uri.parse('https://mm-food-backend.onrender.com/api/mealbox/$id/favorite');
    final headers = await _getAuthHeaders();
    final response = await http.post(
      url,
      headers: headers,
    );
    print("Meal Box favorite status: ${response.statusCode}");
   //print("Meal box favorite body: ${response.body}");
   if(response.statusCode == 200){
    _mealBoxFavoriteIds.add(id);
    notifyListeners();
   }
   else{
    throw Exception('Failed to favorite subcategory');
   }
  }
   
   /// POST to unfavorite a MealBox (remove from favorites)
   Future<void> unfavoriteMealBox ({
    required String id,
   }) async {
    final url = Uri.parse('https://mm-food-backend.onrender.com/api/mealbox/$id/unfavorite');
    final headers = await _getAuthHeaders();
    final response = await http.post(
      url,
      headers: headers,
    );
     print("Meal Box unfavorite status: ${response.statusCode}");
     if (response.statusCode == 200) {
      _mealBoxFavoriteIds.remove(id);
      notifyListeners();
    } else {
      throw Exception('Failed to unfavorite subcategory');
    }
   }

   Future<void> clearFavorites() async {
  _subCategoryFavoriteIds.clear();
  _mealBoxFavoriteIds.clear();
  notifyListeners();
}




  
}


