import 'dart:convert';
import 'package:edit_ezy_project/constants/api_constant.dart';
import 'package:edit_ezy_project/models/otp_model.dart';
import 'package:http/http.dart' as http;

class SmsService {
  /// Login request with mobile number
  Future<http.Response> login(LoginRequest request) async {
    final url = Uri.parse(ApiConstants.login);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );
      return response;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Verify OTP request
  Future<http.Response> verifyOtp(VerifyOtpRequest request) async {
    final url = Uri.parse(ApiConstants.verifyOtp);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.tojson()),
      );
      return response;
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  /// Resend OTP request
  Future<http.Response> resendOtp(ResendOtpRequest request) async {
    final url = Uri.parse(ApiConstants.resendOtp);
      
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );
      return response;
    } catch (e) {
      throw Exception('Resend OTP failed: $e');
    }
  }
}

// Add this ResendOtpRequest class to your existing otp_model.dart file

class ResendOtpRequest {
  final String mobile;

  ResendOtpRequest({required this.mobile});

  Map<String, dynamic> toJson() {
    return {
      'mobile': mobile,
    };
  }
}
