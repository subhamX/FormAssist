import 'package:flutter/material.dart';
import 'package:form_assist/common/common.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:form_assist/screens/loaders/loading.dart';

class FormsList extends StatefulWidget {
  FormsState createState() {
    return FormsState();
  }
}

class FormsState extends State<FormsList> {
  Color _getColor(int n) {
    return Common.colors[n % 5];
  }

  final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;
  Future<List<Widget>> _getFormsList() async {
    List<Widget> data = [];
    FirebaseUser user = await _auth.currentUser();
    if (!user.isAnonymous) {
      String uid = user.uid;
      CollectionReference formsRef =
          _firestore.collection("forms").document(uid).collection("userform");
      QuerySnapshot forms = await formsRef.getDocuments();
      int size = forms.documents.length;
      if (size == 0) {
        // No forms
        data.add(
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 10),
            alignment: Alignment.center,
            child: Text(
              "THERE ARE NO EXISTING FORMS LINKED TO THIS ACCOUNT",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        );
        data.add(Image.asset(
          'assets/noform.png',
          height: 250,
        ));
        return data;
      } else {
        for (int i = 0; i < size; i++) {
          DocumentSnapshot doc = forms.documents[i];
          Widget temp = ListTile(
            trailing: Icon(
              Icons.format_list_bulleted,
              color: _getColor(i),
            ),
            onTap: () {
              Navigator.pushNamed(context, "form_sections", arguments: {
                "formId": doc.documentID,
                "formName": doc.data["form_name"],
                "formType": doc.data["bank_form_name"],
                "uid": uid,
              });
            },
            title: Text(
              doc.data["form_name"] ?? "NO_NAME",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
            ),
          );
          data.add(temp);
        }
      }
    } else {
      print("yes");
    }
    return data;
  }

  @override
  Widget build(context) {
    _getFormsList();
    return FutureBuilder(
      future: _getFormsList(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: Common.getAppBar(context),
            bottomNavigationBar: BottomAppBar(
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                child: FlatButton(
                  color: Colors.blue[800],
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
                        'CREATE NEW FORM',
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, 'new_form');
                  },
                ),
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
                          'assets/recent-form-icon.png',
                          height: 45,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "RECENT FORMS",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                      ],
                    ),
                    Divider(
                      height: 20,
                      indent: 20,
                      endIndent: 20,
                      color: Colors.black,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "*Tap to view the form instance",
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
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
