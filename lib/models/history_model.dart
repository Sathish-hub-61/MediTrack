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
    // The DatabaseService logs only have: userId, action, timestamp
    // Parse the action string to extract action type and details
    final rawAction = json['action']?.toString() ?? '';
    String parsedAction = 'Other';
    String parsedDetails = rawAction;

    if (rawAction.toLowerCase().startsWith('added medicine:')) {
      parsedAction = 'Added';
      parsedDetails = rawAction.substring('Added medicine: '.length);
    } else if (rawAction.toLowerCase().startsWith('disposed medicine:')) {
      parsedAction = 'Disposed';
      parsedDetails = rawAction.substring('Disposed medicine: '.length);
    } else if (rawAction.toLowerCase().startsWith('edited')) {
      parsedAction = 'Edited';
      parsedDetails = rawAction;
    }

    return HistoryModel(
      id: json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      userId: json['userId'] ?? '',
      medicineId: json['medicineId'] ?? '',
      action: parsedAction,
      details: parsedDetails,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
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
