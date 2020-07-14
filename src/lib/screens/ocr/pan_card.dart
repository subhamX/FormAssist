import 'dart:io';
import 'package:flutter/material.dart';
import 'package:form_assist/error/errorpage.dart';
import 'package:form_assist/screens/loaders/loadingbox.dart';
import 'package:form_assist/services/ocrService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flushbar/flushbar.dart';
import 'package:form_assist/common/common.dart';

class PanOCR extends StatefulWidget {
  @override
  _PanOCRState createState() => _PanOCRState();
}

class _PanOCRState extends State<PanOCR> {
  File pickedImage;
  bool isImageRead = false;
  bool isImageLoaded = false;
  List<TextLine> words = new List<TextLine>();
  final myController = TextEditingController();
  String dob = "NO_VAL", cardNum = "NO_VAL", name = "NO_VAL";

  @override
  void dispose() {
    myController.dispose();

    super.dispose();
  }

  void setData(String input) {
    myController.text = input;
  }

/*
  name = 0
  dob = 1
  pan_card_number = 4

*/
  final _key = GlobalKey<FormState>();
  Future<void> showPopUp(int id) async {
    String fieldName;
    RegExp fieldPattern;
    if (id == 1) {
      myController.text = dob;
      fieldPattern = dobPattern;
      fieldName = "Date Of Birth";
    } else if (id == 0) {
      fieldPattern = namPattern;
      fieldName = "Name";
      myController.text = name;
    } else if (id == 4) {
      fieldPattern = cardNumPattern;
      fieldName = "PAN Card Number";
      myController.text = cardNum;
    } else {
      // Invalid Query
      return;
    }
    if (myController.text == 'NO_VAL') {
      myController.text = "";
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Form(
            key: _key,
            child: TextFormField(
              decoration: InputDecoration(
                labelText: fieldName,
              ),
              controller: myController,
              validator: (input) {
                if (fieldPattern.hasMatch(input)) {
                  return null;
                } else {
                  return "Please Enter a valid $fieldName";
                }
              },
            ),
          ),
          actions: <Widget>[
            Container(
              // width: MediaQuery.of(context).size.width * 0.20,
              child: RaisedButton(
                  color: Colors.blue,
                  onPressed: () async {
                    await Navigator.pushNamed(
                      context,
                      'listening_fetch',
                      arguments: {
                        "setData": setData,
                      },
                    );
                  },
                  child: Row(
                    children: <Widget>[
                      Text(
                        'MIC',
                        style: TextStyle(color: Colors.white),
                      ),
                      Icon(
                        Icons.mic,
                        color: Colors.white,
                      ),
                    ],
                  )),
            ),
            RaisedButton(
              color: Colors.blue,
              child: Text(
                "UPDATE CHANGES",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                if (_key.currentState.validate()) {
                  // Updating fields
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return LoadingBox();
                      });
                  String result =
                      await OCRService.updateData(myController.text, id);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  if (result == 'error') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ErrorPage(),
                      ),
                    );
                  } else {
                    if (id == 1) {
                      setState(() {
                        dob = myController.text;
                      });
                    } else if (id == 0) {
                      setState(() {
                        name = myController.text;
                      });
                    } else if (id == 4) {
                      setState(() {
                        cardNum = myController.text;
                      });
                    } else {
                      // Invalid Query
                      return;
                    }
                    if (myController.text == 'NO_VAL') {
                      myController.text = "";
                    }
                    Flushbar(
                      message: "Field Updation Successful!",
                      duration: Duration(seconds: 1),
                    ).show(context);
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void pickImage() async {
    final imagesource = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Select the image source"),
              actions: <Widget>[
                MaterialButton(
                  child: Text(
                    "Camera",
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 17,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, ImageSource.camera);
                  },
                ),
                MaterialButton(
                  child: Text(
                    "Browse",
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 17,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, ImageSource.gallery);
                  },
                )
              ],
            ));
    if (imagesource != null) {
      final file = await ImagePicker.pickImage(source: imagesource);
      if (file != null) {
        setState(() {
          pickedImage = file;
          isImageLoaded = true;
          isImageRead = false;
        });
      }
    }
  }

  TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
  final namPattern = RegExp(r'[a-zA-Z]+(([,. -][a-zA-Z ])?[a-zA-Z]*)*$');
  final dobPattern = RegExp(
      r'(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$');
  final cardNumPattern = RegExp(r'^([a-zA-Z]){5}([0-9]){4}([a-zA-Z]){1}?$');

  Future readText() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return LoadingBox();
        });
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(pickedImage);
    VisionText readText = await recognizeText.processImage(ourImage);
    List<TextLine> newList = new List<TextLine>();

    int i = 0;
    dob = "NO_VAL";
    cardNum = "NO_VAL";
    name = 'NO_VAL';
    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        newList.add(line);
        if (namPattern.hasMatch(line.text) && i <= 5) {
          name = namPattern.stringMatch(line.text);
          print("Name Match - $name");
          i += 1;
        } else if (dobPattern.hasMatch(line.text)) {
          dob = dobPattern.stringMatch(line.text);
          print("DOB Match - $dob");
        } else if (cardNumPattern.hasMatch(line.text)) {
          cardNum = cardNumPattern.stringMatch(line.text);
          print("Card Number Match - $cardNum");
        }
      }
    }
    Navigator.of(context).pop();
    words = newList;
    setState(() {
      isImageRead = true;
    });
    return;
  }

  Container _getResultsUI() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Text(
              "RESULTS",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "*Tap to Edit",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ListTile(
              title: Text("Name"),
              subtitle: Text(name),
              onTap: () async {
                await showPopUp(0);
              },
            ),
            ListTile(
              title: Text("Date Of Birth"),
              subtitle: Text(dob),
              onTap: () async {
                await showPopUp(1);
              },
            ),
            ListTile(
              title: Text("PAN Card Number"),
              subtitle: Text(cardNum),
              onTap: () async {
                await showPopUp(4);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Common.getAppBar(context),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: <Widget>[
              SizedBox(height: 10.0),
              Text(
                "PAN CARD OCR",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              SizedBox(height: 2.5),
              Divider(
                height: 20,
              ),
              GestureDetector(
                onTap: pickImage,
                child: Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    width: MediaQuery.of(context).size.width * 0.98,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: isImageLoaded
                              ? FileImage(pickedImage)
                              : ExactAssetImage('assets/backimg.png'),
                          fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              isImageLoaded && !isImageRead
                  ? RaisedButton(
                      child: Text(
                        'READ TEXT',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      color: isImageLoaded ? Colors.blue[800] : Colors.grey,
                      onPressed: () async {
                        if (isImageLoaded) {
                          await readText();
                        } else {
                          Flushbar(
                            message: "Please select an image",
                            duration: Duration(seconds: 2),
                            reverseAnimationCurve: Curves.fastOutSlowIn,
                          ).show(context);
                          await Future.delayed(
                              Duration(seconds: 2, milliseconds: 200));
                        }
                      },
                    )
                  : SizedBox(),
              isImageRead ? _getResultsUI() : SizedBox(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        child: Icon(
          Icons.image,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue[800],
      ),
    );
  }
}
