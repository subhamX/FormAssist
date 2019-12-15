import 'package:flutter/material.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';

class Explore extends StatelessWidget {
  final pages = [
    PageViewModel(
      pageColor: Colors.white,
      bubbleBackgroundColor: Colors.blue[900],
      title: Container(),
      body: Column(
        children: <Widget>[
          Text('Want a loan?'),
          Text(
            'But don\'t want to get into the hassle of filling the tedious bank forms again and again?',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
      mainImage: Image.asset(
        'assets/explore/image.png',
        width: 285.0,
        alignment: Alignment.center,
      ),
      textStyle: TextStyle(color: Colors.black),
    ),
    PageViewModel(
      pageColor: Colors.white,
      iconColor: null,
      bubbleBackgroundColor: Colors.blue[900],
      title: Container(),
      body: Column(
        children: <Widget>[
          Text('Now fill forms digitally…'),
          Text(
            'Pick a template or Start from scratch to create a brand new form.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16.0,
            ),
          ),
          Text(
            'Using Form Assist Zero typing forms are now a reality.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
      mainImage: Image.asset(
        'assets/explore/digital_india.jpg',
        width: 285.0,
        alignment: Alignment.center,
      ),
      textStyle: TextStyle(color: Colors.black),
    ),
    PageViewModel(
      pageColor: Colors.white,
      iconColor: null,
      bubbleBackgroundColor: Colors.blue[900],
      title: Container(),
      body: Column(
        children: <Widget>[
          Text(
              'Utilise the information you entered earlier, and build a brand new form'),
        ],
      ),
      mainImage: Image.asset(
        'assets/explore/video3.gif',
        width: 285.0,
        alignment: Alignment.center,
      ),
      textStyle: TextStyle(color: Colors.black),
    ),
    PageViewModel(
      pageColor: Colors.white,
      iconColor: null,
      bubbleBackgroundColor: Colors.blue[900],
      title: Container(),
      body: Column(
        children: <Widget>[
          Text(
              'Allow Form Assist to help you get started with your first form!'),
          Text(
            '🙂',
            style: TextStyle(color: Colors.black54, fontSize: 16.0),
          ),
        ],
      ),
      mainImage: Image.asset(
        'assets/explore/fillForm.png',
        width: 285.0,
        alignment: Alignment.center,
      ),
      textStyle: TextStyle(color: Colors.black),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            IntroViewsFlutter(
              pages,
              onTapDoneButton: () {
                Navigator.pop(context);
              },
              showSkipButton: false,
              doneText: Text("Get Started"),
              pageButtonsColor: Colors.blue[900],
              pageButtonTextStyles: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
