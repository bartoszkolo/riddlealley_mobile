import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/task_model.dart';
import '../../../shared/models/game_models.dart';
import '../../../shared/providers/supabase_provider.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final teamIdProvider = StateProvider<String?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString('riddle_team_id');
});

class GameStateData {
  final Team? team;
  final Task? activeTask;
  final bool isLoading;
  final String? error;
  final bool isGameFinished;

  GameStateData({
    this.team,
    this.activeTask,
    this.isLoading = false,
    this.error,
    this.isGameFinished = false,
  });

  GameStateData copyWith({
    Team? team,
    Task? activeTask,
    bool? isLoading,
    String? error,
    bool? isGameFinished,
  }) {
    return GameStateData(
      team: team ?? this.team,
      activeTask: activeTask ?? this.activeTask,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isGameFinished: isGameFinished ?? this.isGameFinished,
    );
  }
}

class GameNotifier extends StateNotifier<GameStateData> {
  final SupabaseClient _supabase;
  final Ref _ref;

  GameNotifier(this._supabase, this._ref) : super(GameStateData(isLoading: true)) {
    loadInitialState();
  }

  Future<void> loadInitialState() async {
    final teamId = _ref.read(teamIdProvider);
    if (teamId == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      // 1. Fetch Team
      final teamRes = await _supabase
          .from('teams')
          .select()
          .eq('id', teamId)
          .single();
      
      final team = Team.fromJson(teamRes);

      if (team.finishTime != null) {
        state = state.copyWith(team: team, isGameFinished: true, isLoading: false);
        return;
      }

      // 2. Fetch Active Task
      if (team.currentTaskId != null) {
        final taskRes = await _supabase
            .from('tasks')
            .select()
            .eq('id', team.currentTaskId!)
            .single();
        
        final task = Task.fromJson(taskRes);
        state = state.copyWith(team: team, activeTask: task, isLoading: false);
      } else {
        state = state.copyWith(team: team, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> completeTask(String answer, int points) async {
    final currentTeam = state.team;
    final currentTask = state.activeTask;
    if (currentTeam == null || currentTask == null) return;

    try {
      state = state.copyWith(isLoading: true);

      // 1. Find next task
      final nextTaskRes = await _supabase
          .from('tasks')
          .select('id')
          .eq('game_id', currentTeam.gameId)
          .gt('order_index', currentTask.orderIndex)
          .order('order_index', ascending: true)
          .limit(1)
          .maybeSingle();

      final nextTaskId = nextTaskRes?['id'];

      // 2. Update Team in DB
      final updates = {
        'score': currentTeam.score + points,
        'current_task_id': nextTaskId,
      };

      if (nextTaskId == null) {
        updates['finish_time'] = DateTime.now().toIso8601String();
      }

      await _supabase.from('teams').update(updates).eq('id', currentTeam.id);

      // 3. Refresh State
      if (nextTaskId == null) {
        state = state.copyWith(
          isGameFinished: true,
          isLoading: false,
          team: Team.fromJson({
            ...currentTeam.toJsonForUpdate(),
            'score': currentTeam.score + points,
            'finish_time': updates['finish_time'],
          }),
        );
      } else {
        await loadInitialState();
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

extension TeamExt on Team {
  Map<String, dynamic> toJsonForUpdate() {
    return {
      'id': id,
      'game_id': gameId,
      'code_used': codeUsed,
      'current_task_id': currentTaskId,
      'start_time': startTime.toIso8601String(),
      'finish_time': finishTime?.toIso8601String(),
      'score': score,
      'team_name': teamName,
    };
  }
}

final gameStateProvider = StateNotifierProvider<GameNotifier, GameStateData>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return GameNotifier(supabase, ref);
});
