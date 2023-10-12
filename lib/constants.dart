import 'dart:convert';
import 'dart:math';
import 'package:address_search_field/address_search_field.dart' as asfadress;
import 'package:advanced_in_app_review/advanced_in_app_review.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nachhaltiges_fahren/assets/widgets/loading.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

// for in-app purchases
class Keys {
  static const playConfigurationKey = 'goog_REPlNCdtqqFBBfUtLXBfREKlmTg';
  static const appleConfigurationKey = 'appl_uXnYCJFJeywwTvyIqFczsUVpHZh';
  static const playMonthlyPlan = 'remove_ads';
}

const List<String> monthsDE = [
  "Januar",
  "Februar",
  "März",
  "April",
  "Mai",
  "Juni",
  "Juli",
  "August",
  "September",
  "Oktober",
  "November",
  "Dezember"
];
const List<String> monthsEN = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  'December'
];
const List<String> monthsES = [
  "Enero",
  "Febrero",
  "Marzo",
  "Abril",
  "Mayo",
  "Junio",
  "Julio",
  "Agosto",
  "Septiembre",
  "Octubre",
  "Noviembre",
  "Diciembre"
];

//Dynamic Links
const String kUriPrefix = 'https://teamcar.page.link';
const String kUri = 'https://teamcar.page.link';
const String kGroupAddLink = '/inviteMember';
const String kHomepageLink = '/homepage';
FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
FirebaseAnalytics analytics = FirebaseAnalytics.instance;

//Basics
const String appName = "TeamCar";
const String appCompanyName = "Kevin Droll";
const String placeHolderProfileImage =
    "https://firebasestorage.googleapis.com/v0/b/nachhaltiges-fahren.appspot.com/o/users%2Fperson.png?alt=media&token=281cb021-84dc-47cb-afac-9873419820b0";
const String placeHolderGroupsImage =
    "https://firebasestorage.googleapis.com/v0/b/nachhaltiges-fahren.appspot.com/o/groups%2Fgroup.png?alt=media&token=9b8cbc8e-caf5-4ae9-8d7a-88d90dc75312";
const String googleMapsApiKey = "AIzaSyB-mkE-5cBYclibchfDThocLtT1qCPJSbM";
const String appleAppStorId = '6443935116';
const String googleAdMobAndroidBannerId =
    "ca-app-pub-3940256099942544/6300978111"; //Test ID ca-app-pub-3940256099942544/6300978111
const String googleAdMobIOSBannerId =
    "ca-app-pub-3940256099942544/2934735716"; //Test ID ca-app-pub-3940256099942544/2934735716
const num levelUpValue = 20;
late CurrentUser currentUserInformations;
const double minWidthCard = 400;

asfadress.GeoMethods geoMethods = asfadress.GeoMethods(
  googleApiKey: googleMapsApiKey,
  language: 'DE',
);

class NavigationDrawerItems {
  String title;
  Icon icon;
  Widget route;
  int id;

  NavigationDrawerItems({
    required this.id,
    required this.icon,
    required this.route,
    required this.title,
  });
}

// List<NavigationDrawerItems> drawerItems = [
//   NavigationDrawerItems(
//     id: 0,
//     icon: const Icon(Icons.home),
//     route: const HomePage(),
//     title: MyLocalization().navigationHome.tr,
//   ),
//   NavigationDrawerItems(
//     id: 1,
//     icon: const Icon(Icons.calendar_month),
//     route: const EventsPage(),
//     title: MyLocalization().navigationEvents.tr,
//   ),
//   NavigationDrawerItems(
//     id: 2,
//     icon: const Icon(Icons.local_parking),
//     route: const MyRidesPage(),
//     title: MyLocalization().navigationMyRides.tr,
//   ),
//   NavigationDrawerItems(
//     id: 3,
//     icon: const Icon(Icons.verified_user),
//     route: const MyGuestRidesPage(),
//     title: MyLocalization().navigationMyTakenRides.tr,
//   ),
//   NavigationDrawerItems(
//     id: 4,
//     icon: const Icon(Icons.message),
//     route: const MessagePage(),
//     title: MyLocalization().navigationMessages.tr,
//   ),
//   NavigationDrawerItems(
//     id: 5,
//     icon: const Icon(Icons.group),
//     route: const GroupSettingsPage(),
//     title: MyLocalization().navigationMyGroups.tr,
//   ),
//   NavigationDrawerItems(
//     id: 6,
//     icon: const Icon(Icons.settings),
//     route: const SettingsPage(),
//     title: MyLocalization().navigationSettings.tr,
//   ), /*
//   NavigationDrawerItems(
//     id: 6,
//     icon: const Icon(Icons.search),
//     route: const SearchPage(),
//     title: "Suchen",
//   ),*/
// ];

//TextStyles

class MyTextstyles {
  static TextStyle kTitleStyle = TextStyle(
    color: MyColors.headingColor,
    fontWeight: FontWeight.bold,
  );

  static TextStyle kSubtitleStyle = TextStyle(
    color: MyColors.subheadingColor,
    fontWeight: FontWeight.w500,
  );

  static TextStyle kFilterStyle = TextStyle(
    color: Color(MyColors.bg02),
    fontWeight: FontWeight.w500,
  );

  static TextStyle appBarTitleStyle =
      GoogleFonts.racingSansOne(fontSize: 36, color: MyColors.primaryColor);
}

const kHintTextStyle = TextStyle(
  color: Colors.white54,
  fontFamily: 'OpenSans',
);

const kLabelStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontFamily: 'OpenSans',
);

//TextInputFieldStyles

class MyTextInputFieldStyles {
  static InputDecoration getWhiteSpacePrimaryBorder(String title) {
    return InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(
          width: 3,
          color: MyColors.primaryColor.withOpacity(0.6),
        ),
      ),
      hintText: title,
      focusColor: MyColors.subheadingColor,
      fillColor: MyColors.textFiledFillColor,
      filled: true,
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(
          width: 3,
          color: MyColors.subheadingColor.withOpacity(0.6),
        ),
      ),
    );
  }
}

final kBoxDecorationStyle = BoxDecoration(
  color: const Color(0xFF6CA8F1),
  borderRadius: BorderRadius.circular(10.0),
  boxShadow: const [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 6.0,
      offset: Offset(0, 2),
    ),
  ],
);

//Colors
class MyColors {
  static const kGreenColor = Color(0xff04814D);
  static const kBlackColor = Color(0xff525252);
  static const kBackGroundColor = Color(0xffF2F2F2);
  static const kWhiteColor = Color(0xffFFFFFF);

  static int heading = 0xff151a56;
  static int subheading = 0xff9796af;
  static int primary = 0xff575de3;
  static int purple01 = 0xff918fa5;
  static int purple02 = 0xff6b6e97;
  static int yellow01 = 0xffeaa63b;
  static int yellow02 = 0xfff29b2b;
  static int bg = 0xfff5f3fe;
  static int bg01 = 0xff6f75e1;
  static int bg02 = 0xffc3c5f8;
  static int bg03 = 0xffe8eafe;
  static int text01 = 0xffbec2fc;
  static int grey01 = 0xffe9ebf0;

  static Color headingColor = const Color.fromARGB(255, 32, 116, 74);
  static Color subheadingColor = const Color.fromARGB(255, 114, 107, 78);
  static Color primaryColor = const Color.fromARGB(255, 119, 142, 113);
  static Color secondColor = const Color.fromARGB(208, 143, 184, 138);
  static Color thirdColor = const Color.fromARGB(255, 182, 182, 182);
  static Color secondNavColor = const Color.fromARGB(255, 82, 205, 98);
  static Color textFiledFillColor = const Color.fromARGB(255, 255, 255, 255);
}

//Firebase Collections
class FirebaseCollection {
  final String users = "users";
  final String groups = "group";
  final String events = "event";
  final String rides = "ride";
  final String developmentIdeas = "developmentideas";
  final String chatMessages = "chatmessages";
  final String chatRoom = "chatroom";
  final String historyPoints = "history_points";
}

class PointsPerAction {
  final int addRideSeat = 3;
  final int useFreeSeat = 1;
}

//Date Formatter
final DateFormat formatterDDMMYYYHHMMSS = DateFormat('dd.MM.yyyy HH:mm:ss');
final DateFormat formatterDDMMYYYHHMM = DateFormat('dd.MM.yyyy HH:mm');
final DateFormat formatterDDMMYYYY = DateFormat('dd.MM.yyyy');
final DateFormat formatterYYYYMMDDHHMMSS = DateFormat('yyyyMMddHHmmss');
final DateFormat formatterHHMM = DateFormat('HH:mm');
final DateFormat formatterWeekDay = DateFormat('EEEE');
final DateFormat formatterDD = DateFormat('dd');

//Localization Links
class MyLocalization {
  final String minutes = "minutes";
  final String previous = "before";
  final String later = "after";
  final String somethingWentWrong = "Sorry, something went wrong";
  final String ideaEditSuccess = 'idea_edit_success';
  final String working = "working";
  final String month = 'month';
  final String year = 'year';
  final String rideIsCreated = 'ride_is_created';
  final String youCannotChooseYourRide = 'you_cant_choose_your_ride';
  final String youHaveRide = 'you_have_ride_this_time';

  // Intro
  final String event = "event";
  final String eventText = "event_text";
  final String group = "group";
  final String groupText = "group_text";
  final String ride = "ride";
  final String rideText = "ride_text";
  final String statistics = "statistics";
  final String statisticsText = "statistics_text";
  final String invite = "invite";
  final String inviteText = "invite_text";
  final String next = "next";
  final String back = "back";
  final String rides = "rides";

  // Home
  final String level = "level";
  final String location = "location";
  final String date = "date";
  final String time = "time";
  final String myFutureRides = "available_rides";
  final String noRideText = "no_rides";
  final String noEventText = "no_events";
  final String addRideText = "tap_to_add_ride";
  final String addEventText = "tap_to_add_event";
  final String addGroup = "add_group";
  final String addEvent = "add_event";
  final String inviteFriend = "invite_friend";
  final String home = "home";
  final String events = "events";
  final String messages = "messages";
  final String more = "more";
  final String distance = "distance";

