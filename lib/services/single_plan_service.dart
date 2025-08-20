import 'dart:convert';

import 'package:edit_ezy_project/constants/api_constant.dart';
import 'package:http/http.dart' as http;

class SinglePlanService {
  Future<Map<String, dynamic>?> getSinglePlan(String planId) async {
    final url = Uri.parse('${ApiConstants.singlePlan}/$planId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to load plan. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching plan: $e');
    }

    return null;
  }
}