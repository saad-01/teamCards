import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/constants.dart';

import '../Widget/back_next_bottom_button.dart';
import '../Widget/circle_bottom_icon.dart';
import 'intro_screen4.dart';
class IntroScreen3 extends StatefulWidget {
  const IntroScreen3({super.key});

  @override
  State<IntroScreen3> createState() => _IntroScreen3State();
}

class _IntroScreen3State extends State<IntroScreen3> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.kBackGroundColor,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 10,
            ),
            Expanded(
              flex: 3,
              child: Image.asset(
                'assets/introScreen/intro3.png',
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width * .9,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      MyLocalization().ride.tr,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .8,
                      child: Text(
                        MyLocalization().rideText.tr,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w300),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      width: 65,
                      height: 30,
                      child: const CircleIcons(screenId: 2),
                    ),
                    BackNextButton(
                      nextPress: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const IntroScreen4(),
                          ));
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
