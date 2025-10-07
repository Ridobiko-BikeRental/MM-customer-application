import 'dart:developer';

import 'package:flutter/material.dart';
import '../API/Categories_api.dart';
import 'package:yumquick/models/category.dart';
import 'package:yumquick/models/subcategory.dart';
import '../models/Review.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryApi _api = CategoryApi();

  List<Category> _categories = [];
  List<SubCategory> _allSubCategories = [];
  String _selectedCategory = 'All';

  bool _isLoading = false;
  String? _errorMessage;

  String? _token;
  List<SubCategory> _filteredSubCategories = [];

  // Required: set this after user login
  set authToken(String t) {
    _token = t;
    notifyListeners();
  }

  List<Category> get categories => _categories;
  List<SubCategory> get allSubCategories => _allSubCategories;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Category> get chipCategories {
    final seen = <String>{};
    return _categories.where((cat) {
      final trimmed = cat.name.trim();
      final isNew = !seen.contains(trimmed);
      if (isNew) seen.add(trimmed);
      return isNew;
    }).toList();
  }

  List<SubCategory> get allSubCategoriesFlat =>
      _categories.expand((cat) => cat.subCategories).toList();

  List<SubCategory> get subCategoriesForSelected {
    if (_filteredSubCategories.isNotEmpty) {
      return _filteredSubCategories;
    }
    if (_selectedCategory == 'All') {
      return allSubCategoriesFlat;
    } else {
      final selectedIds = _categories
          .where((c) => c.name.trim() == _selectedCategory)
          .map((c) => c.id)
          .toSet();
      return allSubCategoriesFlat
          .where((s) => selectedIds.contains(s.categoryId))
          .toList();
    }
  }

  Future<void> loadCategoriesWithSubcategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_token == null || _token!.isEmpty) {
        throw Exception('No token found. Cannot fetch categories.');
      }
      _categories = await _api.fetchAllCategoriesWithSubCategories(token: _token!);
log('Fetched ${_categories.length} categories');
_categories.forEach((cat) {
  log('Category: ${cat.name} has ${cat.subCategories.length} subcategories');
});

      _allSubCategories = allSubCategoriesFlat;
      log('All subcategories count: ${_allSubCategories.length}');
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String categoryName) {
    _selectedCategory = categoryName.trim();
    notifyListeners();
  }

  void applyFilters({String? category, double? rating, double? price}) {
    List<SubCategory> baseList = allSubCategoriesFlat;
    if (category != null && category != 'All') {
      final selectedIds = _categories
          .where((c) => c.name.trim() == category)
          .map((c) => c.id)
          .toSet();
      baseList = baseList.where((s) => selectedIds.contains(s.categoryId)).toList();
    }
    /* if (rating != null && rating > 0) {
      baseList = baseList.where((subCat) {
        double avgRating = getAverageRating(subCat.reviews);
        return avgRating >= rating;
      }).toList();
    } */
    if (price != null && price > 0) {
      baseList = baseList.where((subCat) => subCat.discountedPrice <= price).toList();
    }
    _filteredSubCategories = baseList;
    notifyListeners();
  }

  void clearFilters() {
    _filteredSubCategories.clear();
    notifyListeners();
  }

  double getAverageRating(List<Review> reviews) {
    if (reviews.isEmpty) return 0.0;
    int total = reviews.fold(0, (sum, r) => sum + r.rating);
    return total / reviews.length;
  }
}
