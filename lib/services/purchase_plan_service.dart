// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:edit_ezy_project/constants/api_constant.dart';
import 'package:http/http.dart' as http;

class PurchasePlanService {
  Future<bool> purchasePlan({
    required String userId,
    required String planId,
    required String transactionId
  }) async {
    print('assssssssssssssssssssssssssssss$userId');
    final url = Uri.parse(ApiConstants.purchasePlan);

    final body = jsonEncode({
      'userId': userId,
      'planId': planId,
      'transactionId':transactionId
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // You can return response body or parse response if needed
        print("Plan purchased successfully: ${response.body}");
        return true;
      } else {
        print("Failed to purchase plan: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error purchasing plan: $e");
      return false;
    }
  }
}