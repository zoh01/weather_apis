import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_forecast_app/features/presentation/screens/future_screen/widgets/future_shimmer.dart';

import '../../../../utils/constants/sizes.dart';
import 'widgets/list_container.dart';
import 'widgets/pick_date.dart';
import 'widgets/future_container.dart';
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
  State<FutureScreen> createState() => _FutureScreenState();
}

class _FutureScreenState extends State<FutureScreen> {

  @override
  void initState() {
    super.initState();
    _detectAndFetchWeather();
  }

  /// Automatically get user’s location & fetch tomorrow’s forecast
  Future<void> _detectAndFetchWeather() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final city = placemarks.first.locality ?? 'Unknown';

      widget.locationController.text = city;

      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final formatted = DateFormat('yyyy-MM-dd').format(tomorrow);

      context.read<WeatherProvider>().fetchFuture(city, formatted);
    } catch (e) {
      print('Error detecting location: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<WeatherProvider>();

    // Shimmer or loading indicator
    if (prov.futureState == LoadingState.loading) {
      return const FutureShimmer();
    }

    if (prov.futureState == LoadingState.error) {
      return Center(child: Text('Error: ${prov.errorMessage}'));
    }

    final f = prov.futureForDate;
    if (f == null) {
      return const Center(child: Text('No forecast data yet'));
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
          // Pick Date widget
          PickDate(
            selectedDate: widget.selectedDate,
            locationController: widget.locationController,
            onDateChanged: (picked) {
              widget.onDateChanged(picked);
              final formatted = DateFormat('yyyy-MM-dd').format(picked);
              final loc = widget.locationController.text.trim();
              if (loc.isNotEmpty) {
                prov.fetchFuture(loc, formatted);
              }
            },
            prov: prov,
          ),

          const SizedBox(height: ZohSizes.md),

          // Main Forecast Card
          FutureContainer(dayInfo: dayInfo, astro: astro),

          const SizedBox(height: ZohSizes.md),

          const Text(
            "Hourly Forecast",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ZohSizes.spaceBtwZoh,
            ),
          ),
          const SizedBox(height: ZohSizes.sm),

          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: hours.length > 8 ? 8 : hours.length,
              itemBuilder: (context, index) {
                final h = hours[index];
                final conditionText = h['condition']?['text'] ?? '';
                final conditionIcon = h['condition']?['icon'];
                final temp = h['temp_c'];
                final time = h['time'].toString().split(' ').last;
                final rainChance = h['chance_of_rain'];

                return ListContainer(
                  time: time,
                  conditionIcon: conditionIcon,
                  temp: temp,
                  conditionText: conditionText,
                  rainChance: rainChance,
                );
              },
            ),
          ),

          const SizedBox(height: ZohSizes.md),
        ],
      ),
    );
  }
}
