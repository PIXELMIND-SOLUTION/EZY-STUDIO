
import 'package:edit_ezy_project/models/business_model.dart';
import 'package:edit_ezy_project/services/business_service.dart';
import 'package:flutter/material.dart';

class BusinessPosterProvider extends ChangeNotifier {
  final BusinessPosterServices _services = BusinessPosterServices();

  List<BusinessPosterModel> _posters = [];
  bool _isLoading = false;
  String? _error;

  List<BusinessPosterModel> get posters => _posters;
  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> fetchPosters() async {
    _isLoading = true;

    _error = null;
    notifyListeners();

    try {
      _posters = await _services.fetchBusinessPosters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
