import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/game_code_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kesyrzyuflppgiskptik.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtlc3lyenl1ZmxwcGdpc2twdGlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM0NjA5NzAsImV4cCI6MjA3OTAzNjk3MH0.NRz2JwaSgKxoLkg1zFkW2FhmQSxwf3dtb8KNjFXMn9E',
  );

  runApp(
    const ProviderScope(
      child: RiddleAlleyApp(),
    ),
  );
}

class RiddleAlleyApp extends StatelessWidget {
  const RiddleAlleyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RiddleAlley',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF0040), // Neon Red
          brightness: Brightness.dark,
          surface: const Color(0xFF0F172A), // Slate 950
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const GameCodeScreen(),
    );
  }
}
