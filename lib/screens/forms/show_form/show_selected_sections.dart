import 'package:flutter/material.dart';
import 'package:form_assist/common/common.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:form_assist/screens/loaders/loading.dart';
import 'package:form_assist/screens/loaders/loadingbox.dart';

class ShowSelectedSections extends StatefulWidget {
  @override
  _ShowSelectedSectionsState createState() => _ShowSelectedSectionsState();
}

class _ShowSelectedSectionsState extends State<ShowSelectedSections> {
  String _formName, _formType, formId, uid;
  final myController = TextEditingController();
  final myControllerFT = TextEditingController();
  final _key = GlobalKey<FormState>();

  void setData(String input) {
    myController.text = input;
  }

  @override
  void dispose() {
    myController.dispose();
    myControllerFT.dispose();
    super.dispose();
  }

  final _firestore = Firestore.instance;
  List<Widget> formData = [];

  Future<List<Widget>> getSections() async {
    List<Widget> data = [];
    try {
      DocumentReference formRef = _firestore
          .collection('forms')
          .document(uid)
          .collection('userform')
          .document(formId);

      DocumentSnapshot form = await formRef.get();
      _formName = form.data["form_name"];
      _formType = form.data["bank_form_name"];
      if (form.exists) {
        CollectionReference sectionsRef = formRef.collection('section');
        QuerySnapshot sections = await sectionsRef.getDocuments();
        int size = sections.documents.length;
        if (size == 0) {
          data.add(
            Text(
              "This form is empty! ☹",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
            ),
          );
          return data;
        }
        for (int i = 0; i < size; i++) {
          var section = sections.documents[i];
          data.add(
            ListTileTheme(
              child: ListTile(
                title: Text(
                  section["section_name"] ?? 'None',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
                onTap: () async {
                  await Navigator.pushNamed(context, 'show_selected_fields',
                      arguments: {
                        "section_id": section.documentID,
                        "section_name": section["section_name"],
                        "formId": formId,
                        "formName": _formName,
                        "uid": uid,
                      });
                },
              ),
            ),
          );
        }
      } else {
        data.add(Text("Error in getting form"));
      }
      return data;
    } catch (err) {
      print("Error in getting sections! $err");
      return [
        Text('Error in getting sections!'),
      ];
    }
  }

  void setDataFT(String input) {
    myControllerFT.text = input;
  }

  @override
  Widget build(BuildContext context) {
    try {
      final args = Map.from(ModalRoute.of(context).settings.arguments);
      formId = args["formId"];
      uid = args["uid"];
    } catch (error) {
      // return ErrorPage("Something Went Wrong");
      // Navigator.pushNamed(context, 'error');
    }
    return FutureBuilder(
      future: getSections(),
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
                          Navigator.pushNamed(context, 'show_sections',
                              arguments: {
                                "formId": formId,
                                "uid": uid,
                                "formName": _formName,
                              });
                        },
                        child: Text(
                          'ADD/EDIT FIELDS',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Container(
                      child: FlatButton(
                        color: Colors.blue[800],
                        onPressed: () async {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return LoadingBox();
                              });
                          await Future.delayed(Duration(seconds: 1));
                          Navigator.pop(context);
                          Flushbar(
                            message: "Changes Successfully Saved!",
                            duration: Duration(seconds: 1, milliseconds: 500),
                          ).show(context);
                          await Future.delayed(
                              Duration(seconds: 1, milliseconds: 500));
                          Navigator.pop(context);
                        },
                        child: Text(
                          'SUBMIT',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
            body: SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  width: MediaQuery.of(context).size.width,
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
                                fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                        ],
                      ),
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
                      Divider(
                        height: 15,
                        indent: 20,
                        endIndent: 20,
                        color: Colors.black,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                      padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "*Tap to Edit Form Directly",
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w700,
                            // fontStyle: FontStyle.italic,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                      ListTile(
                        leading: Tab(icon: Image.asset("assets/form-icon.png")),
                        title: Text(
                          "FORM NAME",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(_formName ?? ""),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content: Form(
                                    key: _key,
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: "Form Name",
                                      ),
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
                                  actions: <Widget>[
                                    Container(
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
                                                style: TextStyle(
                                                    color: Colors.white),
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
                                        "UPDATE FORM NAME",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () async {
                                        if (_key.currentState.validate()) {
                                          DocumentReference formRef = _firestore
                                              .collection('forms')
                                              .document(uid)
                                              .collection('userform')
                                              .document(formId);
                                          if (myController.text != _formName) {
                                            await formRef.updateData(
                                              {"form_name": myController.text},
                                            );
                                            setState(() {
                                              _formName = myController.text;
                                            });
                                          }

                                          Navigator.of(context).pop();
                                          Flushbar(
                                            message:
                                                "Form Name Updation Successful!",
                                            duration: Duration(seconds: 1),
                                          ).show(context);
                                        }
                                      },
                                    ),
                                  ],
                                );
                              });
                        },
                        trailing: Icon(Icons.edit),
                      ),
                      ListTile(
                        leading: Tab(
                          icon: Image.asset(
                            "assets/form-type.png",
                            height: 40,
                          ),
                        ),
                        title: Text(
                          "FORM TYPE",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(_formType ?? ""),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content: Form(
                                    key: _key,
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: "Form Type",
                                      ),
                                      controller: myControllerFT,
                                      validator: (input) {
                                        if (input.length > 0) {
                                          return null;
                                        } else {
                                          return "Please Enter a valid Form Type";
                                        }
                                      },
                                    ),
                                  ),
                                  actions: <Widget>[
                                    Container(
                                      child: RaisedButton(
                                          color: Colors.blue,
                                          onPressed: () async {
                                            await Navigator.pushNamed(
                                              context,
                                              'listening_fetch',
                                              arguments: {
                                                "setData": setDataFT,
                                              },
                                            );
                                          },
                                          child: Row(
                                            children: <Widget>[
                                              Text(
                                                'MIC',
                                                style: TextStyle(
                                                    color: Colors.white),
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
                                        "UPDATE FORM TYPE",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () async {
                                        if (_key.currentState.validate()) {
                                          DocumentReference formRef = _firestore
                                              .collection('forms')
                                              .document(uid)
                                              .collection('userform')
                                              .document(formId);
                                          if (myControllerFT.text !=
                                              _formType) {
                                            await formRef.updateData(
                                              {
                                                "bank_form_name":
                                                    myControllerFT.text
                                              },
                                            );
                                            setState(() {
                                              _formType = myControllerFT.text;
                                            });
                                          }

                                          Navigator.of(context).pop();
                                          Flushbar(
                                            message:
                                                "Form Type Updation Successful!",
                                            duration: Duration(seconds: 1),
                                          ).show(context);
                                        }
                                      },
                                    ),
                                  ],
                                );
                              });
                        },
                        trailing: Icon(Icons.edit),
                      ),
                      Divider(
                        height: 15,
                        color: Colors.grey,
                        thickness: 1.1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "SECTIONS",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
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
                    ],
                  )),
            ),
          );
        } else {
          return LoadingScreen();
        }
      },
    );
  }
}
