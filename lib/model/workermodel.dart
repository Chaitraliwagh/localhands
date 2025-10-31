class WorkerModel {
  final String name;
  final String city;
  final String phone;
  final String price;
  final String profileImage;
  final String rating;
  final List<dynamic> services;

  WorkerModel({
    required this.name,
    required this.city,
    required this.phone,
    required this.price,
    required this.profileImage,
    required this.rating,
    required this.services,
  });

  factory WorkerModel.fromMap(Map<String, dynamic> map) {
    return WorkerModel(
      name: map['name'] ?? '',
      city: map['city'] ?? '',
      phone: map['phone'] ?? '',
      price: map['price'] ?? '',
      profileImage: map['profileImage'] ?? '',
      rating: map['rating'] ?? '',
      services: List<dynamic>.from(map['services'] ?? []),
    );
  }
}
