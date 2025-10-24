import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:weather_apis/features/presentation/screens/current_screen/current_screen.dart';
import 'package:weather_apis/features/presentation/screens/current_screen/widgets/info_tile.dart';
import 'package:weather_apis/utils/constants/colors.dart';
import 'package:weather_apis/utils/constants/sizes.dart';

import '../../../domain/provider/weaher_provider.dart';
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
    text: 'Lagos', // example: mid-Atlantic Ocean
  );
  late TabController _tabController;
  DateTime selectedDate = DateTime.now().add(const Duration(days: 15));

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
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
                  child: TextFormField(
                    controller: _locationController,
                    keyboardType: TextInputType.text,
                    cursorColor: ZohColors.darkColor,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: ZohSizes.md,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Enter Location',
                      labelStyle: TextStyle(
                        color: ZohColors.darkColor,
                        fontSize: ZohSizes.md,
                      ),
                      hintText: 'City',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: ZohColors.white,
                      contentPadding: EdgeInsets.symmetric(
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
                        borderSide: BorderSide(
                          color: ZohColors.primaryColor,
                          width: 1.8,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                        color: ZohColors.primaryColor,
                      ),
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

