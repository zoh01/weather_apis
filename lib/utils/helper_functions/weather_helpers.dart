String formatTempC(Map<String, dynamic> current) {
  final temp = current['temp_c'];
  return temp != null ? "${temp.toString()}°C" : '--';
}

String conditionText(Map<String, dynamic> current) {
  return current['condition']?['text'] ?? '';
}