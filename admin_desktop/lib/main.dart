import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'application/routes/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    try {
      // Connect to emulators
      // 127.0.0.1 for Windows/Web, 10.0.2.2 for Android Emulator, localhost for iOS Simulator
      // Assuming this is running on Windows Desktop:
      const String host = '127.0.0.1';

      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
      FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
      print("Connected to Firebase Emulators");
    } catch (e) {
      print("Error connecting to emulators: $e");
    }
  }

  runApp(const ProviderScope(child: AdminDesktopApp()));
}

class AdminDesktopApp extends ConsumerWidget {
  const AdminDesktopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouter);

    return MaterialApp.router(
      title: 'Sistema Pizzería - Administración',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC87941),
          primary: const Color(0xFFC87941),
          surface: const Color(0xFFF9F9F9), // Lighter, cleaner surface
          onSurface: const Color(0xFF2D2D2D), // Darker text for contrast
          secondary: const Color(0xFFD4A373),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0, // Minimalist: no shadow by default
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFC87941), width: 1.5),
          ),
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          prefixIconColor: const Color(0xFFC87941),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFC87941),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            elevation: 0,
            textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFFC87941),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFC87941)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
          ),
        ),
        textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme)
            .apply(
              bodyColor: const Color(0xFF2D2D2D),
              displayColor: const Color(0xFF2D2D2D),
            ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Color(0xFF2D2D2D)),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC87941),
          brightness: Brightness.dark,
          surface: const Color(0xFF1E1E1E),
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: ThemeMode.light, // Force light for now or system
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'MX'), Locale('en', 'US')],
    );
  }
}
