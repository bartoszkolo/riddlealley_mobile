import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/task_model.dart';
import '../../shared/widgets/app_drawer.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  Task? _currentTask;
  bool _isLoading = true;
  String? _error;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _fetchCurrentTask();
  }

  Future<void> _fetchCurrentTask() async {
    try {
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

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgDark,
      endDrawer: const AppDrawer(), // Hamburger Menu Content
      body: Stack(
        children: [
          // Background
          Positioned.fill(
             child: Opacity(
               opacity: 0.05,
               child: Image.asset('assets/images/grid_pattern.png', repeat: ImageRepeat.repeat, errorBuilder: (_,__,___) => const SizedBox()), 
             ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Navbar (Custom AppBar)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      // Logo
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 20,
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
                      const Spacer(),
                      // Hamburger Icon
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                        onPressed: () {
                          _scaffoldKey.currentState?.openEndDrawer();
                        },
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: _buildContent(neonRed),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Color neonRed) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: neonRed));
    }

    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }

    if (_currentTask == null) {
      return const Center(child: Text("No Task Data"));
    }

    return Column(
      children: [
        // Task Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.8),
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

        const SizedBox(height: 16),

        // Task Description
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
        
        // Bottom Action Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: () {}, 
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
                    "CHECK ANSWER",
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
    );
  }

  String _getLocalizedText(Map<String, dynamic> jsonb) {
    return jsonb['pl'] ?? jsonb['en'] ?? jsonb.values.firstOrNull ?? '';
  }
}
