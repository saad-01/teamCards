import 'package:auto_size_text/auto_size_text.dart';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../constants.dart';
import '../assets/widgets/loading.dart';

class QRCodePage extends StatefulWidget {
  const QRCodePage({super.key, required this.url, required this.groupName});
  final String url;
  final String groupName;
  @override
  QRCodePageState createState() => QRCodePageState();
}

class QRCodePageState extends State<QRCodePage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  _getData() async {
    await getUserData();
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Loading();
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: AutoSizeText(
          maxLines: 1,
          widget.groupName,
          style: MyTextstyles.appBarTitleStyle,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: MyColors.primaryColor,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
          child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: QrImageView(
            data: widget.url,
            version: QrVersions.auto,
            errorStateBuilder: (cxt, err) {
              return const Center(
                child: Text(
                  "Uh oh! Something went wrong...",
                  textAlign: TextAlign.center,
                ),
              );
            },
            gapless: false,
          ),
        ),
      )),
    );
  }
}
