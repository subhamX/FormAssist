import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';

class LoadingBox extends StatefulWidget {
  @override
  _LoadingBoxState createState() => _LoadingBoxState();
}

class _LoadingBoxState extends State<LoadingBox> {
  DateTime current;
  @override
  void initState() {
    super.initState();
    current = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SpinKitThreeBounce(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
