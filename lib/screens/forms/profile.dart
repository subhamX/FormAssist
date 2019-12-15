import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:form_assist/common/common.dart';
import 'package:form_assist/error/errorpage.dart';
import 'package:form_assist/screens/loaders/loading.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore _firestore = Firestore.instance;

  Future<List<Widget>> getUserProfile() async {
    FirebaseUser user = await _auth.currentUser();
    List<Widget> data = [];
    String uid = user.uid;
    DocumentSnapshot userDoc =
        await _firestore.collection('users').document(uid).get();
    String name = userDoc["name"];
    String email = userDoc["email"];
    String formNumber;
    var t1 = await _firestore
        .collection('forms')
        .document(uid)
        .collection('userform')
        .getDocuments();
    formNumber = t1.documents.length.toString();

    data.add(Card(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/profile-icon.png',
                height: 55,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                "PROFILE",
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
          ListTile(
            leading: Icon(Icons.person, color: Colors.purple[800]),
            title: Text(
              "NAME",
            ),
            subtitle: Text(name ?? 'NO_NAME'),
          ),
          ListTile(
            leading: Icon(Icons.email, color: Colors.amber[800]),
            title: Text(
              "EMAIL",
            ),
            subtitle: Text(email ?? 'NO_EMAIL'),
          ),
          ListTile(
            leading: Icon(
              Icons.link,
              color: Colors.blue[800],
            ),
            title: Text(
              "NUMBER OF ACTIVE FORMS",
            ),
            subtitle: Text(formNumber ?? 'NO_EMAIL'),
          ),
        ],
      ),
    ));
    data.add(
      Container(
        width: MediaQuery.of(context).size.width * 0.5,
        child: RaisedButton(
          child: Text(
            'MY DATA',
            style: TextStyle(color: Colors.white),
          ),
          color: Colors.blue[800],
          onPressed: () {
            Navigator.pushReplacementNamed(context, 'data_screen');
          },
        ),
      ),
    );
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: Common.getAppBar(context),
            body: Container(
              child: Column(
                children: <Widget>[...snapshot.data],
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
