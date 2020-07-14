import 'package:flutter/material.dart';
import 'package:form_assist/services/Speech2Text.dart';
import 'package:form_assist/services/Text2Speech.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:form_assist/services/permissions_service.dart';

class Listening extends StatefulWidget {
  @override
  _ListeningState createState() => _ListeningState();
}

class _ListeningState extends State<Listening> {
  String resultText = "...", finalText = "";
  TextTSpeech text2Speech;
  SpeechTText speech2Text;
  String fieldName, path, type;
  Firestore _firestore = Firestore.instance;
  @override
  void initState() {
    super.initState();
    // Initializing Speech to text
    text2Speech = TextTSpeech();
    speech2Text = SpeechTText();
    text2Speech.voiceText = fieldName;

    WidgetsBinding.instance.addPostFrameCallback((_) => initFun());

    // Updating resultText in Real Time
    speech2Text.addListener(() {
      if (mounted) {
        setState(() {
          resultText = speech2Text.resultText;
        });
      }
    });
  }

  bool validateField(String s) {
    Pattern pattern;
    RegExp regex;
    if (type == 'phone') {
      pattern = r'^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$';
      regex = RegExp(pattern);
    } else if (type == 'string') {
      return true;
    } else if (type == 'pin') {
    } else if (type == 'number') {
      pattern = r'^[0-9]*$';
      regex = RegExp(pattern);
    } else if (type == 'pin') {
      pattern = r'^[1-9]{1}[0-9]{2}\s{0,1}[0-9]{3}$';
      regex = RegExp(pattern);
    } else if (type == 'email') {
      pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      regex = RegExp(pattern);
    } else {
      return false;
    }
    if (regex.hasMatch(s)) {
      return true;
    }
    return false;
  }

  void initFun() {
    text2Speech.voiceText = fieldName;
    text2Speech.speak().then((_) async {
      if (mounted) {
        await speech2Text.initSpeechRecognizer();
        // Checking for Permissions
        bool noPermission =
            await PermissionsService.listenForPermissionStatus();
        // If Permission Not Granted
        if (noPermission) {
          setState(() {
            resultText = "☹";
          });
          text2Speech.voiceText = "Please check Microphone Permissions";
          Navigator.pushReplacementNamed(context, 'error_page');
          await text2Speech.speak();
          await Future.delayed(Duration(milliseconds: 300));
          Navigator.pop(context);
        }
        if (mounted) {
          await speech2Text.listen();
        } else {
          return;
        }
        await Future.delayed(Duration(milliseconds: 400));
        if (speech2Text.resultText == '') {
          Navigator.of(context).pop();
        } else {
          finalText = speech2Text.resultText;
          if (mounted) {
            text2Speech.voiceText = "You said $resultText. Say YES to confirm?";
            await text2Speech.speak();
          } else {
            return;
          }

          if (mounted) {
            await Future.delayed(Duration(milliseconds: 200));
            await speech2Text.listen();
          } else {
            return;
          }
          await Future.delayed(Duration(milliseconds: 300));

          if (mounted) {
            if (speech2Text.resultText.contains("no")) {
              text2Speech.voiceText = "";
              Navigator.pop(context);
            } else {
              bool ans = validateField(finalText);
              if (ans) {
                print("yesnone");
                text2Speech.voiceText = "Ok changing the field";
                if (finalText.isNotEmpty) {
                  try {
                    _firestore.document(path).updateData({'value': finalText});
                  } catch (err) {
                    print('Error');
                  }
                }
              } else {
                text2Speech.voiceText = "Validation Failed. Please Try Again";
              }
            }
          } else {
            return;
          }

          if (mounted) {
            await text2Speech.speak();
          } else {
            return;
          }
          await Future.delayed(Duration(milliseconds: 200));
          if (mounted) {
            Navigator.pop(context);
          }
        }
      } else {
        return;
      }
    });
  }

  @override
  void dispose() {
    speech2Text.cancel();
    speech2Text.isAvailable = false;
    text2Speech.isPlaying = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = Map.from(ModalRoute.of(context).settings.arguments);
    path = args["path"];
    fieldName = args["fieldName"];
    type = args["type"];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.exit_to_app),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 80,
                ),
                Center(
                  child: Text(
                    'Listening...',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Image.asset(
                  'assets/listening.gif',
                  width: MediaQuery.of(context).size.width * 0.4,
                ),
                Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      resultText ?? '...',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
