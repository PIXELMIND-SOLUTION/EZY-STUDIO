
import 'package:edit_ezy_project/models/signup_model.dart';
import 'package:edit_ezy_project/services/signp_service.dart';
import 'package:flutter/material.dart';

class SignupProvider extends ChangeNotifier {
  final SignupServices _signupServices = SignupServices();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> registerUser(SignupModel signupModel) async {
    _setLoading(true);
    try {
      final success = await _signupServices.registerUser(signupModel);
      if (success) {
        _errorMessage = null;
        _setLoading(false);
        return true;
      } else {
        _errorMessage = 'Registration failed. Please try again.';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
