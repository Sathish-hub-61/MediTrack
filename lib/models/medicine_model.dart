enum MedicineStatus { safe, warning, expired }

class MedicineModel {
  final String id;
  final String userId;
  final String medicineName;
  final String batchNumber;
  final DateTime manufacturedDate;
  final DateTime expiryDate;
  final String useCase;
  final bool disposed;
  final DateTime addedAt;

  MedicineModel({
    required this.id,
    required this.userId,
    required this.medicineName,
    required this.batchNumber,
    required this.manufacturedDate,
    required this.expiryDate,
    required this.useCase,
    this.disposed = false,
    required this.addedAt,
  });

  factory MedicineModel.fromMap(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      medicineName: json['medicineName'] ?? '',
      batchNumber: json['batchNumber'] ?? '',
      manufacturedDate: DateTime.parse(json['manufacturedDate']),
      expiryDate: DateTime.parse(json['expiryDate']),
      useCase: json['useCase'] ?? '',
      disposed: (json['disposed'] == 1 || json['disposed'] == true),
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'medicineName': medicineName,
      'batchNumber': batchNumber,
      'manufacturedDate': manufacturedDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'useCase': useCase,
      'disposed': disposed ? 1 : 0,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  MedicineStatus get status {
    final now = DateTime.now();
    final difference = expiryDate.difference(now).inDays;

    if (difference < 0) {
      return MedicineStatus.expired;
    } else if (difference <= 30) {
      return MedicineStatus.warning;
    } else {
      return MedicineStatus.safe;
    }
  }

  int get daysRemaining => expiryDate.difference(DateTime.now()).inDays;
}
