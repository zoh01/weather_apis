import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weather_apis/features/presentation/screens/future_screen/widgets/list_container.dart';
import 'package:weather_apis/features/presentation/screens/future_screen/widgets/pick_date.dart';
import 'package:weather_apis/features/presentation/screens/future_screen/widgets/future_container.dart';
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
  void initState() {
    super.initState();

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final formatted = DateFormat('yyyy-MM-dd').format(tomorrow);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = widget.locationController.text.trim();
      if (loc.isNotEmpty) {

        context.read<WeatherProvider>().fetchFuture(loc, formatted);
      }
    });
  }

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
          PickDate(
            date: DateFormat('yyyy-MM-dd').format(
              widget.selectedDate.isBefore(DateTime.now().add(const Duration(days: 1)))
                  ? DateTime.now().add(const Duration(days: 1))
                  : widget.selectedDate,
            ),
            locationController: widget.locationController,
            onDateChanged: (picked) {
              // update parent selectedDate via callback and also fetch
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
          FutureContainer(dayInfo: dayInfo, astro: astro),
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
        ],
      ),
    );
  }
}