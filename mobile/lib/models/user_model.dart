class AppUser {
  final int id;
  final String name;
  final String email;
  final int? age;
  final double? heightCm;
  final double? weightKg;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.age,
    this.heightCm,
    this.weightKg,
    required this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      age: json['age'] as int?,
      heightCm: json['height_cm'] != null
          ? (json['height_cm'] as num).toDouble()
          : null,
      weightKg: json['weight_kg'] != null
          ? (json['weight_kg'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
