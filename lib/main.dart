import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/game_code_screen.dart';
import 'features/game/providers/game_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  await Supabase.initialize(
    url: 'https://kesyrzyuflppgiskptik.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtlc3lyenl1ZmxwcGdpc2twdGlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM0NjA5NzAsImV4cCI6MjA3OTAzNjk3MH0.NRz2JwaSgKxoLkg1zFkW2FhmQSxwf3dtb8KNjFXMn9E',
  );

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const RiddleAlleyApp(),
    ),
  );
}

class RiddleAlleyApp extends ConsumerWidget {
  const RiddleAlleyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamId = ref.watch(teamIdProvider);

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
      home: teamId != null ? const GameScreen() : const GameCodeScreen(),
    );
  }
}
