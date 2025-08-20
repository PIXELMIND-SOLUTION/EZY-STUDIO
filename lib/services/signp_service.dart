import 'dart:convert';
 // Import your ApiConstants
import 'package:edit_ezy_project/constants/api_constant.dart';
import 'package:edit_ezy_project/models/signup_model.dart';
import 'package:http/http.dart' as http;

class SignupServices {
  Future<bool> registerUser(SignupModel signupModel) async {
    try {
      print('melvin');
      print('daaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaataaaaaa${signupModel.referralCode}');
      final response = await http.post(
        Uri.parse(ApiConstants.registerUser),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': signupModel.name,
          'email': signupModel.email,
          'mobile': signupModel.mobile,
          'dob': signupModel.dob,
          'marriageAnniversaryDate': signupModel.marriageAnniversary, 
          'referralCode': signupModel.referralCode
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('User registered successfully!');
        return true;
      } else {
        print('Failed to register user: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during registration: $e');
      return false;
    }
  }
}