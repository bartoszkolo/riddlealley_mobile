import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GameCodeScreen extends StatefulWidget {
  const GameCodeScreen({super.key});

  @override
  State<GameCodeScreen> createState() => _GameCodeScreenState();
}

class _GameCodeScreenState extends State<GameCodeScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submitCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Please enter a mission code');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Direct call to Supabase Edge Function or Table to validate code
      // Assuming a 'check_code' function or simple query
      // For now, mirroring PWA logic if it was available, but here we'll assume
      // we check against a table 'game_codes' or similar, OR just a stub for now.

      // REAL IMPLEMENTATION STUB:
      /*
      final response = await Supabase.instance.client
          .from('games')
          .select()
          .eq('access_code', code) // hypothetical column
          .maybeSingle();
      */

      // Since I don't see the exact backend logic for code validation in the PWA files I read yet
      // (it was likely in an API route I didn't deep dive into), I'll keep the logic generic
      // but ready for the real table name.

      await Future.delayed(const Duration(milliseconds: 800)); // Network sim

      // Temporary logic until you confirm table structure for codes
      if (code.length > 3) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Connecting to mission...'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to Map/Game Screen
        }
      } else {
        throw 'Invalid mission code format';
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // RiddleAlley Theme Colors
    const neonRed = Color(0xFFFF0040);
    const bgDark = Color(0xFF0F172A); // Slate 950 roughly
    const bgCard = Color(0xFF1E293B); // Slate 800

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo / Title area
              Center(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                    children: const [
                      TextSpan(text: 'RIDDLE'),
                      TextSpan(
                        text: 'ALLEY',
                        style: TextStyle(color: neonRed),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter your mission code to begin',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),

              // Code Input
              Container(
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _error != null ? neonRed : Colors.white10,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextField(
                  controller: _codeController,
                  style: GoogleFonts.jetbrainsMono(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'CODE',
                    hintStyle: TextStyle(
                      color: Colors.white24,
                      letterSpacing: 4,
                    ),
                  ),
                  onSubmitted: (_) => _submitCode(),
                ),
              ),

              // Error Message
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: neonRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ] else
                const SizedBox(height: 16),

              const SizedBox(height: 32),

              // Action Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: neonRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'START MISSION',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
