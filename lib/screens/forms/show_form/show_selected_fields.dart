import 'dart:async';

import 'package:flutter/material.dart';
import 'package:form_assist/common/common.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:form_assist/error/errorpage.dart';
import 'package:form_assist/screens/loaders/loading.dart';
import 'package:form_assist/screens/loaders/loadingbox.dart';
import 'package:form_assist/services/Speech2Text.dart';
import 'package:form_assist/services/Text2Speech.dart';

class ShowSelectedFields extends StatefulWidget {
  @override
  _ShowSelectedFieldsState createState() => _ShowSelectedFieldsState();
}

class _ShowSelectedFieldsState extends State<ShowSelectedFields> {
  String formId, formName;
  String uid;
  String sectionID, sectionName;
  TextTSpeech text2Speech;
  SpeechTText speech2Text;

  final _firestore = Firestore.instance;
  List<Widget> formData = [];
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  // Function to Submit the form and update the database
  Future<void> _submitForm(Map<String, dynamic> payload) async {
    // Showing Loader
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return LoadingBox();
        });
    for (var entry in payload.entries) {
      String fieldID = entry.key;
      dynamic value = entry.value;
      // If value is changed only then updating it
      if ((initialValue[fieldID] != value.toString())) {
        // If value is '-' then it is dropdown. Making it empty string;
        if (value == '-') {
          value = '';
        }
        try {
          // docRef to the field
          var docRef = _firestore
              .collection('forms')
              .document(uid)
              .collection('userform')
              .document(formId)
              .collection('section')
              .document(sectionID)
              .collection('fields')
              .document(fieldID);
          await docRef.updateData({'value': value});
        } catch (err) {
          print(err);
        }
      }
    }
    print('FORM SUBMITTED SUCCESSFULLY');
    Navigator.pop(context);
  }

  Widget returnWrappedWidget(
      Widget temp, String tag, String docID, String type) {
    return Row(
      children: <Widget>[
        Container(
          child: temp,
          padding: EdgeInsets.fromLTRB(2, 2, 0, 2),
          width: MediaQuery.of(context).size.width * 0.88,
        ),
        GestureDetector(
          onTap: () async {
            await Navigator.pushNamed(
              context,
              'listening',
              arguments: {
                "fieldName": tag,
                "path":
                    "/forms/$uid/userform/$formId/section/$sectionID/fields/$docID",
                "type": type
              },
            );
            Navigator.popAndPushNamed(context, 'show_selected_fields',
                arguments: {
                  "formId": formId,
                  "section_id": sectionID,
                  "section_name": sectionName,
                  "formName": formName,
                  "uid": uid,
                });
          },
          child: Icon(
            Icons.mic,
            color: Colors.black,
            size: 30,
          ),
        ),
      ],
    );
  }

  Map<String, String> initialValue = new Map();
  Future<List<Widget>> getFields() async {
    List<Widget> mainData = [];
    DocumentReference formRef = _firestore
        .collection('forms')
        .document(uid)
        .collection('userform')
        .document(formId);
    DocumentSnapshot form = await formRef.get();
    if (form.exists) {
      // Traversing All Fields Inside section

      mainData.add(
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
      );
      mainData.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Icon(Icons.edit),
                SizedBox(
                  width: 2,
                ),
                Text(
                  "Editing Mode",
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      mainData.add(
        Divider(
          height: 15,
          indent: 20,
          endIndent: 20,
          color: Colors.black,
        ),
      );
      mainData.add(
        SizedBox(
          height: 10,
        ),
      );
      mainData.add(Padding(
        padding: const EdgeInsets.fromLTRB(0, 4, 4, 20),
        child: Text(
          "$sectionName" ?? "NO_NAME",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ));
      Query fieldsRef = formRef
          .collection('section')
          .document(sectionID)
          .collection('fields')
          .orderBy('degree');
      QuerySnapshot fields = await fieldsRef.getDocuments();
      fields.documents.forEach((field) {
        String type = field["type"];
        String docID = field.documentID;
        List options;
        try {
          options = List.from(field["fields"]);
          options.insert(0, '-');
        } catch (err) {
          print(err);
        }
        String tag = field["tag"];
        String value = field["value"];
        if (options.length > 1) {
          initialValue[docID] = value.length > 0 ? value : options[0];
        } else {
          initialValue[docID] = value;
        }
        Widget temp;
        if (options.length > 1) {
          // Show DropDown. <Includes Boolean Too>
          temp = FormBuilderDropdown(
            attribute: docID,
            decoration: InputDecoration(
              labelText: tag,
            ),
            initialValue: value.length > 0 ? value : options[0],
            // hint: Text(value ?? ''),
            validators: [],
            items: options
                .map((option) =>
                    DropdownMenuItem(value: option, child: Text("$option")))
                .toList(),
          );
        } else if (type == 'number') {
          // Number
          temp = FormBuilderTextField(
            attribute: docID,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: tag,
            ),
            initialValue: value.length > 0 ? value : '',
            validators: [
              FormBuilderValidators.numeric(),
            ],
          );
          temp = returnWrappedWidget(temp, tag, docID, "number");
        } else if (type == 'date') {
          temp = FormBuilderDateTimePicker(
            attribute: "date",
            keyboardType: TextInputType.datetime,
            inputType: InputType.date,
            // initialValue: value.length>0? DateTime.parse(value): DateTime.now(),
            initialValue:
                value.length > 0 ? DateTime.parse(value) : DateTime.now(),
            decoration: InputDecoration(labelText: tag),
          );
        } else if (type == 'pin') {
          temp = FormBuilderTextField(
            attribute: docID,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: tag,
            ),
            initialValue: value.length > 0 ? value : '',
            validators: [
              FormBuilderValidators.numeric(),
              FormBuilderValidators.pattern(
                r'^[1-9]{1}[0-9]{2}\s{0,1}[0-9]{3}$',
                errorText: "Please Enter a valid PIN Code",
              ),
            ],
          );
          temp = returnWrappedWidget(temp, tag, docID, "pin");
        } else if (type == 'email') {
          temp = FormBuilderTextField(
            attribute: docID,
            keyboardType: TextInputType.emailAddress,
            initialValue: value.length > 0 ? value : '',
            decoration: InputDecoration(
              labelText: "Email",
            ),
            validators: [
              FormBuilderValidators.email(),
            ],
          );
          temp = returnWrappedWidget(temp, tag, docID, "email");
        } else if (type == 'phone') {
          temp = FormBuilderTextField(
            attribute: docID,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: tag,
            ),
            initialValue: value.length > 0 ? value : '',
            validators: [
              FormBuilderValidators.pattern(
                r'^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$',
                errorText: "Please Enter a valid Phone Number",
              ),
            ],
          );
          temp = returnWrappedWidget(temp, tag, docID, "phone");
        } else if (type == 'string') {
          temp = FormBuilderTextField(
            attribute: docID,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: tag,
            ),
            initialValue: value.length > 0 ? value : '',
            validators: [],
          );
          temp = returnWrappedWidget(temp, tag, docID, "string");
        } else {
          // For Others Returning A TextField
          temp = FormBuilderTextField(
            attribute: docID,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: tag,
            ),
            validators: [],
          );
          temp = returnWrappedWidget(temp, tag, docID, "string");
        }

        mainData.add(temp);
      });

      return mainData;
    } else {
      print('Form Doesn\'t Exist');
      // Navigating to ERROR PAGE
      Navigator.pushReplacementNamed(context, 'error_page');
      return [];
    }
  }

  @override
  void dispose() {
    super.dispose();
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
      formName = args["formName"];
      uid = args["uid"];
      // formId = 'DZdvdm333eGs04Fg0jYN';
      // uid = 'ZZ0OtuI66beDmrChXF01367apH32';
    } catch (error) {
      print(error);
      // Navigator.pushNamed(context, 'error');
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
                            _submitForm(_fbKey.currentState.value).then((f) {
                              if (mounted) {
                                Navigator.pop(context);
                              }
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
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: <Widget>[
                        FormBuilder(
                          key: _fbKey,
                          initialValue: {
                            'date': DateTime.now(),
                          },
                          autovalidate: true,
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    'assets/edit-form-icon.png',
                                    height: 40,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    "EDIT FORM",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24),
                                  ),
                                ],
                              ),
                              ...snapshot.data,
                            ],
                          ),
                        ),
                      ],
                    )),
              ));
        } else if (snapshot.hasError) {
          return ErrorPage();
        } else {
          return LoadingScreen();
        }
      },
    );
  }
}
