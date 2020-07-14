// import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:form_assist/common/common.dart';
import 'package:form_assist/error/errorpage.dart';
import 'package:form_assist/screens/loaders/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:form_assist/screens/loaders/loadingbox.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class ExportScreen extends StatefulWidget {
  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  String formId, uid, formName, formTypeName = 'NO_NAME', agentEmail;

  Firestore _firestore = Firestore.instance;
  Future<List<Widget>> getData() async {
    int count = 0;
    List<Widget> data = [];
    DocumentReference formRef = _firestore
        .collection('forms')
        .document(uid)
        .collection('userform')
        .document(formId);
    DocumentSnapshot form = await formRef.get();
    formTypeName = form["bank_form_name"];
    agentEmail = form["agent_email"];
    CollectionReference sectionsRef = formRef.collection('section');
    QuerySnapshot sections = await sectionsRef.getDocuments();
    int size = sections.documents.length;
    if (size == 0) {
      // No Sections
      data.add(
        ListTile(
          title: Text('There are no sections in this form! ☹'),
        ),
      );
      return data;
    } else {
      for (int i = 0; i < size; i++) {
        CollectionReference fieldsRef = sectionsRef
            .document(sections.documents[i].documentID)
            .collection('fields');
        QuerySnapshot fields = await fieldsRef.getDocuments();
        int fSize = fields.documents.length;
        for (int j = 0; j < fSize; j++) {
          if (fields.documents[i].data["value"].toString().isEmpty) {
            count++;
          }
        }
      }
    }
    data.add(
      Card(
        color: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.near_me),
              title: Text(
                "FORM NAME",
              ),
              subtitle: Text(formName ?? 'NO_NAME'),
            ),
            ListTile(
              leading: Icon(Icons.toys),
              title: Text(
                "FORM TYPE",
              ),
              subtitle: Text(formTypeName ?? 'NO_TYPE'),
            ),
            ListTile(
              title: Text(
                'Fields With Empty Values: $count',
                style: TextStyle(
                    color: Colors.red[700], fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
    return data;
  }

  String _validateEmail(String input) {
    return RegExp(r'^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$')
            .hasMatch(input)
        ? null
        : 'Please Enter a valid Email Address';
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  final myController = TextEditingController();
  void setData(String input) {
    myController.text = input;
  }

  final _key = GlobalKey<FormState>();

  Future<void> _sendDetails() async {
    http.post(
      Common.appRootUrl + 'exportform/',
      body: convert.jsonEncode({
        "method": 10,
        "email": agentEmail,
        "form_id": formId,
        "uid": uid,
        "form_type": formTypeName,
        "form_name": formName,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    print({
      "method": 10,
      "email": agentEmail,
      "form_id": formId,
      "uid": uid,
      "form_type": formTypeName,
      "form_name": formName,
    });
    await Future.delayed(Duration(seconds: 1));
    Navigator.of(context).pop();
  }

  Future<void> _exportForm(int method) async {
    if (method == 3) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return LoadingBox();
          });
      // Send {form_id} {uid} {method} and {email} it to Cloud Function => if method==1 means CSV and if method==2 means Export as Excel
      var response = await http.post(
        Common.appRootUrl + 'exportform/',
        body: convert.jsonEncode({
          "method": method,
          "email": "dummy@example.com",
          "form_id": formId,
          "uid": uid,
          "form_type": formTypeName,
          "form_name": formName,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      print({
        "method": method,
        "email": 'dummy@example.com',
        "form_id": formId,
        "uid": uid,
        "form_type": formTypeName,
        "form_name": formName,
      });
      var json = convert.jsonDecode(response.body);
      print(json);
      if (json["error"] == false) {
        Navigator.of(context).pop();
        ClipboardManager.copyToClipBoard(Common.appUrl + json["url"])
            .then((result) {
          Flushbar(
            message: "Link Copied to Clipboard!",
            duration: Duration(seconds: 2),
          ).show(context);
        });
        await Future.delayed(Duration(seconds: 2, milliseconds: 100));
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        // Error Occured
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ErrorPage(),
          ),
        );
      }
      return;
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            // title:Text('Share with Others'),
            title: Text('Enter email address...'),
            content: Form(
              key: _key,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: "EMAIL",
                ),
                controller: myController,
                validator: _validateEmail,
              ),
            ),
            actions: <Widget>[
              Container(
                child: RaisedButton(
                    onPressed: () async {
                      await Navigator.pushNamed(
                        context,
                        'listening_fetch',
                        arguments: {
                          "fieldName": "New Form Name",
                          "setData": setData,
                        },
                      );
                    },
                    color: Colors.blue,
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
                  "GET ${method == 2 ? 'CSV' : 'EXCEL'}",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  if (_key.currentState.validate()) {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return LoadingBox();
                        });
                    http.post(
                      Common.appRootUrl + 'exportform/',
                      body: convert.jsonEncode({
                        "method": method,
                        "email": myController.text,
                        "form_id": formId,
                        "form_type": formTypeName,
                        "uid": uid,
                        "form_name": formName,
                      }),
                      headers: {'Content-Type': 'application/json'},
                    );

                    await Future.delayed(Duration(seconds: 1));
                    // Send {form_id} {uid} {method} and {email} it to Cloud Function => if method==1 means CSV and if method==2 means Export as CSV
                    Navigator.of(context).pop();
                    Flushbar(
                      message:
                          "You will recieve Your Form Data in ${method == 2 ? 'CSV' : 'EXCEL'} shortly!",
                      duration: Duration(seconds: 1),
                    ).show(context);
                    await Future.delayed(
                        Duration(seconds: 1, milliseconds: 100));
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          );
        });
  }

  void _sendToAgent() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Are you sure you want to send the details to bank executive?",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            content: Text("You will be contacted by the agent shortly"),
            actions: <Widget>[
              RaisedButton(
                color: Colors.red,
                child: Text(
                  "YES",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return LoadingBox();
                      });
                  // await Future.delayed(
                  //   Duration(seconds: 2),
                  // );
                  await _sendDetails();
                  // TODO: SEND EMAIL await _sendDetails();
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Flushbar(
                    message: "Application Successfully Submitted!",
                    duration: Duration(seconds: 1),
                  ).show(context);
                  await Future.delayed(Duration(seconds: 1, microseconds: 500));
                },
              ),
              RaisedButton(
                color: Colors.green,
                child: Text("NO", style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Map args = Map.from(ModalRoute.of(context).settings.arguments);
    formId = args["formId"];
    formName = args["formName"];
    uid = args["uid"];
    return FutureBuilder(
      future: getData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: Common.getAppBar(context),
            bottomNavigationBar: BottomAppBar(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'We recommend Exporting a Completely Filled Form',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black54),
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "EXPORT THE FORM",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          "Form Name: $formName" ?? "NO_NAME",
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      height: 15,
                      indent: 20,
                      endIndent: 20,
                      color: Colors.black,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ...snapshot.data,
                    Divider(
                      height: 10,
                      color: Colors.black,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: RaisedButton(
                        onPressed: () {
                          _exportForm(2);
                        },
                        child: Text('EXPORT AS CSV'),
                        color: Colors.amber[600],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: RaisedButton(
                        onPressed: () async {
                          _exportForm(1);
                        },
                        child: Text(
                          'EXPORT AS EXCEL DOCUMENT',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: RaisedButton(
                        onPressed: () {
                          _exportForm(3);
                        },
                        child: Text(
                          'GET SHAREABLE LINK',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.green[600],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: RaisedButton(
                        onPressed: () {
                          _sendToAgent();
                        },
                        child: Text(
                          'SUBMIT APPLICATION',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return ErrorPage();
        } else {
          return LoadingScreen();
        }
      },
    );
  }
}
