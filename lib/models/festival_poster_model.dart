class FestivalPoster {
  final String id;
  final String title;
  final String imageUrl;
  final String category;
  final DateTime date;
  final String location;
  final String description;
  final List<String> artists;
  final bool isFeatured;
  final String submittedBy;
  final DateTime createdAt;

  FestivalPoster({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.date,
    required this.location,
    required this.description,
    required this.artists,
    this.isFeatured = false,
    required this.submittedBy,
    required this.createdAt,
  });

  // Convert JSON to FestivalPoster object
  factory FestivalPoster.fromJson(Map<String, dynamic> json) {
    return FestivalPoster(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? 'Uncategorized',
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : DateTime.now(),
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      artists: json['artists'] != null 
          ? List<String>.from(json['artists']) 
          : [],
      isFeatured: json['isFeatured'] ?? false,
      submittedBy: json['submittedBy'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  // Convert FestivalPoster object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'imageUrl': imageUrl,
      'category': category,
      'date': date.toIso8601String(),
      'location': location,
      'description': description,
      'artists': artists,
      'isFeatured': isFeatured,
      'submittedBy': submittedBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  FestivalPoster copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? category,
    DateTime? date,
    String? location,
    String? description,
    List<String>? artists,
    bool? isFeatured,
    String? submittedBy,
    DateTime? createdAt,
  }) {
    return FestivalPoster(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      date: date ?? this.date,
      location: location ?? this.location,
      description: description ?? this.description,
      artists: artists ?? this.artists,
      isFeatured: isFeatured ?? this.isFeatured,
      submittedBy: submittedBy ?? this.submittedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}