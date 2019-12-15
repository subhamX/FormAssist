import 'package:flutter/material.dart';
import 'package:form_assist/common/common.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:form_assist/error/errorpage.dart';
import 'package:form_assist/screens/loaders/loading.dart';

class ShowSections extends StatefulWidget {
  @override
  _ShowSectionsState createState() => _ShowSectionsState();
}

class _ShowSectionsState extends State<ShowSections> {
  final _firestore = Firestore.instance;
  var sectionsList;
  String formId, formName, uid;
  // Map<int, Color> visited = new Map();

  Future<List<Widget>> getSections() async {
    List<Widget> data = [];
    try {
      var collectionRef = _firestore.collection('master_fields');
      QuerySnapshot sections = await collectionRef.getDocuments();

      // forEach is not working because of Async Nature inside.
      for (int i = 0; i < sections.documents.length; i++) {
        var section = sections.documents[i];
        // List<Widget> fields = await getFields(entryRef);
        // visited[i] = Colors.blue;
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
                await Navigator.pushNamed(context, 'show_fields', arguments: {
                  "section_id": section.documentID,
                  "section_name": section["section_name"],
                  "formId": formId,
                  "formName": formName,
                  "uid": uid,
                });
                // setState(() {
                //   visited[i] = Colors.grey;
                // });
                // print("Setting visited $i as true");
              },
            ),
          ),
        );
      }
      data.add(
        ListTile(
          title: Text(
            'OTHERS',
            style: TextStyle(
              color: Colors.blue,
            ),
          ),
          onTap: () async {
            await Navigator.pushNamed(context, 'custom_field_list', arguments: {
              "formId": formId,
              "uid": uid,
              "formName": formName,
            });
          },
        ),
      );
      return data;
    } catch (err) {
      print("Error in getting sections! $err");
      return [
        Text('Error in getting sections!'),
      ];
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

  void _submitForm() {
    Navigator.pushReplacementNamed(context, 'show_selected_sections',
        arguments: {
          'formId': formId,
          'uid': uid,
        });
  }

  @override
  Widget build(BuildContext context) {
    try {
      final args = Map.from(ModalRoute.of(context).settings.arguments);
      formId = args["formId"];
      uid = args["uid"];
      formName = args["formName"];
    } catch (error) {
      print(error);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ErrorPage(),
        ),
      );
    }
    return FutureBuilder(
      future: getSections(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: Common.getAppBar(context),
            bottomNavigationBar: Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: FlatButton(
                color: Colors.blue[800],
                onPressed: () {
                  _submitForm();
                  // Navigator.pushReplacementNamed(context, "home");
                },
                child: Text(
                  'UPDATE CHANGES',
                  style: TextStyle(
                    color: Colors.white,
                  ),
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
                  children: [
                    Text(
                      "FORM BUILDER",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "NOTE - ",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                            // fontStyle: FontStyle.italic,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "*Build Your Form By Selecting Fields In Each Section. \n*Custom Fields can be added in OTHERS section. \n*Fields will be autofilled with your previous data.",
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
