import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../Events/Widgets/appbar_back_arrow_widget.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  TextEditingController feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    feedbackController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    // const kPrimaryColor = Color(0XFF2DBB54);
    const kTextColor = Color(0XFF303030);

    const kDefaultPadding = 18.0;
    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
              child: Stack(
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
                    textt: MyLocalization().feedback.tr,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 50),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(kDefaultPadding),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 15,
                                    offset: const Offset(0.0, 15.0),
                                    color: kTextColor.withAlpha(20))
                              ]),
                          child: TextField(
                            textInputAction: TextInputAction.newline,
                            keyboardType: TextInputType.multiline,
                            maxLines: 15,
                            controller: feedbackController,
                            decoration:
                                MyTextInputFieldStyles.getWhiteSpacePrimaryBorder(
                                    MyLocalization().feedbackPageTextfieldHint.tr),
                          ),
                        ),
                        const SizedBox(height: kDefaultPadding),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              MyLocalization().feedbackPageSendButton.tr,
                              style: TextStyle(
                                  color: MyColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                            const SizedBox(width: kDefaultPadding),
                            Container(
                              width: 50.0,
                              height: 50.0,
                              decoration: const BoxDecoration(
                                borderRadius:
                                BorderRadius.all(Radius.circular(25.0)),
                                color: MyColors.kGreenColor,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_forward),
                                onPressed: () async {
                                  if (feedbackController.text != "") {
                                    await sendFeedbackMailToDeveloper(
                                        "Neues Feedback von ${currentUserInformations.name}",
                                        "Email: ${currentUserInformations.email}\n Feedback:\n ${feedbackController.text}",
                                        context);
                                  } else {
                                    openWarningSnackBar(
                                        context,
                                        MyLocalization()
                                            .feedbackPageNotificationNoText
                                            .tr);
                                  }
                                },
                                color: Colors.white,
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
          ))),
    );
  }
}
