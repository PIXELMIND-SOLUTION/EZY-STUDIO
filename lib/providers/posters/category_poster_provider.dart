
import 'package:edit_ezy_project/models/category_model.dart';
import 'package:edit_ezy_project/services/getposter_category.dart';
import 'package:flutter/material.dart';


class CategoryPosterProvider extends ChangeNotifier {
  final CategoryPosterService _service = CategoryPosterService();
  List<CategoryModel> _categoryPosters = [];
  bool _isLoading = false;
  String _error = '';

  List<CategoryModel> get categoryPosters => _categoryPosters;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchPostersByCategory(String category) async {
    print('heeeeeeeelooo$category');
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final posters = await _service.fetchPostersByCategory(category);
      _categoryPosters = posters;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      print('Error in CategoryPosterProvider: $e');
    }
  }
}