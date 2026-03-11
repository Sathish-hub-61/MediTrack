import 'package:flutter/material.dart';
import '../models/medicine_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class MedicineProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<MedicineModel> _medicines = [];
  bool _isLoading = false;

  List<MedicineModel> get medicines => _medicines;
  bool get isLoading => _isLoading;

  int get expiringCount =>
      _medicines.where((m) => m.status == MedicineStatus.warning).length;

  int get expiredCount =>
      _medicines.where((m) => m.status == MedicineStatus.expired).length;

  Future<void> loadMedicines(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _db.getMedicines(userId);
      final newList = data.map((json) => MedicineModel.fromMap(json)).toList();
      newList.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
      
      // Schedule local notifications for all active medicines
      for (var medicine in newList) {
        if (medicine.status != MedicineStatus.expired) {
          NotificationService().scheduleExpiryNotification(
            id: medicine.id.hashCode,
            title: 'Medicine Expiring Soon',
            body: '${medicine.medicineName} is expiring on ${medicine.expiryDate.toString().split(' ')[0]}',
            expiryDate: medicine.expiryDate,
            daysBefore: 7, // Default 7 day warning
          );
        }
      }

      // Only replace the list AFTER data is ready — avoids blank flash on refresh
      _medicines = newList;
    } catch (e) {
      debugPrint('Error loading medicines: $e');
      // Keep the existing _medicines list so the screen doesn't go blank
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMedicine(MedicineModel medicine) async {
    try {
      await _db.insertMedicine(medicine.toMap());

      // Update local list (or reload)
      _medicines.add(medicine);
      _medicines.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
      notifyListeners();

      // Schedule Notification
      await NotificationService().scheduleExpiryNotification(
        id: medicine.id.hashCode,
        title: 'Medicine Expiring Soon',
        body:
            '${medicine.medicineName} is expiring on ${medicine.expiryDate.toString().split(' ')[0]}',
        expiryDate: medicine.expiryDate,
        daysBefore: 30,
      );
    } catch (e) {
      debugPrint('Error adding medicine: $e');
      rethrow;
    }
  }

  Future<void> updateMedicine(MedicineModel medicine) async {
    try {
      await _db.insertMedicine(medicine.toMap());

      // Update local list
      final index = _medicines.indexWhere((m) => m.id == medicine.id);
      if (index != -1) {
        _medicines[index] = medicine;
      }
      _medicines.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
      notifyListeners();

      // Update Notification
      await NotificationService().cancelNotification(medicine.id.hashCode);
      await NotificationService().scheduleExpiryNotification(
        id: medicine.id.hashCode,
        title: 'Medicine Expiring Soon',
        body:
            '${medicine.medicineName} is expiring on ${medicine.expiryDate.toString().split(' ')[0]}',
        expiryDate: medicine.expiryDate,
        daysBefore: 30,
      );
    } catch (e) {
      debugPrint('Error updating medicine: $e');
      rethrow;
    }
  }

  Future<void> disposeMedicine(String medicineId, String userId) async {
    try {
      await _db.disposeMedicine(
          medicineId, userId, 'Marked medicine as disposed');

      // Update local list
      _medicines.removeWhere((m) => m.id == medicineId);
      notifyListeners();

      // Cancel scheduled notification
      await NotificationService().cancelNotification(medicineId.hashCode);
    } catch (e) {
      debugPrint('Error disposing medicine: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getHistory(String userId) async {
    try {
      return await _db.getHistory(userId);
    } catch (e) {
      debugPrint('Error getting history: $e');
      return [];
    }
  }
}
