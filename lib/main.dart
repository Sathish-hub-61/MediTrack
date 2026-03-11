import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'providers/auth_provider.dart';
import 'providers/medicine_provider.dart';
import 'providers/theme_provider.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('App: Widgets initialized');

    try {
      await dotenv.load(fileName: ".env");
      debugPrint('App: dotenv initialized');
    } catch (e) {
      debugPrint('App: dotenv initialization failed: $e');
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('App: Firebase initialized successfully');
    } catch (e) {
      debugPrint('App: Firebase init failed: $e');
      // Catching this so we don't crash if the web setup is incomplete.
    }

    await initializeDateFormatting('en_IN', null);
    debugPrint('App: Date formatting initialized');

    await Hive.initFlutter();
    await Hive.openBox<String>('medicines');
    await Hive.openBox<String>('history');
    debugPrint('App: Hive database initialized');

    // Lock orientation only on non-web platforms
    if (!kIsWeb) {
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp]);
      debugPrint('App: Orientation locked');
    }

    runApp(const MyApp());
  } catch (e, stack) {
    debugPrint('App: Initialization Error: $e');
    debugPrint('App: StackTrace: $stack');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MedicineProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Sizer(
        builder: (context, orientation, screenType) {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return MaterialApp(
                title: 'MediTrack',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeProvider.themeMode,
                initialRoute: AppRoutes.initial, // '/'
                routes: AppRoutes.routes,
                debugShowCheckedModeBanner: false,
              );
            },
          );
        },
      ),
    );
  }
}
