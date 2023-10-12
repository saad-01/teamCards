import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/constants.dart';

class AppBarBackArrowWidget extends StatelessWidget {
  final String textt;
  final String? pencileUrl;
  final VoidCallback? onPressed;
  const AppBarBackArrowWidget({
    super.key,
    required this.textt,
    this.pencileUrl,
    this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                textt == MyLocalization().addEvent.tr ? "" : textt,
                style: const TextStyle(
                    fontSize: 30,
                    color: MyColors.kWhiteColor,
                    fontWeight: FontWeight.w400),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: pencileUrl != null
                  ? GestureDetector(
                      onTap: onPressed,
                      child: Image.asset(
                        pencileUrl ?? '',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ))
                  : null,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(
                  Icons.arrow_circle_left_outlined,
                  color: MyColors.kWhiteColor,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