  // Events
  final String departureAddress = "departure_address";
  final String selectSeat = "select_seat";
  final String offerSeat = "offer_seat";
  final String description = "description";
  final String freeSeats = "free_seats";
  final String offeredSeats = "offered_seats";
  final String eventDetails = "event_details";
  final String address = "address";
  final String recurring = "recurring";
  final String createEvent = "create_event";
  final String eventTitle = "event_title";
  final String summary = "summary";
  final String image = "image";
  final String filter = "filter";
  final String from = "from:";
  final String actualPosition = "actual_position";
  final String all = "all";
  final String offer = "offer";
  final String selectImage = "select_image";
  final String flexibleTime = "Flexible time";

  // Rides and settings
  final String myRides = "my_rides";
  final String futureRides = "future_rides";
  final String pastRides = "past_rides";
  final String myTakenRides = "my_taken_rides";
  final String settings = "settings";
  final String myGroups = "my_groups";
  final String removeAds = "Remove Ads";
  final String noMessages = "no_messages";
  final String messageTip = "message_tip";
  final String drivers = "drivers";
  final String now = "now";
  final String chat = "chat";
  final String notification = "notification";
  final String language = "language";
  final String developmentIdeas = "development_ideas";
  final String releaseNotes = "release_notes";
  final String help = "help";
  final String feedback = "feedback";
  final String review = "review";
  final String logOut = "log_out";
  final String editProfile = "edit_profile";
  final String changeEmail = "change_email";
  final String changePassword = "change_password";
  final String deleteUser = "delete_user";
  final String name = "name";
  final String typeName = "type_name";
  final String profile = "profile";
  final String costPerKM = "cost_per_km";
  final String save = "save";
  final String password = "password";
  final String email = "email";
  final String oldPassword = "old_password";
  final String newPassword = "new_password";
  final String repeatNewPassword = "repeat_new_password";
  final String oldEmail = "old_email";
  final String newEmail = "new_email";
  final String typePass = "type_pass";
  final String typeEmail = "type_email";
  final String points = "points";
  final String offeredCars = "offered_cars";
  final String totalCostKM = "total_cost_km";
  final String seatsOffered = "seats_offered";
  final String selectedSeats = "selected_seats";
  final String drivenKm = "driven_km";
  final String logOutText = "log_out_text";
  final String cancel = "cancel";
  final String deleteUserText = "delete_user_text";

  final String addGroupText = "add_group_text";
  final String participants = "participants";
  final String search = "search";
  final String removeGroup = "remove_group";
  final String admin = "admin";
  final String activities = "activities";
  final String totalRides = "total_rides";
  final String editGroup = "edit_group";
  final String totalPoints = "total_points";
  final String passenger = "passenger";
  final String earnedMoney = "earned_money";

  // Ideas
  final String ideas = "ideas";
  final String addIdeaText = "add_idea_text";
  final String remarks = "remarks";
  final String status = "status";
  final String subject = "subject";
  final String addIdea = "add_idea";
  final String invitation = "invitation";
  final String invitationText = "invite_text";
  final String closed = "closed";
  final String open = "open";
  final String openIdeas = "open_ideas";
  final String closedIdeas = "closed_ideas";
  final String checkBilling = "check_billing";

  //Register Page
  final String registerPageFullnameLable = "register_page_Fullname_lable";
  final String registerPageEmailLable = "register_page_email_lable";
  final String registerPagePasswordLable = "register_page_password_lable";
  final String registerPageRegisterButton = "register_page_register_button";
  final String registerPageDetermination = "register_page_determination";
  final String registerPagePrivacy = "register_page_privacy";
  final String registerPageTermsOfUse = "register_page_termsofuse";

  final String registerPageLoggedInButton = "register_page_loggedin_button";

  final String registerPageNotificationEmailInUse =
      "register_page_notification_email_in_use";
  final String registerPageNotificationUnexpectedError =
      "register_page_notification_unexpected_error";
  final String registerPageNotificationUserCreatedSuccessfull =
      "register_page_notification_user_created_successfull";
  final String registerPageNotificationUserCreatedFailure =
      "register_page_notification_user_created_failure";
  final String registerPageBackButton = "register_page_back_button";
  final String registerPageNotificationNameNotNull =
      "register_page_notification_name_not_null";
  final String registerPageNotificationPasswordNotMatch =
      "register_page_notification_password_not_match";
  final String registerPageHowFoundTeamCarLable =
      "register_page_how_found_teamcar_lable";
  final String registerPageAdditionalSignUpFormDescription =
      "register_page_additional_signup_form_description";
  //Login Page
  final String loginPageEmailLable = "login_page_email_lable";
  final String loginPagePasswordLable = "login_page_password_lable";
  final String loginPagePasswordForgetButton =
      "login_page_password_forget_button";
  final String loginPageLoginButton = "login_page_login_button";

  final String loginPageNotRegisteredButton =
      "login_page_not_registered_button";
  final String loginPageRegisterButton = "login_page_register_button";

  final String loginPageNotificationWrongPassword =
      "login_page_notification_wrong_password";
  final String loginPageNotificationUnexpectedError =
      "login_page_notification_unexpected_error";
  final String loginPageNotificationVerificationMailSend =
      "login_page_notification_verification_mail_send";

  //Navigation
  final String navigationHome = "navigation_home";
  final String navigationEvents = "navigation_events";
  final String navigationMyRides = "navigation_my_rides";
  final String navigationMyTakenRides = "navigation_my_taken_rides";
  final String navigationMessages = "navigation_messages";
  final String navigationSettings = "navigation_settings";
  final String navigationMyGroups = "navigation_my_groups";
  //Dashboard
  final String dashboardPageTitle = "dashboard_page_title";

