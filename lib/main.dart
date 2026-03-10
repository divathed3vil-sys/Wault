// lib/main.dart
// WAult — Multi-instance WhatsApp Web client by DIVA.
// Entry point. Sets up theme, routes, and orientation lock.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/wault_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait only for V1
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar, dark nav bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: WaultColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const WaultApp());
}

class WaultApp extends StatelessWidget {
  const WaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WAult',
      debugShowCheckedModeBanner: false,
      theme: WaultTheme.dark,
      home: const SplashScreen(),
    );
  }
}
