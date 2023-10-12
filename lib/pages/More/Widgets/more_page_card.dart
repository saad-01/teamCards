import 'package:flutter/material.dart';
import 'package:nachhaltiges_fahren/constants.dart';

class MorePageCards extends StatelessWidget {
  const MorePageCards({
    super.key,
    required this.textt,
    required this.url,
    required this.onPressed,
    this.trailingText,
  });

  final String textt;
  final String? trailingText;
  final String url;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 1),
        child: Card(
          borderOnForeground: true,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: MyColors.kGreenColor, width: 0.3)),
          child: ListTile(
            leading: Image.asset(
              url,
              width: 40,
              height: 35,
              fit: BoxFit.fill,
            ),
            title: Row(
              children: [
                const Text(
                  '|\t\t',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w200),
                ),
                Text(
                  textt,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
            trailing: trailingText != ''
                ? Text(
                    trailingText ?? '',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500),
                  )
                : const Text(""),
          ),
        ),
      ),
    );
  }
}
