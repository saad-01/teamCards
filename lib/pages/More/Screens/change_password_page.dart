// ignore_for_file: avoid_print, deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/assets/widgets/loading.dart';

import '../../../constants.dart';
import '../../Events/Widgets/appbar_back_arrow_widget.dart';
import '../../Groups/Widgets/edit_profile_image_widget.dart';
import '../../Groups/Widgets/textfield_with_label.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    getUserData();
    setState(() {
      _loading = false;
    });
  }

  final TextEditingController _actualPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _newPasswordRepeatController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Loading();
    }

    return SafeArea(
      child: Scaffold(
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
                  textt: MyLocalization().password.tr,
                ),
                Container(
                    margin:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: EditProfileImageWidget(
                      hasImage: false,
                      editable: false,
                      url: currentUserInformations.image,
                    )),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 340,
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              EditProfileTextField(
                                controller: _actualPasswordController,
                                onChanged: (value) {},
                                title: MyLocalization().oldPassword.tr,
                                hintText: MyLocalization().typePass.tr,
                              ),
                              EditProfileTextField(
                                onChanged: (value) {},
                                controller: _newPasswordController,
                                title: MyLocalization().newPassword.tr,
                                hintText: MyLocalization().typePass.tr,
                              ),
                              EditProfileTextField(
                                onChanged: (value) {},
                                controller: _newPasswordRepeatController,
                                title: MyLocalization().repeatNewPassword.tr,
                                hintText: MyLocalization().typePass.tr,
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
                      onPressed: () async {
                        _changePassword(
                            _actualPasswordController.text,
                            _newPasswordController.text,
                            _newPasswordRepeatController.text,
                            context);
                      },
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
}

void _changePassword(String getActualPassword, String getNewPassword,
    String getNewPasswordRepeat, context) async {
  String email = currentUserInformations.email;
  User user = FirebaseAuth.instance.currentUser!;
  //Create field for user to input old password

  //pass the password here
  String password = getActualPassword;
  String newPassword = getNewPassword;
  String newPasswordRepeat = getNewPasswordRepeat;
  if (newPassword == newPasswordRepeat) {
    if (newPassword.length >= 6) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        user.updatePassword(newPassword).then((_) {
          print("Successfully changed password");
          openSuccsessSnackBar(
              context,
              MyLocalization()
                  .editPasswordPageNotificationPasswordSuccessfullyChanged
                  .tr);
          Navigator.pop(context);
        }).catchError((error) {
          print("Password can't be changed $error");
          openErrorSnackBar(
              context,
              MyLocalization()
                  .editPasswordPageNotificationPasswordChangeFailure
                  .tr);
          //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
        });
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
          openErrorSnackBar(context,
              MyLocalization().editPasswordPageNotificationUserNotFound.tr);
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
          openErrorSnackBar(context,
              MyLocalization().editPasswordPageNotificationWrongPassword.tr);
        }
      }
    } else {
      openErrorSnackBar(context,
          MyLocalization().editPasswordPageNotificationPasswordToShort.tr);
    }
  } else {
    openErrorSnackBar(context,
        MyLocalization().editPasswordPageNotificationPasswordsNotCompliant.tr);
  }
}
