import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nachhaltiges_fahren/constants.dart';

class FIlterButton extends StatefulWidget {
  const FIlterButton({
    super.key,
    required this.first,
    required this.second,
    required this.firstPress,
    required this.secondPress,
  });

  final VoidCallback firstPress;
  final VoidCallback secondPress;
  final String first;
  final String second;

  @override
  State<FIlterButton> createState() => _FIlterButtonState();
}

class _FIlterButtonState extends State<FIlterButton> {
  bool center = false;
  Alignment _align = Alignment.bottomRight;

  void _animate() {
    setState(() {
      if (center) {
        _align = Alignment.bottomRight;
        center = false;
      } else {
        center = true;
        _align = Alignment.bottomCenter;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: SizedBox(
        height: center ? size.height * 0.34 : size.height * 0.09,
        width: size.width,
        child: GestureDetector(
          onTap: () {
            _animate();
          },
          child: Column(
            children: [
              Visibility(
                visible: center,
                child: Column(
                  children: [
                    Card(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: MyColors.kGreenColor)
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  widget.firstPress();
                                  _animate();
                                },
                                child: ListTile(
                                  leading: Image.asset(
                                    'assets/event/eventlogo.PNG',
                                    width: 35,
                                    height: 35,
                                    fit: BoxFit.fill,
                                  ),
                                  title: Row(
                                    children: [
                                      const Text(
                                        '|\t\t',
                                        style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w200),
                                      ),
                                      // '${selectedDateTime ?? ''}',
                                      Text(
                                        widget.first,
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: MyColors.kGreenColor)
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  widget.secondPress();
                                  _animate();
                                },
                                child: ListTile(
                                  leading: Image.asset(
                                    'assets/event/eventlogo.PNG',
                                    width: 35,
                                    height: 35,
                                    fit: BoxFit.fill,
                                  ),
                                  title: Row(
                                    children: [
                                      const Text(
                                        '|\t\t',
                                        style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w200),
                                      ),
                                      // '${selectedDateTime ?? ''}',
                                      Text(
                                        widget.second,
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              MyLocalization().filter.tr,
                              style: const TextStyle(fontSize: 15, color: MyColors.kBlackColor),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedAlign(
                alignment: _align,
                duration: const Duration(milliseconds: 300),
                child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeInOutBack,
                    transitionBuilder: (child, animation) => ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                    child: !center
                        ? Container(
                            height: 60,
                            width: 60,
                            key: const ValueKey('filter'),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: MyColors.kGreenColor,
                            ),
                            child: const Icon(
                              Icons.filter_alt_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                          )
                        : Container(
                            height: 60,
                            width: 60,
                            key: const ValueKey('close'),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: MyColors.kGreenColor,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 40,
                              color: Colors.white,
                            ),
                          )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
