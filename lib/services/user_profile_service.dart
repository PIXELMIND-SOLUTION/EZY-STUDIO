import 'dart:convert';
import 'package:edit_ezy_project/constants/api_constant.dart';
import 'package:edit_ezy_project/models/get_user_profile_model.dart';
import 'package:http/http.dart' as http;

class UserProfileServices {
  Future<UserModel> fetchUserProfile(String userId) async {
    final url = Uri.parse('${ApiConstants.getUserProfile}/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return UserModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load user profile:${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user profile:$e');
    }
  }
}