import 'package:flutter/material.dart';
import 'package:nachhaltiges_fahren/constants.dart';
import '../Widgets/step_circular_indicator.dart';
import 'splash_screen2.dart';

class SplashScreen1 extends StatefulWidget {
  const SplashScreen1({super.key});

  @override
  State<SplashScreen1> createState() => _SplashScreen1State();
}

class _SplashScreen1State extends State<SplashScreen1> {
  @override
  void initState() {
    super.initState();
//     Future.delayed(const Duration(seconds: 2)).then((value) {
// Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SplashScreen2(),));
//     });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          color: MyColors.kGreenColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                  flex: 9,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/splashScreen/logo1.png',
                        width: 159,
                        height: 159,
                      ),
                      const SizedBox(
                        height: 44,
                      ),
                      const Text(
                        "TEAM CAR",
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w500,
                            color: MyColors.kWhiteColor,
                            fontStyle: FontStyle.italic),
                      )
                    ],
                  )),
              Expanded(
                  flex: 1,
                  child: KCircularProgressIndicator()),
            ],
          ),
        ),
      );
  }
}
