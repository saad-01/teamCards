
import 'package:flutter/material.dart';

class LanguageCard extends StatelessWidget {
  const LanguageCard(
      {super.key,
      required this.isSelected,
      required this.language,
      required this.flag});

  final bool isSelected;
  final String language;
  final String flag;
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: isSelected
            ? const BorderSide(color: Colors.green, width: 2.5) 
            : BorderSide.none,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        leading: Text(
          '$flag \t|',
          style: TextStyle(
              fontSize: 40,
              color: Colors.grey.shade300,
              fontWeight: FontWeight.w100),
        ),
        title: Text(
          language,
          style: const TextStyle(fontSize: 15, color: Colors.black),
        ),
        trailing: const Icon(
          Icons.check_circle_outline_rounded,
          color: Colors.black,
        ),
      ),
    );
  }
}
