import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meditrack/services/database_service.dart';
import 'package:meditrack/models/medicine_model.dart';
import 'package:uuid/uuid.dart';
import 'package:meditrack/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Verify SQLite database operations', (WidgetTester tester) async {
    // Start the app to ensure initialization happens
    app.main();
    await tester.pumpAndSettle();

    // Access Database Service directly
    final dbService = DatabaseService();
    // Ensure DB is open (implicitly handled by methods)

    // 1. Create a Medicine
    final testId = const Uuid().v4();
    final testUserId = 'test_integration_user';
    final medicine = MedicineModel(
      id: testId,
      userId: testUserId,
      medicineName: 'Test Paracetamol',
      batchNumber: 'BATCH001',
      manufacturedDate: DateTime.now().subtract(const Duration(days: 30)),
      expiryDate: DateTime.now().add(const Duration(days: 365)),
      useCase: 'Fever',
      disposed: false,
      addedAt: DateTime.now(),
    );

    await dbService.insertMedicine(medicine.toMap());
    debugPrint('Medicine inserted successfully');

    // 2. Read
    final maps = await dbService.getMedicines(testUserId);
    expect(maps.isNotEmpty, true, reason: 'Should have at least one medicine');

    // Check if added medicine exists
    final retrievedMap = maps.firstWhere((m) => m['id'] == testId,
        orElse: () => throw Exception('Medicine not found'));
    expect(retrievedMap['medicineName'], 'Test Paracetamol');
    debugPrint('Medicine retrieved successfully');

    // 3. Dispose
    await dbService.disposeMedicine(testId, testUserId, 'Test dispose');

    final mapsAfter = await dbService.getMedicines(testUserId);
    final exists = mapsAfter.any((m) => m['id'] == testId);
    expect(exists, false, reason: 'Medicine should be disposed');
    debugPrint('Medicine disposed successfully');
  });
}
