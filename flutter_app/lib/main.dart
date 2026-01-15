import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AutoARMaskApp());
}

class AutoARMaskApp extends StatelessWidget {
  const AutoARMaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoARMask Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        primaryColor: const Color(0xFFE53935),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFE53935),
          secondary: const Color(0xFFFF1744),
          surface: const Color(0xFF1A1A1A),
          background: const Color(0xFF0A0A0A),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
        ),
        textTheme: GoogleFonts.rajdhaniTextTheme(
          ThemeData.dark().textTheme,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      home: const HomeScreen(),
    );
  }
}
