import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:flutter/material.dart';
import 'package:form_assist/common/common.dart';
// import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:flushbar/flushbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:form_assist/error/errorpage.dart';
import 'package:form_assist/screens/loaders/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:form_assist/screens/loaders/loadingbox.dart';

/// Implements All Links Screen
class Links extends StatefulWidget {
  @override
  _LinksState createState() => _LinksState();
}

class _LinksState extends State<Links> {
  final _firestore = Firestore.instance;

  // Fetching Links from Firestore
  Future<List<Widget>> getLinks() async {
    var user = await FirebaseAuth.instance.currentUser();
    CollectionReference docRef = _firestore
        .collection('/links')
        .document(user.uid)
        .collection('sharedlinks');
    QuerySnapshot doc = await docRef.getDocuments();
    var links = doc.documents;
    // links.
    if (links.length == 0) {
      return [
        SizedBox(
          height: 10,
        ),
        Text(
          "There are No Shared Form Links! ☹",
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(
          height: 10,
        ),
        Text("You can always export your existing form"),
        SizedBox(
          height: 25,
        ),
        Container(
          // width: MediaQuery.of(context).size.width * 0.4,
          child: RaisedButton(
            color: Colors.blue[800],
            onPressed: () {
              Navigator.pushReplacementNamed(context, 'form_list');
            },
            child: Text(
              'RECENT FORMS',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        )
      ];
    }
    return [
      SizedBox(
        height: 10,
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            "*Tap To Copy Link To Clipboard\n*Long Press To Toggle Form Status",
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      ...links
          .map(
            (link) => ListTile(
              onLongPress: () async {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return LoadingBox();
                    });
                await _firestore
                    .collection('links')
                    .document(user.uid)
                    .collection('sharedlinks')
                    .document(link.documentID)
                    .updateData({"isActive": !link["isActive"]});

                Navigator.pop(context);
                Navigator.popAndPushNamed(context, 'links');
              },
              onTap: () async {
                // On Click Copying Link to ClipBoard and Showing FlushBar
                await ClipboardManager.copyToClipBoard(
                    Common.appUrl + link["slug"]);
                Flushbar(
                  message: "Copied to Clipboard",
                  duration: Duration(seconds: 2),
                ).show(context);
              },
              leading: link["isActive"]
                  ? Icon(
                      Icons.link,
                      color: Colors.blue[700],
                    )
                  : Icon(
                      Icons.link_off,
                      color: Colors.blue[700],
                    ),
              title: Text(
                link["name"] ?? "NO_NAME",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (link["isActive"]) ...[
                    Row(
                      children: <Widget>[
                        Text(
                          "Status - ",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                        Text(
                          "Active",
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                  if (!link["isActive"]) ...[
                    Row(
                      children: <Widget>[
                        Text(
                          "Status - ",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                        Text(
                          "Inactive",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                  Text(
                    Common.appUrl + link["slug"] ?? "NO_LINK",
                    style: TextStyle(color: Colors.blue),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          )
          .toList(),
    ];
  }

  @override
  void initState() {
    super.initState();
    getLinks();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getLinks(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: Common.getAppBar(context),
              body: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            'assets/shared-link.png',
                            height: 45,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            "SHARED LINKS",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                        ],
                      ),
                      Divider(
                        height: 15,
                        indent: 20,
                        endIndent: 20,
                        color: Colors.black,
                      ),
                      // Rendering the Main UI Section of Links
                      ...snapshot.data,
                      Divider(
                        height: 30,
                      ),
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
        });
  }
}
