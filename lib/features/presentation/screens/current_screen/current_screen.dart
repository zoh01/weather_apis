import 'package:flutter/material.dart';
import 'package:weather_apis/features/domain/model/current_model.dart';
import 'package:weather_apis/features/presentation/screens/current_screen/widgets/current_shimmer.dart';
import 'package:weather_apis/utils/constants/colors.dart';
import 'package:weather_apis/utils/constants/sizes.dart';
import '../../../domain/provider/weaher_provider.dart';
import 'widgets/info_tile.dart';

class CurrentScreen extends StatefulWidget {
  final WeatherProvider prov;

  const CurrentScreen({super.key, required this.prov});

  @override
  State<CurrentScreen> createState() => _CurrentScreenState();
}

class _CurrentScreenState extends State<CurrentScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.prov.currentState == LoadingState.loading) {
      return const CurrentShimmer();
    }

    if (widget.prov.currentState == LoadingState.error) {
      return Center(child: Text('Error: ${widget.prov.errorMessage}'));
    }

    final cur = widget.prov.current;
    if (cur == null) {
      return const CurrentShimmer();
    }

    final location = cur['location'] ?? {};
    final current = cur['current'] ?? {};

    final List<CurrentModel> materialZoh = [
      CurrentModel(
        'Feels like',
        "${current['feelslike_c'] ?? '--'}°C",
        Icons.thermostat,
      ),
      CurrentModel('Wind', "${current['wind_kph'] ?? '--'} kph", Icons.air),
      CurrentModel(
        'Humidity',
        "${current['humidity'] ?? '--'}%",
        Icons.water_drop,
      ),
      CurrentModel(
        'Pressure',
        "${current['pressure_mb'] ?? '--'} mb",
        Icons.speed,
      ),
      CurrentModel('UV', "${current['uv'] ?? '--'}", Icons.wb_sunny_outlined),
      CurrentModel(
        'Last updated',
        (current['last_updated'] != null)
            ? current['last_updated'].toString().split(' ').last
            : '--',
        Icons.access_time,
      ),
    ];

    return Column(
      children: [
        Text(
          "${location['name'] ?? ''}, ${location['country'] ?? ''}",
          style: const TextStyle(
            fontSize: ZohSizes.defaultSpace,
            fontWeight: FontWeight.bold,
            color: ZohColors.darkColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "${current['temp_c'] ?? '--'}°C",
          style: const TextStyle(
            fontSize: ZohSizes.spaceBtwSections,
            fontWeight: FontWeight.bold,
            color: ZohColors.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          current['condition']?['text'] ?? '',
          style: const TextStyle(
            fontSize: ZohSizes.spaceBtwZoh,
            fontWeight: FontWeight.bold,
            color: ZohColors.darkColor,
          ),
        ),
        const SizedBox(height: 12),

        Expanded(
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: materialZoh.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemBuilder: (context, index) {
              final zoh = materialZoh[index];
              return InfoTile(icon: zoh.icon, title: zoh.title, value: zoh.value);
            },
          ),
        ),
      ],
    );
  }
}
