import 'package:flutter/material.dart';
import 'package:form_assist/services/Speech2Text.dart';
import 'package:form_assist/services/Text2Speech.dart';
import 'package:form_assist/services/permissions_service.dart';

class ListeningFetch extends StatefulWidget {
  @override
  _ListeningState createState() => _ListeningState();
}

class _ListeningState extends State<ListeningFetch> {
  String resultText = "...", finalText = "";
  TextTSpeech text2Speech;
  SpeechTText speech2Text;
  dynamic setData;

  @override
  void initState() {
    super.initState();
    // Initializing Speech to text
    speech2Text = SpeechTText();
    text2Speech = TextTSpeech();

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

  void initFun() {
    // Initializing speech2Text
    speech2Text.initSpeechRecognizer().then((_) async {
      if (mounted) {
        // Checking for Permissions
        bool noPermission = await PermissionsService.listenForPermissionStatus();
        // If Permission Not Granted
        if (noPermission) {
          setState(() {
            resultText = "☹";
            noPermission = true;
          });
          Navigator.pushReplacementNamed(context, 'error_page');
          // Navigator.pop(context);
          text2Speech.voiceText = "Please check Microphone Permissions";
          await text2Speech.speak();
          await Future.delayed(Duration(milliseconds: 300));
        }
        try {
          // Listening
          if (mounted) {
            await speech2Text.listen();
          } else {
            return;
          }
        } catch (err) {
          print('Error In Listening: $err');
        }
        await Future.delayed(Duration(milliseconds: 500));
        print("Result[Speech To Text]: ${speech2Text.resultText}");
        if (speech2Text.resultText == "") {
          Navigator.of(context).pop();
        } else {
          finalText = speech2Text.resultText;
          await Future.delayed(Duration(milliseconds: 500));
          if (mounted) {
            setData(finalText);
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
    setData = args["setData"];
    
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
