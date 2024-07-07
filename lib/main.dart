import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/views/home_page/home_screen.dart';
import 'package:scouting_app/db/auth/authentication.dart';
import 'package:scouting_app/views/login_page/login_screen.dart';
import 'package:scouting_app/theme/theme_constants.dart';
import 'package:scouting_app/theme/theme_provider.dart';
import 'package:scouting_app/utils/preferences.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AuthManager.init();
  await UserPreferences.init();
  runApp(const ScoutingApp());
}

class ScoutingApp extends StatelessWidget {
  const ScoutingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider();
    Future.delayed(const Duration(seconds: 2), () => FlutterNativeSplash.remove());
    return ChangeNotifierProvider(
      create: (context) => themeProvider,
      child: Consumer<ThemeProvider>(
        builder: (context, value, child) {
          return MaterialApp(
            title: 'Scouting App',
            debugShowCheckedModeBanner: false,
            theme: AppThemeOptions.lightTheme,
            darkTheme: AppThemeOptions.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: AuthManager.loggedIn ? '/home' : '/login',
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
            },
          );
        },
      ),
    );
  }
}
