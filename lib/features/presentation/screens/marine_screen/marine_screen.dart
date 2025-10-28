import 'package:flutter/material.dart';
import 'package:weather_apis/features/presentation/screens/marine_screen/widgets/marine_shimmer.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../domain/provider/weaher_provider.dart';

class MarineScreen extends StatelessWidget {
  final WeatherProvider prov;

  const MarineScreen({super.key, required this.prov});

  @override
  Widget build(BuildContext context) {
    if (prov.currentState == LoadingState.loading) {
      return MarineShimmer();
    }

    if (prov.marineState == LoadingState.error) {
      return Center(child: Text('Error: ${prov.errorMessage}'));
    }

    final m = prov.marine;
    if (m == null) return const MarineShimmer();

    final regionName = m['location']?['name'] ?? '';
    final tides = m['tide'] ?? {};
    final forecastDay = m['forecast']?['forecastday'] as List?;

    if (forecastDay == null || forecastDay.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(regionName, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('No forecast data available'),
          ],
        ),
      );
    }

    final hours = (forecastDay[0]['hour'] as List?) ?? <dynamic>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          regionName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: ZohSizes.defaultSpace,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: ZohSizes.sm),

        if (tides.isNotEmpty) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tide info:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(tides.toString()),
            ],
          ),
          const SizedBox(height: 12),
        ],

        const Text(
          'Marine forecast (hourly):',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: ZohSizes.md),
        ),
        const SizedBox(height: 12),

        Flexible(
          child: GridView.builder(
            padding: EdgeInsets.all(ZohSizes.xs),
            itemCount: hours.length,
            physics: BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final h = hours[index];
              final swell = h['swell_height_m'];
              final wave = h['wave_height_m'];
              final hasMarineData = swell != null || wave != null;

              return Container(
                margin: const EdgeInsets.all(ZohSizes.fontSizeSm),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ZohColors.bodyTextColor,
                  borderRadius: BorderRadius.circular(ZohSizes.md),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        overflow: TextOverflow.ellipsis,
                        h['time'].toString().split(' ').last,
                        style: TextStyle(
                          fontSize: ZohSizes.defaultSpace,
                          fontWeight: FontWeight.bold,
                          color: ZohColors.darkColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (h['condition']?['icon'] != null)
                      Image.network(
                        'https:${h['condition']?['icon']}',
                        width: 60,
                        height: 60,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    const SizedBox(height: 6),
                    Flexible(
                      child: Text(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        h['condition']?['text'] ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: ZohSizes.md,
                          color: ZohColors.darkColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (h['temp_c'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        "${h['temp_c']}°C",
                        style: TextStyle(
                          fontSize: ZohSizes.md,
                          fontWeight: FontWeight.w600,
                          color: ZohColors.darkColor,
                        ),
                      ),
                    ],
                    if (hasMarineData) ...[
                      const SizedBox(height: 4),
                      Text(
                        "${swell ?? '--'}m / ${wave ?? '--'}m",
                        style: TextStyle(
                          fontSize: ZohSizes.sm,
                          color: ZohColors.darkColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}