import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/constants.dart';
import '../../../assets/widgets/loading.dart';
import '../../Events/Widgets/appbar_back_arrow_widget.dart';
import '../../Groups/Widgets/edit_profile_image_widget.dart';
import '../../Groups/Widgets/textfield_with_label.dart';

class MyProfileEditPage extends StatefulWidget {
  const MyProfileEditPage({
    Key? key,
  }) : super(key: key);

  @override
  MyProfileEditPageState createState() => MyProfileEditPageState();
}

class MyProfileEditPageState extends State<MyProfileEditPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController costPerKMController = TextEditingController();

  Uint8List byteList = Uint8List(0);
  bool _loading = true;
  bool pickedImage = false;

  String name = "";
  String image = "";
  @override
  void initState() {
    super.initState();

    _getData();
  }

  _getData() async {
    await getUserData();
    await FirebaseFirestore.instance
        .collection(FirebaseCollection().users)
        .doc(currentUserInformations.id)
        .get()
        .then((user) {
      image = user.get('image') ?? "";
      name = user.get('name');

      nameController.text = name;
      costPerKMController.text = user.get('costPerKM').toString();
    });
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Loading();
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: MyColors.kBackGroundColor,
        body: Stack(
          children: [
            Image.asset(
              'assets/event/bg.png',
              height: 230,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
            Column(
              children: [
                AppBarBackArrowWidget(
                  textt: MyLocalization().editProfile.tr,
                ),
                Container(
                    margin:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: GestureDetector(
                      onTap: () async {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles(
                          allowMultiple: false,
                          type: FileType.image,
                          withData: true,
                        );

                        if (result != null) {
                          PlatformFile file = result.files.first;
                          byteList = file.bytes!;
                          pickedImage = true;
                          setState(() {});
                        }
                      },
                      child: EditProfileImageWidget(
                        hasImage: pickedImage,
                        image: Image.memory(Uint8List.fromList(byteList)),
                        url: image,
                      ),
                    )),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 240,
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              EditProfileTextField(
                                  controller: nameController,
                                  title: MyLocalization().name.tr,
                                  onChanged: (value) {},
                                  hintText: MyLocalization().typeName.tr,
                                  url: 'assets/settings/editprofile.png'),
                              EditProfileTextField(
                                controller: costPerKMController,
                                onChanged: (value) {},
                                title: '${MyLocalization().costPerKM.tr}(\$)',
                                hintText: '0.5',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 40),
                  child: ElevatedButton(
                      onPressed: () async => await _updateUser(),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.kGreenColor,
                          shape: const RoundedRectangleBorder(
                              side: BorderSide(
                                  color: MyColors.kBlackColor, width: .2)),
                          foregroundColor: MyColors.kWhiteColor,
                          textStyle: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                          minimumSize: const Size(double.infinity, 52)),
                      child: Text(MyLocalization().save.tr)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  _updateUser() async {
    setState(() {
      _loading = true;
    });
    String userImage = image;

    if (pickedImage) {
      userImage = await uploadImageFirestorage(
          "users", currentUserInformations.id, byteList);
      FirebaseFirestore.instance
          .collection(FirebaseCollection().users)
          .doc(currentUserInformations.id)
          .update({"image": userImage});
    }

    await FirebaseFirestore.instance
        .collection(FirebaseCollection().users)
        .doc(currentUserInformations.id)
        .update({
      'name': nameController.text,
      'image': userImage,
      'costPerKM': double.parse(costPerKMController.text)
    }).then((value) {
      Navigator.pop(context);
      openSuccsessSnackBar(
        context,
        MyLocalization()
            .editProfilePageNotificationProfileUpdatedSuccessfull
            .tr,
      );
      setState(() {
        _loading = false;
      });
    }).catchError((error) {
      openErrorSnackBar(
        context,
        MyLocalization().editProfilePageNotificationProfileUpdatedFailure.tr,
      );
      if (kDebugMode) {
        print("Failed to add group: $error");
      }
    });
  }
}
