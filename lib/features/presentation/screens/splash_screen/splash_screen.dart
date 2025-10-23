import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:weather_apis/features/presentation/screens/dashboard_screen/dashboard_screen.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 7)).then((zoh) {
      Navigator.pushReplacement(
          context, CupertinoPageRoute(builder: (ctx) => HomeScreen()));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
      body: Padding(
        padding: const EdgeInsets.all(ZohSizes.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BounceInDown(
              duration: Duration(milliseconds: 2000),
              child: Image(
                image: AssetImage(ZohImageStrings.splashImage),
                height: MediaQuery.of(context).size.height * .4,
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
            ),

            SizedBox(height: ZohSizes.spaceBtwSections),

            FadeInUp(
              duration: Duration(milliseconds: 2000),
              delay: Duration(milliseconds: 1000),
              child: Center(
                child: DefaultTextStyle(
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Roboto',
                      color: ZohColors.primaryColor,
                      fontSize: ZohSizes.spaceBtwZoh,
                      fontWeight: FontWeight.bold
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(ZohTextString.splashTitle),
                    ],
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
