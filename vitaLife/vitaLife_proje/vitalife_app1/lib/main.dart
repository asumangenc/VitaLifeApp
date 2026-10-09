import 'package:flutter_localizations/flutter_localizations.dart'; // 1. Bu importu ekledik
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Proje klasör yapına göre import yollarını kontrol et
import 'screens/auth_screen.dart';
import 'screens/health_input_screen.dart';
import 'screens/home_screen.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VitaLifeApp());
}

class VitaLifeApp extends StatelessWidget {
  const VitaLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VitaLife',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.teal.withOpacity(0.05),
        ),
      ),

      // --- 2. TAKVİM HATASINI ÇÖZEN YERELLEŞTİRME AYARLARI ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'), // Türkçe desteği
        Locale('en', 'US'), // İngilizce desteği
      ],
      // -----------------------------------------------------

      home: const AuthScreen(),
    );
  }
}