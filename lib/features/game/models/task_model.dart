// lib/features/game/models/task_model.dart

class Task {
  final String id;
  final String gameId;
  final int orderIndex;
  final String taskType;
  final Map<String, dynamic> title; // JSONB
  final Map<String, dynamic> description; // JSONB
  final Map<String, dynamic> contentData; // JSONB
  final double? locationLat;
  final double? locationLng;
  final int radiusMeters;
  final bool showMap;
  final String? mysteryImageUrl;

  Task({
    required this.id,
    required this.gameId,
    required this.orderIndex,
    required this.taskType,
    required this.title,
    required this.description,
    required this.contentData,
    this.locationLat,
    this.locationLng,
    this.radiusMeters = 50,
    this.showMap = true,
    this.mysteryImageUrl,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      gameId: json['game_id'],
      orderIndex: json['order_index'],
      taskType: json['task_type'],
      title: json['title'] ?? {},
      description: json['description'] ?? {},
      contentData: json['content_data'] ?? {},
      locationLat: json['location_lat']?.toDouble(),
      locationLng: json['location_lng']?.toDouble(),
      radiusMeters: json['radius_meters'] ?? 50,
      showMap: json['show_map'] ?? true,
      mysteryImageUrl: json['mystery_image_url'],
    );
  }
}
