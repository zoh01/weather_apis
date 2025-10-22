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

  Future<void> fetchFuture(String location, String date) async {
    futureState = LoadingState.loading;
    notifyListeners();
    try {
      futureForDate = await _service.getFuture(location, date);
      futureState = LoadingState.idle;
    } catch (e) {
      futureState = LoadingState.error;
      errorMessage = e.toString();
    }
    notifyListeners();
  }
}