import 'dart:convert';

import 'package:edit_ezy_project/constants/api_constant.dart';
import 'package:edit_ezy_project/models/user_model.dart';
import 'package:http/http.dart' as http;

class Authservice {
  
  Future<LoginResponse?> login(String mobile) async {
    try {
      print('Mobile number: $mobile');
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile': mobile}),
      );

      print('${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Successsssss$data');
        return LoginResponse.fromJson(data);
      } else {
        throw Exception('Login Failed');
      }
    } catch (e) {
      print('Errrrrrrrrrr $e');
      return null;
    }
  }

  Future<String?> uploadProfileImage(String userId, String imagePath) async {
    try {
      print("lllllllllllllllllllllllllllll$userId");
      print("lllllllllllllllllllllllllllll$imagePath");

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse(ApiConstants.uploadProfileImage(userId)),
      );

      // Add the image file
      request.files.add(await http.MultipartFile.fromPath('profileImage', imagePath));

      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("kkkkkkkk${response.statusCode}");
      print('gggggggggggggggggggggggg${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // Based on your API response, the profile image URL should be in data['profileImage']
        print("pppppppppppppp${data['user']['profileImage']}");
        return data['user']['profileImage'];
      } else {
        print('Error uploading image: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }
}