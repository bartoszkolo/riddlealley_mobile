import 'dart:convert';

typedef LocalizedText = dynamic;

String getLocalizedText(LocalizedText text, String lang) {
  if (text is String) return text;
  if (text is Map) {
    return text[lang] ?? text['en'] ?? text.values.firstOrNull?.toString() ?? '';
  }
  return '';
}

class Hint {
  final LocalizedText text;
  final int cost;

  Hint({required this.text, required this.cost});

  factory Hint.fromJson(Map<String, dynamic> json) {
    return Hint(
      text: json['text'],
      cost: json['cost'] ?? 0,
    );
  }
}

class TaskContent {
  final String? imageUrl;
  final List<String>? imageUrls;
  final String? audioUrl;
  final String? videoUrl;
  final LocalizedText? correctAnswer;
  final String? answerHash;
  final int? pointsReward;
  final List<Hint>? hints;
  final List<Map<String, dynamic>>? promptBlocks;
  final List<LocalizedText>? options;
  final bool? optionsAreImages;
  final int? timeLimitSeconds;
  final LocalizedText? systemPrompt;
  final String? secretPassword;
  final LocalizedText? initialMessage;
  final String? qrCodeValue;
  final LocalizedText? targetDescription;
  final LocalizedText? callerName;
  final List<String>? items;
  final List<String>? correctOrder;
  final LocalizedText? senderName;
  final LocalizedText? customSuccessMessage;
  final LocalizedText? customErrorMessage;
  final LocalizedText? customSuccessButton;
  final LocalizedText? customErrorButton;

  TaskContent({
    this.imageUrl,
    this.imageUrls,
    this.audioUrl,
    this.videoUrl,
    this.correctAnswer,
    this.answerHash,
    this.pointsReward,
    this.hints,
    this.promptBlocks,
    this.options,
    this.optionsAreImages,
    this.timeLimitSeconds,
    this.systemPrompt,
    this.secretPassword,
    this.initialMessage,
    this.qrCodeValue,
    this.targetDescription,
    this.callerName,
    this.items,
    this.correctOrder,
    this.senderName,
    this.customSuccessMessage,
    this.customErrorMessage,
    this.customSuccessButton,
    this.customErrorButton,
  });

  factory TaskContent.fromJson(Map<String, dynamic> json) {
    return TaskContent(
      imageUrl: json['image_url'],
      imageUrls: json['image_urls'] != null ? List<String>.from(json['image_urls']) : null,
      audioUrl: json['audio_url'],
      videoUrl: json['video_url'],
      correctAnswer: json['correct_answer'],
      answerHash: json['answer_hash'],
      pointsReward: json['points_reward'],
      hints: json['hints'] != null ? (json['hints'] as List).map((h) => Hint.fromJson(h)).toList() : null,
      promptBlocks: json['prompt_blocks'] != null ? List<Map<String, dynamic>>.from(json['prompt_blocks']) : null,
      options: json['options'] != null ? List<LocalizedText>.from(json['options']) : null,
      optionsAreImages: json['options_are_images'],
      timeLimitSeconds: json['time_limit_seconds'],
      systemPrompt: json['system_prompt'],
      secretPassword: json['secret_password'],
      initialMessage: json['initial_message'],
      qrCodeValue: json['qr_code_value'],
      targetDescription: json['target_description'],
      callerName: json['caller_name'],
      items: json['items'] != null ? List<String>.from(json['items']) : null,
      correctOrder: json['correct_order'] != null ? List<String>.from(json['correct_order']) : null,
      senderName: json['sender_name'],
      customSuccessMessage: json['custom_success_message'],
      customErrorMessage: json['custom_error_message'],
      customSuccessButton: json['custom_success_button'],
      customErrorButton: json['custom_error_button'],
    );
  }
}

class Task {
  final String id;
  final String taskType;
  final LocalizedText title;
  final LocalizedText description;
  final TaskContent contentData;
  final int orderIndex;
  final String gameId;
  final double? locationLat;
  final double? locationLng;
  final double? radiusMeters;
  final bool? showMap;
  final String? mysteryImageUrl;

  Task({
    required this.id,
    required this.taskType,
    required this.title,
    required this.description,
    required this.contentData,
    required this.orderIndex,
    required this.gameId,
    this.locationLat,
    this.locationLng,
    this.radiusMeters,
    this.showMap,
    this.mysteryImageUrl,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      taskType: json['task_type'],
      title: json['title'],
      description: json['description'],
      contentData: TaskContent.fromJson(json['content_data'] ?? {}),
      orderIndex: json['order_index'] ?? 0,
      gameId: json['game_id'],
      locationLat: json['location_lat']?.toDouble(),
      locationLng: json['location_lng']?.toDouble(),
      radiusMeters: json['radius_meters']?.toDouble(),
      showMap: json['show_map'],
      mysteryImageUrl: json['mystery_image_url'],
    );
  }
}