  final String dashboardPageAddGroupButton = "dashboard_page_add_group_button";
  final String dashboardPageInviteMemberButton =
      "dashboard_page_invite_member_button";
  final String dashboardPageAddEventButton = "dashboard_page_add_event_button";
  final String dashboardPageMyStatisticsButton =
      "dashboard_page_my_statistics_button";
  final String dashboardPageSendFeedbackButton =
      "dashboard_page_send_feedback_button";
  final String dashboardPageHelpButton = "dashboard_page_help_button";
  final String dashboardPageDevelopmentIdeasButton =
      "dashboard_page_development_ideas_button";
  final String dashboardPageReviewButton = "dashboard_page_review_button";
  final String dashboardPageNextEventsLable =
      "dashboard_page_next_events_lable";
  final String dashboardPageNextEventsButton =
      "dashboard_page_next_events_button";
  final String dashboardPageNextRidesLable = "dashboard_page_next_rides_lable";
  final String dashboardPageNextRidesButton =
      "dashboard_page_next_rides_button";
  final String dashboardPageDialogCreateEventsTitle =
      'dashboard_page_dialog_create_events_title';
  final String dashboardPageDialogCreateEventsDescription =
      'dashboard_page_dialog_create_events_description';
  final String dashboardPageDialogCreateEventsButton =
      'dashboard_page_dialog_create_events_button';
  final String dashboardPageNoEvents = 'dashboard_page_dialog_no_events';
  final String dashboardPageNoRides = 'dashboard_page_dialog_no_rides';
  //Add Group
  final String addGroupPageTitle = "add_group_page_title";
  final String addGroupPageNameLable = "add_group_page_name_lable";
  final String addGroupPageDescriptionLable =
      "add_group_page_description_lable";
  final String addGroupPageSelectPictureButton =
      "add_group_page_select_picture_button";
  final String addGroupPageSaveButton = "add_group_page_save_button";
  final String addGroupPageNotificationGroupAddedSuccessfull =
      "add_group_page_notification_group_added_successfull";
  final String addGroupPageNotificationGroupAddedFailure =
      "add_group_page_notification_group_added_failure";
  final String addGroupPageNotificationNameNotNull =
      "add_group_page_notification_name_not_null";
  //Invite Member
  final String inviteMemberPageTitle = "invite_member_page_title";
  final String inviteMemberPageDescription = "invite_member_page_description";
  final String inviteMemberPageSuccessSnackbarText =
      "invite_member_page_success_snackbar_text";
  //Add Event
  final String availableEvents = "available_events";
  final String addEventPageTitle = "add_event_page_title";
  final String addEventPageGroupLable = "add_event_page_group_lable";
  final String addEventPageEventTitleLable = "add_event_page_event_title_lable";
  final String addEventPageDescriptionLable =
      "add_event_page_description_lable";
  final String addEventPageDateLable = "add_event_page_date_lable";
  final String addEventPageAdressLable = "add_event_page_adress_lable";
  final String addEventPageSaveButton = "add_event_page_save_button";
  final String addEventPageNotificationLocationDisabled =
      "add_event_page_notification_location_disabled";
  final String addEventPageNotificationLocationDenied =
      "add_event_page_notification_location_denied";
  final String addEventPageNotificationLocationForeverDenied =
      "add_event_page_notification_location_forever_denied";
  final String addEventPageNotificationEventMustInFuture =
      "add_event_page_notification_event_must_in_future";
  final String addEventPageNotificationNoTitle =
      "add_event_page_notification_no_title";
  final String addEventPageAdressSearchCancelButton =
      "add_event_page_adress_search_cancel_button";
  final String addEventPageAdressSearchSaveButton =
      "add_event_page_adress_search_save_button";
  final String addEventPageAdressSearchHint =
      "add_event_page_adress_search_hint";
  final String addEventPageAdressSearchNoResult =
      "add_event_page_adress_search_no_result";
  final String addEventPageDateTimePickerCancelButton =
      "add_event_page_date_time_picker_cancel_button";
  final String addEventPageDateTimePickerSaveButton =
      "add_event_page_date_time_picker_save_button";
  final String addEventPageDateTimePickerTitle =
      "add_event_page_date_time_picker_title";
  final String addEventPageDateTimePickerDateLable =
      "add_event_page_date_time_picker_date_lable";
  final String addEventPageDateTimePickerTimeLable =
      "add_event_page_date_time_picker_time_lable";
  final String addEventPageNotificationEventCreated =
      "add_event_page_notification_event_created";
  final String addEventPageNotificationEventNotCreated =
      "add_event_page_notification_event_not_created";
  final String addEventPageSummaryLable = "add_event_page_summary_lable";
  final String addEventPageRecurringLable = "add_event_page_recurring_lable";
  final String addEventPageRecurringCycleDropdownDaily =
      "add_event_page_recurring_cycle_dropdown_daily";
  final String addEventPageRecurringCycleDropdownWeekly =
      "add_event_page_recurring_cycle_dropdown_weekly";
  final String addEventPageRecurringCycleDropdownMonthly =
      "add_event_page_recurring_cycle_dropdown_monthly";
  final String addEventPageRecurringCycleDropdownYearly =
      "add_event_page_recurring_cycle_dropdown_yearly";
  final String addEventPageRecurringEndDateLable =
      "add_event_page_recurring_end_date_lable";
  final String addEventPageNotificationRecurringEndDateBeforeStartDate =
      "add_event_page_notification_recurring_end_date_before_start_date";
  final String addEventPageRecurringIntervalLable =
      "add_event_page_recurring_interval_lable";
  final String addEventPageRecurringHint = "add_event_page_recurring_hint";
  final String addEventPageNotificationLocationNotValid =
      "add_event_page_notification_event_lcoation_not_valid";
  //My Statistic
  final String myStatisticPageTitle = "my_statistic_page_title";
  final String myStatisticPageLevelLable = "my_statistic_page_level_lable";
  final String myStatisticPagePointsLable = "my_statistic_page_points_lable";
  final String myStatisticPageOfferedCarsLable =
      "my_statistic_page_offered_cars_lable";
  final String myStatisticPageOfferedSeatsLable =
      "my_statistic_page_offered_seats_lable";
  final String myStatisticPageTakenPersonsLable =
      "my_statistic_page_taken_persons_lable";
  final String myStatisticPageSavedCO2Lable =
      "my_statistic_page_saved_co2_lable";
  final String myStatisticPageDrivenKMLable =
      "my_statistic_page_driven_km_lable";
  final String myStatisticPageDrivenKMCostLable =
      "my_statistic_page_driven_km_cost_lable";
  //Help
  final String helpPageTitle = "help_page_title";
  final String helpPageItemAddGroupTitle = "help_page_item_add_group_title";
  final String helpPageItemAddGroupText = "help_page_item_add_group_text";
  final String helpPageItemInviteMemberTitle =
      "help_page_item_invite_member_title";
  final String helpPageItemInviteMemberText =
      "help_page_item_invite_member_text";
  final String helpPageItemAddEventTitle = "help_page_item_add_event_title";
  final String helpPageItemAddEventText = "help_page_item_add_event_text";
  final String helpPageItemLevelTitle = "help_page_item_points_title";
  final String helpPageItemLevelText = "help_page_item_points_text";
  final String helpPageItemFeedbackTitle = "help_page_item_feedback_title";
  final String helpPageItemFeedbackText = "help_page_item_feedback_text";
  final String helpPageItemFunctionwishTitle =
      "help_page_item_functionwish_title";
  final String helpPageItemFunctionwishText =
      "help_page_item_functionwish_text";
  final String helpPageItemEnterGroupTitle = "help_page_item_enter_group_title";
  final String helpPageItemEnterGroupText = "help_page_item_enter_group_text";
  final String helpPageItemPointsRewardsTitle =
      "help_page_item_points_rewards_title";
  final String helpPageItemPointsRewardsText =
      "help_page_item_points_rewards_text";
  final String helpPageItemNewFunctionsTitle =
      "help_page_item_new_functions_title";
  final String helpPageItemNewFunctionsText =
      "help_page_item_new_functions_text";
  final String helpPageItemErrorMessageTitle =
      "help_page_item_error_message_title";
  final String helpPageItemErrorMessageText =
      "help_page_item_error_message_text";
  final String helpPageItemAddChatTitle = "help_page_item_add_chat_title";
  final String helpPageItemAddChatText = "help_page_item_add_chat_text";
  //Development Ideas
  final String developmentIdeasPageTitle = "development_ideas_page_title";
  final String developmentIdeasPageAddIdeaButton =
      "development_ideas_page_add_ideas_button";
  final String developmentIdeasPageFilterButton =
      "development_ideas_page_filter_button";
  final String developmentIdeasPageNoIdeasAvailable =
      "development_ideas_page_no_ideas_available";
  final String developmentIdeasPageStatusLable =
      "development_ideas_page_status_lable";
  //Create Development Idea
  final String addDevelopmentIdeasPageTitle =
      "add_development_ideas_page_title";
  final String addDevelopmentIdeasPageSubjectLable =
      "add_development_ideas_page_subject_lable";
  final String addDevelopmentIdeasPageDescriptionLable =
      "add_development_ideas_page_description_lable";
  final String addDevelopmentIdeasPageSaveButton =
      "add_development_ideas_page_save_button";
  final String addDevelopmentIdeasPageNotificationNoTitle =
      "add_development_ideas_page_notification_no_title";
  final String addDevelopmentIdeasPageNotificationThankYouForEntering =
      "add_development_ideas_page_notification_thank_you_for_entering";
  final String addDevelopmentIdeasPageNotificationFailure =
      "add_development_ideas_page_notification_failure";
  //Filter Development Ideas
  final String filterDevelopmentIdeasModalTitle =
      "add_development_ideas_modal_title";
  final String filterDevelopmentIdeasModalDoneButton =
      "add_development_ideas_modal_done_button";
  final String filterDevelopmentIdeasModalUndoneButton =
      "add_development_ideas_modal_undone_button";
  //Development details
  final String developmentIdeasDetailsPageCreatedAt =
      'development_ideas_page_created_at';
  final String developmentIdeasDetailsPageStatus =
      'development_ideas_page_status';
  final String developmentIdeasDetailsPageLikes =
      'development_ideas_page_likes';
  final String developmentIdeasDetailsPageRemark =
      'development_ideas_page_remark';
  //Events
  final String eventsPageTitle = "events_page_title";
  final String eventsPageAddEventButton = "events_page_add_event_button";
  final String eventsPageFilterButton = "events_page_filter_button";
  final String eventsPageNoEvents = "events_page_no_events";
  //Filter Events
  final String filterEventsModalTitle = "events_modal_title";
  final String filterEventsModalDoneButton = "events_modal_done_button";
  final String filterEventsModalUndoneButton = "events_modal_undone_button";
  //Event Details
  final String eventDetailsPageNotificationError =
      "event_details_page_notification_error";
  final String eventDetailsPageOClock = "event_details_page_o_clock";
  final String eventDetailsPageEventAdress = "event_details_page_event_adress";
  final String eventDetailsPageOfferedCars = "event_details_page_offered_cars";
  final String eventDetailsPageFreeSeats = "event_details_page_free_seats";
  final String eventDetailsPageLocation = "event_details_page_location";
  final String eventDetailsPageRemark = "event_details_page_remark";
  final String eventDetailsPageOfferSeatsButton =
      "event_details_page_offer_seats_button";
  final String eventDetailsPageSelectOfferdSeatsButton =
      "event_details_page_select_offerd_seats_button";
  final String eventDetailsPageInfoSeatsAlreadyOffered =
      "event_details_page_info_seats_already_offered";
  final String eventDetailsPagePickerFreeSeatsLable =
      "event_details_page_picker_free_seats_lable";
  final String eventDetailsPageDrivingStartLocationLable =
      "event_details_page_driving_start_location_lable";
  final String eventDetailsPageAdressSearchCancelButton =
      "event_details_page_adress_search_cancel_button";
  final String eventDetailsPageAdressSearchSaveButton =
      "event_details_page_adress_search_save_button";
  final String eventDetailsPageAdressSearchHintText =
      "event_details_page_adress_search_hint_text";
  final String eventDetailsPageAdressSearchNoAdressFound =
      "event_details_page_adress_search_no_adress_found";
  final String eventDetailsPageDateTimePickerCancelButton =
      "event_details_page_date_time_picker_cancel_button";
  final String eventDetailsPageDateTimePickerSaveButton =
      "event_details_page_date_time_picker_save_button";
  final String eventDetailsPageDateTimePickerTitle =
      "event_details_page_date_time_picker_title";
  final String eventDetailsPageDateTimePickerTimeLable =
      "event_details_page_date_time_picker_time_lable";
  final String eventDetailsPageDateTimePickerDateLable =
      "event_details_page_date_time_picker_date_lable";
  final String eventDetailsPageNotificationDepartureTimeMustLater =
      "event_details_page_notification_departure_time_must_later";
  final String eventDetailsPageOfferSeatsSaveButton =
      "event_details_page_offer_seats_save_button";
  final String eventDetailsPageFreeSeatsLable =
      "event_details_page_free_seats_lable";
  final String eventDetailsPageDescriptionLable =
      "event_details_page_description_lable";
  final String eventDetailsPageNotificationSeatsWillBeOffered =
      "event_details_page_notificaiton_seats_will_be_offered";
  final String eventDetailsPageNotificationSeatsCanNotBeOffered =
      "event_details_page_notificaiton_seats_can_not_be_offered";
  final String eventDetailsPageNotificationMaxSeats =
      "event_details_page_notificaiton_max_seats";
  final String eventDetailsPageNotificationMinSeats =
      "event_details_page_notificaiton_min_seats";
  final String eventDetailsPageFlexibleTimeCheckBoxLable =
      "event_details_page_flexible_time_checkbox_lable";
  final String eventDetailsPageFlexibleTimeRange =
      "event_details_page_flexible_time_range_lable";
  final String eventDetailsPageRemoveDialogTitle =
      "event_details_page_remove_dialog_title";
  final String eventDetailsPageRemoveDialogText =
      "event_details_page_remove_dialog_text";
  final String eventDetailsPageRemoveDialogDeleteButton =
      "event_details_page_remove_dialog_delete_button";
  final String eventDetailsPageRemoveDialogCancelButton =
      "event_details_page_remove_dialog_cancel_button";
  final String eventDetailsPageRemoveDialogNotificationSuccessfull =
      "event_details_page_remove_dialog_notifiation_successfull";
  final String eventDetailsPageRemoveDialogNotificationFailure =
      "event_details_page_remove_dialog_notifiation_failure";
  //My Rides (Meine Fahrten)
  final String myRidesPageTitle = "my_rides_page_title";
  final String myRidesPageNoRidesText = "my_rides_page_no_rides_text";
  final String myRidesPageFilterButton = "my_rides_page_filter_button";
  //Filter My Rides
  final String filterMyRidesModalTitle = "my_rides_modal_title";
  final String filterMyRidesModalDoneButton = "my_rides_modal_done_button";
  final String filterMyRidesModalUndoneButton = "my_rides_modal_undone_button";
  //My Drives (Meine Mitfahrten)
  final String myDrivesPageTitle = "my_drives_page_title";
  final String myDrivesPageNoRidesText = "my_drives_page_no_rides_text";
  final String myDrivesPageFilterButton = "my_drives_page_filter_button";
  //Filter My Drives
  final String filterMyDrivesModalTitle = "my_drives_modal_title";
  final String filterMyDrivesModalDoneButton = "my_drives_modal_done_button";
  final String filterMyDrivesModalUndoneButton =
      "my_drives_modal_undone_button";
  //Chats
  final String chatsPageTitle = "chats_page_title";
  final String chatPageMessageTextfieldHint =
      "chat_page_message_text_field_hint";
  final String chatPageUserLastOnline = "chat_page_user_last_online";
  final String chatPageNotMessagesAvailable =
      "chat_page_not_messages_available";
  //Settings
  final String settingsPageTitle = "settings_page_title";
  final String settingsPageItemUser = "settings_page_item_user";
  final String settingsPageItemGroups = "settings_page_item_groups";
  final String settingsPageItemNotification = "settings_page_item_notification";
  final String settingsPageItemLanguage = "settings_page_item_language";
  final String settingsPageItemDevelopmentIdeas =
      "settings_page_item_development_ideas";
  final String settingsPageItemReleasNotes = "settings_page_item_release_notes";
  final String settingsPageItemHelp = "settings_page_item_help";
  final String settingsPageItemReview = "settings_page_item_review";
  final String settingsPageItemIntroduction = "settings_page_item_introduction";
  final String settingsPageItemLogout = "settings_page_item_logout";
  final String settingsPageItemFeedback = "settings_page_item_feedback";
  final String settingsPageDialogLogoutQuestion =
      "settings_page_dialog_logout_question";
  final String settingsPageDialogLogoutAcceptButton =
      "settings_page_dialog_logout_accept_button";
  final String settingsPageDialogLogoutCancelButton =
      "settings_page_dialog_logout_cancel_button";
  final String settingsPageVersion = "settings_page_version";
  final String settingsPageBadgeSoonAvailable =
      "settings_page_badge_soon_available";
  //Settings => User
  final String userSettingsPageTitle = "user_settings_page_title";
  final String userSettingsPageItemStatistic =
      "user_settings_page_item_statistic";
  final String userSettingsPageItemEditProfile =
      "user_settings_page_item_edit_profile";
  final String userSettingsPageItemEditEmail =
      "user_settings_page_item_edit_email";
  final String userSettingsPageItemEditPassword =
      "user_settings_page_item_edit_password";
  final String userSettingsPageItemDeleteUser =
      "user_settings_page_item_delete_user";
  final String userSettingsPageDialogDeleteUserTitle =
      "user_settings_page_dialog_delete_user_title";
  final String userSettingsPageDialogDeleteUserQuestion =
      "user_settings_page_dialog_delete_user_question";
  final String userSettingsPageNotificationUserDeletedSuccessfull =
      "user_settings_page_notification_user_deleted_successfull";
  final String userSettingsPageDialogDeleteUserDeleteButton =
      "user_settings_page_dialog_delete_user_delete_button";
  final String userSettingsPageDialogDeleteUserCancelButton =
      "user_settings_page_dialog_delete_user_cancel_button";
  //Settings => User => Edit Profile
  final String editProfilePageTitle = "edit_profile_page_title";
  final String editProfilePageNameLable = "edit_profile_page_name_lable";
  final String editProfilePageSaveButton = "edit_profile_page_save_button";
  final String editProfilePageChangePictureButton =
      'edit_profile_page_change_picture_button';
  final String editProfilePageNotificationProfileUpdatedSuccessfull =
      'edit_profile_page_notification_profile_updated_successfull';
  final String editProfilePageNotificationProfileUpdatedFailure =
      'edit_profile_page_notification_profile_updated_failure';
  final String editProfilePageCostPerKMLable =
      "edit_profile_page_cost_per_km_lable";
  //Settings => User => Edit Email
  final String editEmailPageTitle = "edit_email_page_title";
  final String editEmailPageNewEmailLable = "edit_email_page_new_email_lable";
  final String editEmailPagePasswordLable = "edit_email_page_password_lable";
  final String editEmailPageSaveButton = "edit_email_page_save_button";
  final String editEmailPageNotificationEditMailSuccessful =
      "edit_email_page_notification_edit_mail_successfull";
  final String editEmailPageNotificationEditMailFailure =
      "edit_email_page_notification_edit_mail_failure";
  final String editEmailPageNotificationEditMailNoUserFound =
      "edit_email_page_notification_edit_mail_no_user_found";
  final String editEmailPageNotificationEditMailEmailCouldNotEmpty =
      "edit_email_page_notification_edit_mail_email_could_not_empty";
  //Settings => User => Edit Password
  final String editPasswordPageTitle = "edit_password_page_title";
  final String editPasswordPageActualPasswordLable =
      "edit_password_page_actual_password_lable";
  final String editPasswordPageNewPasswordLable =
      "edit_password_page_new_password_lable";
  final String editPasswordPageNewPasswordConfirmationLable =
      "edit_password_page_password_confirmation_lable";
  final String editPasswordPageSaveButton = "edit_password_page_save_button";
  final String editPasswordPageNotificationPasswordSuccessfullyChanged =
      "edit_password_page_notification_password_successfully_changed";
  final String editPasswordPageNotificationPasswordChangeFailure =
      "edit_password_page_notification_password_change_failure";
  final String editPasswordPageNotificationUserNotFound =
      "edit_password_page_notification_user_not_found";
  final String editPasswordPageNotificationWrongPassword =
      "edit_password_page_notification_wrong_password";
  final String editPasswordPageNotificationPasswordToShort =
      "edit_password_page_notification_password_to_short";
  final String editPasswordPageNotificationPasswordsNotCompliant =
      "edit_password_page_notification_passwords_not_compliant";
  //Settings => Group
  final String groupSettingsPageTitle = "group_settings_page_title";
  final String groupSettingsPageItemMyGroups =
      "group_settings_page_item_my_groups";
  final String groupSettingsPageItemAddGroup =
      "group_settings_page_item_add_groups";
  //Settings => Group => My Groups
  final String myGroupsPageTitle = "my_groups_page_title";
  final String myGroupsPageAddGroupButton = "my_groups_page_add_group_button";
  final String myGroupsPageFilterButton = "my_groups_page_filter_button";
  //Feedback
  final String feedbackPageTitle = "feedback_page_title";
  final String feedbackPageTextfieldHint = "feedback_page_textfield_hint";
  final String feedbackPageSendButton = "feedback_page_send_button";
  final String feedbackPageNotificationNoText = "feedback_page_no_text";
  //Add Group member by Link
  final String addGroupMemberByLinkPageGroupNameIfNotAvailable =
      "add_group_member_by_link_page_group_name_if_not_available";
  final String addGroupMemberByLinkPageTextIfNotAvailable =
      "add_group_member_by_link_page_text_if_not_available";
  final String addGroupMemberByLinkPageTitle =
      'add_group_member_by_link_page_title';
  final String addGroupMemberByLinkPageAddGroupButton =
      'add_group_member_by_link_page_add_group_button';
  final String addGroupMemberByLinkPageNotificationGroupAddedSuccessfull =
      'add_group_member_by_link_page_notification_group_added_successfull';
  final String addGroupMemberByLinkPageNotificationGroupAddedFailure =
      'add_group_member_by_link_page_notification_group_added_failure';
  //Group Details Member
  final String groupDetailsMemberPageNoMember =
      'group_details_member_page_no_member';
  final String groupDetailsMemberPageDialogRemoveAdministratorTitle =
      'group_details_member_page_dialog_remove_adminstrator_title';
  final String groupDetailsMemberPageDialogRemoveAdministratorQuestion =
      'group_details_member_page_dialog_remove_adminstrator_question';
  final String groupDetailsMemberPageNotificationRemoveAdministratorFailure =
      'group_details_member_page_notification_remove_adminstrator_failure';
  final String
      groupDetailsMemberPageNotificationRemoveAdministratorFailureDescription =
      'group_details_member_page_notification_remove_adminstrator_failure_description';
  final String
      groupDetailsMemberPageDialogRemoveAdministratorFailureAcceptButton =
      'group_details_member_page_dialog_remove_adminstrator_failure_accept_button';
  final String groupDetailsMemberPageDialogRemoveAdministratorRemoveButton =
      'group_details_member_page_dialog_remove_adminstrator_remove_button';
  final String groupDetailsMemberPageDialogRemoveAdministratorCancelButton =
      'group_details_member_page_dialog_remove_adminstrator_cancel_button';
  final String groupDetailsMemberPageDialogAddAdministratorTitle =
      'group_details_member_page_dialog_add_adminstrator_title';
  final String groupDetailsMemberPageDialogAddAdministratorQuestion =
      'group_details_member_page_dialog_add_adminstrator_question';
  final String groupDetailsMemberPageDialogAddAdministratorAddButton =
      'group_details_member_page_dialog_add_adminstrator_add_button';
  final String groupDetailsMemberPageDialogAddAdministratorCancelButton =
      'group_details_member_page_dialog_add_adminstrator_cancel_button';
  //Group Details Page
  final String groupDetailsPageNotifiationUnexpectedError =
      'group_details_page_notification_unexpected_error';
  final String groupDetailsPageNotifiationInvitementCopied =
      'group_details_page_notification_invitement_copied';
  final String groupDetailsPageRemarkLable = 'group_details_page_remark_lable';
  final String groupDetailsPageLeaveGroupButton =
      'group_details_page_leave_group_button';
  final String groupDetailsPageDialogLeavGroupTitle =
      'group_details_page_dialog_leave_group_title';
  final String groupDetailsPageDialogLeavGroupQuestion =
      'group_details_page_dialog_leave_group_question';
  final String groupDetailsPageNotificationLeavGroupFailure =
      'group_details_page_notification_leave_group_failure';
  final String groupDetailsPageNotificationLeavGroupSuccessfull =
      'group_details_page_notification_leave_group_successfull';
  final String groupDetailsPageDialogLeaveGroupButton =
      'group_details_page_dialog_leave_group_button';
  final String groupDetailsPageDialogCancelButton =
      'group_details_page_dialog_cancel_button';
  final String groupDetailsPageRemoveGroupButton =
      'group_details_page_remove_group_button';
  final String groupDetailsPageBottomSheetRemoveGroupForeverButton =
      'group_details_page_bottom_sheet_remove_group_forever_button';
  final String groupDetailsPageBottomSheetCancelButton =
      'group_details_page_bottom_sheet_cancel_button';
  final String groupDetailsPageNotificationRemoveGroupSuccessfull =
      'group_details_page_notification_remove_group_successfull';
  final String groupDetailsPageNotificationRemoveGroupFailure =
      'group_details_page_notification_remove_group_failure';
  final String groupDetailsPageBottomSheetRemoveGroupTitle =
      'group_details_page_bottom_sheet_remove_group_title';
  final String groupDetailsPageMemberCardTitle =
      'group_details_page_member_card_title';
  final String groupDetailsPageAdminCardTitle =
      'group_details_page_admin_card_title';
  final String groupDetailsPageCreatedAtLable =
      'group_details_page_created_at_lable';
  //Group edit
  final String groupEditPageSaveButton = 'group_edit_page_save_button';
  final String groupEditPageNameLable = 'group_edit_page_name_lable';
  final String groupEditPageDescriptionLable =
      'group_edit_page_description_lable';
  final String groupEditPageTitle = 'group_edit_page_title';
  final String groupEditPageEditPictureButton =
      'group_edit_page_edit_picture_button';
  final String groupEditPageNotificationRemovePictureSuccessfull =
      'group_edit_page_notification_remove_picture_successfull';
  final String groupEditPageRemovePictureButton =
      'group_edit_page_remove_picture_button';
  final String groupEditPageNotificationUpdateGroupSuccessfull =
      'group_edit_page_notification_update_group_successfull';
  final String groupEditPageNotificationUpdateGroupFailure =
      'group_edit_page_notification_update_group_failure';
  //Group Page
  final String groupPageNoGroups = 'group_page_not_groups';
  //Group Select Page
  final String groupSelectPageNoGroups = 'group_select_page_no_groups';
  //Introduction Page
  final String instructionPageTitle = 'instruction_page_title';
  final String instructionPageItem1Title = 'instruction_page_item_1_title';
  final String instructionPageItem1Text = 'instruction_page_item_1_text';
  final String instructionPageItem2Title = 'instruction_page_item_2_title';
  final String instructionPageItem2Text = 'instruction_page_item_2_text';
  final String instructionPageItem3Title = 'instruction_page_item_3_title';
  final String instructionPageItem3Text = 'instruction_page_item_3_text';
  final String instructionPageItem4Title = 'instruction_page_item_4_title';
  final String instructionPageItem4Text = 'instruction_page_item_4_text';
  final String instructionPageItem5Title = 'instruction_page_item_5_title';
  final String instructionPageItem5Text = 'instruction_page_item_5_text';
  final String instructionPageItem6Title = 'instruction_page_item_6_title';
  final String instructionPageItem6Text = 'instruction_page_item_6_text';
  final String instructionPageItem7Title = 'instruction_page_item_7_title';
  final String instructionPageItem7Text = 'instruction_page_item_7_text';
  final String instructionPageSkipButton = 'instruction_page_skip_button';
  final String instructionPageFinishButton = 'instruction_page_finish_button';
  //Language Page
  final String languagePageTitle = 'language_page_title';
  //Messages Page
  final String messagesPageNoMessages = 'messages_page_no_messages';
  final String messagesPageNoChatrooms = 'messages_page_no_chatrooms';
  //Offline Page
  final String offlinePageTitle = 'offline_page_title';
  final String offlinePageText1 = 'offline_page_text_1';
  final String offlinePageText2 = 'offline_page_text_2';
  //Password forget Page
  final String passwordForgetPageTitle = 'password_forget_page_title';
  final String passwordForgetPageEmailLable =
      'password_forget_page_email_lable';
  final String passwordForgetPageNotificationNoUserWithEmail =
      'password_forget_page_notification_no_user_with_email';
  final String passwordForgetPageNotificationResetEmailSent =
      'password_forget_page_notification_reset_email_sent';
  final String passwordForgetPageResetPasswordButton =
      'password_forget_page_reset_password_button';
  final String passwordForgetPagePasswordRemember =
      'password_forget_page_password_remember';
  final String passwordForgetPageLoginButton =
      'password_forget_page_login_button';
  final String passwordForgetPageHeaderText =
      'password_forget_page_header_text';
  final String passwordForgetPageFooterText =
      'password_forget_page_footer_text';
  //Profile Page
  final String profilePagePointsLable = 'profile_page_points_lable';
  //Release Notes Page
  final String releaseNotesPageTitle = 'release_notes_page_title';
  final String relaseNotesVersion = 'release_notes_version';
  final String relaseNotesItem1 = 'release_notes_item_1';
  final String relaseNotesItem2 = 'release_notes_item_2';
  final String relaseNotesItem3 = 'release_notes_item_3';
  final String relaseNotesItem4 = 'release_notes_item_4';
  final String relaseNotesItem5 = 'release_notes_item_5';
  final String relaseNotesItem6 = 'release_notes_item_6';
  final String relaseNotesItem7 = 'release_notes_item_7';
  final String relaseNotesItem8 = 'release_notes_item_8';
  final String relaseNotesItem9 = 'release_notes_item_9';
  final String relaseNotesItem10 = 'release_notes_item_10';
  final String relaseNotesItem11 = 'release_notes_item_11';
  final String relaseNotesItem12 = 'release_notes_item_12';
  final String relaseNotesItem13 = 'release_notes_item_13';
  final String relaseNotesItem14 = 'release_notes_item_14';
  final String relaseNotesItem15 = 'release_notes_item_15';
  final String relaseNotesItem16 = 'release_notes_item_16';
  final String relaseNotesItem17 = 'release_notes_item_17';
  final String relaseNotesItem18 = 'release_notes_item_18';
  final String relaseNotesItem19 = 'release_notes_item_19';
  //Ride Details Page
  final String rideDetailsPageUnexpectedError =
      'ride_details_page_unexpected_error';
  final String rideDetailsPageOClock = 'ride_details_page_o_clock';
  final String rideDetailsPageStartAdress = 'ride_details_page_start_adress';
  final String rideDetailsPageOfferedSeats = 'ride_details_page_offered_seats';
  final String rideDetailsPageFreeSeats = 'ride_details_page_free_seats';
  final String rideDetailsPageRemark = 'ride_details_page_remark';
  final String rideDetailsPageLocation = 'ride_details_page_location';
  final String rideDetailsPagePassengers = 'ride_details_page_passengers';
  final String rideDetailsPageNoPassengers = 'ride_details_page_no_passengers';
  final String rideDetailsPageInAnotherCar = 'ride_details_page_in_another_car';
  final String rideDetailsPageTimeIsOver = 'ride_details_page_time_is_over';
  final String rideDetailsPageCarFull = 'ride_details_page_car_full';
  final String rideDetailsPageGetInButton = 'ride_details_page_get_in_button';
  final String rideDetailsPageNotificationGetInSuccessfull =
      'ride_details_page_notification_get_in_successfull';
  final String rideDetailsPageNotificationUnexpectedError =
      'ride_details_page_notification_get_in_failure';
  final String rideDetailsPageGetOutButton = 'ride_details_page_get_out_button';
  final String rideDetailsPageNotificationGetOutSuccessfull =
      'ride_details_page_notification_get_out_successfull';
  final String rideDetailsPageCancelRideButton =
      'ride_details_page_cancel_ride_button';
  final String rideDetailsPageNotificationCancelRideSuccessfull =
      'ride_details_page_notification_cancel_ride_successfull';
  final String rideDetailsPageContactDriver =
      'ride_details_page_constact_driver';
  final String rideDetailsPageEventDetailsLable =
      'ride_details_page_event_details_lable';
  final String rideDetailsPageStartRouteButton =
      'ride_details_page_start_route_button';
  final String rideDetailsPageRideDetailsLable =
      'ride_details_page_ride_details_lable';
  final String rideDetailsPagePassengerDetailsLable =
      'ride_details_page_passenger_details_lable';
  final String rideDetailsPagePassengerRemovedFromCarButton =
      'ride_details_page_passenger_removed_from_car_button';
  final String rideDetailsPageNotificationPassengerRemovedFromCarSuccessfull =
      'ride_details_page_notification_passenger_removed_from_car_successfull';
  final String rideDetailsPageNotificationPassengerRemovedFromCarFailure =
      'ride_details_page_notification_passenger_removed_from_car_failure';
  //Ride Edit page
  final String rideEditPageStartAdressLable =
      'ride_edit_page_start_adress_lable';
  final String rideEditPageAdressSearchCancelButton =
      'ride_edit_page_adress_search_cancel_button';
  final String rideEditPageAdressSearchSaveButton =
      'ride_edit_page_adress_search_save_button';
  final String rideEditPageAdressSearchHint =
      'ride_edit_page_adress_search_hint';
  final String rideEditPageAdressSearchNoAdressFound =
      'ride_edit_page_adress_search_no_adress_found';
  final String rideEditPageDateTimePickerTitle =
      'ride_edit_page_date_time_picker_title';
  final String rideEditPageDateTimePickerCancelButton =
      'ride_edit_page_date_time_picker_cancel_button';
  final String rideEditPageDateTimePickerSaveButton =
      'ride_edit_page_date_time_picker_save_button';
  final String rideEditPageDateTimePickerDateLable =
      'ride_edit_page_date_time_picker_date_lable';
  final String rideEditPageDateTimePickerTimeLable =
      'ride_edit_page_date_time_picker_time_lable';
  final String rideEditPageSaveButton = 'ride_edit_page_save_button';
  final String rideEditPageOfferdSeatsLable =
      'ride_edit_page_offered_seats_lable';
  final String rideEditPageDescriptionLable =
      'ride_edit_page_description_lable';
  final String rideEditPageTitle = 'ride_edit_page_title';
  final String rideEditPageNotificationSeatsEditSuccessfull =
      'ride_edit_page_notification_seats_edit_successfull';
  final String rideEditPageNotificationSeatsEditFailure =
      'ride_edit_page_notification_seats_edit_failure';
  //Ride Select Page
  final String rideSelectPageNoRides = 'ride_select_page_no_rides';
  final String rideSelectPageActualPosition =
      'ride_select_page_actual_position';
  final String rideSelectPageFromAddressLable =
      'ride_select_page_from_address_lable';
  final String rideSelectPageFilterAllLable =
      'ride_select_page_filter_all_lable';
  final String rideSelectPageTravelTimeLable =
      'ride_select_page_travel_time_lable';
  final String rideSelectPageTravelTimeHour =
      'ride_select_page_travel_time_hour';
  final String rideSelectPageTravelTimeMinute =
      'ride_select_page_travel_time_minute';
  //Level Description
  final String levelDescriptionLevel0 = 'level_description_level_0';
  final String levelDescriptionLevel1 = 'level_description_level_1';
  final String levelDescriptionLevel2 = 'level_description_level_2';
  final String levelDescriptionLevel3 = 'level_description_level_3';
  final String levelDescriptionLevel4 = 'level_description_level_4';
  final String levelDescriptionLevel5 = 'level_description_level_5';
  //History Points page
  final String historyPointsPageTitle = 'history_points_page_title';
  final String historyPointsNoPointsHistory =
      'history_points_page_no_points_history';
  final String historyPointsItemHeadlineRideAdded =
      'history_points_item_headline_ride_added';
  final String historyPointsItemHeadlineRideRemoved =
      'history_points_item_headline_ride_removed';
  final String historyPointsItemHeadlineSeatGetIn =
      'history_points_item_headline_seat_get_in';
  final String historyPointsItemHeadlineSeatGetOut =
      'history_points_item_headline_seat_get_out';
  final String historyPointsItemHeadlinePointsLable =
      'history_points_item_headline_points_lable';
}

