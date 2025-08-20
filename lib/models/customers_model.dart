class CustomerModel {
  final String id; 
  final String name;
  final String email;
  final String mobile;
  final String dob;
  final String marriageAnniversary;
  final String address;
  final String gender;
  final String anniversaryDate;

  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.dob,
    required this.marriageAnniversary,
    required this.address,
    required this.gender,
    required this.anniversaryDate,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      dob: json['dob'] ?? '',
      marriageAnniversary: json['marriageAnniversary'] ?? '',
      address: json['address'] ?? '',
      gender: json['gender'] ?? '',
      anniversaryDate: json['anniversaryDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 
      'name': name,
      'email': email,
      'mobile': mobile,
      'dob': dob,
      'marriageAnniversary': marriageAnniversary,
      'address': address,
      'gender': gender,
      'anniversaryDate': anniversaryDate,
    };
  }
}
