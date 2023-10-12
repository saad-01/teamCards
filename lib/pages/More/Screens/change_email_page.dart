// ignore_for_file: avoid_print, deprecated_member_use, unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/assets/widgets/loading.dart';

import '../../../constants.dart';
import '../../Events/Widgets/appbar_back_arrow_widget.dart';
import '../../Groups/Widgets/edit_profile_image_widget.dart';
import '../../Groups/Widgets/textfield_with_label.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({Key? key}) : super(key: key);

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    getUserData();
    setState(() {
      _loading = false;
    });
  }

  final _oldEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _newEmailController = TextEditingController();

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
                  textt: MyLocalization().email.tr,
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
                                controller: _oldEmailController,
                                onChanged: (value) {},
                                title: MyLocalization().oldEmail.tr,
                                hintText: MyLocalization().typeEmail.tr,
                              ),
                              EditProfileTextField(
                                controller: _newEmailController,
                                title: MyLocalization().newEmail.tr,
                                onChanged: (value) {},
                                hintText: MyLocalization().typeEmail.tr,
                              ),
                              EditProfileTextField(
                                controller: _passwordController,
                                onChanged: (value) {},
                                title: MyLocalization().password.tr,
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
                        _changeEmail(
                            _passwordController.text,
                            _oldEmailController.text,
                            _newEmailController.text,
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

  void _changeEmail(
      String getPassword, String oldEmail, String getNewEmail, context) async {
    String email = oldEmail;
    User user = FirebaseAuth.instance.currentUser!;
    //Create field for user to input old password

    //pass the password here
    String password = getPassword;
    String newEmail = getNewEmail;
    if (newEmail != null) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        user.updateEmail(newEmail).then((_) {
          print("Successfully changed email");
          openSuccsessSnackBar(context,
              MyLocalization().editEmailPageNotificationEditMailSuccessful.tr);

          CollectionReference users =
              FirebaseFirestore.instance.collection(FirebaseCollection().users);

          users
              .doc(currentUserInformations.id)
              .update({'email': newEmail})
              .then((value) => print("User Updated in Firebase"))
              .catchError((error) =>
                  print("Failed to update user in Firebase: $error"));
          Navigator.pop(context);
          setState(() {});
        }).catchError((error) {
          print("Email can't be changed $error");
          openErrorSnackBar(context,
              MyLocalization().editEmailPageNotificationEditMailFailure.tr);
          //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
        });
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
          openErrorSnackBar(context,
              MyLocalization().editEmailPageNotificationEditMailNoUserFound.tr);
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
          openErrorSnackBar(context, 'Falsches Passwort zu diesem Benutzer');
        }
      }
    } else {
      openErrorSnackBar(
          context,
          MyLocalization()
              .editEmailPageNotificationEditMailEmailCouldNotEmpty
              .tr);
    }
  }
}
