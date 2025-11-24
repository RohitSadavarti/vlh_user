class User {
  final int? id;
  final String fullName;
  final String mobile;
  final String email;
  final String address;
  final double latitude;
  final double longitude;

  User({
    this.id,
    required this.fullName,
    required this.mobile,
    required this.email,
    this.address = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['name'] ?? json['full_name'] ?? '',
      mobile: json['mobile'] ?? json['mobile_number'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? json['address_full'] ?? '',
      latitude: double.tryParse(json['lat']?.toString() ?? '0.0') ?? 0.0,
      longitude: double.tryParse(json['lng']?.toString() ?? '0.0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': fullName,
      'mobile': mobile,
      'email': email,
      'address': address,
      'lat': latitude,
      'lng': longitude,
    };
  }
}
