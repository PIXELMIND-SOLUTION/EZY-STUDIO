
import 'package:edit_ezy_project/models/business_category_model.dart';
import 'package:edit_ezy_project/services/business_category_service.dart';
import 'package:flutter/material.dart';

class BusinessCategoryProvider extends ChangeNotifier{

final BusinessCategoryServices _services=BusinessCategoryServices();

List<BusinessCategoryModel>_categories=[];
List<BusinessCategoryModel>get categories=>_categories;

bool _isLoading =false;
bool get isLoading =>_isLoading;

String?_errorMessage;
String?get errorMessage=>_errorMessage;

Future<void>fetchCategories()async{
  _isLoading=true;
  notifyListeners();

  try{
  
  _categories=await _services.fetchBusinessCategories();
  _errorMessage=null;

  }catch(e){
    _errorMessage=e.toString();
    _categories=[];
  }

  _isLoading=false;
  notifyListeners();

}

}