import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/providers/supabase_provider.dart';
import '../game/providers/game_provider.dart';
import '../game/game_screen.dart';

class GameCodeScreen extends ConsumerStatefulWidget {
  const GameCodeScreen({super.key});

  @override
  ConsumerState<GameCodeScreen> createState() => _GameCodeScreenState();
}

enum AuthStep { enterCode, enterTeamName }

class _GameCodeScreenState extends ConsumerState<GameCodeScreen> {
  // State
  AuthStep _currentStep = AuthStep.enterCode;
  bool _isLoading = false;
  String? _error;

  // Data
  Map<String, dynamic>? _verifiedCodeData;

  // Controllers
  final _codeController = TextEditingController();
  final _teamNameController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _teamNameController.dispose();
    super.dispose();
  }

  // --- Logic: Phase 1 (Verify Code) ---
  Future<void> _verifyCode() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final supabase = ref.read(supabaseClientProvider);
      final response = await supabase
          .from('access_codes')
          .select()
          .eq('code', code)
          .maybeSingle();

      if (response == null) {
        throw 'Invalid access code';
      }

      final data = response as Map<String, dynamic>;

      // Check status
      if (data['status'] == 'expired') {
        throw 'This code has expired';
      }

      // Check 24h expiration logic if activated
      if (data['activated_at'] != null) {
        final activatedAt = DateTime.parse(data['activated_at']);
        final now = DateTime.now();
        final difference = now.difference(activatedAt);
        if (difference.inHours > 24) {
          throw 'Code expired (24h limit reached)';
        }
      }

      setState(() {
        _verifiedCodeData = data;
        _currentStep = AuthStep.enterTeamName;
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- Logic: Phase 2 (Create Team) ---
  Future<void> _createTeam() async {
    final teamName = _teamNameController.text.trim();
    if (teamName.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final supabase = ref.read(supabaseClientProvider);
      final gameId = _verifiedCodeData!['game_id'];
      final code = _verifiedCodeData!['code'];

      // 1. Fetch first task
      final taskResponse = await supabase
          .from('tasks')
          .select('id')
          .eq('game_id', gameId)
          .order('order_index', ascending: true)
          .limit(1)
          .maybeSingle();

      if (taskResponse == null) {
        throw 'Game configuration error: No tasks found';
      }

      final firstTaskId = taskResponse['id'];

      // 2. Create Team
      final teamResponse = await supabase
          .from('teams')
          .insert({
            'game_id': gameId,
            'code_used': code,
            'current_task_id': firstTaskId,
            'start_time': DateTime.now().toIso8601String(),
            'team_name': teamName,
          })
          .select()
          .single();

      // 3. Mark code as activated (if not already)
      if (_verifiedCodeData!['activated_at'] == null) {
        await supabase
            .from('access_codes')
            .update({'activated_at': DateTime.now().toIso8601String()})
            .eq('code', code);
      }

      // 4. Save to SharedPreferences
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString('riddle_team_id', teamResponse['id']);
      
      // Update teamIdProvider state
      ref.read(teamIdProvider.notifier).state = teamResponse['id'];

      // 5. Navigate to Game
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const GameScreen()),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    const neonRed = Color(0xFFFF0040);
    const bgDark = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
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
              const SizedBox(height: 48),

              // Steps
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _currentStep == AuthStep.enterCode
                    ? _buildCodeInput(neonRed)
                    : _buildTeamInput(neonRed),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeInput(Color accentColor) {
    return Column(
      key: const ValueKey('code_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'ENTER MISSION CODE',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: Colors.white54,
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _error != null ? accentColor : Colors.white10,
            ),
          ),
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
              hintStyle: TextStyle(color: Colors.white24),
            ),
            onSubmitted: (_) => _verifyCode(),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
          ),
        ],
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _isLoading ? null : _verifyCode,
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('VERIFY CODE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        ),
      ],
    );
  }

  Widget _buildTeamInput(Color accentColor) {
    return Column(
      key: const ValueKey('team_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'TEAM NAME',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: Colors.white54,
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _error != null ? accentColor : Colors.white10,
            ),
          ),
          child: TextField(
            controller: _teamNameController,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter name...',
              hintStyle: TextStyle(color: Colors.white24),
            ),
            onSubmitted: (_) => _createTeam(),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
          ),
        ],
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _isLoading ? null : _createTeam,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.emerald,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('START MISSION', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() {
              _currentStep = AuthStep.enterCode;
              _error = null;
              _teamNameController.clear();
            });
          },
          child: const Text('Back', style: TextStyle(color: Colors.white54)),
        ),
      ],
    );
  }
}
