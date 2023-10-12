

import 'package:flutter/material.dart';

class Heading extends StatelessWidget {
  const Heading({super.key, required this.heading});
  final String heading;
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: kGreenColor,
      height: 45,
      width: double.infinity,
      padding: const EdgeInsets.only(left: 40, top: 20, bottom: 7),
      child: Text(
        heading,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    );
  }
}
