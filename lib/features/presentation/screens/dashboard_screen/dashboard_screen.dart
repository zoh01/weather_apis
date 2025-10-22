import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:weather_apis/utils/constants/colors.dart';
import 'package:weather_apis/utils/constants/sizes.dart';

import '../../../data/services/weaher_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _locationController = TextEditingController(
    text: 'Ibadan',
  );
  late TabController _tabController;
  DateTime selectedDate = DateTime.now().add(const Duration(days: 15));

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
    // Optionally load initial data:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<WeatherProvider>();
      prov.fetchCurrent(_locationController.text);
      prov.fetchMarine(_locationController.text);
      prov.fetchFuture(
        _locationController.text,
        DateFormat('yyyy-MM-dd').format(selectedDate),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<WeatherProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Weather API Integration',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ZohSizes.md,
            color: ZohColors.secondaryColor,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: ZohColors.secondaryColor,
          unselectedLabelColor: ZohColors.secondaryColor,
          indicatorColor: ZohColors.primaryColor,
          tabs: const [
            Tab(text: 'Current'),
            Tab(text: 'Marine'),
            Tab(text: 'Future'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location (city or lat,lon)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: ZohSizes.sm),
                ElevatedButton(
                  onPressed: () {
                    // fetch all
                    final loc = _locationController.text.trim();
                    prov.fetchCurrent(loc);
                    prov.fetchMarine(loc);
                    prov.fetchFuture(
                      loc,
                      DateFormat('yyyy-MM-dd').format(selectedDate),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 4,
                    backgroundColor: ZohColors.primaryColor,
                  ),
                  child: const Text(
                    'Fetch',
                    style: TextStyle(
                      fontSize: ZohSizes.md,
                      fontWeight: FontWeight.bold,
                      color: ZohColors.secondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCurrentTab(prov),
                _buildMarineTab(prov),
                _buildFutureTab(prov),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTab(WeatherProvider prov) {
    if (prov.currentState == LoadingState.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (prov.currentState == LoadingState.error) {
      return Center(child: Text('Error: ${prov.errorMessage}'));
    }
    final cur = prov.current;
    if (cur == null) {
      return const Center(child: Text('No data yet'));
    }

    final location = cur['location'] ?? {};
    final current = cur['current'] ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            "${location['name'] ?? ''}, ${location['country'] ?? ''}",
            style: const TextStyle(fontSize: ZohSizes.defaultSpace, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "${current['temp_c'] ?? '--'}°C",
            style: const TextStyle(fontSize: ZohSizes.spaceBtwSections, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(current['condition']?['text'] ?? '', style: TextStyle(fontSize: ZohSizes.md, fontWeight: FontWeight.normal),),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _infoTile('Feels like', "${current['feelslike_c'] ?? '--'}°C"),
              _infoTile('Wind', "${current['wind_kph'] ?? '--'} kph"),
              _infoTile('Humidity', "${current['humidity'] ?? '--'}%"),
              _infoTile('Pressure', "${current['pressure_mb'] ?? '--'} mb"),
              _infoTile('UV', "${current['uv'] ?? '--'}"),
              _infoTile('Last updated', "${current['last_updated'] ?? '--'}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarineTab(WeatherProvider prov) {
    if (prov.currentState == LoadingState.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (prov.currentState == LoadingState.error) {
      return Center(child: Text('Error: ${prov.errorMessage}'));
    }
    final m = prov.marine;
    if (m == null) return const Center(child: Text('No marine data'));

    // Marine response structure varies; show key fields if present
    final regionName = m['location']?['name'] ?? '';
    final tides = m['tide'] ?? {};
    final forecastDay = m['forecast']?['forecastday'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            regionName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (tides.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tide info:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(tides.toString()),
                // refine parsing based on actual payload
              ],
            ),
          const SizedBox(height: 12),
          if (forecastDay != null)
            const Text(
              'Marine forecast (hourly/day):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          if (forecastDay != null) ...[
            // show first day hourly if exists
            ...(forecastDay as List).isNotEmpty
                ? (forecastDay[0]['hour'] as List).take(8).map<Widget>((h) {
                  return ListTile(
                    dense: true,
                    title: Text(
                      "${h['time'].toString().split(' ').last} - ${h['condition']?['text'] ?? ''}",
                    ),
                    subtitle: Text(
                      "Swell height: ${h['swell_height_m'] ?? '--'} m, Wave height: ${h['wave_height_m'] ?? '--'} m",
                    ),
                  );
                }).toList()
                : [const SizedBox()],
          ],
        ],
      ),
    );
  }

  Widget _buildFutureTab(WeatherProvider prov) {
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
                    final formatted = DateFormat('yyyy-MM-dd').format(picked);
                    setState(() {
                      selectedDate = picked;
                    });
                    prov.fetchFuture(_locationController.text, formatted);
                  }
                },
                icon: const Icon(Icons.calendar_month, size: 18),
                label: const Text("Pick Date"),
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
                  style: const TextStyle(fontSize: ZohSizes.spaceBtwZoh),
                ),
                const SizedBox(height: ZohSizes.sm),
                Text("Avg Temp: ${dayInfo['avgtemp_c']}°C"),
                Text(
                  "Max: ${dayInfo['maxtemp_c']}°C • Min: ${dayInfo['mintemp_c']}°C",
                ),
                Text("Humidity: ${dayInfo['avghumidity']}%"),
                Text("UV: ${dayInfo['uv']}"),
                const SizedBox(height: ZohSizes.sm),
                Text(
                  "Sunrise: ${astro['sunrise']} • Sunset: ${astro['sunset']}",
                ),
              ],
            ),
          ),
          const SizedBox(height: ZohSizes.spaceBtwZoh),
          const Text(
            "Hourly Forecast",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                      Text(h['time'].toString().split(' ').last),
                      const SizedBox(height: 4),
                      Text("${h['temp_c']}°C"),
                      Text(h['condition']?['text'] ?? ''),
                      Text("Rain: ${h['chance_of_rain']}%"),
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

  Widget _infoTile(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: 170,
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black54),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: ZohSizes.spaceBtwZoh)),
          const SizedBox(height: ZohSizes.sm),
          Text(value, style: TextStyle(fontSize: ZohSizes.md),),
        ],
      ),
    );
  }
}
