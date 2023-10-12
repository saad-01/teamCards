import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/constants.dart';
import 'package:nachhaltiges_fahren/pages/login_page.dart';

import '../Widget/back_next_bottom_button.dart';
import '../Widget/circle_bottom_icon.dart';

class IntroScreen5 extends StatefulWidget {
  const IntroScreen5({super.key});

  @override
  State<IntroScreen5> createState() => _IntroScreen5State();
}

class _IntroScreen5State extends State<IntroScreen5> {
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
                'assets/introScreen/intro5.png',
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
                      MyLocalization().invite.tr,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .8,
                      child: Text(
                        MyLocalization().inviteText.tr,
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
                      child: const CircleIcons(screenId: 4),
                    ),
                    BackNextButton(
                      nextPress: () {
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ), (route) => false);
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
