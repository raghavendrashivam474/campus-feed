import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'utils/constants.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Feed',
      debugShowCheckedModeBanner: false,
      
      // 🎨 COMPLETE THEME CONFIGURATION
      theme: ThemeData(
        // Primary Colors
        primaryColor: AppConstants.primaryPurple,
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        
        // Color Scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryPurple,
          primary: AppConstants.primaryPurple,
          secondary: AppConstants.lightPurple,
          surface: AppConstants.cardColor,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppConstants.textPrimary,
        ),
        
        // Text Theme
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 17,
            color: AppConstants.textPrimary,
            height: 1.6,
          ),
          bodyMedium: TextStyle(
            fontSize: 15,
            color: AppConstants.textPrimary,
          ),
          bodySmall: TextStyle(
            fontSize: 13,
            color: AppConstants.textSecondary,
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            color: AppConstants.textLight,
          ),
        ),
        
        // Card Theme - FIXED
        cardTheme: CardThemeData(
          color: AppConstants.cardColor,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        
        // AppBar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.primaryPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        // Floating Action Button Theme
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppConstants.primaryPurple,
          foregroundColor: Colors.white,
          elevation: 8,
        ),
        
        // Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryPurple,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Text Button Theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppConstants.primaryPurple,
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppConstants.primaryPurple,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        
        // Dialog Theme - FIXED
        dialogTheme: DialogThemeData(
          backgroundColor: AppConstants.cardColor,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
          ),
          contentTextStyle: const TextStyle(
            fontSize: 15,
            color: AppConstants.textSecondary,
          ),
        ),
        
        // Snackbar Theme
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppConstants.textPrimary,
          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        
        // Progress Indicator Theme
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppConstants.primaryPurple,
        ),
        
        // Divider Theme
        dividerTheme: DividerThemeData(
          color: AppConstants.textLight.withValues(alpha: 0.2),
          thickness: 1,
        ),
        
        useMaterial3: true,
      ),
      
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppConstants.backgroundColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryPurple.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 64,
                      color: AppConstants.primaryPurple,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Campus Feed',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryPurple,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const CircularProgressIndicator(
                    color: AppConstants.primaryPurple,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Loading...',
                    style: TextStyle(
                      color: AppConstants.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // User logged in - go to home
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }

        // Not logged in - show login
        return const LoginScreen();
      },
    );
  }
}