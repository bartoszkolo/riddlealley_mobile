import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/game_provider.dart';
import 'widgets/game_hud.dart';
import '../../../shared/models/task_model.dart';
import '../../shared/widgets/app_drawer.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String _lang = 'pl'; // Should be from a provider later

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    const bgDark = Color(0xFF0F172A);

    if (gameState.isLoading) {
      return const Scaffold(
        backgroundColor: bgDark,
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFF0040))),
      );
    }

    if (gameState.error != null) {
      return Scaffold(
        backgroundColor: bgDark,
        body: Center(child: Text(gameState.error!, style: const TextStyle(color: Colors.red))),
      );
    }

    if (gameState.isGameFinished) {
      return _buildCompletionScreen(gameState);
    }

    final activeTask = gameState.activeTask;
    if (activeTask == null) {
      return const Scaffold(
        backgroundColor: bgDark,
        body: Center(child: Text("NO ACTIVE MISSION", style: TextStyle(color: Colors.white54))),
      );
    }

    // Determine view: Map or Task
    final bool showMap = activeTask.taskType == 'NAVIGATE';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgDark,
      endDrawer: const AppDrawer(),
      body: Column(
        children: [
          GameHUD(
            score: gameState.team?.score ?? 0,
            stageTitle: getLocalizedText(activeTask.title, _lang),
            distance: showMap ? ref.watch(distanceProvider(LatLng(activeTask.locationLat ?? 0, activeTask.locationLng ?? 0))) : null,
            onMenuClick: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
          Expanded(
            child: showMap ? _buildMapView(activeTask) : _buildTaskView(activeTask),
          ),
        ],
      ),
    );
  }

import 'package:latlong2/latlong2.dart';
import '../../../shared/providers/location_provider.dart';
import 'widgets/game_map_widget.dart';
import 'widgets/qr_task_widget.dart';
import 'widgets/abcd_task_widget.dart';

// ... inside _GameScreenState class ...

  Widget _buildMapView(Task task) {
    final target = LatLng(task.locationLat ?? 0, task.locationLng ?? 0);
    final distance = ref.watch(distanceProvider(target));
    final bool isAtTarget = distance != null && distance <= (task.radiusMeters ?? 50);

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GameMapWidget(
              targetLat: task.locationLat ?? 0,
              targetLng: task.locationLng ?? 0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            height: 80,
            child: ElevatedButton(
              onPressed: isAtTarget 
                ? () => ref.read(gameStateProvider.notifier).completeTask('ARRIVED', 50)
                : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAtTarget ? Colors.emerald : Colors.white10,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: isAtTarget 
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 32),
                      SizedBox(width: 12),
                      Text("GO TO MISSION", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("APPROACH THE TARGET", style: TextStyle(fontSize: 12, color: Colors.white54)),
                      Text("${distance?.round() ?? '...'} M REMAINING", 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
            ),
          ),
        ),
      ],
    );
  }

import 'widgets/qr_task_widget.dart';
import 'widgets/abcd_task_widget.dart';

// ... inside _GameScreenState class ...

  Widget _buildTaskView(Task task) {
    final onComplete = ref.read(gameStateProvider.notifier).completeTask;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            getLocalizedText(task.description, _lang),
            style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 32),
          
          if (task.taskType == 'QR_SCAN')
            SizedBox(
              height: 400,
              child: QrTaskWidget(
                expectedValue: task.contentData.qrCodeValue ?? '',
                onComplete: onComplete,
              ),
            )
          else if (task.taskType == 'ABCD')
            AbcdTaskWidget(
              options: task.contentData.options ?? [],
              onComplete: onComplete,
              lang: _lang,
            )
          else
            // Fallback for Riddle/Text
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                hintText: "Enter Answer...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (val) => onComplete(val, 100),
            ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen(GameStateData state) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 100, color: Colors.amber),
            const SizedBox(height: 24),
            const Text("MISSION ACCOMPLISHED", 
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("SCORE: ${state.team?.score}", style: const TextStyle(color: Colors.amber, fontSize: 32)),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                // Reset or Logout
              },
              child: const Text("FINISH"),
            )
          ],
        ),
      ),
    );
  }
}