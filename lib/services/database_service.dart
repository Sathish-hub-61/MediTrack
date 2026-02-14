import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// DatabaseService now acts as a gateway to the Python Flask Backend API.
/// This aligns with the project specification for Python Flask and Firestore.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // The base URL for the Flask Backend
  // When running locally on emulator, use 10.0.2.2. For web, use localhost.
  static const String _baseUrl =
      kIsWeb ? 'http://localhost:5000/api' : 'http://10.0.2.2:5000/api';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Insert Medicine (Calls Flask POST /api/medicines)
  Future<void> insertMedicine(Map<String, dynamic> data) async {
    try {
      debugPrint('DatabaseService: Syncing to Flask/Firestore: $data');
      await _dio.post('/medicines', data: data);
    } catch (e) {
      debugPrint('DatabaseService: Error inserting medicine: $e');
      // Fallback or rethrow based on app needs
      rethrow;
    }
  }

  // Query Medicines (Calls Flask GET /api/medicines/<userId>)
  Future<List<Map<String, dynamic>>> getMedicines(String userId) async {
    try {
      debugPrint('DatabaseService: Fetching from Flask for $userId');
      final response = await _dio.get('/medicines/$userId');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      debugPrint('DatabaseService: Error fetching medicines: $e');
      return [];
    }
  }

  // Dispose Medicine (Calls Flask PUT /api/medicines/dispose)
  Future<void> disposeMedicine(
      String medicineId, String userId, String details) async {
    try {
      debugPrint('DatabaseService: Disposing via Flask: $medicineId');
      await _dio.put('/medicines/dispose', data: {
        'id': medicineId,
        'userId': userId,
        'details': details,
      });
    } catch (e) {
      debugPrint('DatabaseService: Error disposing medicine: $e');
      rethrow;
    }
  }

  // Get History Logs (Calls Flask GET /api/history/<userId>)
  Future<List<Map<String, dynamic>>> getHistory(String userId) async {
    try {
      debugPrint('DatabaseService: Fetching history from Flask for $userId');
      final response = await _dio.get('/history/$userId');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      debugPrint('DatabaseService: Error fetching history: $e');
      return [];
    }
  }
}
