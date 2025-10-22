import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  final String _base = "https://api.weatherapi.com/v1";
  final String _key = dotenv.env['WEATHER_API_KEY'] ?? "";

  // Simple in-memory cache: key -> JSON decoded map
  final Map<String, dynamic> _cache = {};

  Future<Map<String, dynamic>> _get(String path, Map<String, String> params,
      {bool forceRefresh = false}) async {
    params['key'] = _key;
    final uri = Uri.parse("$_base/$path").replace(queryParameters: params);
    final cacheKey = uri.toString();

    if (!forceRefresh && _cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as Map<String, dynamic>;
    }

    final resp = await http.get(uri).timeout(const Duration(seconds: 15));
    if (resp.statusCode != 200) {
      // Try decode error body, otherwise throw a readable exception
      try {
        final body = jsonDecode(resp.body);
        throw Exception(body['error']?['message'] ?? 'API error ${resp.statusCode}');
      } catch (e) {
        throw Exception('API error ${resp.statusCode}');
      }
    }

    final Map<String, dynamic> decoded = jsonDecode(resp.body);
    _cache[cacheKey] = decoded;
    return decoded;
  }

  /// Current weather
  Future<Map<String, dynamic>> getCurrent(String q,
      {bool forceRefresh = false}) {
    return _get('current.json', {'q': q}, forceRefresh: forceRefresh);
  }

  /// Marine weather
  Future<Map<String, dynamic>> getMarine(String q,
      {bool forceRefresh = false}) {
    return _get('marine.json', {'q': q}, forceRefresh: forceRefresh);
  }

  /// Future weather for a specific date (yyyy-MM-dd) - WeatherAPI supports dt param
  Future<Map<String, dynamic>> getFuture(String q, String date,
      {bool forceRefresh = false}) {
    return _get('future.json', {'q': q, 'dt': date}, forceRefresh: forceRefresh);
  }

  /// Forecast (days up to 14 via forecast.json)
  Future<Map<String, dynamic>> getForecast(String q, int days,
      {bool forceRefresh = false, bool includeAlerts = false}) {
    final params = {'q': q, 'days': days.toString(), 'alerts': includeAlerts ? 'yes' : 'no'};
    return _get('forecast.json', params, forceRefresh: forceRefresh);
  }

  /// call getFuture repeatedly but be mindful of API quotas.
  Future<List<Map<String, dynamic>>> getFutureRange(
      String q, List<String> dates,
      {bool forceRefresh = false}) async {
    final results = <Map<String, dynamic>>[];
    for (final d in dates) {
      final data = await getFuture(q, d, forceRefresh: forceRefresh);
      results.add(data);
    }
    return results;
  }
}
