import 'package:flutter/material.dart';
import 'package:nachhaltiges_fahren/constants.dart';
//import 'package:nachhaltiges_fahren/pages/Splash/Screens/language_select_page.dart';
import '../Widgets/step_circular_indicator.dart';

class SplashScreen2 extends StatefulWidget {
  const SplashScreen2({super.key});

  @override
  State<SplashScreen2> createState() => _SplashScreen2State();
}

class _SplashScreen2State extends State<SplashScreen2> {
//     @override
//   void initState() {
//     super.initState();
// //     Future.delayed(const Duration(seconds: 2)).then((value) {
// // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LanguageSelectPage(),));
// //     });
//   }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: MyColors.kWhiteColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/splashScreen/logo2.png',
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
                        color: Color(0xff00C897),
                        fontStyle: FontStyle.italic),
                  ),

                ],
              ),
            ),
            Container(
                height: 314,
                width: double.infinity,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                          'assets/splashScreen/sp2bg.png',
                        ),
                        fit: BoxFit.cover)),
                child: const Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [KCircularProgressIndicator()])),
          ],
        ),
      ),
    );
  }
}
