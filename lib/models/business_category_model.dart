class BusinessCategoryModel {
  final String id;
  final String categoryName;
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<dynamic> subCategories;

  BusinessCategoryModel(
      {required this.id,
      required this.categoryName,
      required this.image,
      required this.createdAt,
      required this.updatedAt,
      required this.subCategories});

  factory BusinessCategoryModel.fromJson(Map<String, dynamic> json) {
    return BusinessCategoryModel(
        id: json['_id'] ?? '',
        categoryName: json['categoryName'] ?? '',
        image: json['image'] ?? '',
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        subCategories: json['subCategories'] ?? []);
  }

  Map<String, dynamic> tojson() {
    return {
      '_id': id,
      'categoryName': categoryName,
      'image': image,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'subCategories': subCategories
    };
  }
}
