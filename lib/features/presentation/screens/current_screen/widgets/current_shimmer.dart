import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:weather_apis/utils/constants/colors.dart';
import 'package:weather_apis/utils/constants/sizes.dart';

class CurrentShimmer extends StatelessWidget {
  const CurrentShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white54,
      highlightColor: Colors.grey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(ZohSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Location shimmer
            Container(
              width: 180,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ZohSizes.spaceBtwZoh),
                color: ZohColors.bodyTextColor,
              ),
            ),
            const SizedBox(height: 12),

            // Temperature shimmer
            Container(
              width: 100,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ZohSizes.spaceBtwZoh),
                color: ZohColors.bodyTextColor,
              ),
            ),
            const SizedBox(height: 12),

            // Weather condition shimmer
            Container(
              width: 80,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ZohSizes.spaceBtwZoh,),
                color: ZohColors.bodyTextColor,
              ),
            ),
            const SizedBox(height: 24),

            // InfoTiles shimmer (same layout as your GridView)
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 6, // Same number of tiles
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: ZohSizes.gridViewSpacing,
                mainAxisSpacing: ZohSizes.defaultSpace,
              ),
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon shimmer circle
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Title shimmer
                      Container(
                        width: 60,
                        height: 10,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 6),
                      // Value shimmer
                      Container(
                        width: 40,
                        height: 10,
                        color: Colors.white,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}