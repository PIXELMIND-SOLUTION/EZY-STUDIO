class BusinessPosterModel {
  final String id;
  final String name;
  final String categoryName;
  final double price;
  final double offerPrice;
  final List<String> images;
  final String description;
  final String size;
  final bool inStock;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusinessPosterModel(
      {required this.id,
      required this.name,
      required this.categoryName,
      required this.price,
      required this.offerPrice,
      required this.images,
      required this.description,
      required this.size,
      required this.inStock,
      required this.tags,
      required this.createdAt,
      required this.updatedAt});

  factory BusinessPosterModel.fromjson(Map<String, dynamic> json) {
    return BusinessPosterModel(
      id: json['_id'],
      name: json['name'],
      categoryName: json['categoryName'],
      price: (json['price'] as num).toDouble(),
      offerPrice: (json['offerPrice'] as num).toDouble(),
      images: List<String>.from(json['images']),
      description: json['description'],
      size: json['size'],
      inStock: json['inStock'],
      tags: List<String>.from(json['tags']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'categoryName': categoryName,
      'price': price,
      'offerPrice': offerPrice,
      'images': images,
      'description': description,
      'size': size,
      'inStock': inStock,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
