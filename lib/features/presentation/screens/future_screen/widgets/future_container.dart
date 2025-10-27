import 'package:flutter/material.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class FutureContainer extends StatelessWidget {
  const FutureContainer({
    super.key,
    required this.dayInfo,
    required this.astro,
  });

  final dynamic dayInfo;
  final dynamic astro;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              ZohColors.primaryColor.withOpacity(0.9),
              ZohColors.darkColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: ZohColors.primaryColor.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Weather icon and condition text
            Column(
              children: [
                Image.network(
                  'https:${dayInfo['condition']?['icon']}',
                  width: 90,
                  height: 90,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: ZohSizes.sm),
                Text(
                  dayInfo['condition']?['text'] ?? '',
                  style: const TextStyle(
                    fontSize: ZohSizes.spaceBtwZoh,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            // Temperature info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.thermostat, color: Colors.orangeAccent),
                const SizedBox(width: 8),
                Text(
                  "Avg Temp: ${dayInfo['avgtemp_c']}°C",
                  style: const TextStyle(
                    fontSize: ZohSizes.md,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Max: ${dayInfo['maxtemp_c']}°C • Min: ${dayInfo['mintemp_c']}°C",
              style: TextStyle(
                fontSize: ZohSizes.md,
                color: Colors.white.withOpacity(0.9),
              ),
            ),

            const SizedBox(height: 12),
            const Divider(color: Colors.white24, thickness: 1),

            // Other details (Humidity, UV, Sunrise, Sunset)
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildWeatherStat(
                  Icons.water_drop,
                  "Humidity",
                  "${dayInfo['avghumidity']}%",
                ),
                _buildWeatherStat(Icons.wb_sunny, "UV", "${dayInfo['uv']}"),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildWeatherStat(
                  Icons.wb_twighlight,
                  "Sunrise",
                  astro['sunrise'],
                ),
                _buildWeatherStat(
                  Icons.nightlight_round,
                  "Sunset",
                  astro['sunset'],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}