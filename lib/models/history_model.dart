class HistoryModel {
  final String id;
  final String userId;
  final String medicineId;
  final String action;
  final String details;
  final DateTime timestamp;

  HistoryModel({
    required this.id,
    required this.userId,
    required this.medicineId,
    required this.action,
    required this.details,
    required this.timestamp,
  });

  factory HistoryModel.fromMap(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'].toString(),
      userId: json['userId'] ?? '',
      medicineId: json['medicineId'] ?? '',
      action: json['action'] ?? '',
      details: json['details'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'medicineId': medicineId,
      'action': action,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
