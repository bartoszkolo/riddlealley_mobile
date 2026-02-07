class GameState {
  final String teamId;
  final String gameId;
  final String code;
  final int score;
  final DateTime startTime;
  final String? teamName;
  final String? avatarId;

  GameState({
    required this.teamId,
    required this.gameId,
    required this.code,
    required this.score,
    required this.startTime,
    this.teamName,
    this.avatarId,
  });

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      teamId: json['teamId'],
      gameId: json['gameId'],
      code: json['code'],
      score: json['score'] ?? 0,
      startTime: DateTime.parse(json['startTime']),
      teamName: json['teamName'],
      avatarId: json['avatarId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'gameId': gameId,
      'code': code,
      'score': score,
      'startTime': startTime.toIso8601String(),
      'teamName': teamName,
      'avatarId': avatarId,
    };
  }
}

class Team {
  final String id;
  final String gameId;
  final String codeUsed;
  final String? currentTaskId;
  final DateTime startTime;
  final DateTime? finishTime;
  final int score;
  final String? teamName;

  Team({
    required this.id,
    required this.gameId,
    required this.codeUsed,
    this.currentTaskId,
    required this.startTime,
    this.finishTime,
    this.score = 0,
    this.teamName,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      gameId: json['game_id'],
      codeUsed: json['code_used'],
      currentTaskId: json['current_task_id'],
      startTime: DateTime.parse(json['start_time']),
      finishTime: json['finish_time'] != null ? DateTime.parse(json['finish_time']) : null,
      score: json['score'] ?? 0,
      teamName: json['team_name'],
    );
  }
}
