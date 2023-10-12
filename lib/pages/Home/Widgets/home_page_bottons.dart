
import 'package:flutter/material.dart';

class HomePageButton extends StatelessWidget {
  const HomePageButton({
    super.key,
    required this.icon,
    required this.textt,
    required this.onPressed,
  });
  final String textt;
  final IconData icon;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 90,
        width: 90,
        decoration: BoxDecoration(
            color: const Color(0xffCFF5E5),
            borderRadius: BorderRadius.circular(14)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 30,
            ),
            Text(
              textt,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}