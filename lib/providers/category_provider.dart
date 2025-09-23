import 'dart:developer';

import 'package:flutter/material.dart';
import '../API/Categories_api.dart';
import 'package:yumquick/models/category.dart';
import 'package:yumquick/models/subcategory.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryApi _api = CategoryApi();

  List<Category> _categories = []; // With subcategories nested
  List<SubCategory> _allSubCategories = [];
  String _selectedCategory = 'All';

  bool _isLoading = false;
  String? _errorMessage;

  String? _vendorId;
  String? get vendorId => _vendorId;

  List<Category> get categories => _categories;
  List<SubCategory> get allSubCategories => _allSubCategories;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Chips: use unique trimmed names from all categories
  List<Category> get chipCategories {
    final seen = <String>{};
    return _categories.where((cat) {
      final trimmed = cat.name.trim();
      final isNew = !seen.contains(trimmed);
      if (isNew) seen.add(trimmed);
      return isNew;
    }).toList();
  }

  // All subcategories flat (for ALL/initial display)
  List<SubCategory> get allSubCategoriesFlat =>
      _categories.expand((cat) => cat.subCategories).toList();

  // For the selected chip
  List<SubCategory> get subCategoriesForSelected {
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
     //print("Starting to load categories");

    try {
      _categories = await _api.fetchAllCategoriesWithSubCategories();
       //log('Loaded categories count: ${_categories.length}');
    
       _vendorId = _categories.isNotEmpty ? _categories.first.vendor : null;
      // Flat list for debugging or if needed
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
}
