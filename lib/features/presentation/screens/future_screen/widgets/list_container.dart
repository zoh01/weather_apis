import 'package:flutter/material.dart';

import '../../../../../utils/constants/colors.dart';


class ListContainer extends StatelessWidget {
  const ListContainer({
    super.key,
    required this.time,
    required this.conditionIcon,
    required this.temp,
    required this.conditionText,
    required this.rainChance,
  });

  final String time;
  final dynamic conditionIcon;
  final dynamic temp;
  final dynamic conditionText;
  final dynamic rainChance;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      width: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ZohColors.primaryColor.withOpacity(0.8),
            ZohColors.darkColor.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: ZohColors.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          if (conditionIcon != null)
            Image.network(
              'https:$conditionIcon',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
              errorBuilder:
                  (_, __, ___) => const Icon(
                Icons.wb_cloudy,
                color: Colors.white70,
                size: 32,
              ),
            ),
          const SizedBox(height: 6),
          Text(
            "$temp°C",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            conditionText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.water_drop,
                color: Colors.blueAccent,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                "$rainChance%",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}