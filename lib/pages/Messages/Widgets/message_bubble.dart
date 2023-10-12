import 'package:flutter/material.dart';
import 'package:nachhaltiges_fahren/constants.dart';


class MessageBubble extends StatelessWidget {
  const MessageBubble(
      {super.key,
      required this.sender,
      required this.message,
      });
  final bool sender;
  final String message;

  @override
  Widget build(BuildContext context) {

    return Align(
      alignment: sender ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: Row(
          mainAxisAlignment:
              sender ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  color: sender
                      ? const Color(0xff019267)
                      : MyColors.kWhiteColor,
                  borderRadius: BorderRadius.only(
                    topRight: sender
                        ? const Radius.circular(0)
                        : const Radius.circular(10),
                    topLeft: sender
                        ? const Radius.circular(10)
                        : const Radius.circular(0),
                    bottomRight: const Radius.circular(10),
                    bottomLeft: const Radius.circular(10),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                margin: const EdgeInsets.only(left: 16, top: 8),
                child: Column(
                    mainAxisAlignment: sender
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    crossAxisAlignment: sender
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top:5.0,bottom: 5,left: 5,right: 50),
                        child: Text(
                          message,
                          textWidthBasis: TextWidthBasis.parent,
                          style: TextStyle(color:sender? MyColors.kWhiteColor:MyColors.kBlackColor, fontSize: 15),
                        ),
                      ),
                      
                          
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}