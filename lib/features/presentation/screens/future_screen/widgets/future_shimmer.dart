import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:weather_apis/utils/constants/colors.dart';

import '../../../../../utils/constants/sizes.dart';

class FutureShimmer extends StatefulWidget {
  const FutureShimmer({super.key});

  @override
  State<FutureShimmer> createState() => _FutureShimmerState();
}

class _FutureShimmerState extends State<FutureShimmer> {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey,
      highlightColor: ZohColors.darkerGrey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(ZohSizes.md),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date shimmer
                Container(
                  width: 100,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ZohSizes.spaceBtwZoh),
                    color: ZohColors.white,
                  ),
                ),
                // Calendar Shimmer
                Container(
                  width: 100,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ZohSizes.spaceBtwZoh),
                    color: ZohColors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ZohSizes.md),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * .8,
                height: MediaQuery.of(context).size.height * .6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ZohSizes.spaceBtwZoh),
                  color: ZohColors.white,
                ),
              ),
            ),

            Container(
              width: 150,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ZohSizes.spaceBtwZoh),
                color: ZohColors.white,
              ),
            ),

            SizedBox(
              height: 180,
              child: ListView.builder(
                itemCount: 5,
                padding: const EdgeInsets.all(16),
                itemBuilder:
                    (context, index) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
