/// Will get sectionID and formID from list_sections

import 'package:flutter/material.dart';
import 'package:form_assist/common/common.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:form_assist/screens/loaders/loading.dart';
import 'package:form_assist/screens/loaders/loadingbox.dart';

class ShowFields extends StatefulWidget {
  @override
  _ShowFieldsState createState() => _ShowFieldsState();
}

class _ShowFieldsState extends State<ShowFields> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final _firestore = Firestore.instance;
  String formId, uid, sectionID, sectionName, formName;
  List<dynamic> selectedFields = [];

  Future<void> _deleteField(String id) async {
    DocumentReference docRef = _firestore
        .collection('forms')
        .document(uid)
        .collection('userform')
        .document(formId)
        .collection("section")
        .document(sectionID)
        .collection("fields")
        .document(id);
    await docRef.delete();
  }

  Future<dynamic> getFields() async {
    List<FormBuilderFieldOption> data = [];
    List<Widget> selectedData = [];
    CollectionReference formRef = _firestore
        .collection('forms')
        .document(uid)
        .collection('userform')
        .document(formId)
        .collection("section")
        .document(sectionID)
        .collection("fields");
    QuerySnapshot formFields = await formRef.getDocuments();
    formFields.documents.forEach((f) {
      selectedFields.add(f.documentID);
    });
    Query entryRef = _firestore
        .collection('master_fields')
        .document(sectionID)
        .collection('section')
        .orderBy('degree');
    QuerySnapshot fields = await entryRef.getDocuments();
    fields.documents.forEach((field) {
      if (!selectedFields.contains(field.documentID)) {
        var temp = FormBuilderFieldOption(
          value: field.documentID,
          label: field["tag"],
        );
        data.add(temp);
      } else {
        var temp = ListTile(
          contentPadding: EdgeInsets.fromLTRB(16, 0, 18, 0),
          leading: Text(
            field["tag"],
            style: TextStyle(fontSize: 13.5),
          ),
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text("Are you sure you want to delete it?"),
                    actions: <Widget>[
                      RaisedButton(
                        color: Colors.red[900],
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
                          await _deleteField(field.documentID);
                          Navigator.pop(context);
                          Flushbar(
                            message: "Field Deletion successful!",
                            duration: Duration(seconds: 1),
                          ).show(context);
                          await Future.delayed(
                              Duration(seconds: 1, microseconds: 500));
                          Navigator.popAndPushNamed(
                              context, 'show_fields',
                              arguments: {
                                "formId": formId,
                                "section_id": sectionID,
                                "section_name": sectionName,
                                "uid": uid,
                                "formName": formName
                              });
                          // Navigator.popUntil(
                          //     context,
                          //     (route) =>
                          //         route.settings.name == 'ashow_sections');
                        },
                      ),
                      RaisedButton(
                        color: Colors.black,
                        child: Text(
                          "NO",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                });
          },
          trailing: Icon(
            Icons.delete,
            color: Colors.red,
          ),
        );
        selectedData.add(temp);
      }
    });
    if (selectedData.isNotEmpty) {
      return [
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 8, 4),
            child: Text(
              "CURRENT FIELDS",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        ...selectedData,
        Divider(
          color: Colors.black,
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 8, 4),
            child: Text(
              "ADD FIELDS",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 8, 0),
          child: FormBuilderCheckboxList(
            options: data,
            attribute: sectionID ?? 'NO_NAME',
          ),
        ),
      ];
    } else {
      return [
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 8, 0),
            child: Text(
              "*Add Form Elements to this Section",
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 8, 0),
          child: FormBuilderCheckboxList(
            options: data,
            attribute: sectionID ?? 'NO_NAME',
          ),
        ),
      ];
    }
  }

  Future<void> _submitForm(Map<String, dynamic> payload) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return LoadingBox();
        });
    for (var entry in payload.entries) {
      List<dynamic> fields = entry.value;
      for (int i = 0; i < fields.length; i++) {
        DocumentReference entryRef = _firestore
            .collection("master_fields")
            .document(sectionID)
            .collection('section')
            .document(fields[i]);
        await entryRef.get().then(
          (onValue) async {
            DocumentReference docRef = _firestore
                .collection('forms')
                .document(uid)
                .collection('userform')
                .document(formId)
                .collection('section')
                .document(sectionID);

            // Writing Section Name
            await docRef.setData({"section_name": sectionName});
            // Writing Field Data
            await docRef
                .collection('fields')
                .document(entryRef.documentID)
                .setData({"value": "", ...onValue.data}, merge: true);
          },
        );
      }
    }
    Navigator.pop(context);
    print("uid: $uid");
    print(formId);
    print("Success");
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    try {
      final args = Map.from(ModalRoute.of(context).settings.arguments);
      formId = args["formId"];
      sectionID = args["section_id"];
      sectionName = args["section_name"];
      uid = args["uid"];
      formName = args["formName"];
      // selectedFields = args["fields"];
    } catch (error) {
      print("Error encountered in Listing Fields! $error");
    }
    return StreamBuilder(
      stream: Stream.fromFuture(getFields()),
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
                        if (_fbKey.currentState.saveAndValidate()) {
                          _submitForm(_fbKey.currentState.value).then((val) {
                            Navigator.pop(context);
                          });
                        }
                      },
                      child: Text(
                        'SUBMIT',
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
                      color: Colors.blue[800],
                      onPressed: () {
                        _fbKey.currentState.reset();
                      },
                      child: Text(
                        'RESET',
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
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                width: MediaQuery.of(context).size.width,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FormBuilder(
                        key: _fbKey,
                        initialValue: {
                          'date': DateTime.now(),
                        },
                        child: Column(children: [
                          Text(
                            "FORM BUILDER",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                          // SizedBox(height: 5,),
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
                            height: 7,
                          ),
                          Text(
                            "$sectionName" ?? "NO_NAME",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.blue[900]),
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          ...snapshot.data
                        ]),
                      ),
                    ]),
              ),
            ),
          );
        } else {
          return LoadingScreen();
        }
      },
    );
  }
}
