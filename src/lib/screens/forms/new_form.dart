import 'package:flutter/material.dart';
import 'package:form_assist/common/common.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:form_assist/error/errorpage.dart';
import 'package:form_assist/screens/loaders/loadingbox.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class NewForm extends StatefulWidget {
  @override
  _NewFormState createState() => _NewFormState();
}

class _NewFormState extends State<NewForm> {
  final _key = GlobalKey<FormState>();
  String _name;
  int _templateId;
  List<Map<dynamic, dynamic>> forms;
  final _firestore = Firestore.instance;
  final _auth = FirebaseAuth.instance;
  final myController = TextEditingController();

  @override
  void initState() {
    forms = Common.forms;
    super.initState();
  }

  void _submitForm() async {
    try {
      // Validating Form
      if (_key.currentState.validate()) {
        // Showing Loading Box
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return LoadingBox();
            });
        _key.currentState.save();
        print(_name);
        print(_templateId);

        // Fetching current user instance
        FirebaseUser user = await _auth.currentUser();

        // Make a new form instance and get it's id. then Navigate to EDIT_FIELDS
        // Adding form_name inside forms/uid/formid/loan_details/

        // If User Is Logged In
        if (!user.isAnonymous) {
          // Custom Form
          if (_templateId == -1) {
            DocumentReference userFormRef = _firestore
                .collection('forms')
                .document(user.uid)
                .collection('userform')
                .document();
            await userFormRef.setData(
                {"form_name": _name, "bank_form_name": 'CUSTOMIZED FORM'},
                merge: true);
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, 'show_sections',
                arguments: {
                  'formId': userFormRef.documentID,
                  'uid': user.uid,
                  'formName': _name,
                });
          } else {
            String bankFormID;
            if (_templateId == 0) {
              bankFormID = Common.sbiFormId;
            } else if (_templateId == 1) {
              bankFormID = Common.hdfcBankFormId;
            } else if (_templateId == 2) {
              bankFormID = Common.unionBankFormId;
            } else if (_templateId == 3) {
              bankFormID = Common.indianBankFormId;
            } else {
              return;
            }

            // Sending POST request to server to copy the bank form
            var url = Common.appRootUrl + 'copybankform/';
            var response = await http.post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: convert.jsonEncode({
                'uid': user.uid,
                'form_name': _name,
                'bank_form_id': bankFormID,
                'bank_form_name': forms[_templateId]["name"]
              }),
            );
            var jsonData = convert.jsonDecode(response.body);
            print("Response: ${response.body}");

            // Poping Loading Screen
            Navigator.pop(context);
            // If there is error
            if (jsonData["error"] == true) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ErrorPage(),
                ),
              );
            } else {
              // Navigating User to Add Data to Form
              Navigator.pushReplacementNamed(context, 'show_selected_sections',
                  arguments: {
                    'formId': jsonData["formId"],
                    'uid': user.uid,
                    'formName': _name,
                  });
            }
          }
        }
      }
    } catch (onError) {
      print(onError);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ErrorPage(),
        ),
      );
    }
  }

  // Helper Function To Set Data
  void setData(String input) {
    myController.text = input;
    _name = input;
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Common.getAppBar(context),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/template-icon.png',
                    height: 55,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "FORM GALLERY",
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
              SizedBox(
                height: 20,
              ),
              Text(
                "*Pick a template or start from scratch to create a brand new Form",
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Form(
                key: _key,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.fromLTRB(2, 2, 0, 2),
                          width: MediaQuery.of(context).size.width * 0.80,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Form Name",
                            ),
                            onChanged: (input) {
                              _name = input;
                            },
                            controller: myController,
                            validator: (input) {
                              if (input.length > 0) {
                                return null;
                              } else {
                                return "Please Enter a valid Form Name";
                              }
                            },
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await Navigator.pushNamed(
                              context,
                              'listening_fetch',
                              arguments: {
                                "fieldName": "Form Name",
                                "path": "/forms/",
                                "setData": setData,
                              },
                            );
                          },
                          child: Icon(
                            Icons.mic,
                            color: Colors.black,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: DropdownButtonFormField<int>(
                        validator: (input) {
                          if (input == null) {
                            return 'Please Choose A Valid Option';
                          } else {
                            return null;
                          }
                        },
                        hint: Text("Select Template"),
                        value: _templateId,
                        items: [
                          ...forms.map((Map value) {
                            return new DropdownMenuItem<int>(
                              value: value["id"],
                              child: new Text(value["name"]),
                            );
                          }).toList(),
                          DropdownMenuItem<int>(
                            value: -1,
                            child: new Text('BUILD FROM SCRATCH'),
                          ),
                        ],
                        onChanged: (a) {
                          setState(() {
                            _templateId = a;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    RaisedButton(
                      color: Colors.blue[800],
                      onPressed: () {
                        _submitForm();
                      },
                      child: Text(
                        'SUBMIT',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ]),
          ),
        ));
  }
}
