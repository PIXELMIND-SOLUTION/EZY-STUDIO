
import 'package:edit_ezy_project/helper/storage_helper.dart';
import 'package:edit_ezy_project/providers/auth/auth_provider.dart';
import 'package:edit_ezy_project/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthController {
  final Authservice _authservice = Authservice();

  Future<bool> loginUser(BuildContext context, String mobile) async {
    try {
      final user = await _authservice.login(mobile);
      
      if (user != null) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.setUser(user);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Add method to check if user is already logged in (useful for splash screens)
  Future<bool> checkLoggedInStatus() async {
    return await AuthPreferences.isLoggedIn();
  }
  
  // Method to handle logout
  Future<bool> logoutUser(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return await authProvider.logout();
  }
}