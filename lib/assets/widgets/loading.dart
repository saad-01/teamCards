import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading({super.key, this.small = false});

  final bool small;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      child: Center(
        child: Image.asset(
          "lib/assets/animations/car-loading.gif",
          height: small ? size.height * 0.2 : size.height * 0.4,
          width: small ? size.width * 0.3 : size.width * 0.5,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