class Languages {
  String language;

  String imagePath;
  Languages({
    required this.imagePath,
    required this.language,
  });
}

List<Languages> languageSelection = [
  Languages(
    imagePath: "lib/assets/images/flags/germany.jpg",
    language: "Deutsch",
  ),
  Languages(
    imagePath: "lib/assets/images/flags/england.png",
    language: "English",
  ),
  Languages(
    imagePath: "lib/assets/images/flags/spain.png",
    language: "Español",
  ),
];

//Functions

//DynamicLink

Future<String> createDynamicLink(bool short, String link) async {
  final DynamicLinkParameters parameters = DynamicLinkParameters(
    uriPrefix: kUriPrefix,
    link: Uri.parse(kUriPrefix + link),
    androidParameters: const AndroidParameters(
      packageName: 'de.kevindroll.nachhaltigesfahren',
      minimumVersion: 0,
    ),
    iosParameters:
        const IOSParameters(bundleId: "de.kevindroll.nachhaltigesfahren"),
  );

  Uri url;
  if (short) {
    final ShortDynamicLink shortLink =
        await dynamicLinks.buildShortLink(parameters);
    url = shortLink.shortUrl;
  } else {
    url = await dynamicLinks.buildLink(parameters);
  }

  return url.toString();
}

//Firebase Messaging FCM
void sendPushMessage(String deviceToken, String title, String text,
    {Map info = const {}}) async {
  try {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=', //HERE to place the key for working
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': text, 'title': title},
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'info': info,
          },
          "to": deviceToken,
        },
      ),
    );
  } catch (e) {
    if (kDebugMode) {
      print("error push notification");
    }
  }
}

