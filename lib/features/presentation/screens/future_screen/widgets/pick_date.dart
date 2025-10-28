import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../domain/provider/weaher_provider.dart';

class PickDate extends StatefulWidget {
  const PickDate({
    super.key,
    required this.selectedDate,
    required this.locationController,
    required this.onDateChanged,
    required this.prov,
  });

  final DateTime selectedDate; // now a DateTime (safer)
  final TextEditingController locationController;
  final Function(DateTime) onDateChanged;
  final WeatherProvider prov;

  @override
  State<PickDate> createState() => _PickDateState();
}

class _PickDateState extends State<PickDate> {
  late DateTime _selectedDate;
  late final DateTime _tomorrow;

  @override
  void initState() {
    super.initState();
    _tomorrow = DateTime.now().add(const Duration(days: 1));

    // Initialize from widget.selectedDate, but ensure it's at least tomorrow
    if (widget.selectedDate.isBefore(_tomorrow)) {
      _selectedDate = _tomorrow;
    } else {
      _selectedDate = widget.selectedDate;
    }
  }

  String get _displayText => DateFormat('yyyy-MM-dd').format(_selectedDate);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: _tomorrow,
      lastDate: DateTime.now().add(const Duration(days: 300)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ZohColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: ZohColors.darkColor,
            ),
            dialogBackgroundColor: ZohColors.bodyTextColor,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: ZohColors.secondaryColor),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() => _selectedDate = picked);

    // notify parent (so parent state updates too)
    widget.onDateChanged(picked);

    // Validate location
    final location = widget.locationController.text.trim();
    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid location first.')),
      );
      return;
    }

    // Format and fetch via provider
    final formatted = DateFormat('yyyy-MM-dd').format(picked);
    try {
      widget.prov.fetchFuture(location, formatted);
    } catch (e) {
      // If provider throws, show a friendly message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching forecast: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _displayText,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ZohSizes.spaceBtwZoh,
            color: ZohColors.darkColor,
          ),
        ),
        ElevatedButton.icon(
          onPressed: _pickDate,
          icon: const Icon(Icons.calendar_month, size: ZohSizes.md, color: Colors.white),
          label: const Text("Pick Date", style: TextStyle(color: Colors.white, fontSize: ZohSizes.md)),
          style: ElevatedButton.styleFrom(
            backgroundColor: ZohColors.darkColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }
}