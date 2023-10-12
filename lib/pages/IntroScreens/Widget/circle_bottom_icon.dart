
import 'package:flutter/material.dart';
import 'package:nachhaltiges_fahren/constants.dart';


class CircleIcons extends StatelessWidget {
  const CircleIcons({
    super.key,
    required this.screenId,
  });

  final int screenId;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return Icon(
          Icons.circle,
          size: 12,
          color: screenId == index ? MyColors.kGreenColor : Colors.grey.shade300,
        );
      },
    );
  }
}
