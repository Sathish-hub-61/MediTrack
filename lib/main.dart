import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'providers/auth_provider.dart';
import 'providers/medicine_provider.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('App: Widgets initialized');

    // Lock orientation
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    debugPrint('App: Orientation locked');

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
      ],
      child: Sizer(
        builder: (context, orientation, screenType) {
          return MaterialApp(
            title: 'MediTrack',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            initialRoute: AppRoutes.initial, // '/'
            routes: AppRoutes.routes,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
