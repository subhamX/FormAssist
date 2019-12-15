import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_assist/common/common.dart';
import 'package:form_assist/screens/loaders/loading.dart';

class DataScreen extends StatefulWidget {
  @override
  _DataScreenState createState() => _DataScreenState();
}

// Screen Shows Cumulative Data of User
class _DataScreenState extends State<DataScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore _firestore = Firestore.instance;

  Future<List<Widget>> getUserData() async {
    FirebaseUser user = await _auth.currentUser();
    List<Widget> data = [];
    String uid = user.uid;
    DocumentSnapshot userDoc =
        await _firestore.collection('users').document(uid).get();
    String name = userDoc["name"];
    String email = userDoc["email"];

    data.add(
      Card(
        color: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Row(
                children: <Widget>[
                  Icon(
                    Icons.data_usage,
                    color: Colors.blue[700],
                    size: 40,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "MY DATA",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ],
              ),
            ),
            
            ListTile(
              leading: Icon(
                Icons.person,
                color: Colors.amber[800],
              ),
              title: Text(
                "NAME",
              ),
              subtitle: Text(name ?? 'NO_NAME'),
            ),
            ListTile(
              leading: Icon(Icons.email, color: Colors.green[800]),
              title: Text(
                "EMAIL",
              ),
              subtitle: Text(email ?? 'NO_EMAIL'),
            ),
          ],
        ),
      ),
    );
    CollectionReference dataRef =
        _firestore.collection('users').document(uid).collection('data');
    QuerySnapshot dataSections = await dataRef.getDocuments();
    int size = dataSections.documents.length;

    int addedCount = 0;
    for (int i = 0; i < size; i++) {
      Query fieldsRef = dataRef
          .document(dataSections.documents[i].documentID)
          .collection('fields')
          .orderBy('degree');
      QuerySnapshot fields = await fieldsRef.getDocuments();
      int fieldsLen = fields.documents.length;
      // print("${dataSections.documents[i]["section_name"]} and $fieldsLen");
      if (fieldsLen == 0) {
        continue;
      }
      if (fieldsLen > 0) {
        data.add(
          Text(
            dataSections.documents[i]["section_name"] ?? 'SECTION',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        );
        data.add(
          SizedBox(
            height: 10,
          ),
        );
      }
      for (int j = 0; j < fieldsLen; j++) {
        String value = fields.documents[j].data["value"];
        String tag = fields.documents[j].data["tag"];
        if (value.toString().isEmpty) {
          continue;
        }
        data.add(ListTile(
          title: Text(tag ?? 'NO_TAG'),
          subtitle: Text(value ?? 'NO_VAL'),
        ));
        addedCount += fieldsLen;
      }
      if (fieldsLen > 0) {
        data.add(Divider(
          height: 10,
          color: Colors.black87,
        ));
        data.add(
          SizedBox(
            height: 10,
          ),
        );
      }
    }
    if (addedCount == 0) {
      data.add(
        Container(
            padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
            alignment: Alignment.center,
            child: Icon(Icons.error)),
      );
      data.add(
        Container(
          padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
          alignment: Alignment.center,
          child: Text(
            'There is No Saved Data.',
            style: TextStyle(fontSize: 14),
          ),
        ),
      );
      data.add(
        Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text(
            'You can add data using OCR or by creating a form',
            style: TextStyle(fontSize: 12),
          ),
        ),
      );
      data.add(
        SizedBox(
          height: 10,
        ),
      );
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: Common.getAppBar(context),
            body: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: <Widget>[
                    
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
