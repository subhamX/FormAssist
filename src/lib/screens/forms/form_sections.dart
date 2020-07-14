import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:form_assist/common/common.dart';
import 'package:flushbar/flushbar.dart';
import 'package:form_assist/screens/loaders/loading.dart';
import 'package:form_assist/screens/loaders/loadingbox.dart';

class FormSections extends StatefulWidget {
  @override
  _FormSectionsState createState() => _FormSectionsState();
}

class _FormSectionsState extends State<FormSections> {
  String formName, formId, uid, formType;
  final _firestore = Firestore.instance;
  Future<void> _deleteForm() async {
    DocumentReference docRef = _firestore
        .collection("forms")
        .document(uid)
        .collection("userform")
        .document(formId);
    await docRef.delete();
  }

  Future<List<Widget>> _getSections() async {
    List<Widget> data = [];
    DocumentReference docRef = _firestore
        .collection("forms")
        .document(uid)
        .collection("userform")
        .document(formId);
    DocumentSnapshot doc = await docRef.get();
    if (doc.exists) {
      CollectionReference sectionRef = docRef.collection("section");
      QuerySnapshot sections = await sectionRef.getDocuments();
      int size = sections.documents.length;
      if (size == 0) {
        data.add(Container(child: Text("This form is empty! ☹")));
        return data;
      }
      for (int i = 0; i < size; i++) {
        var section = sections.documents[i];
        Widget temp = ListTile(
          onTap: () {
            // Navigate to doc.documentID
            Navigator.pushNamed(context, "form_fields", arguments: {
              "uid": uid,
              "formId": formId,
              "section_id": section.documentID,
              "formName": formName,
              "section_name": section.data["section_name"]
            });
          },
          title: Text(section.data["section_name"] ?? "NO_NAME"),
        );
        data.add(temp);
      }
      return data;
    } else {
      // Show ERROR - Form Doesn't exist
      data.add(Text('ERROR'));
      return data;
    }
  }

  @override
  Widget build(BuildContext context) {
    Map args = Map.from(ModalRoute.of(context).settings.arguments);
    formId = args["formId"];
    uid = args["uid"];
    formName = args["formName"];
    formType = args["formType"];
    return FutureBuilder(
      future: _getSections(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: Common.getAppBar(context),
            bottomNavigationBar: Padding(
              padding: EdgeInsets.fromLTRB(7, 0, 7, 0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width*0.38,
                    child: FlatButton(
                      color: Colors.blue[800],
                      onPressed: () {
                        // Sending it to EDIT THE FORM
                        Navigator.popAndPushNamed(
                            context, "show_selected_sections",
                            arguments: {
                              "formId": formId,
                              "uid": uid,
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
                    width: 7,
                  ),
                  Expanded(
                    child: FlatButton(
                      color: Colors.red[800],
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(
                                  "Are you sure you want to delete the form?",
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                                content:
                                    Text("This action cannot be reverted."),
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
                                      await _deleteForm();
                                      Navigator.pop(context);
                                      Flushbar(
                                        message: "Form Deletion Successful!",
                                        duration: Duration(seconds: 1),
                                      ).show(context);
                                      await Future.delayed(Duration(
                                          seconds: 1, microseconds: 500));
                                      Navigator.of(context).popUntil((route) =>
                                          route.settings.name == "form_list");
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
                        'DELETE',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 7,
                  ),
                  Expanded(
                    child: FlatButton(
                      color: Colors.green[800],
                      onPressed: () {
                        Navigator.pushNamed(context, 'export_screen',
                            arguments: {
                              'formId': formId,
                              'formName': formName,
                              'uid': uid,
                            });
                      },
                      child: Text(
                        'EXPORT',
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
                    // Text(
                    //   "FORM PREVIEW",
                    //   style:
                    //       TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    // ),
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
                          "*Read Or Export the final form",
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
                      height: 10,
                    ),
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      ListTile(
                        leading: Tab(icon: Image.asset("assets/form-icon.png")),
                        title: Text(
                          "FORM NAME",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(formName ?? 'NO_NAME'),
                      ),
                      ListTile(
                        leading: Tab(
                            icon: Image.asset(
                          "assets/form-type.png",
                          height: 40,
                        )),
                        title: Text(
                          "FORM TYPE",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(formType ?? 'NO_NAME'),
                      ),
                    ]),
                    Divider(
                      height: 15,
                      color: Colors.black,
                    ),
                    Text(
                      "SECTIONS",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "*Tap On Any Section To View the Fields",
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
                      height: 10,
                    ),
                    Divider(
                      height: 15,
                      endIndent: 50,
                      indent: 60,
                      color: Colors.black,
                    ),

                    ...snapshot.data,
                  ],
                ),
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
