import 'dart:convert';
import 'package:edit_ezy_project/constants/api_constant.dart';
import 'package:edit_ezy_project/models/canva_poster_model.dart';
import 'package:http/http.dart' as http;

class NewCanvasPosterService {
  Future<List<CanvasPosterModel>> fetchCanvasPosters() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.canvaPosters));

      print('Raw Response Status Code: ${response.statusCode}');
      print('Raw Response Body: ${response.body}');
        
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // Fixed: Use 'posters' instead of 'poster' to match your JSON response
        final List<dynamic> postersJson = decoded['posters'] ?? [];

        return postersJson
            .map((json) => CanvasPosterModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load canvas posters: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error details: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error fetching canvas posters: $e');
    }
  }
}