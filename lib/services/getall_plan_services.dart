import 'dart:convert';
import 'package:edit_ezy_project/constants/api_constant.dart';
import 'package:edit_ezy_project/models/getall_plan_model.dart';
import 'package:http/http.dart' as http;

class GetAllPlanServices {
  Future<List<GetAllPlanModel>> fetchAllPlans() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.getAllPlans));
      
      if (response.statusCode == 200) {
        // Parse the response as a Map first
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Check if the response contains a 'plans' key
        if (responseData.containsKey('plans') && responseData['plans'] is List) {
          final List<dynamic> plansData = responseData['plans'];
          
          final plans = plansData
              .map((planJson) => GetAllPlanModel.fromJson(planJson))
              .toList();
              
          return plans;
        } else {
          throw Exception('Invalid data format: Missing or invalid plans array');
        }
      } else {
        throw Exception('Failed to load plans: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching plans: $e');
      throw Exception('Error fetching plans: $e');
    }
  }
}