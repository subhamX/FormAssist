/// Will get sectionID and formID from list_sections

import 'package:flutter/material.dart';
import 'package:form_assist/common/common.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:form_assist/error/errorpage.dart';
import 'package:form_assist/screens/loaders/loading.dart';
import 'package:form_assist/screens/loaders/loadingbox.dart';

class CustomFieldList extends StatefulWidget {
  @override
  _CustomFieldListState createState() => _CustomFieldListState();
}

class _CustomFieldListState extends State<CustomFieldList> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final _key = GlobalKey<FormState>();
  final _firestore = Firestore.instance;
  String formId, formName, fieldName;
  String uid;
  List<dynamic> selectedFields = [];
  final myController = TextEditingController();

  void setData(String input) {
    myController.text = input;
    fieldName = input;
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  void addNewField() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'ADD NEW FIELD',
              style: TextStyle(),
            ),
            content: Container(
              child: Form(
                key: _key,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Field Name",
                  ),
                  controller: myController,
                  onChanged: (input) {
                    fieldName = input;
                  },
                  validator: (input) {
                    if (input.length > 0) {
                      return null;
                    } else {
                      return "Please Enter a valid Field Name";
                    }
                  },
                ),
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
                          "fieldName": "Field Name",
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
                  "ADD FIELD",
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
                    DocumentReference othersRef = _firestore
                        .collection('forms')
                        .document(uid)
                        .collection('userform')
                        .document(formId)
                        .collection("section")
                        .document("others");
                    CollectionReference userDataRef = _firestore
                        .collection('users')
                        .document(uid)
                        .collection('data')
                        .document("others")
                        .collection('fields');
                    DocumentReference temp = await userDataRef.add(
                      {
                        "tag": fieldName,
                        "degree": 1,
                        "type": "string",
                        "value": "",
                        "fields": [],
                      },
                    );
                    await othersRef.setData({'section_name': 'OTHERS'});
                    CollectionReference fieldRef =
                        othersRef.collection("fields");
                    await fieldRef.document(temp.documentID).setData(
                      {
                        "tag": fieldName,
                        "degree": 1,
                        "type": "string",
                        "value": "",
                        "fields": [],
                      },
                    );
                    Flushbar(
                      message: "Field Addition Successful!",
                      duration: Duration(seconds: 1),
                    ).show(context);
                    await Future.delayed(
                        Duration(seconds: 1, milliseconds: 100));
                    Navigator.of(context).pop();
                    Navigator.pop(context);

                    Navigator.popAndPushNamed(context, 'custom_field_list',
                        arguments: {
                          "formId": formId,
                          "uid": uid,
                          "formName": formName,
                        });
                  }
                },
              ),
            ],
          );
        });
  }

  Future<void> _deleteField(String id) async {
    DocumentReference docRef = _firestore
        .collection('forms')
        .document(uid)
        .collection('userform')
        .document(formId)
        .collection("section")
        .document('others')
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
        .document("others")
        .collection("fields");
    QuerySnapshot formFields = await formRef.getDocuments();
    formFields.documents.forEach((f) {
      selectedFields.add(f.documentID);
    });
    Query entryRef = _firestore
        .collection('users')
        .document(uid)
        .collection('data')
        .document('others')
        .collection('fields');
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
                          await _deleteField(field.documentID);
                          Flushbar(
                            message: "Field Deletion successful!",
                            duration: Duration(seconds: 1),
                          ).show(context);
                          await Future.delayed(
                              Duration(seconds: 1, microseconds: 500));
                          Navigator.popUntil(
                              context,
                              (route) =>
                                  route.settings.name == 'show_sections');
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
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: RaisedButton(
            color: Colors.pink[800],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.add_box,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'ADD NEW FIELD',
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
            onPressed: addNewField,
          ),
        ),
        Divider(
          color: Colors.black,
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          "CURRENT FIELDS",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        SizedBox(
          height: 10,
        ),
        ...selectedData,
        Divider(
          color: Colors.black,
        ),
        SizedBox(
          height: 20,
        ),
        data.isNotEmpty
            ? Text(
                "ADD CUSTOM FIELDS",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              )
            : SizedBox(),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 8, 0),
          child: FormBuilderCheckboxList(
            options: data,
            attribute: 'others',
          ),
        ),
      ];
    } else {
      return [
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: RaisedButton(
            color: Colors.pink[800],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.add_box,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'ADD NEW FIELD',
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
            onPressed: addNewField,
          ),
        ),
        Divider(
          color: Colors.black,
        ),
        SizedBox(
          height: 20,
        ),
        data.isNotEmpty
            ? Text(
                "ADD CUSTOM FIELDS",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              )
            : SizedBox(),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 8, 0),
          child: FormBuilderCheckboxList(
            options: data,
            attribute: 'others',
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
            .collection("users")
            .document(uid)
            .collection('data')
            .document('others')
            .collection('fields')
            .document(fields[i]);
        await entryRef.get().then(
          (onValue) async {
            DocumentReference docRef = _firestore
                .collection('forms')
                .document(uid)
                .collection('userform')
                .document(formId)
                .collection('section')
                .document('others');

            // Writing Section Name
            await docRef.setData({"section_name": 'OTHERS'});
            // Writing Field Data
            await docRef
                .collection('fields')
                .document(entryRef.documentID)
                .setData(onValue.data);
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
      uid = args["uid"];
      formName = args["formName"];
    } catch (error) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ErrorPage(),
        ),
      );
    }
    return FutureBuilder(
      future: getFields(),
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
                child: Column(children: [
                  Text(
                    "OTHERS SECTION" ?? "NO_NAME",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                  FormBuilder(
                    key: _fbKey,
                    initialValue: {
                      'date': DateTime.now(),
                    },
                    child: Column(children: [
                      ...snapshot.data,
                    ]),
                  ),
                  SizedBox(
                    height: 10,
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
