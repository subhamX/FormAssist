import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:form_assist/common/common.dart';
import 'package:flushbar/flushbar.dart';
import 'package:form_assist/error/errorpage.dart';
import 'package:form_assist/screens/loaders/loading.dart';
import 'package:form_assist/screens/loaders/loadingbox.dart';

class FormFields extends StatefulWidget {
  @override
  _FormFieldsState createState() => _FormFieldsState();
}

class _FormFieldsState extends State<FormFields> {
  String formId, uid, sectionId, sectionName, formName;
  final _firestore = Firestore.instance;
  Future<List<Widget>> _getFields() async {
    List<Widget> data = [];

    data.add(Padding(
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
    ));
    data.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Icon(Icons.remove_red_eye),
              SizedBox(
                width: 2,
              ),
              Text(
                "Viewing Mode",
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    data.add(
      Divider(
        height: 15,
        indent: 20,
        endIndent: 20,
        color: Colors.black,
      ),
    );
    data.add(SizedBox(
      height: 10,
    ));
    data.add(Text(
      "$sectionName" ?? "NO_NAME",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    ));
    data.add(Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          "*NOTE - NO_VAL corresponds to Empty Values",
          style: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w700,
            // fontStyle: FontStyle.italic,
            fontSize: 11,
          ),
        ),
      ),
    ));
    data.add(SizedBox(
      height: 10,
    ));
    CollectionReference fieldsRef = _firestore
        .collection("forms")
        .document(uid)
        .collection("userform")
        .document(formId)
        .collection("section")
        .document(sectionId)
        .collection("fields");
    QuerySnapshot fields = await fieldsRef.getDocuments();
    int size = fields.documents.length;
    if (size == 0) {
      // This case will never arise; Already handled it in form creation.
      data.add(Text("No Fields Chosen"));
    }
    for (int i = 0; i < size; i++) {
      var field = fields.documents[i];
      Widget temp = ListTile(
        title: Text(field.data["tag"] ?? "NO_TAG"),
        subtitle:
            Text(field.data["value"] == "" ? "NO_VAL" : field.data["value"]),
      );
      data.add(temp);
    }
    return data;
  }

  Future<void> _deleteSection() async {
    DocumentReference docRef = _firestore
        .collection("forms")
        .document(uid)
        .collection("userform")
        .document(formId)
        .collection("section")
        .document(sectionId);
    await docRef.delete();
  }

  @override
  Widget build(BuildContext context) {
    Map args = Map.from(ModalRoute.of(context).settings.arguments);
    formId = args["formId"];
    uid = args["uid"];
    sectionId = args["section_id"];
    sectionName = args["section_name"];
    formName = args["formName"];
    return FutureBuilder(
      future: _getFields(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: Common.getAppBar(context),
            bottomNavigationBar: Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      color: Colors.blue[800],
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, "show_selected_fields",
                            arguments: {
                              "formId": formId,
                              "section_name": sectionName,
                              "formName": formName,
                              "uid": uid,
                              "section_id": sectionId,
                            });
                      },
                      child: Text(
                        'EDIT MODE',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: FlatButton(
                      color: Colors.red[800],
                      onPressed: () async {
                        await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(
                                  "Are you sure you want to delete the section?",
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                                content:
                                    Text("This action cannot be reverted."),
                                actions: <Widget>[
                                  RaisedButton(
                                    color: Colors.red,
                                    child: Text("YES",
                                        style: TextStyle(color: Colors.white)),
                                    onPressed: () async {
                                      showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) {
                                            return LoadingBox();
                                          });
                                      await _deleteSection();
                                      Navigator.pop(context);
                                      Flushbar(
                                        message: "Section Deletion Successful!",
                                        duration: Duration(seconds: 1),
                                      ).show(context);
                                      await Future.delayed(Duration(
                                          seconds: 1, microseconds: 500));
                                      Navigator.of(context).popUntil((route) =>
                                          route.settings.name ==
                                          "form_sections");
                                    },
                                  ),
                                  RaisedButton(
                                    color: Colors.green,
                                    child: Text("NO",
                                        style: TextStyle(color: Colors.white)),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                      child: Text(
                        'DELETE SECTION',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/form-preview.png',
                          height: 55,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "PREVIEW FORM",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                      ],
                    ),
                    ...snapshot.data,
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
