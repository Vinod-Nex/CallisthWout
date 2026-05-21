import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/user_data.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigator.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final userData = await UserData.init();
  final prefs = await SharedPreferences.getInstance();
  final savedThemeIdx = prefs.getInt('theme_mode') ?? 0;
  final savedTheme = ThemeMode.values[savedThemeIdx];

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider(userData)),
        ChangeNotifierProvider(create: (_) => ThemeProvider(savedTheme)),
        Provider<UserData>.value(value: userData),
      ],
      child: CallisthWoutApp(userData: userData),
    ),
  );
}

class CallisthWoutApp extends StatelessWidget {
  final UserData userData;

  const CallisthWoutApp({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'CallisthWout',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Still connecting
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final user = snapshot.data;

          if (user == null) {
            // Not logged in → show login
            return const LoginScreen();
          }

          // Logged in → check onboarding
          if (!userData.hasOnboarded) {
            return const OnboardingScreen();
          }

          return const MainNavigator();
        },
      ),
    );
  }
}
