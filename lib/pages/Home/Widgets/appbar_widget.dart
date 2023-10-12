
import 'package:flutter/material.dart';
import 'package:nachhaltiges_fahren/constants.dart';
import 'package:nachhaltiges_fahren/localization_service.dart';

class AppBarWidget extends StatelessWidget {
  const AppBarWidget({
    super.key,
    required this.textt,
    required this.imageAddress,
    required this.onPressed,
  });
  final String textt;
  final String imageAddress;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    String locale = LocalizationService().getCurrentLocale().toString();
    String lang = locale.substring(0, 2).toUpperCase();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 100,
      child: Stack(
        children: [
          Center(
            child: GestureDetector(
              onTap: onPressed,
              child: Row(
                children: [
                  Image.asset(
                    imageAddress,
                    width: 22,
                    height: 20,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    lang,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Text(
              textt,
              style: const TextStyle(
                  fontSize: 30, color: MyColors.kWhiteColor, fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}
