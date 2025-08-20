// lib/models/brand_data_model.dart

import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BrandDataModel {
  File? logoImage;
  File? extraElementImage;
  String businessName;
  String mobileNumber;
  String address;
  String email;
  String website;
  List<String> selectedSocialMedia;
  
  // Path storage for persistence
  String? logoImagePath;
  String? extraElementImagePath;

  BrandDataModel({
    this.logoImage,
    this.extraElementImage,
    this.businessName = '',
    this.mobileNumber = '',
    this.address = '',
    this.email = '',
    this.website = '',
    this.selectedSocialMedia = const [],
  });

  // Convert to a map for storing in shared preferences
  Map<String, dynamic> toJson() {
    return {
      'logoImagePath': logoImage?.path,
      'extraElementImagePath': extraElementImage?.path,
      'businessName': businessName,
      'mobileNumber': mobileNumber,
      'address': address,
      'email': email,
      'website': website,
      'selectedSocialMedia': selectedSocialMedia,
    };
  }

  // Create from a map retrieved from shared preferences
  factory BrandDataModel.fromJson(Map<String, dynamic> json) {
    return BrandDataModel(
      logoImage: json['logoImagePath'] != null ? File(json['logoImagePath']) : null,
      extraElementImage: json['extraElementImagePath'] != null ? File(json['extraElementImagePath']) : null,
      businessName: json['businessName'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      address: json['address'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
      selectedSocialMedia: List<String>.from(json['selectedSocialMedia'] ?? []),
    );
  }

  // Save to shared preferences
  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Set file paths before saving
    if (logoImage != null) {
      logoImagePath = logoImage!.path;
    }
    if (extraElementImage != null) {
      extraElementImagePath = extraElementImage!.path;
    }
    
    await prefs.setString('brandData', jsonEncode(toJson()));
  }

  // Load from shared preferences
  static Future<BrandDataModel?> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonData = prefs.getString('brandData');
      
      if (jsonData == null) {
        return null;
      }
      
      Map<String, dynamic> map = jsonDecode(jsonData);
      return BrandDataModel.fromJson(map);
    } catch (e) {
      print('Error loading brand data: $e');
      return null;
    }
  }
}