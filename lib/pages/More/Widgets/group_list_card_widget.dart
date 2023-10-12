
import 'package:flutter/material.dart';
import 'package:nachhaltiges_fahren/constants.dart';

class GroupListCard extends StatelessWidget {
  const GroupListCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.url,
  });
final String title;
final String subtitle;
final String url;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: MyColors.kWhiteColor,
        border:
            Border.all(color: MyColors.kBlackColor, width: .3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 120,
            height: 140,
            decoration: const BoxDecoration(
              color: Color(0xffABEDDD),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(50),
                bottomRight: Radius.circular(50),
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
            ),
            child: Center(
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(15),
                    image: url.isNotEmpty ? DecorationImage(
                        image: NetworkImage(url),
                        fit: BoxFit.cover) : null,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 30,
          ),
           Expanded(child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: MyColors.kGreenColor),
                  ),
                ),
                Flexible(
                  child: Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey),
                  ),
                ),
              ],
          ),
           )
        ],
      ),
    );
  }
}