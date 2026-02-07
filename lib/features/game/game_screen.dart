import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/task_model.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  Task? _currentTask;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCurrentTask();
  }

  Future<void> _fetchCurrentTask() async {
    // Assumption: we stored teamId somewhere or can get it from session
    // For now, fetching the *first* active team found for this device/user
    // In a real app, use a proper Auth Provider.
    
    // Placeholder logic for prototype: fetch 'demo' or last used team
    try {
      // 1. Get Team (Assuming we just created one or have one in storage)
      // Real impl: LocalStorage.getItem('team_id')
      
      // MOCK: Fetch a task for demo purposes if no team logic yet
      // final taskData = await Supabase.instance.client.from('tasks').select().limit(1).single();
      
      // Let's rely on the real flow. If we came from Auth, we have a session? 
      // The previous screen didn't save teamId globally. 
      // Let's refetch active team using a known method or handle loading state.
      
      // Temporary: Just load *any* task to show UI
      final response = await Supabase.instance.client
          .from('tasks')
          .select()
          .limit(1)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _currentTask = Task.fromJson(response);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "No tasks found in DB";
          _isLoading = false;
        });
      }

    } catch (e) {
       setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgDark = Color(0xFF0F172A);
    const neonRed = Color(0xFFFF0040);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: bgDark,
        body: Center(child: CircularProgressIndicator(color: neonRed)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: bgDark,
        body: Center(child: Text(_error!, style: const TextStyle(color: Colors.red))),
      );
    }

    if (_currentTask == null) {
      return const Scaffold(
         backgroundColor: bgDark,
         body: Center(child: Text("No Task Data")),
      );
    }

    // Task View UI (Mirroring PWA)
    return Scaffold(
      backgroundColor: bgDark,
      body: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
             child: Opacity(
               opacity: 0.05,
               child: Image.asset('assets/images/grid_pattern.png', repeat: ImageRepeat.repeat, errorBuilder: (_,__,___) => const SizedBox()), // Placeholder
             ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header (Task Type + Title)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.8), // Glass-like
                      borderRadius: BorderRadius.circular(24),
                      border: Border(top: BorderSide(color: neonRed.withOpacity(0.3))),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _currentTask!.taskType.replaceAll('_', ' '),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white54,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getLocalizedText(_currentTask!.title),
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content (Description)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _getLocalizedText(_currentTask!.description),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Bottom Actions
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: () {}, // Submit logic placeholder
                      style: ElevatedButton.styleFrom(
                        backgroundColor: neonRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 8,
                        shadowColor: neonRed.withOpacity(0.4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           Text(
                            "CHECK ANSWER", // TODO: Localize
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper to get text for current locale (defaulting to 'en')
  String _getLocalizedText(Map<String, dynamic> jsonb) {
    // Simple fallback logic
    return jsonb['pl'] ?? jsonb['en'] ?? jsonb.values.firstOrNull ?? '';
  }
}
