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
      _medicines = data.map((json) => MedicineModel.fromMap(json)).toList();

      // Add temporary medicines for demo
      final now = DateTime.now();
      _medicines.addAll([
        MedicineModel(
          id: 'temp1',
          userId: userId,
          medicineName: 'Paracetamol 500mg',
          batchNumber: 'PCM2024A123',
          manufacturedDate: DateTime(2024, 1, 15),
          expiryDate: DateTime(2025, 8, 15),
          useCase: 'Fever, Pain relief',
          addedAt: now,
        ),
        MedicineModel(
          id: 'temp2',
          userId: userId,
          medicineName: 'Amoxicillin 250mg',
          batchNumber: 'AMX2024B456',
          manufacturedDate: DateTime(2024, 3, 10),
          expiryDate: DateTime(2025, 2, 15), // Very soon!
          useCase: 'Bacterial infections',
          addedAt: now,
        ),
        MedicineModel(
          id: 'temp3',
          userId: userId,
          medicineName: 'Cetirizine 10mg',
          batchNumber: 'CET2023C789',
          manufacturedDate: DateTime(2023, 12, 5),
          expiryDate: DateTime(2025, 1, 5), // Expired
          useCase: 'Allergies',
          addedAt: now,
        ),
      ]);

      _medicines.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    } catch (e) {
      debugPrint('Error loading medicines: $e');
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
