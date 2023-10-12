import 'package:flutter/material.dart';
import 'package:nachhaltiges_fahren/constants.dart';

class EditProfileImageWidget extends StatelessWidget {

  const EditProfileImageWidget({
    super.key,
    required this.url,
    required this.hasImage,
    this.image,
    this.editable = true,
    this.asset = false,
  });

  final String url;
  final bool hasImage;
  final Image? image;
  final bool editable;
  final bool asset;

  @override
  Widget build(BuildContext context) {
    ImageProvider img = !asset ? NetworkImage(url) : AssetImage(url) as ImageProvider;
    return Container(
      height: 140,
      width: 140,
      decoration: BoxDecoration(
        color: MyColors.kWhiteColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MyColors.kBlackColor, width: .2),
      ),
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
        child: CircleAvatar(
          radius: 50,
          backgroundImage: hasImage ? image!.image : img,
          child: Visibility(
            visible: editable,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(38),
                    bottomRight: Radius.circular(38)),
                color: Color(0x9904814D),
              ),
              margin: const EdgeInsets.only(top: 72),
              height: 35,
              width: 106,
              child: GestureDetector(
                  onTap: () {},
                  child: const Center(
                      child: Icon(
                    Icons.camera_alt_outlined,
                    color: MyColors.kWhiteColor,
                  ))),
            ),
          ),
        ),
      ),
    );
  }
}
