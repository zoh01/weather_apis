import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weather_apis/utils/constants/colors.dart';
import 'package:weather_apis/utils/constants/sizes.dart';
import '../../../domain/provider/weaher_provider.dart';

class FutureScreen extends StatefulWidget {
  final TextEditingController locationController;
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const FutureScreen({
    super.key,
    required this.locationController,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<FutureScreen> createState() => _FutureTabState();
}

class _FutureTabState extends State<FutureScreen> {
  @override
  Widget build(BuildContext context) {
    final prov = context.watch<WeatherProvider>();

    if (prov.futureState == LoadingState.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (prov.futureState == LoadingState.error) {
      return Center(child: Text('Error: ${prov.errorMessage}'));
    }

    final f = prov.futureForDate;
    if (f == null) {
      return const Center(child: Text('No future weather loaded'));
    }

    final forecastList = f['forecast']?['forecastday'] as List?;
    if (forecastList == null || forecastList.isEmpty) {
      return const Center(child: Text('No forecast data available'));
    }

    final forecast = forecastList[0];
    final dayInfo = forecast['day'] ?? {};
    final astro = forecast['astro'] ?? {};
    final hours = forecast['hour'] as List? ?? [];
    final date = forecast['date'] ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: now.add(const Duration(days: 15)),
                    firstDate: now.add(const Duration(days: 14)),
                    lastDate: now.add(const Duration(days: 300)),
                  );
                  if (picked != null) {
                    widget.onDateChanged(picked);
                    final formatted = DateFormat('yyyy-MM-dd').format(picked);
                    prov.fetchFuture(widget.locationController.text, formatted);
                  }
                },
                icon: const Icon(
                  Icons.calendar_month,
                  size: ZohSizes.md,
                  color: Colors.white,
                ),
                label: const Text(
                  "Pick Date",
                  style: TextStyle(color: Colors.white, fontSize: ZohSizes.md),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ZohColors.darkColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: ZohSizes.md),
          Center(
            child: Column(
              children: [
                Image.network(
                  'https:${dayInfo['condition']?['icon']}',
                  width: 80,
                  height: 80,
                ),
                Text(
                  dayInfo['condition']?['text'] ?? '',
                  style: const TextStyle(
                    fontSize: ZohSizes.spaceBtwZoh,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: ZohSizes.sm),
                Text(
                  "Avg Temp: ${dayInfo['avgtemp_c']}°C",
                  style: const TextStyle(
                    fontSize: ZohSizes.md,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Max: ${dayInfo['maxtemp_c']}°C • Min: ${dayInfo['mintemp_c']}°C",
                  style: const TextStyle(
                    fontSize: ZohSizes.md,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Humidity: ${dayInfo['avghumidity']}%",
                  style: const TextStyle(
                    fontSize: ZohSizes.md,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "UV: ${dayInfo['uv']}",
                  style: const TextStyle(
                    fontSize: ZohSizes.md,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: ZohSizes.sm),
                Text(
                  "Sunrise: ${astro['sunrise']} • Sunset: ${astro['sunset']}",
                  style: const TextStyle(
                    fontSize: ZohSizes.md,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ZohSizes.spaceBtwZoh),
          const Text(
            "Hourly Forecast",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ZohSizes.spaceBtwZoh,
            ),
          ),
          const SizedBox(height: ZohSizes.sm),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hours.length > 8 ? 8 : hours.length,
              itemBuilder: (context, index) {
                final h = hours[index];
                return Container(
                  width: 130,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        h['time'].toString().split(' ').last,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${h['temp_c']}°C",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        h['condition']?['text'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Rain: ${h['chance_of_rain']}%",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}