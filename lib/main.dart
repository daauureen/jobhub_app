import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants/app_routes.dart';
import 'screens/common/not_found_screen.dart';
import 'utils/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(JobHubApp());
}

class JobHubApp extends StatelessWidget {
  JobHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _){
    return MaterialApp(
      title: 'JobHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: mode,
      initialRoute: '/',
      onGenerateRoute: AppRoutes.generateRoute,
      onUnknownRoute: (_) => MaterialPageRoute(builder: (_) => NotFoundScreen()),
    );
      },
    );
  }
}
  
