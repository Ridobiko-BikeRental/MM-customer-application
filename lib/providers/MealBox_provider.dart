import 'package:flutter/material.dart';
import 'package:yumquick/API/mealbox_api.dart';
import '../models/MealBox_model.dart';

class MealboxProvider extends ChangeNotifier{
  List<MealBox> _MealBoxes = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MealBox> get Mealboxes => _MealBoxes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMealboxes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try{
      final result = await MealBoxApi.fetchMealboxes();
      _MealBoxes = result;
    }
    catch(e) {
       _errorMessage = 'Failed to load meal boxes: $e';
      _MealBoxes = [];
    }
    finally {
      _isLoading = false;
    notifyListeners();
    }
  }
}