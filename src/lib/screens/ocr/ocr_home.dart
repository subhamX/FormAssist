import 'package:flutter/material.dart';
import 'package:form_assist/common/common.dart';

class OCRHome extends StatefulWidget {
  @override
  _OCRHomeState createState() => _OCRHomeState();
}

class _OCRHomeState extends State<OCRHome> {
  static const cards = <String>[
    'Aadhar Card',
    'Pan Card',
    'Master Credit Card',
    'Visa Credit Card',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Common.getAppBar(context),
        body: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Column(
                children: <Widget>[
                  Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/ocr-icon.png',
                    height: 55,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "OCR HOME",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ],
              ),
                  Divider(
                    height: 15,
                    indent: 20,
                    endIndent: 20,
                    color: Colors.black,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "*Tap To Open OCR.",
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w700,
                          // fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.credit_card, color: Colors.yellow[900],),
                          title: Text('AADHAAR CARD'),
                          onTap: () {
                            Navigator.pushNamed(context, "aadhar_ocr");
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.assignment_ind, color: Colors.blue[500],),
                          title: Text('PAN CARD'),
                          onTap: () {
                            Navigator.pushNamed(context, "pan_ocr");
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.card_travel, color: Colors.purple[500],),
                          title: Text('VOTER ID CARD'),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: Icon(Icons.person_add, color: Colors.amber[500],),
                          title: Text('STUDENT ID CARD'),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: Icon(Icons.chrome_reader_mode, color: Colors.brown[500],),
                          title: Text('DRIVING LICENSE'),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: Icon(Icons.dock, color: Colors.pink[500],),
                          title: Text('DIGILOCKER DOCUMENTS'),
                          onTap: () {},
                        ),
                      ],
                    ),
                  )
                ],
              )),
        ));
  }
}
