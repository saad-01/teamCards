import 'package:flutter/material.dart';
import 'package:nachhaltiges_fahren/constants.dart';

class EditProfileTextField extends StatelessWidget {
  const EditProfileTextField(
      {super.key, required this.title, required this.hintText, this.url});
  final String title;
  final String hintText;
  final String? url;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              title,
              style: const TextStyle(color: MyColors.kBlackColor),
            )),
        TextField(
          cursorColor: Colors.black,
          cursorHeight: 20,
          style: const TextStyle(fontSize: 18, color: Colors.black),
          decoration: InputDecoration(
            fillColor: MyColors.kWhiteColor,
            filled: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            hintText: hintText,
            prefixIcon: url != null
                ? SizedBox(
                    width: 60,
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Image.asset(
                          "$url",
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                        Text(
                          "|",
                          style: TextStyle(
                              fontSize: 40,
                              color: Colors.grey.shade300,
                              fontWeight: FontWeight.w200),
                        )
                      ],
                    ),
                  )
                : null,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: MyColors.kBlackColor, width: .5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: MyColors.kBlackColor, width: .5),
            ),
          ),
        ),
      ],
    );
  }
}
