import 'package:flutter_test/flutter_test.dart';

import 'package:meditrack/models/medicine_model.dart';

void main() {
  group('MedicineModel Status Logic', () {
    test('Status is SAFE when more than 30 days remaining', () {
      final now = DateTime.now();
      final expiryDate = now.add(const Duration(days: 32));

      final medicine = MedicineModel(
        id: '1',
        userId: 'user1',
        medicineName: 'Test Med',
        batchNumber: 'B1',
        manufacturedDate: now,
        expiryDate: expiryDate,
        useCase: 'Test',
        addedAt: now,
      );

      expect(medicine.status, MedicineStatus.safe);
    });

    test('Status is WARNING when exactly 30 days remaining', () {
      final now = DateTime.now();
      final expiryDate = now.add(const Duration(days: 30));

      final medicine = MedicineModel(
        id: '2',
        userId: 'user1',
        medicineName: 'Test Med',
        batchNumber: 'B2',
        manufacturedDate: now,
        expiryDate: expiryDate,
        useCase: 'Test',
        addedAt: now,
      );

      expect(medicine.status, MedicineStatus.warning);
    });

    test('Status is WARNING when less than 30 days remaining but not expired',
        () {
      final now = DateTime.now();
      final expiryDate = now.add(const Duration(days: 1));

      final medicine = MedicineModel(
        id: '3',
        userId: 'user1',
        medicineName: 'Test Med',
        batchNumber: 'B3',
        manufacturedDate: now,
        expiryDate: expiryDate,
        useCase: 'Test',
        addedAt: now,
      );

      expect(medicine.status, MedicineStatus.warning);
    });

    test('Status is WARNING when expiring today (0 days left)', () {
      // Note: difference in days might depend on time implementation.
      // The model uses `expiryDate.difference(now).inDays`.
      // If now is 10:00 and expiry is 10:00 same day, result is 0.
      final now = DateTime.now();
      final expiryDate = now; // Same time

      final medicine = MedicineModel(
        id: '4',
        userId: 'user1',
        medicineName: 'Test Med',
        batchNumber: 'B4',
        manufacturedDate: now,
        expiryDate: expiryDate,
        useCase: 'Test',
        addedAt: now,
      );

      // difference might be 0.
      // Logic: difference < 0 is expired. <= 30 is warning.
      // 0 <= 30 -> Warning.

      expect(medicine.status, MedicineStatus.warning);
    });

    test('Status is EXPIRED when date is in the past', () {
      final now = DateTime.now();
      final expiryDate = now.subtract(const Duration(days: 1));

      final medicine = MedicineModel(
        id: '5',
        userId: 'user1',
        medicineName: 'Test Med',
        batchNumber: 'B5',
        manufacturedDate: now,
        expiryDate: expiryDate,
        useCase: 'Test',
        addedAt: now,
      );

      expect(medicine.status, MedicineStatus.expired);
    });
  });
}
