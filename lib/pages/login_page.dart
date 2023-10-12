import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/constants.dart';
import 'package:nachhaltiges_fahren/pages/basic_page.dart';
import 'package:nachhaltiges_fahren/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseAuth auth = FirebaseAuth.instance;

  var loggedIn = false;
  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        if (kDebugMode) {
          print('User is currently signed out!');
        }
      } else {
        if (kDebugMode) {
          print('User is signed in!');
        }
      }
    });
  }

  Future<void> initPlatformState() async {
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(Keys.playConfigurationKey);
      await Purchases.configure(configuration);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(Keys.appleConfigurationKey);
      await Purchases.configure(configuration);
    }
  }

  Future<String?> _authUser(LoginData data) async {
    debugPrint('Email: ${data.name}, Password: ${data.password}');

    return await loginUser(data);
  }

  Future<String?> loginUser(LoginData data) async {
    bool successfull = false;
    try {
      successfull = true;
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data.name.replaceAll(' ', ''),
        password: data.password,
      );
      MyPref.saveUserEmail(data.name);
      //configure purchases
      initPlatformState();
      
      if (!FirebaseAuth.instance.currentUser!.emailVerified) {
        await FirebaseAuth.instance.currentUser!.sendEmailVerification();
        await FirebaseAuth.instance.signOut();
        return MyLocalization().loginPageNotificationVerificationMailSend.tr;
      }
    } on FirebaseAuthException catch (e) {
      successfull = false;
      if (e.code == 'user-not-found') {
        if (kDebugMode) {
          print(
            'Kein Benutzer mit dieser Email gefunden!',
          );
          // openErrorSnackBar(
          //   context,
          //   MyLocalization().passwordForgetPageNotificationNoUserWithEmail.tr,
          // );
        }

        return 'User not exists';
      } else if (e.code == 'wrong-password') {
        if (kDebugMode) {
          print(
            'Falsches Passwort für diesen Benutzer!',
          );
        }

        return MyLocalization().registerPageNotificationPasswordNotMatch.tr;
      } else {
        return "";
      }
    }
    if (successfull) {
      successfull = false;

      return null;
    }
  }

  Future<String?> _signupUser(SignupData data) {
    return createNewUser(data);
  }

  Future<String?> createNewUser(SignupData data) async {
    bool successfull = false;
    try {
      successfull = true;
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: data.name!.replaceAll(' ', ''), password: data.password!);
    } on FirebaseAuthException catch (e) {
      successfull = false;
      if (e.code == 'weak-password') {
        if (kDebugMode) {
          print('The password provided is too weak.');
        }
      } else if (e.code == 'email-already-in-use') {
        if (kDebugMode) {
          print('The account already exists for that email.');
        }
        return MyLocalization().registerPageNotificationEmailInUse.tr;
      } else {
        if (kDebugMode) {
          print(e.code);
        }
        return "";
      }
      return "";
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    if (kDebugMode) {
      print("IsSuccessfull: $successfull");
    }
    if (successfull) {
      final user = FirebaseAuth.instance.currentUser;
      await user?.updateDisplayName(data.additionalSignupData!['Name']);
      await user?.updateEmail(data.name!.replaceAll(' ', ''));
      await FirebaseAuth.instance.setLanguageCode("de");
      CollectionReference users =
          FirebaseFirestore.instance.collection(FirebaseCollection().users);
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      await users.doc(auth.currentUser!.uid).set({
        'email': data.name!.replaceAll(' ', ''),
        'fcmtoken': "",
        'id': auth.currentUser!.uid,
        'image': placeHolderProfileImage,
        'lastLogin': DateTime.now(),
        'registerDate': DateTime.now(),
        'name': data.additionalSignupData!['Name'],
        'pushNotification': true,
        'level': 1,
        'points': 0,
        'onboardingScreenDone': false,
        'roleAdmin': false,
        'platform': userPlatform(),
        'version': packageInfo.version,
        'howFound': data.additionalSignupData!['TeamCarWoGefunden'],
        'costPerKM': 0.30
      }).catchError((error) {
        if (kDebugMode) {
          print("Failed to add user: $error");
        }
        return MyLocalization().registerPageNotificationUserCreatedFailure.tr;
      }).whenComplete(() async {
        if (!kIsWeb) {
          await analytics.logEvent(
              name: "user_registration",
              parameters: {'userId': auth.currentUser!.uid});
        }
        await FirebaseAuth.instance.currentUser!.sendEmailVerification();
        await FirebaseAuth.instance.signOut();
      });
      return null;
    }
  }

  Future<String?> _recoverPassword(String name) {
    return forgetPassword(name);
  }

  Future<String?> forgetPassword(String name) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: name,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        if (kDebugMode) {
          print(
            'Kein Benutzer mit dieser Email gefunden!',
          );
        }
        openErrorSnackBar(
          context,
          MyLocalization().passwordForgetPageNotificationNoUserWithEmail.tr,
        );
      }
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      theme: LoginTheme(
        titleStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        primaryColor: MyColors.primaryColor.withOpacity(0.6),
        accentColor: MyColors.subheadingColor,
        buttonTheme: LoginButtonTheme(
          backgroundColor: MyColors.primaryColor,
          splashColor: MyColors.subheadingColor,
        ),
      ),
      loginAfterSignUp: false,
      title: appName,
      logo: const AssetImage('lib/assets/images/logo_removebg.png'),
      onLogin: _authUser,
      onSignup: _signupUser,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const BasicPage(),
        ));
      },
      initialAuthMode: AuthMode.login,
      additionalSignupFields: [
        UserFormField(
          keyName: "Name",
          displayName: MyLocalization().registerPageFullnameLable.tr,
          fieldValidator: (value) {
            if (value == null || value == "") {
              return MyLocalization().registerPageNotificationNameNotNull.tr;
            } else {
              return null;
            }
          },
          userType: LoginUserType.name,
          icon: const Icon(Icons.person),
        ),
        UserFormField(
            keyName: "TeamCarWoGefunden",
            displayName: MyLocalization().registerPageHowFoundTeamCarLable.tr,
            icon: const Icon(Icons.question_mark))
      ],
      termsOfService: [
        TermOfService(
            id: "Datenschutz",
            mandatory: true,
            text: MyLocalization().registerPagePrivacy.tr,
            linkUrl: "https://teamcar.app/datenschutzerklaerung/"),
        TermOfService(
            id: "AGBs",
            mandatory: true,
            text: MyLocalization().registerPageDetermination.tr,
            linkUrl:
                "https://kevindroll.de/wp-content/uploads/2023/08/Allgemeine-Geschaeftsbedingungen.pdf"),
        TermOfService(
            id: "Nutzungsbedingungen",
            mandatory: true,
            text: MyLocalization().registerPageTermsOfUse.tr,
            linkUrl:
                "https://teamcar.app/wp-content/uploads/2023/08/Nutzungsbedingungen-TeamCar.pdf")
      ],
      userType: LoginUserType.email,
      onRecoverPassword: _recoverPassword,
      navigateBackAfterRecovery: true,
      messages: LoginMessages(
          forgotPasswordButton:
              MyLocalization().loginPagePasswordForgetButton.tr,
          recoverPasswordButton:
              MyLocalization().passwordForgetPageResetPasswordButton.tr,
          signupButton: MyLocalization().registerPageRegisterButton.tr,
          loginButton: MyLocalization().loginPageLoginButton.tr,
          recoverPasswordSuccess:
              MyLocalization().passwordForgetPageNotificationResetEmailSent.tr,
          confirmationCodeValidationError:
              MyLocalization().loginPageNotificationUnexpectedError.tr,
          confirmPasswordError:
              MyLocalization().loginPageNotificationWrongPassword.tr,
          confirmSignupSuccess: MyLocalization()
              .registerPageNotificationUserCreatedSuccessfull
              .tr,
          confirmSignupButton: MyLocalization().registerPageRegisterButton.tr,
          passwordHint: MyLocalization().loginPagePasswordLable.tr,
          confirmPasswordHint: MyLocalization().registerPagePasswordLable.tr,
          recoverPasswordIntro:
              MyLocalization().passwordForgetPageHeaderText.tr,
          recoverPasswordDescription:
              MyLocalization().passwordForgetPageFooterText.tr,
          goBackButton: MyLocalization().registerPageBackButton.tr,
          additionalSignUpSubmitButton:
              MyLocalization().registerPageRegisterButton.tr,
          additionalSignUpFormDescription:
              MyLocalization().registerPageAdditionalSignUpFormDescription.tr),
    );
  }
}
