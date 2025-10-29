import 'package:flutter/material.dart';
import '../../data/services/weather_service.dart';

enum LoadingState { idle, loading, error }

class WeatherProvider extends ChangeNotifier {
  final WeatherService _service = WeatherService();

  Map<String, dynamic>? current;
  Map<String, dynamic>? marine;
  Map<String, dynamic>? futureForDate;

  LoadingState currentState = LoadingState.idle;
  LoadingState marineState = LoadingState.idle;
  LoadingState futureState = LoadingState.idle;

  String? errorMessage;

  Future<void> fetchCurrent(String location) async {
    currentState = LoadingState.loading;
    notifyListeners();
    try {
      current = await _service.getCurrent(location);
      currentState = LoadingState.idle;
    } catch (e) {
      currentState = LoadingState.error;
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> fetchMarine(String location) async {
    marineState = LoadingState.loading;
    notifyListeners();
    try {
      marine = await _service.getMarine(location);
      marineState = LoadingState.idle;
    } catch (e) {
      marineState = LoadingState.error;
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  /// Fetch future weather for a specific date (yyyy-MM-dd).
  /// Uses forecast.json for dates within next 14 days and future.json for 15-300 days.
  Future<void> fetchFuture(String location, String date) async {
    futureState = LoadingState.loading;
    notifyListeners();

    try {
      // parse date and decide endpoint
      final now = DateTime.now();
      final requested = DateTime.parse(date);
      final diffDays = requested.difference(DateTime(now.year, now.month, now.day)).inDays;

      Map<String, dynamic> response;

      // Logging for debugging
      debugPrint('fetchFuture: location=$location date=$date diffDays=$diffDays');

      if (diffDays <= 14) {
        // use forecast endpoint (supports days up to 14)
        response = await _service.getForecast(location, (diffDays < 1) ? 1 : diffDays + 1);
        // Note: forecast.json returns foreCastDay list - pick the specific date inside UI when rendering
        debugPrint('Used forecast.json (days=${(diffDays < 1) ? 1 : diffDays + 1})');
      } else {
        // use future endpoint (15..300 days)
        response = await _service.getFuture(location, date);
        debugPrint('Used future.json');
      }

      futureForDate = response;
      futureState = LoadingState.idle;
      errorMessage = null;
    } catch (e, st) {
      debugPrint('fetchFuture error: $e\n$st');
      errorMessage = e.toString();
      futureState = LoadingState.error;
    }

    notifyListeners();
  }
}