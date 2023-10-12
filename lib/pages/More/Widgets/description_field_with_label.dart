
import 'package:flutter/material.dart';
import 'package:nachhaltiges_fahren/constants.dart';

class DescriptioFieldWithLabel extends StatelessWidget {
  const DescriptioFieldWithLabel(
      {super.key, required this.title, required this.hintText, required this.colour,required this.minline});
  final String title;
  final String hintText;
  final Color colour;
  final int minline;


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              title,
              style:  TextStyle(color: colour,fontWeight: FontWeight.w500),
            )),
        TextField(
          cursorColor: Colors.black,
          minLines: minline,
          maxLines: 10,
          cursorHeight: 20,
          style:const TextStyle(fontSize: 18,color: Colors.black),
          decoration: InputDecoration(
            fillColor: MyColors.kWhiteColor,
            filled: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            hintText: hintText,
           
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: MyColors.kBlackColor, width: .1),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: MyColors.kBlackColor, width: .1),
            ),
          ),
        ),
      ],
    );
  }
}
