import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../domain/provider/weaher_provider.dart';

class PickDate extends StatefulWidget {
  const PickDate({
    super.key,
    required this.date,
    required this.locationController,
    required this.onDateChanged,
    required this.prov,
  });

  final String date; // you can use String or DateTime depending on usage
  final TextEditingController locationController;
  final Function(DateTime) onDateChanged;
  final WeatherProvider prov;

  @override
  State<PickDate> createState() => _PickDateState();
}

class _PickDateState extends State<PickDate> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    DateTime? parsed;

    try {
      parsed = DateTime.tryParse(widget.date);
    } catch (_) {}

    // Use tomorrow if no valid future date is provided
    if (parsed == null || parsed.isBefore(tomorrow)) {
      _selectedDate = tomorrow;
    } else {
      _selectedDate = parsed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayText = DateFormat('yyyy-MM-dd').format(_selectedDate);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          displayText,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ZohSizes.spaceBtwZoh,
            color: ZohColors.darkColor,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            final now = DateTime.now();

            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: now.add(const Duration(days: 1)),
              lastDate: now.add(const Duration(days: 300)),
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
                      style: TextButton.styleFrom(
                        foregroundColor: ZohColors.secondaryColor,
                      ),
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (picked != null) {
              // Update local label immediately
              setState(() => _selectedDate = picked);

              // Notify parent/screen
              widget.onDateChanged(picked);

              // Validate location
              final location = widget.locationController.text.trim();
              if (location.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid location first.'),
                  ),
                );
                return;
              }

              // Format and fetch
              final formatted = DateFormat('yyyy-MM-dd').format(picked);
              widget.prov.fetchFuture(location, formatted);
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }
}