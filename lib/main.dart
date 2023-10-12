import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:internet_connectivity_checker/internet_connectivity_checker.dart';
import 'package:nachhaltiges_fahren/constants.dart';
import 'package:nachhaltiges_fahren/locale_notification_service.dart';
import 'package:nachhaltiges_fahren/pages/Events/Screens/event_details_page.dart';
import 'package:nachhaltiges_fahren/pages/Messages/Screens/chat_details.dart';
import 'package:nachhaltiges_fahren/pages/Splash/Screens/splash_screen2.dart';
import 'package:nachhaltiges_fahren/pages/basic_page.dart';
import 'package:nachhaltiges_fahren/pages/Groups/Screens/group_add_member_by_link_page.dart';
import 'package:nachhaltiges_fahren/pages/Splash/Screens/language_select_page.dart';
import 'package:nachhaltiges_fahren/pages/offline_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash_screen_view/SplashScreenView.dart';
import 'firebase_options.dart';
import 'localization_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPlatformState();
  MobileAds.instance.initialize();
  tz.initializeTimeZones();
  //await getCurrentUserLoggedIn();
  //await getFirebaseInstance();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await GetStorage.init();
  await NotificationService().initialize();
  /*await FirebaseAppCheck.instance.activate(
    webRecaptchaSiteKey: '6LeahIsjAAAAAHeOdZYtEC1bMJLdg5BMavBI3CEZ',
    androidProvider: AndroidProvider.playIntegrity,
  );*/

  // Set the background messaging handler early on, as a named top-level function
  Widget nextWidget = const LanguageSelectPage(first: true);

  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (user == null) {
      if (kDebugMode) {
        print('User is currently signed out!');
      }
    } else {
      if (kDebugMode) {
        print('User is signed in!');
      }
      if (user.emailVerified) {
        await getUserData();

        await FirebaseFirestore.instance
            .collection(FirebaseCollection().users)
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'lastLogin': DateTime.now(),
          'platform': userPlatform(),
          'version': packageInfo.version
        });
        /*await analytics.logAppOpen();
        await analytics.setUserId(id: FirebaseAuth.instance.currentUser!.uid);
        await analytics.setCurrentScreen(screenName: 'Main');*/

        if (!kIsWeb) {
          await getInitialLink().then((value) {
            if (value != null) {
              nextWidget = GroupAddMemberByLinkPage(groupId: value);
            } else {
              nextWidget = const BasicPage();
            }
          }).onError((error, stackTrace) {
            if (kDebugMode) {
              print("Error in initialLink: $error");
            }
            nextWidget = const BasicPage();
          });
          // Not supported on web
          await FirebaseAnalytics.instance
              .setDefaultEventParameters({'version': packageInfo.version});
        } else {
          nextWidget = const BasicPage();
        }

        if (kDebugMode) {
          print(
              "OnBoardingDone: ${currentUserInformations.onboardingScreenDone}");
        }
      }
    }
    runApp(
      ProviderScope(
        child: MyApp(
          destinationSite: nextWidget,
        ),
      ),
    );
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
Future<String?> getInitialLink() async {
  String groupid = "groupid";
  final appLinks = AppLinks();
  final PendingDynamicLinkData? linkData =
      await FirebaseDynamicLinks.instance.getInitialLink();
  if (linkData != null) {
    return linkData.link.queryParameters[groupid];
  } else {
    final Uri? uri = await appLinks.getInitialAppLink();
    if (uri != null) {
      final PendingDynamicLinkData? applinkData =
          await FirebaseDynamicLinks.instance.getDynamicLink(uri);
      if (applinkData != null) {
        return applinkData.link.queryParameters[groupid];
      }
    }
  }
  return null;
}

class MyApp extends StatefulWidget {
  final Widget destinationSite;
  const MyApp({Key? key, required this.destinationSite}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: HomeBuilder(
        destinationSite: widget.destinationSite,
      ),
      title: appName, translations: LocalizationService(), // your translations
      locale: LocalizationService()
          .getCurrentLocale(), // translations will be displayed in that locale
      fallbackLocale: const Locale(
        'de',
        'DE',
      ), // specify the fallback locale in case an invalid locale is selected.
    );
  }
}

class HomeBuilder extends StatefulWidget {
  final Widget destinationSite;
  const HomeBuilder({Key? key, required this.destinationSite})
      : super(key: key);

  @override
  State<HomeBuilder> createState() => _HomeBuilderState();
}

class _HomeBuilderState extends State<HomeBuilder> {
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  @override
  Widget build(BuildContext context) {
    return SplashScreenView(
      navigateRoute: Scaffold(
        body: Builder(
          builder: ((context) {
            if (!kIsWeb) {
              return internetConnectivityBuilder(
                interval: 1000,
                (ConnectivityStatus status) {
                  if (status == ConnectivityStatus.online) {
                    return widget.destinationSite;
                  } else if (status == ConnectivityStatus.offine) {
                    return const OfflinePage();
                  } else {
                    return const SplashScreen2();
                  }
                },
              );
            } else {
              return widget.destinationSite;
            }
          }),
        ),
      ),
      duration: 2300,
      imageSize: 130,
      imageSrc: "lib/assets/icon/playstore.png",
      text: appName,
      textType: TextType.NormalText,
      textStyle: GoogleFonts.racingSansOne(
        fontSize: 25,
        color: MyColors.secondColor,
        letterSpacing: 1,
      ),
      backgroundColor: Colors.white,
    );
  }
}
