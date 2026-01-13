import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart'; // untuk kReleaseMode
import 'package:flutter/material.dart';

import 'ui/splash_screen.dart';
import 'ui/home_screen.dart';
import 'ui/qr_generator_screen.dart';
import 'ui/qr_scanner_screen.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // mati otomatis saat build release
      defaultDevice: Devices.ios.iPhone11ProMax,
      devices: [
        Devices.ios.iPhone11ProMax,
      ],
      builder: (context) => const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Integrasi Device Preview (wajib ketiga baris ini)
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,

      debugShowCheckedModeBanner: false,
      title: 'QRODE - QR Generator & Scanner',

      // Tema global menggunakan Material 3
      theme: ThemeData(
        fontFamily: 'Manrope',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF553FB8), // warna brand utama
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
      ),

      // Routing sederhana dengan named routes
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/create': (context) => const QrGeneratorScreen(),
        '/scan': (context) => const QrScannerScreen(),
      },
    );
  }
}