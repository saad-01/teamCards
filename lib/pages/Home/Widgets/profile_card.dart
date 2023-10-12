import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.name,
    required this.level,
    required this.description,
    required this.profilePhoto,
  });

  final String name;
  final String level;
  final String description;
  final String profilePhoto;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xff019267),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SizedBox(
              width: 20,
            ),
            CircleAvatar(
              backgroundImage: NetworkImage(profilePhoto),
              radius: 40,
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 28, color: MyColors.kWhiteColor),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                        fontSize: 15, color: MyColors.kBackGroundColor),
                  ),
                ],
              ),
            ),

            //Level Anzeige
            /*
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Image.asset(
                  'assets/home/levelicon.PNG',
                  fit: BoxFit.cover,
                  width: 60,
                  height: 60,
                ),
                Text(
                  "${MyLocalization().level.tr} ${currentUserInformations.level}",
                  style: const TextStyle(
                    fontSize: 24,
                    color: MyColors.kBackGroundColor,
                  ),
                ),
              ],
            ),*/
            const SizedBox(
              width: 20,
            ),
          ],
        ),
      ),
    );
  }
}
