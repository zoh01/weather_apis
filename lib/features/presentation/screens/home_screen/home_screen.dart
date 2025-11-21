import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../domain/provider/weaher_provider.dart';
import '../current_screen/current_screen.dart';
import '../future_screen/future_screen.dart';
import '../marine_screen/marine_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _locationController = TextEditingController(
    text: 'Lagos',
  );

  late TabController _tabController;
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _detectedCity;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (_tabController.index == 2) {
        final loc = _locationController.text.trim();
        if (loc.isNotEmpty) {
          context.read<WeatherProvider>().fetchFuture(
            loc,
            DateFormat('yyyy-MM-dd').format(selectedDate),
          );
        }
      }
    });

    // 👇 Detect location and fetch all forecasts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detectAndFetchWeather();
    });
  }

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

      // ✅ Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // ✅ Reverse geocode to get city name
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final city = placemarks.first.locality ?? 'Unknown';
      setState(() {
        _detectedCity = city;
        _locationController.text = city;
      });

      // ✅ Fetch all 3 sections (Current, Marine, Future)
      final prov = context.read<WeatherProvider>();
      prov.fetchCurrent(city);
      prov.fetchMarine(city);
      prov.fetchFuture(city, DateFormat('yyyy-MM-dd').format(selectedDate));
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Weather Forecast',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ZohSizes.spaceBtwZoh,
            color: ZohColors.secondaryColor,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: ZohColors.secondaryColor,
          unselectedLabelColor: ZohColors.secondaryColor,
          indicatorColor: ZohColors.primaryColor,
          labelStyle: const TextStyle(
            fontSize: ZohSizes.md,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          splashBorderRadius: BorderRadius.circular(ZohSizes.md),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.pressed)) {
              return ZohColors.primaryColor.withOpacity(0.2);
            }
            if (states.contains(WidgetState.hovered)) {
              return ZohColors.primaryColor.withOpacity(0.1);
            }
            return null;
          }),
          tabs: const [
            Tab(text: 'Current'),
            Tab(text: 'Marine'),
            Tab(text: 'Future'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Shimmer Loading
          if (_detectedCity == null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Shimmer.fromColors(
                    baseColor: ZohColors.grey,
                    highlightColor: ZohColors.darkerGrey,
                    child: Container(
                      width: 100,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          ZohSizes.spaceBtwZoh,
                        ),
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Shimmer.fromColors(
                    baseColor: ZohColors.grey,
                    highlightColor: ZohColors.darkerGrey,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                ZohSizes.spaceBtwZoh,
                              ),
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 80,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              ZohSizes.spaceBtwZoh,
                            ),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on_sharp, color: Colors.redAccent),
                      Text(
                        ': $_detectedCity',
                        style: const TextStyle(
                          fontSize: ZohSizes.spaceBtwZoh,
                          fontWeight: FontWeight.bold,
                          color: ZohColors.darkColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _locationController,
                          keyboardType: TextInputType.text,
                          cursorColor: ZohColors.darkColor,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: ZohSizes.md,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Enter City',
                            labelStyle: const TextStyle(
                              color: ZohColors.darkColor,
                              fontSize: ZohSizes.md,
                            ),
                            hintText: 'City',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: ZohColors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(ZohSizes.sm),
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(ZohSizes.sm),
                              borderSide: const BorderSide(
                                color: ZohColors.primaryColor,
                                width: 1.8,
                              ),
                            ),
                            prefixIcon: const Icon(
                              Icons.location_on_outlined,
                              color: ZohColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: ZohSizes.sm),
                      ElevatedButton(
                        onPressed: () {
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
                ],
              ),
            ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                CurrentScreen(prov: prov),
                MarineScreen(prov: prov),
                FutureScreen(
                  locationController: _locationController,
                  selectedDate: selectedDate,
                  onDateChanged: (newDate) {
                    setState(() => selectedDate = newDate);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
