import 'package:flutter/material.dart';
import 'package:nachhaltiges_fahren/constants.dart';
import 'package:nachhaltiges_fahren/localization_service.dart';
import 'package:nachhaltiges_fahren/pages/IntroScreens/Screens/intro_screen1.dart';

import '../Widgets/language_card.dart';

class LanguageSelectPage extends StatefulWidget {
  const LanguageSelectPage({Key? key, this.first = false,}) : super(key: key);

  final bool first;

  @override
  LanguageSelectPageState createState() => LanguageSelectPageState();
}

class LanguageSelectPageState extends State<LanguageSelectPage> {
  int lang = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.kBackGroundColor,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Image.asset(
                'assets/splashScreen/globe.png',
                // width: double.infinity,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * .6,
              child: const Column(
                children: [
                  Text(
                    "Select Language",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Please select language according to your region",
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * .8,
              child: Column(
                children: [
                  InkWell(
                    onTap: () => setState(() => lang = 0),
                    child: LanguageCard(
                      isSelected: lang == 0,
                      flag: '🇩🇪',
                      language: 'Deutsch',
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () => setState(() => lang = 1),
                    child: LanguageCard(
                      isSelected: lang == 1,
                      flag: '🇬🇧',
                      language: 'English',
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () => setState(() => lang = 2),
                    child: LanguageCard(
                      isSelected: lang == 2,
                      flag: '🇪🇸',
                      language: 'Española',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              width: MediaQuery.of(context).size.width * .8,
              child: Card(
                color: MyColors.kGreenColor,
                child: ElevatedButton(
                    onPressed: () {
                      if (lang != 10) {
                        LocalizationService().changeLocale(languageSelection[lang].language);
                        if(!widget.first) {
                          Navigator.pop(context);
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const IntroScreen1()));
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.kGreenColor,
                        foregroundColor: MyColors.kWhiteColor,
                        minimumSize: const Size(double.infinity, 52)),
                    child: const Text("Next")),
              ),
            )
          ],
        ),
      ),
    );
  }
}
