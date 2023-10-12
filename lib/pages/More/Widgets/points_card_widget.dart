import 'package:flutter/material.dart';
import 'package:nachhaltiges_fahren/constants.dart';

class PointScreenCard extends StatelessWidget {
  const PointScreenCard({
    super.key,
    required this.url,
    required this.title,
    required this.distance,
    required this.color
  });
  final String url;
  final String title;
  final String distance;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: MyColors.kWhiteColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MyColors.kBlackColor, width: .2),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: GestureDetector(
                    onTap: () {
                      showDialog(context: context, builder: (context) {
                        return SimpleDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          titlePadding: const EdgeInsets.all(10),
                          title: Text(
                            distance,
                            maxLines: 3,
                            style:  TextStyle(
                              color: color,
                              fontSize: 36,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      });
                    },
                    child: Text(
                      distance,
                      overflow: TextOverflow.ellipsis,
                      style:  TextStyle(
                        color: color,
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5,),
                Text(
                  title,
                  style: const TextStyle(
                      color: MyColors.kBlackColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          Container(
            width: 100,
            height: 100,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child:Image.asset(url)
          ),
        ],
      ),
    );
  }
}
