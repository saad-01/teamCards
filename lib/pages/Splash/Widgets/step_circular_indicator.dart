import 'package:flutter/material.dart';
import 'package:nachhaltiges_fahren/constants.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class KCircularProgressIndicator extends StatelessWidget {
  const KCircularProgressIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:const EdgeInsets.only(bottom: 40),
      child: const Center(
        child: SizedBox(
          width: 36,
          height: 36,
          child: CircularStepProgressIndicator(
            padding: .6,
            totalSteps: 8,
            currentStep: 8,
            selectedColor: MyColors.kWhiteColor,
            unselectedColor: Colors.cyan,
            selectedStepSize: 7.0,
            unselectedStepSize: 7.0,
            width: 36,
          ),
        ),
      ),
    );
  }
}
