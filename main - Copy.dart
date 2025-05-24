import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
// Screens
import '../LoginScreen.dart';
import 'screens/DashboardScreen.dart';
import 'screens/CartScreen.dart';
import 'screens/OrderHistoryScreen.dart';
import 'screens/InventoryScreen.dart';
import 'screens/SettingsScreen.dart';
import '../theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure Google Fonts to use local assets
  GoogleFonts.config.allowRuntimeFetching = false; // Disable runtime font fetching

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCTfSFM_38TRychUydMHbKXxgsbMWMAYI8",
        authDomain: "garoceryauth.firebaseapp.com",
        projectId: "garoceryauth",
        storageBucket: "garoceryauth.appspot.com",
        messagingSenderId: "864170297938",
        appId: "1:864170297938:web:xxxxxxxxxxxxxxxxxxxxxx", // Replace with real appId
      ),
    );
    runApp(const GroceryApp());
  } catch (e) {
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: Text('Firebase Initialization Failed: $e')),
      ),
    ));
  }
}

class GroceryApp extends StatelessWidget {
  const GroceryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Grocery Management System',
            theme: ThemeData(
              fontFamily: 'Poppins',
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFF0f2027),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              textTheme: GoogleFonts.poppinsTextTheme(),
              cardTheme: CardTheme(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF203a43),
                foregroundColor: Colors.white,
              ),
            ),
            darkTheme: ThemeData(
              fontFamily: 'Poppins',
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFF0f2027),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              textTheme: GoogleFonts.poppinsTextTheme(
                ThemeData.dark().textTheme,
              ),
              cardTheme: CardTheme(
                color: Colors.grey[850],
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF203a43),
                foregroundColor: Colors.white,
              ),
            ),
            themeMode: themeProvider.themeMode,
            home: const AuthWrapper(),
            routes: {
              '/cart': (context) => const CartScreen(),
              '/order-history': (context) => const OrderHistoryScreen(),
              '/inventory': (context) => const InventoryScreen(),
            },
          );
        },
      ),
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return DashboardScreen(); // Single instance of DashboardScreen
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}