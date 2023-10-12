
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/constants.dart';


class BackNextButton extends StatelessWidget {
  const BackNextButton({
    super.key,
    required this.nextPress,
  });
final VoidCallback nextPress;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 30, bottom: 40),
      width: MediaQuery.of(context).size.width * .9,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                    minimumSize:
                        const Size(double.infinity, 52),
                    backgroundColor: MyColors.kBackGroundColor,
                    foregroundColor: const Color(0xff595959),
                    side: const BorderSide(
                      color: Color(0xff595959),
                    )),
                child: Text(
                  MyLocalization().back.tr,
                  style: const TextStyle(fontSize: 20),
                )),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: ElevatedButton(
                onPressed: nextPress,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  backgroundColor: MyColors.kGreenColor,
                  foregroundColor: Colors.white,
                  side: const BorderSide(
                      color: Color(0xff595959)),
                ),
                child: Text(
                  MyLocalization().next.tr,
                  style: const TextStyle(fontSize: 20),
                )),
          ),
        ],
      ),
    );
  }
}
