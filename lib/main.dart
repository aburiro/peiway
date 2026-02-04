import 'package:flutter/material.dart';
import 'splash_screen.dart';
// Import other screens as you create them
// import 'screens/onboarding_screen.dart';
// import 'screens/login_screen.dart';
import "screens/discover_onboarding.dart";
import "screens/login_screen.dart";
import "screens/signup_screen.dart";

void main() {
  runApp(const PeiwayApp());
}

class PeiwayApp extends StatelessWidget {
  const PeiwayApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peiway',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Primary color scheme
        primaryColor: const Color(0xFF4DAF50),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4DAF50),
          brightness: Brightness.light,
        ),
        // Typography
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3C3C3B),
            fontFamily: 'Poppins',
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3C3C3B),
            fontFamily: 'Poppins',
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3C3C3B),
            fontFamily: 'Poppins',
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF3C3C3B),
            fontFamily: 'Poppins',
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF3C3C3B),
            fontFamily: 'Poppins',
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF3C3C3B),
            fontFamily: 'Poppins',
          ),
        ),
        // Button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4DAF50),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE8E7E7)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE8E7E7)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4DAF50), width: 2),
          ),
          hintStyle: TextStyle(
            color: const Color(0xFF3C3C3B).withOpacity(0.5),
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
        ),
        // App bar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4DAF50),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        // Scaffold background
        scaffoldBackgroundColor: Colors.white,
      ),
      // Routes configuration
      routes: {
        '/': (context) => const SplashScreen(),
        '/discover_onboarding': (context) => const DiscoverOnboarding(),
        '/login_screen': (context) => const LoginScreen(),
        '/signup_screen': (context) => const SignupScreen(),
      },
      initialRoute: '/',
    );
  }
}
