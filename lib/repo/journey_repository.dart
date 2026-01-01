// journey_repository.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../model/journey_model.dart';

class JourneyRepository {
  final String baseUrl;
  final http.Client _client;

  JourneyRepository({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Save a journey to backend (create or update).
  Future<Journey> saveJourney(Journey journey) async {
    final url = Uri.parse('$baseUrl/journeys');
    // You can make it POST for create, PUT for update depending on id.

    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(journey.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Journey.fromJson(data);
    } else {
      throw Exception(
        'Failed to save journey (status: ${response.statusCode}): ${response.body}',
      );
    }
  }

  /// Fetch list of journeys (e.g., history)
  Future<List<Journey>> fetchJourneys({int page = 1, int limit = 20}) async {
    final url = Uri.parse('$baseUrl/journeys?page=$page&limit=$limit');

    final response = await _client.get(url);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((item) => Journey.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Failed to fetch journeys (status: ${response.statusCode}): ${response.body}',
      );
    }
  }

  /// Optionally: fetch single journey by id
  Future<Journey> fetchJourneyById(String id) async {
    final url = Uri.parse('$baseUrl/journeys/$id');

    final response = await _client.get(url);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Journey.fromJson(data);
    } else {
      throw Exception(
        'Failed to fetch journey (status: ${response.statusCode}): ${response.body}',
      );
    }
  }
}
