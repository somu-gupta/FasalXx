import 'dart:typed_data';

import 'package:http_parser/http_parser.dart';

import '../core/network/api_client.dart';
import 'fasalx_api.dart';

class AuthRepository {
  const AuthRepository();

  Future<void> syncUser() async {
    await FasalxApi.main.post('/users/sync');
  }

  Future<Map<String, dynamic>> getProfile() async {
    final data = await FasalxApi.main.get('/users/me');
    return Map<String, dynamic>.from(data as Map);
  }

  Future<void> updateProfile(Map<String, dynamic> profile) async {
    await FasalxApi.main.post('/users/me', data: profile);
  }

  Future<void> logout() async {
    await FasalxApi.main.post('/users/logout');
  }

  Future<void> deactivate() async {
    await FasalxApi.main.post('/users/deactivate');
  }

  Future<void> deleteAccount() async {
    await FasalxApi.main.delete('/users/me');
  }

  Future<List<Map<String, dynamic>>> activities({
    int limit = 20,
    int offset = 0,
  }) async {
    final data = await FasalxApi.main.get(
      '/users/activities',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final activities = data is Map ? data['activities'] : data;
    return (activities as List? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }
}

class DashboardRepository {
  const DashboardRepository();

  Future<Map<String, bool>> visibility() async {
    final data = await FasalxApi.main.get('/dashboard/visibility');
    final map = Map<String, dynamic>.from(data as Map);
    final components = Map<String, dynamic>.from(map['components'] as Map);
    return components.map((key, value) => MapEntry(key, value == true));
  }
}

class GeoRepository {
  const GeoRepository();

  Future<Map<String, dynamic>> reverseGeocode({
    required double lat,
    required double lon,
  }) async {
    final data = await FasalxApi.main.post(
      '/geo/',
      data: {'lat': lat, 'lon': lon},
    );
    return Map<String, dynamic>.from(data as Map);
  }
}

class ChatbotReply {
  const ChatbotReply({required this.reply, this.model});

  final String reply;
  final String? model;
}

class ChatbotRepository {
  const ChatbotRepository();

  Future<ChatbotReply> sendMessage(String message) async {
    final data = await FasalxApi.main.post(
      '/chatbot/message',
      data: {'message': message},
    );
    final map = Map<String, dynamic>.from(data as Map);
    return ChatbotReply(
      reply: map['reply']?.toString() ?? 'No reply returned.',
      model: map['model']?.toString(),
    );
  }

  Future<Map<String, dynamic>> sendVoice({
    required Uint8List audioBytes,
    required String filename,
  }) async {
    final data = await FasalxApi.main.multipart(
      '/chatbot/voice',
      fields: const {},
      file: MultipartBytes(
        field: 'audio',
        filename: filename,
        bytes: audioBytes,
        contentType: _contentTypeFor(filename, fallback: 'audio/webm'),
      ),
    );
    return Map<String, dynamic>.from(data as Map);
  }
}

class DiseasePrediction {
  const DiseasePrediction({
    required this.disease,
    required this.confidence,
    required this.source,
    required this.raw,
  });

  final String disease;
  final double confidence;
  final String source;
  final Map<String, dynamic> raw;
}

class DiseaseRepository {
  const DiseaseRepository();

  Future<DiseasePrediction> predict({
    required String cropName,
    Uint8List? imageBytes,
    String? imageName,
    String? issueText,
  }) async {
    final data = await FasalxApi.main.multipart(
      '/disease/predict',
      fields: {
        'crop_name': cropName,
        if (issueText != null && issueText.trim().isNotEmpty)
          'issue_text': issueText.trim(),
      },
      file: imageBytes == null
          ? null
          : MultipartBytes(
              field: 'image',
              filename: imageName ?? 'leaf.jpg',
              bytes: imageBytes,
              contentType: _contentTypeFor(imageName ?? 'leaf.jpg'),
            ),
    );
    final map = Map<String, dynamic>.from(data as Map);
    return DiseasePrediction(
      disease: map['disease']?.toString() ?? 'Unknown issue',
      confidence: _asDouble(map['confidence']),
      source: map['source']?.toString() ?? 'api',
      raw: map,
    );
  }
}

class AgronomyRepository {
  const AgronomyRepository();

  Future<Map<String, dynamic>> weather({double? lat, double? lon}) async {
    final data = await FasalxApi.main.get(
      '/agronomy/weather',
      queryParameters: {'lat': lat, 'lon': lon},
    );
    return Map<String, dynamic>.from(data as Map);
  }

  Future<dynamic> mandiPrices({
    String? state,
    String? market,
    String? commodity,
  }) {
    return FasalxApi.main.get(
      '/agronomy/mandi-prices',
      queryParameters: {
        'state': state,
        'market': market,
        'commodity': commodity,
      },
    );
  }

  Future<List<Map<String, dynamic>>> templates() async {
    final data = await FasalxApi.main.get('/agronomy/templates');
    return (data as List? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<Map<String, dynamic>> createTemplate(
    Map<String, dynamic> template,
  ) async {
    final data = await FasalxApi.main.post(
      '/agronomy/templates',
      data: template,
    );
    return Map<String, dynamic>.from(data as Map);
  }
}

class FieldRepository {
  const FieldRepository();

  Future<List<Map<String, dynamic>>> listFields() async {
    final data = await FasalxApi.main.get('/fields/');
    return (data as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<Map<String, dynamic>> createField({
    required String name,
    required double lat,
    required double lon,
    required double area,
  }) async {
    final data = await FasalxApi.main.post(
      '/fields/',
      data: {'name': name, 'lat': lat, 'lon': lon, 'area': area},
    );
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> summary() async {
    final data = await FasalxApi.main.get('/fields/summary');
    return Map<String, dynamic>.from(data as Map);
  }
}

class RecommendationRepository {
  const RecommendationRepository();

  Future<Map<String, dynamic>> calculate({
    required String fieldId,
    String? targetSeason,
  }) async {
    final data = await FasalxApi.recommendation.post(
      '/recommend/calculate',
      data: {
        'field_id': fieldId,
        if (targetSeason != null) 'target_season': targetSeason,
      },
    );
    return Map<String, dynamic>.from(data as Map);
  }

  Future<void> select({
    required String fieldId,
    required String recommendationId,
    required String cropName,
  }) async {
    await FasalxApi.recommendation.post(
      '/recommend/select',
      data: {
        'field_id': fieldId,
        'recommendation_id': recommendationId,
        'crop_name': cropName,
      },
    );
  }
}

class FieldIntelligenceRepository {
  const FieldIntelligenceRepository();

  Future<Map<String, dynamic>> fetch({
    required double lat,
    required double lon,
    String? commodity,
  }) async {
    final data = await FasalxApi.recommendation.get(
      '/ingest/',
      queryParameters: {'lat': lat, 'lon': lon, 'commodity': commodity},
    );
    return Map<String, dynamic>.from(data as Map);
  }
}

class TimelineRepository {
  const TimelineRepository();

  Future<Map<String, dynamic>> getByUser(String userId) async {
    final data = await FasalxApi.timeline.get('/timeline/$userId');
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> request) async {
    final data = await FasalxApi.timeline.post('/timeline/', data: request);
    return Map<String, dynamic>.from(data as Map);
  }

  Future<void> syncIot({
    required String userId,
    required double tMax,
    required double tMin,
    required double soilMoisture,
  }) async {
    await FasalxApi.timeline.post(
      '/timeline/sync-iot',
      queryParameters: {
        'user_id': userId,
        't_max': tMax,
        't_min': tMin,
        'soil_moisture': soilMoisture,
      },
    );
  }

  Future<void> recalibrate({
    required String userId,
    required String milestoneName,
  }) async {
    await FasalxApi.timeline.patch(
      '/timeline/recalibrate',
      queryParameters: {
        'user_id': userId,
        'milestone_name': milestoneName,
      },
    );
  }
}

class TelemetryRepository {
  const TelemetryRepository();

  Future<void> ingest(Map<String, dynamic> payload) async {
    await FasalxApi.main.post('/telemetry/data', data: payload);
  }
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

MediaType _contentTypeFor(String filename, {String fallback = 'image/jpeg'}) {
  final lower = filename.toLowerCase();
  final value = lower.endsWith('.png')
      ? 'image/png'
      : lower.endsWith('.webp')
      ? 'image/webp'
      : lower.endsWith('.mp3')
      ? 'audio/mpeg'
      : lower.endsWith('.wav')
      ? 'audio/wav'
      : lower.endsWith('.m4a') || lower.endsWith('.mp4')
      ? 'audio/mp4'
      : lower.endsWith('.ogg')
      ? 'audio/ogg'
      : lower.endsWith('.aac')
      ? 'audio/aac'
      : lower.endsWith('.flac')
      ? 'audio/flac'
      : lower.endsWith('.webm')
      ? 'audio/webm'
      : fallback;
  return MediaType.parse(value);
}
