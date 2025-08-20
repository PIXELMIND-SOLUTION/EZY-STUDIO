import 'dart:convert';
import 'package:edit_ezy_project/constants/api_constant.dart';
import 'package:edit_ezy_project/models/logo_model.dart';
import 'package:http/http.dart' as http;

class LogoService {
  Future<List<LogoItem>> fetchLogos() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.getLogos));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((jsonItem) => LogoItem.fromjson(jsonItem)).toList();
      } else {
        throw Exception('Failed to load logos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching logos: $e');
    }
  }
}