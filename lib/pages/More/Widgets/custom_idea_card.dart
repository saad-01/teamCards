import 'package:flutter/material.dart';
import 'package:nachhaltiges_fahren/constants.dart';

class CustomIdeaCards extends StatelessWidget {
  const CustomIdeaCards({
    super.key,
    required this.textt,
    required this.url,
    required this.onPressed,
    required this.trailingText,
    required this.subtextt,
    required this.liked,
    this.icon,
  });

  final String textt;
  final String subtextt;
  final String trailingText;
  final String url;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool liked;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Card(
        borderOnForeground: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: MyColors.kGreenColor, width: 0.3)),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 35,
              margin:const EdgeInsets.only(left: 5),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(url),
                ),
              ),
            ),
            Text(
              '|\t\t',
              style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w100,
                  color: Colors.grey.shade300),
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  textt,
                  style: const TextStyle(fontSize: 15, color: Colors.black),
                ),
                Text(
                  subtextt,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            )),
            SizedBox(
              height: 40,
              width: 60,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: liked ? MyColors.kGreenColor : Colors.grey,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    trailingText,
                    style: const TextStyle(color: MyColors.kGreenColor),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
