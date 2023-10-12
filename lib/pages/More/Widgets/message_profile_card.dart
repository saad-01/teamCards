import 'package:flutter/material.dart';
import 'package:nachhaltiges_fahren/constants.dart';

class ProfileCardForMessage extends StatelessWidget {
  const ProfileCardForMessage({
    super.key,
    required this.url,
    required this.disctanceUrl,
    required this.title,
    required this.subtitle,
    required this.thirdtitle,
    required this.editable,
  });
  final String url;
  final String disctanceUrl;
  final String title;
  final String subtitle;
  final String thirdtitle;
  final bool editable;
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
      child: Row(
        children: [
          Row(
            children: [
              editable
                  ? Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(url),
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(47),
                                bottomRight: Radius.circular(47)),
                            color: Color(0x9904814D),
                          ),
                          margin: const EdgeInsets.only(top: 56),
                          height: 38,
                          width: 92,
                          child: const Center(
                              child: Icon(
                            Icons.camera_alt_outlined,
                            color: MyColors.kWhiteColor,
                          )),
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.only(right: 5, left: 20),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(url),
                      ),
                    ),
              const Text(
                "|",
                style: TextStyle(
                    fontSize: 120,
                    color: Color(0xffBDE3D7),
                    fontWeight: FontWeight.w100),
              ),
            ],
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 2,
                    child: Text(
                      title,
                      maxLines: 2,
                      style: const TextStyle(
                          color: MyColors.kBlackColor,
                          fontSize: 26,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0xFF676767),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  if (thirdtitle.isNotEmpty)
                    Flexible(
                      child: Text(
                        thirdtitle,
                        style: const TextStyle(
                            color: MyColors.kGreenColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),
                    )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
