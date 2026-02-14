class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final int alertDays;
  final bool notificationPreferences;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.alertDays = 30,
    this.notificationPreferences = true,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> json, String docId) {
    return UserModel(
      id: docId,
      name: json['name'] as String? ?? 'User',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      alertDays: json['alertDays'] as int? ?? 30,
      notificationPreferences: json['notificationPreferences'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'alertDays': alertDays,
      'notificationPreferences': notificationPreferences,
    };
  }
}