//Snackbar
openErrorSnackBar(context, String text) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: Colors.red,
    content: Row(
      children: [
        const Icon(
          Icons.error_outline,
          color: Colors.white,
        ),
        const SizedBox(
          width: 5,
        ),
        Expanded(child: Text(text))
      ],
    ),
    duration: const Duration(milliseconds: 2500),
  ));
}

openSuccsessSnackBar(context, String text) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: Colors.green,
    content: Row(
      children: [
        const Icon(
          Icons.check,
          color: Colors.white,
        ),
        const SizedBox(
          width: 5,
        ),
        Expanded(child: Text(text))
      ],
    ),
    duration: const Duration(milliseconds: 2500),
  ));
}

openWarningSnackBar(context, String text) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: Colors.yellow,
    content: Row(
      children: [
        const Icon(
          Icons.warning,
          color: Colors.black,
        ),
        const SizedBox(
          width: 5,
        ),
        Expanded(
          child: Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
          ),
        )
      ],
    ),
    duration: const Duration(milliseconds: 12500),
  ));
}

//Show Toast
Future showToast(String message) async {
  await Fluttertoast.cancel();
  Fluttertoast.showToast(msg: message, fontSize: 18);
}

class EventCard extends StatefulWidget {
  final void Function() onTap;
  final String title;
  final String subtitle;
  final String date;
  final String time;
  final String image;
  final GeoPoint location;

