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
  AuthStep _currentStep = AuthStep.enterCode;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _verifiedCodeData;
  final _codeController = TextEditingController();
  final _teamNameController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _teamNameController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() { _isLoading = true; _error = null; });

    try {
      final supabase = ref.read(supabaseClientProvider);
      final response = await supabase.from('access_codes').select().eq('code', code).maybeSingle();
      if (response == null) throw 'Invalid access code';
      final data = response as Map<String, dynamic>;
      if (data['status'] == 'expired') throw 'This code has expired';
      setState(() { _verifiedCodeData = data; _currentStep = AuthStep.enterTeamName; });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createTeam() async {
    final teamName = _teamNameController.text.trim();
    if (teamName.isEmpty) return;
    setState(() { _isLoading = true; _error = null; });

    try {
      final supabase = ref.read(supabaseClientProvider);
      final taskRes = await supabase.from('tasks').select('id').eq('game_id', _verifiedCodeData!['game_id']).order('order_index').limit(1).maybeSingle();
      if (taskRes == null) throw 'No tasks found';

      final teamRes = await supabase.from('teams').insert({
        'game_id': _verifiedCodeData!['game_id'],
        'code_used': _verifiedCodeData!['code'],
        'current_task_id': taskRes['id'],
        'start_time': DateTime.now().toIso8601String(),
        'team_name': teamName,
      }).select().single();

      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString('riddle_team_id', teamRes['id']);
      ref.read(teamIdProvider.notifier).state = teamRes['id'];

      if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const GameScreen()));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Text("RIDDLE ALLEY", style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w900, color: const Color(0xFFFF0040)))),
              const SizedBox(height: 48),
              _currentStep == AuthStep.enterCode ? _buildInput("ENTER CODE", _codeController, _verifyCode) : _buildInput("TEAM NAME", _teamNameController, _createTeam),
              if (_error != null) Padding(padding: const EdgeInsets.all(8.0), child: Text(_error!, style: const TextStyle(color: Colors.red))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, VoidCallback onSub) {
    return Column(children: [
      Text(label, style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
      TextField(controller: ctrl, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, color: Colors.white)),
      const SizedBox(height: 20),
      ElevatedButton(onPressed: _isLoading ? null : onSub, child: _isLoading ? const CircularProgressIndicator() : const Text("CONTINUE")),
    ]);
  }
}