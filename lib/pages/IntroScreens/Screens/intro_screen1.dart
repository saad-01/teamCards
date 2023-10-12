import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/constants.dart';
import '../Widget/back_next_bottom_button.dart';
import '../Widget/circle_bottom_icon.dart';
import 'intro_screen2.dart';

class IntroScreen1 extends StatefulWidget {
  const IntroScreen1({super.key});

  @override
  State<IntroScreen1> createState() => _IntroScreen1State();
}

class _IntroScreen1State extends State<IntroScreen1> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                  'assets/introScreen/intro1.png',
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
                        MyLocalization().event.tr,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .8,
                        child: Text(
                          MyLocalization().eventText.tr,
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
                        child: const CircleIcons(screenId: 0),
                      ),
                      BackNextButton(
                        nextPress: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const IntroScreen2(),
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
      ),
    );
  }
}