  const EventCard({
    Key? key,
    required this.onTap,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
    required this.image,
    required this.location,
  }) : super(key: key);

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  @override
  void initState() {
    super.initState();
    _getData();
  }

  late GeoData _locationAdress;

  bool _loading = true;

  _getData() async {
    try {
      _locationAdress = await Geocoder2.getDataFromCoordinates(
        latitude: widget.location.latitude,
        longitude: widget.location.longitude,
        googleMapApiKey: googleMapsApiKey,
        language: 'de',
      );

      setState(() {
        _loading = false;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    // if (_loading) {
    //   return const Loading();
    // }
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: MyColors.primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  /*
                  CircleAvatar(
                        backgroundColor: Colors.transparent,
                        backgroundImage: NetworkImage(image),
                      ),*/
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            image: widget.image.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(widget.image))
                                : null,
                            color: Colors.transparent),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.title,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white)),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            overflow: TextOverflow.ellipsis,
                            widget.subtitle,
                            style: const TextStyle(color: Colors.white60),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          const Text(
                            overflow: TextOverflow.ellipsis,
                            "Country", //"${_locationAdress.countryCode} - ${_locationAdress.postalCode} ${_locationAdress.city}",
                            style: const TextStyle(color: Colors.white60),
                            softWrap: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ScheduleCard(date: widget.date, time: widget.time),
                ],
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 10,
          decoration: BoxDecoration(
            color: MyColors.secondColor,
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 40, right: 40, bottom: 15),
          height: 10,
          decoration: BoxDecoration(
            color: MyColors.secondColor.withOpacity(0.6),
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

class RideCard extends StatefulWidget {
  final void Function() onTap;
  final List passenger;
  final String desription;
  final int freeSeats;
  final int offeredSeats;
  final String image;
  final String title;
  final String createdById;
  final String subtitle;
  final String eventDate;
  final GeoPoint location;
  const RideCard({
    Key? key,
    required this.onTap,
    required this.image,
    required this.desription,
    required this.freeSeats,
    required this.offeredSeats,
    required this.title,
    required this.createdById,
    required this.subtitle,
    required this.eventDate,
    required this.location,
    required this.passenger,
  }) : super(key: key);

  @override
  State<RideCard> createState() => _RideCardState();
}

class _RideCardState extends State<RideCard> {
  final List<Widget> _icons = [];
  @override
  void initState() {
    super.initState();

    getData();
  }

  getData() async {
    _icons.clear();
    for (int i = 0; i < widget.freeSeats; i++) {
      _icons.add(
        const Icon(Icons.chair_rounded),
      );
    }

    /*for (int k = freeSeats; k < offeredSeats; k++) {
                                  _icons.add(const Icon(Icons
                                      .airline_seat_recline_normal_outlined));
                                }*/
    if (widget.passenger.isNotEmpty) {
      for (var user in widget.passenger) {
        await FirebaseFirestore.instance
            .collection(FirebaseCollection().users)
            .doc(user)
            .get()
            .then((userValue) {
          _icons.add(
            CircleAvatar(
              backgroundImage: NetworkImage(userValue['image']),
            ),
          );
        });
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          decoration: BoxDecoration(
            color: MyColors.primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: NetworkImage(widget.image),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white)),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                overflow: TextOverflow.ellipsis,
                                widget.subtitle,
                                style: const TextStyle(color: Colors.white60),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                            ]),
                      ],
                    ),
                    Builder(
                      builder: (context) {
                        Widget buildIcon(int index) {
                          return _icons[index];
                        }

                        return SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Wrap(
                            spacing: 2.0, // gap between adjacent chips
                            runSpacing: 4.0, // gap between lines
                            direction: Axis.horizontal,
                            clipBehavior: Clip.antiAlias,
                            children: _icons
                                .asMap()
                                .entries
                                .map(
                                  (MapEntry map) => buildIcon(map.key),
                                )
                                .toList(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SeatCard(
                        location: widget.location, eventDate: widget.eventDate),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          width: double.infinity,
          height: 10,
          decoration: BoxDecoration(
            color: MyColors.secondColor,
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 40, right: 40, bottom: 15),
          width: double.infinity,
          height: 10,
          decoration: BoxDecoration(
            color: MyColors.secondColor.withOpacity(0.6),
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final String time;
  final String date;
  const ScheduleCard({
    Key? key,
    required this.time,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MyColors.secondColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.calendar_today,
                color: Colors.white,
                size: 15,
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                date,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.access_alarm,
                color: Colors.white,
                size: 17,
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                time,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SeatCard extends StatefulWidget {
  final GeoPoint location;
  final String eventDate;
  const SeatCard({
    Key? key,
    required this.eventDate,
    required this.location,
  }) : super(key: key);

  @override
  State<SeatCard> createState() => _SeatCardState();
}

class _SeatCardState extends State<SeatCard> {
  @override
  void initState() {
    super.initState();
    _getData();
  }

  bool _loading = true;
  GeoData _locationAdress = GeoData(
    address: "",
    city: "",
    country: "",
    latitude: 0,
    longitude: 0,
    postalCode: "",
    state: "",
    countryCode: "",
    streetNumber: "",
  );
  _getData() async {
    _locationAdress = await Geocoder2.getDataFromCoordinates(
        latitude: widget.location.latitude,
        longitude: widget.location.longitude,
        googleMapApiKey: googleMapsApiKey);

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Loading();
    }

    return Container(
      decoration: BoxDecoration(
        color: MyColors.secondColor,
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_pin,
                color: Colors.white,
                size: 15,
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                textAlign: TextAlign.center,
                "${_locationAdress.postalCode}\n${_locationAdress.city}",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.date_range,
                color: Colors.white,
                size: 17,
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                textAlign: TextAlign.center,
                widget.eventDate,
                softWrap: true,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CurrentUser {
  final String name;
  final String image;
  final num level;
  final num points;
  final String email;
  final String fcmtoken;
  final String id;
  final List memberGroups;
  final List adminMemberGroups;
  final bool onboardingScreenDone;
  final Timestamp lastLogin;
  bool roleAdmin = false;
  final double costPerKM;

  CurrentUser(
    this.name,
    this.image,
    this.level,
    this.points,
    this.email,
    this.fcmtoken,
    this.id,
    this.memberGroups,
    this.adminMemberGroups,
    this.onboardingScreenDone,
    this.lastLogin,
    this.roleAdmin,
    this.costPerKM,
  );
}

Future<CurrentUser> getCurrentUserInformation() async {
  await FirebaseFirestore.instance
      .collection(FirebaseCollection().users)
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get()
      .then((DocumentSnapshot snapshot) async {
    String profileImage = placeHolderProfileImage;
    if (snapshot.get('image') != "" && snapshot.get('image') != null) {
      profileImage = snapshot.get('image');
    }
    List memberGroups = [];

    await FirebaseFirestore.instance
        .collection(FirebaseCollection().groups)
        .where('member', arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        for (var docSnap in snapshot.docs) {
          memberGroups.add(docSnap.id);
        }
      } else {
        memberGroups.add("A123");
      }
    });

    List adminMemberGroups = [];

    await FirebaseFirestore.instance
        .collection(FirebaseCollection().groups)
        .where('groupAdmin',
            arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        for (var docSnap in snapshot.docs) {
          adminMemberGroups.add(docSnap.id);
        }
      }
    });

    currentUserInformations = CurrentUser(
      snapshot.get('name'),
      profileImage,
      snapshot.get('level'),
      snapshot.get('points'),
      snapshot.get('email'),
      snapshot.get('fcmtoken'),
      FirebaseAuth.instance.currentUser!.uid,
      memberGroups,
      adminMemberGroups,
      snapshot.get('onboardingScreenDone'),
      snapshot.get('lastLogin'),
      snapshot.get('roleAdmin'),
      snapshot.get('costPerKM'),
    );
  });
  return currentUserInformations;
}

getUserData() async {
  currentUserInformations = await getCurrentUserInformation();
}

String getCurrentUserLevelDescription(num currentUserLevel) {
  String levelDescription = MyLocalization().levelDescriptionLevel0.tr;

  switch (currentUserLevel) {
    case 0:
      levelDescription = MyLocalization().levelDescriptionLevel0.tr;
      break;
    case 1:
      levelDescription = MyLocalization().levelDescriptionLevel1.tr;
      break;
    case 2:
      levelDescription = MyLocalization().levelDescriptionLevel2.tr;
      break;
    case 3:
      levelDescription = MyLocalization().levelDescriptionLevel3.tr;
      break;
    case 4:
      levelDescription = MyLocalization().levelDescriptionLevel4.tr;
      break;
    case 5:
      levelDescription = MyLocalization().levelDescriptionLevel5.tr;
      break;
  }
  return levelDescription;
}

Future<String> uploadImageFirestorage(
    String filePath, String documentId, Uint8List file) async {
  final Reference storageReference =
      FirebaseStorage.instance.ref().child(filePath);
  UploadTask uploadTask = storageReference
      .child(
          "${filePath}_${documentId}_${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}")
      .putData(file);

  String url = await (await uploadTask).ref.getDownloadURL();
  return url;
}

Future<void> updatePointsAndLevel(num points) async {
  num newLevel = 0;
  num newPoints = 0;
  await FirebaseFirestore.instance
      .collection(FirebaseCollection().users)
      .doc(currentUserInformations.id)
      .get()
      .then((user) {
    newPoints = user['points'] + points;
    newLevel = user['level'];

    if (newPoints >= levelUpValue) {
      newLevel = user['level'] + 1;
      newPoints = newPoints - levelUpValue;
    }
    if (newPoints < 0) {
      if (newLevel <= 1) {
        newLevel = user['level'];
        newPoints = 0;
      } else {
        newLevel = user['level'] - 1;
        newPoints = newPoints + levelUpValue;
      }
    }
  });

  await FirebaseFirestore.instance
      .collection(FirebaseCollection().users)
      .doc(currentUserInformations.id)
      .update({
    'points': newPoints,
    'level': newLevel,
  });

  await getUserData();
}

createEntryHistoryPoints(
    {required int points,
    bool rideAdded = false,
    bool rideRemoved = false,
    bool seatGetIn = false,
    bool seatGetOut = false}) async {
  await FirebaseFirestore.instance
      .collection(FirebaseCollection().historyPoints)
      .add({
    'points': points,
    'userId': currentUserInformations.id,
    'createdDateTime': DateTime.now(),
    'rideAdded': rideAdded,
    'rideRemoved': rideRemoved,
    'seatGetIn': seatGetIn,
    'seatGetOut': seatGetOut,
  });
}

Future<bool> isUserRiderInEvent(String eventId) async {
  bool returnState = false;
  await FirebaseFirestore.instance
      .collection(FirebaseCollection().rides)
      .where('eventId', isEqualTo: eventId)
      .where('passenger', arrayContains: currentUserInformations.id)
      .get()
      .then((events) {
    if (events.docs.isNotEmpty) {
      returnState = true;
    }
  });

  return returnState;
}

//Send Mail SMTP
sendFeedbackMailToDeveloper(
    String title, String text, BuildContext context) async {
  String username = ''; //Enter Username for working
  String password = ''; //Enter Password for working

  //final smtpServer = gmail(username, password);
  //Use the SmtpServer class to configure an SMTP server:
  final smtpServer = SmtpServer(
    "", //Enter Server for working
    port: 465,
    ssl: true,
    ignoreBadCertificate: false,
    allowInsecure: false,
    username: username,
    password: password,
  );

  // See the named arguments of SmtpServer for further configuration
  // options.

  // Create our message.
  final message = Message()
    ..from = const Address('', appName) //Enter Username Mail Adress for working
    ..recipients.add('') //Enter Destination Email for working
    ..subject = title
    ..text = text;

  try {
    final sendReport = await send(message, smtpServer);
    if (kDebugMode) {
      print('Message sent: $sendReport');
    }
    openSuccsessSnackBar(context, "Vielen Dank für Dein Feedback!");
    Navigator.pop(context);
  } on MailerException catch (e) {
    if (kDebugMode) {
      print('Message not sent.');
    }
    for (var p in e.problems) {
      if (kDebugMode) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  var connection = PersistentConnection(smtpServer);

  await connection.close();
}

Future<String> generateGroupInviteLink(String groupId, String lang) async {
  String text = '';
  switch (lang) {
    case "en":
      text =
          "You can also use the $appName app with your group or club and organize your carpooling easier and faster. In addition, you can contribute something good to the environment.";
      break;
    case "de":
      text =
          "Nutze auch du mit deiner Gruppe oder Verein die $appName App und organisiert eure Fahrgemeinschaften einfacher und schneller. Zusätzlich könnt ihr so etwas Gutes zur Umwelt beitragen.";
      break;
    default:
      text =
          "También puede usar la aplicación $appName con su grupo o club y organizar su viaje compartido de manera más fácil y rápida. Además, puedes aportar algo bueno al medio ambiente.";
  }
  final dynamicLink = FirebaseDynamicLinks.instance;

  var link = await dynamicLink.buildShortLink(DynamicLinkParameters(
    uriPrefix: kUri,
    link: Uri.parse("$kUri$kGroupAddLink?groupid=$groupId"),
    androidParameters: const AndroidParameters(
      packageName: 'de.kevindroll.nachhaltigesfahren',
      minimumVersion: 1,
    ),
    iosParameters: const IOSParameters(
      bundleId: "de.kevindroll.nachhaltigesfahren",
      minimumVersion: '2',
    ),
  ));

  return link.shortUrl.toString();
}

String userPlatform() {
  if (defaultTargetPlatform == TargetPlatform.android) {
    return "Android";
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    return "IOS";
  } else {
    return "Web";
  }
}

List<Widget> getAdvertisementList(BuildContext context) {
  List<Widget> advertisementList = [
    advertisementKevinDroll(context),
  ];
  if (defaultTargetPlatform != TargetPlatform.iOS) {
    advertisementList.add(advertisementTeamCarApp(context));
  }

  return advertisementList;
}

Widget advertisementTeamCarApp(BuildContext context) {
  return InkWell(
    onTap: () async {
      launchUrl(Uri.parse('https://teamcar.app'));
      if (!kIsWeb) {
        await analytics.logEvent(
            name: "advertisement_clicked",
            parameters: {'advertisement': "teamcar.app"});
      }
    },
    child: Container(
      width: MediaQuery.of(context).size.width,
      height: 180,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(200, 215, 211, 162),
            MyColors.primaryColor,
            const Color.fromARGB(200, 215, 211, 162)
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        image: const DecorationImage(
          image: AssetImage(
            'lib/assets/images/advertisements/panorama_Full.png',
          ),
          fit: BoxFit.contain,
        ),
      ),
    ),
  );
}

Widget advertisementKevinDroll(BuildContext context) {
  return InkWell(
    onTap: () async {
      launchUrl(Uri.parse('https://kevindroll.de'));
      if (!kIsWeb) {
        await analytics.logEvent(
            name: "advertisement_clicked",
            parameters: {'advertisement': "kevindroll.de"});
      }
    },
    child: Container(
      width: MediaQuery.of(context).size.width,
      height: 180,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(199, 200, 200, 198),
            Color.fromARGB(199, 252, 252, 252),
            Color.fromARGB(199, 200, 200, 198),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        image: const DecorationImage(
          image: AssetImage(
            'lib/assets/images/advertisements/logo_kevindroll.png',
          ),
          fit: BoxFit.contain,
        ),
      ),
    ),
  );
}

getRandomIndex(List list) {
  return Random().nextInt(list.length);
}

class TicketContainer extends StatefulWidget {
  const TicketContainer({
    super.key,
    required this.passenger,
    required this.description,
    required this.freeSeats,
    required this.offeredSeats,
    required this.image,
    required this.title,
    required this.createdByName,
    required this.subtitle,
    required this.eventDate,
    required this.startRideLocation,
    required this.eventLocation,
    required this.filterDistance,
    required this.fromAdressCoords,
    required this.onTap,
    required this.duration,
    required this.distance,
  });
  final void Function() onTap;
  final List passenger;
  final String description;
  final int freeSeats;
  final int offeredSeats;
  final String image;
  final String title;
  final String createdByName;
  final String subtitle;
  final String eventDate;
  final GeoPoint startRideLocation;
  final GeoPoint eventLocation;
  final int filterDistance;
  final asfadress.Coords fromAdressCoords;
  final int duration;
  final int distance;
  @override
  State<TicketContainer> createState() => _TicketContainerState();
}

class _TicketContainerState extends State<TicketContainer> {
  GeoData startAddress = GeoData(
    address: "NO ADDRESS beacuse of api",
    city: "Some city",
    country: "USA",
    latitude: 0,
    longitude: 0,
    postalCode: "100012",
    state: "California",
    countryCode: "",
    streetNumber: "",
  );
  GeoData eventAddress = GeoData(
    address: "NO ADDRESS beacuse of api",
    city: "Some city",
    country: "USA",
    latitude: 0,
    longitude: 0,
    postalCode: "100012",
    state: "California",
    countryCode: "",
    streetNumber: "",
  );

  bool _loading = true;
  int durationRideInMinutes = 0;
  int distanceStartAdress = 0;
  @override
  void initState() {
    super.initState();
    getLocationAdress();
  }

  getLocationAdress() async {
    try {
      startAddress = await Geocoder2.getDataFromCoordinates(
          latitude: widget.startRideLocation.latitude,
          longitude: widget.startRideLocation.longitude,
          googleMapApiKey: googleMapsApiKey);
      eventAddress = await Geocoder2.getDataFromCoordinates(
          latitude: widget.eventLocation.latitude,
          longitude: widget.eventLocation.longitude,
          googleMapApiKey: googleMapsApiKey);
    } catch (_) {}

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Loading();
    }
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(15.0),
        margin: const EdgeInsets.only(top: 8.0),
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(25.0)),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(widget.createdByName),
                      const SizedBox(
                        height: 5.0,
                      ),
                      CircleAvatar(
                        backgroundImage: NetworkImage(widget.image),
                        radius: 22,
                      )
                    ],
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.withOpacity(.3),
                              border:
                                  Border.all(color: Colors.blue, width: 3.0),
                            ),
                          ),
                          const SizedBox(
                            width: 9.0,
                          ),
                          RichText(
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: (widget.distance > 1000)
                                          ? (widget.distance / 1000)
                                              .round()
                                              .toString()
                                          : widget.distance.toString(),
                                    ),
                                    TextSpan(
                                      text: (widget.distance > 1000)
                                          ? " km"
                                          : " m",
                                    )
                                  ],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                    ],
                  ),
                ),
                Text(
                  widget.eventDate,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .apply(color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.withOpacity(.3),
                              border:
                                  Border.all(color: Colors.blue, width: 3.0),
                            ),
                          ),
                          const SizedBox(
                            width: 9.0,
                          ),
                          Flexible(
                            child: Text(
                              overflow: TextOverflow.visible,
                              startAddress.address,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.orange.withOpacity(.3),
                              border:
                                  Border.all(color: Colors.orange, width: 3.0),
                            ),
                          ),
                          const SizedBox(
                            width: 9.0,
                          ),
                          Flexible(
                            child: Text(
                              overflow: TextOverflow.visible,
                              eventAddress.address,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NewRideCard extends StatefulWidget {
  const NewRideCard({
    super.key,
    required this.onTap,
    required this.passenger,
    required this.description,
    required this.freeSeats,
    required this.offeredSeats,
    required this.image,
    required this.title,
    required this.createdByName,
    required this.subtitle,
    required this.eventDate,
    required this.startRideLocation,
    required this.eventLocation,
  });
  final void Function() onTap;
  final List passenger;
  final String description;
  final int freeSeats;
  final int offeredSeats;
  final String image;
  final String title;
  final String createdByName;
  final String subtitle;
  final String eventDate;
  final GeoPoint startRideLocation;
  final GeoPoint eventLocation;

  @override
  State<NewRideCard> createState() => _NewRideCardState();
}

class _NewRideCardState extends State<NewRideCard> {
  late GeoData startAdress;
  late GeoData eventAdress;

  bool _loading = true;
  int durationRideInMinutes = 0;
  int distanceStartAdress = 0;
  @override
  void initState() {
    super.initState();
    getLocationAdress();
  }

  getLocationAdress() async {
    startAdress = await Geocoder2.getDataFromCoordinates(
        latitude: widget.startRideLocation.latitude,
        longitude: widget.startRideLocation.longitude,
        googleMapApiKey: googleMapsApiKey);
    eventAdress = await Geocoder2.getDataFromCoordinates(
        latitude: widget.eventLocation.latitude,
        longitude: widget.eventLocation.longitude,
        googleMapApiKey: googleMapsApiKey);

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Loading();
    }
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(15.0),
        margin: const EdgeInsets.only(top: 8.0),
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(25.0)),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(widget.createdByName),
                      const SizedBox(
                        height: 5.0,
                      ),
                      CircleAvatar(
                        backgroundImage: NetworkImage(widget.image),
                        radius: 22,
                      )
                    ],
                  ),
                ),
                Text(
                  widget.eventDate,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .apply(color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.withOpacity(.3),
                              border:
                                  Border.all(color: Colors.blue, width: 3.0),
                            ),
                          ),
                          const SizedBox(
                            width: 9.0,
                          ),
                          Expanded(
                            child: Expanded(
                              child: Flexible(
                                child: Text(
                                  overflow: TextOverflow.visible,
                                  startAdress.address,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.orange.withOpacity(.3),
                              border:
                                  Border.all(color: Colors.orange, width: 3.0),
                            ),
                          ),
                          const SizedBox(
                            width: 9.0,
                          ),
                          Expanded(
                            child: Flexible(
                              child: Text(
                                overflow: TextOverflow.visible,
                                eventAdress.address,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NewEventCard extends StatefulWidget {
  final void Function() onTap;

  final String description;

  final String image;
  final String title;

  final String subtitle;
  final String eventDate;

  final GeoPoint eventLocation;
  final String groupName;
  const NewEventCard({
    Key? key,
    required this.onTap,
    required this.description,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.eventDate,
    required this.eventLocation,
    required this.groupName,
  }) : super(key: key);

  @override
  State<NewEventCard> createState() => _NewEventCardState();
}

class _NewEventCardState extends State<NewEventCard> {
  late GeoData eventAdress;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    getLocationAdress();
  }

  getLocationAdress() async {
    eventAdress = await Geocoder2.getDataFromCoordinates(
        latitude: widget.eventLocation.latitude,
        longitude: widget.eventLocation.longitude,
        googleMapApiKey: googleMapsApiKey);

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Loading();
    }
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(15.0),
        margin: const EdgeInsets.only(top: 8.0),
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(25.0)),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(widget.groupName),
                      const SizedBox(
                        height: 5.0,
                      ),
                      CircleAvatar(
                        backgroundImage: NetworkImage(widget.image),
                        backgroundColor: Colors.transparent,
                        radius: 22,
                      )
                    ],
                  ),
                ),
                Text(
                  widget.eventDate,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .apply(color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(Icons.description),
                          const SizedBox(
                            width: 9.0,
                          ),
                          Expanded(
                            child: Flexible(
                              child: Text(
                                overflow: TextOverflow.visible,
                                widget.subtitle,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          const Icon(Icons.location_on),
                          const SizedBox(
                            width: 9.0,
                          ),
                          Expanded(
                            child: Flexible(
                              child: Text(
                                overflow: TextOverflow.visible,
                                eventAdress.address,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

getReview() async {
  AdvancedInAppReview()
      .setMinDaysBeforeRemind(7)
      .setMinDaysAfterInstall(5)
      .setMinLaunchTimes(5)
      .monitor();
  /*if(!kIsWeb){await analytics.logEvent(
      name: "review_requested",
      parameters: {'userId': currentUserInformations.id}).then((value) {
    print("Analytics Review logged");
  });}*/
}

int getDistance(
  GeoPoint startAdress,
  GeoPoint endAdress,
) {
  if (kDebugMode) {
    print(startAdress.latitude);
    print(startAdress.longitude);
    print(endAdress.latitude);
    print(endAdress.longitude);
  }

  int distance = Geolocator.distanceBetween(
    startAdress.latitude,
    startAdress.longitude,
    endAdress.latitude,
    endAdress.longitude,
  ).floor();
  if (kDebugMode) {
    print("Distanz ist: $distance");
  }
  return distance;
}
