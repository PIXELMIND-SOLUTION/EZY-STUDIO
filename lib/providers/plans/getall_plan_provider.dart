
import 'package:edit_ezy_project/models/getall_plan_model.dart';
import 'package:edit_ezy_project/services/getall_plan_services.dart';
import 'package:flutter/material.dart';

class GetAllPlanProvider extends ChangeNotifier {
  final GetAllPlanServices _planService = GetAllPlanServices();

  List<GetAllPlanModel> _plans = [];
  bool _isLoading = false;
  String? _error;

  List<GetAllPlanModel> get plans => _plans;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAllPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _plans = await _planService.fetchAllPlans();
    } catch (e) {
      print('sfjsjfjsjjsdfjs$e');
      print('planssssssssss$_plans');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
