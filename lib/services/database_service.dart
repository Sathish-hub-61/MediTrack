import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine_model.dart';

/// DatabaseService now uses Hive as a robust, fast local database.
/// This prevents data loss associated with SharedPreferences and acts
/// as the offline-first layer before adding cloud sync.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static const String _medicinesBoxName = 'medicines';
  static const String _historyBoxName = 'history';

  // Get Boxes
  Box<String> _getMedicinesBox() {
    return Hive.box<String>(_medicinesBoxName);
  }

  Box<String> _getHistoryBox() {
    return Hive.box<String>(_historyBoxName);
  }

  // Insert Medicine
  Future<void> insertMedicine(Map<String, dynamic> data) async {
    try {
      debugPrint(
          'DatabaseService: Saving Locally with Hive: ${data['medicineName']}');
      final box = _getMedicinesBox();
      final String id = data['id'];

      // Save directly with ID as key locally
      await box.put(id, jsonEncode(data));

      // Push to Cloud Firestore for Web Portal syncing
      try {
        await FirebaseFirestore.instance
            .collection('medicines')
            .doc(id)
            .set(data);
        debugPrint('DatabaseService: Successfully pushed to Cloud Firestore');
      } catch (e) {
        debugPrint('DatabaseService: Cloud Firestore push ignored/failed: $e');
      }

      // Log history
      await _logHistory(
          data['userId'], 'Added medicine: ${data['medicineName']}');
    } catch (e) {
      debugPrint('DatabaseService: Hive local storage error: $e');
      rethrow;
    }
  }

  // Query Medicines — Firestore is the primary source of truth
  Future<List<Map<String, dynamic>>> getMedicines(String userId) async {
    try {
      final box = _getMedicinesBox();
      final List<Map<String, dynamic>> medicines = [];

      // STEP 1: Read from Firestore (cloud source of truth)
      try {
        debugPrint('DatabaseService: Querying Firestore for userId: $userId');

        final querySnapshot = await FirebaseFirestore.instance
            .collection('medicines')
            .where('userId', isEqualTo: userId)
            .limit(100) // CodeRabbit Performance Fix
            .get();

        debugPrint(
            'DatabaseService: Firestore returned ${querySnapshot.docs.length} documents for userId: $userId');

        final cloudIds = <String>{};

        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          debugPrint(
              'DatabaseService: Found medicine: ${data['medicineName']} | disposed: ${data['disposed']} | userId: ${data['userId']}');
          cloudIds.add(data['id'] ?? doc.id);
          if (data['disposed'] == 0 || data['disposed'] == false) {
            medicines.add(data);
            // Keep local cache in sync safely
            try {
              // We need to ensure we don't try to JSON encode raw Timestamp objects if they exist
              // MedicineModel handles fromMap/toMap properly.
              final medicine = MedicineModel.fromMap(data);
              await box.put(data['id'] ?? doc.id, jsonEncode(medicine.toMap()));
            } catch (e) {
              debugPrint('DatabaseService: Local sync encode error: $e');
            }
          }
        }

        // STEP 2: Upload any LOCAL-ONLY medicines (added before cloud sync)
        // to Firestore so they aren't lost
        // Background sync to prevent dropping frames on the main rendering thread
        Future.microtask(() async {
          for (var value in box.values) {
            try {
              final Map<String, dynamic> item = jsonDecode(value);
              if (item['userId'] == userId &&
                  !cloudIds.contains(item['id']) &&
                  (item['disposed'] == 0 || item['disposed'] == false)) {
                debugPrint(
                    'DatabaseService: Background uploading local medicine to Firestore: ${item['medicineName']}');
                try {
                  await FirebaseFirestore.instance
                      .collection('medicines')
                      .doc(item['id'])
                      .set(item);
                } catch (e) {
                  debugPrint('DatabaseService: Failed to upload local medicine in bg: $e');
                }
              }
            } catch (e) {
              debugPrint('DatabaseService: Skipping invalid local cache item in bg: $e');
            }
          }
        });
        
        // Return immediately while the above async loop runs silently in bg. 
        // We still provide the local equivalents so the UI displays them.
        for (var value in box.values) {
           try {
              final Map<String, dynamic> item = jsonDecode(value);
              if (item['userId'] == userId &&
                  !cloudIds.contains(item['id']) &&
                  (item['disposed'] == 0 || item['disposed'] == false)) {
                  medicines.add(item);
              }
           } catch (_) {}
        }
      } catch (e) {
        debugPrint(
            'DatabaseService: Firestore unavailable, falling back to Hive: $e');
        // FALLBACK: If Firestore fails entirely, show from local Hive
        for (var value in box.values) {
          final Map<String, dynamic> item = jsonDecode(value);
          if (item['userId'] == userId &&
              (item['disposed'] == 0 || item['disposed'] == false)) {
            medicines.add(item);
          }
        }
      }

      return medicines;
    } catch (e) {
      debugPrint('DatabaseService: Error in getMedicines: $e');
      return [];
    }
  }

  // Dispose Medicine
  Future<void> disposeMedicine(
      String medicineId, String userId, String details) async {
    try {
      final box = _getMedicinesBox();
      final String? existingData = box.get(medicineId);

      if (existingData != null) {
        final Map<String, dynamic> data = jsonDecode(existingData);
        data['disposed'] = 1;
        await box.put(medicineId, jsonEncode(data));

        // Update Cloud Firebase
        try {
          await FirebaseFirestore.instance
              .collection('medicines')
              .doc(medicineId)
              .update({'disposed': 1});
        } catch (e) {
          debugPrint('DatabaseService: Cloud update error: $e');
        }

        await _logHistory(userId, 'Disposed medicine: $details');
      }
    } catch (e) {
      debugPrint('DatabaseService: Hive dispose error: $e');
      rethrow;
    }
  }

  // Get History Logs
  Future<List<Map<String, dynamic>>> getHistory(String userId) async {
    try {
      final box = _getHistoryBox();
      final List<Map<String, dynamic>> history = [];

      for (var value in box.values) {
        final Map<String, dynamic> item = jsonDecode(value);
        if (item['userId'] == userId) {
          history.add(item);
        }
      }

      // Sort history descending by timestamp
      history.sort((a, b) {
        final timeA = DateTime.parse(a['timestamp']);
        final timeB = DateTime.parse(b['timestamp']);
        return timeB.compareTo(timeA); // Newest first
      });

      return history;
    } catch (e) {
      debugPrint('DatabaseService: Hive history error: $e');
      return [];
    }
  }

  // Helper to log history actions
  Future<void> _logHistory(String userId, String action) async {
    final box = _getHistoryBox();
    final String logId = DateTime.now().millisecondsSinceEpoch.toString();

    final log = {
      'id': logId,
      'userId': userId,
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await box.put(logId, jsonEncode(log));
  }
}
