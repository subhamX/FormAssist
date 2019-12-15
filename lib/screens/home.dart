import 'package:flutter/material.dart';
import 'package:form_assist/common/common.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  PermissionStatus _permissionStatus = PermissionStatus.granted;
  PermissionGroup _permissionGroup = PermissionGroup.microphone;

  Future<void> requestPermission(PermissionGroup permission) async {
    final List<PermissionGroup> permissions = <PermissionGroup>[permission];
    final Map<PermissionGroup, PermissionStatus> permissionRequestResult =
        await PermissionHandler().requestPermissions(permissions);

    setState(() {
      _permissionStatus = permissionRequestResult[permission];
    });
  }

  Future<void> _listenForPermissionStatus() async {
    final Future<PermissionStatus> statusFuture =
        PermissionHandler().checkPermissionStatus(_permissionGroup);

    var status = await statusFuture;
    setState(() {
      _permissionStatus = status;
    });
  }
  double iconSize = 30;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      iconSize = MediaQuery.of(context).size.height*0.05;
    });
    _listenForPermissionStatus().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (_permissionStatus == PermissionStatus.denied) {
          await requestPermission(PermissionGroup.microphone);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Common.getAppBar(context),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                child: Card(
                  elevation: 0,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: Tab(icon: Image.asset("assets/dashboard.png")),
                        title: Text(
                          "DASHBOARD",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        subtitle: Text('Welcome, to Form Assist!'),
                      ),
                      ButtonTheme.bar(
                        // make buttons use the appropriate styles for cards
                        child: ButtonBar(
                          children: <Widget>[
                            FlatButton(
                              child: Text('EXPLORE'),
                              onPressed: () {
                                Navigator.pushNamed(context, 'explore');
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 10,
                indent: 5,
                endIndent: 5,
                color: Colors.black,
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Tab(icon: Image.asset("assets/menu.png", height: 55,)),
                  Text(
                    "MENU",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25),
                  ),
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Container(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: FlatButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "new_form");
                            },
                            child: Container(
                              width: 160,
                              child: Column(
                                children: <Widget>[
                                  Icon(Icons.format_align_justify, size: iconSize,),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('New Form')
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: FlatButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "form_list");
                            },
                            child: Container(
                              width: 160,
                              child: Column(
                                children: <Widget>[
                                  Icon(Icons.list, size: iconSize,),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Form List')
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 28,
                    ),
                    Row(
                      // scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        Expanded(
                          child: FlatButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "links");
                            },
                            child: Container(
                              width: 160,
                              child: Column(
                                children: <Widget>[
                                  Icon(Icons.link, size: iconSize,),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Shared Links')
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: FlatButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "ocr_home");
                            },
                            child: Container(
                              width: 160,
                              child: Column(
                                children: <Widget>[
                                  Icon(Icons.linked_camera, size: iconSize,),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('OCR')
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 28,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: FlatButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "profile");
                            },
                            child: Container(
                              width: 160,
                              child: Column(
                                children: <Widget>[
                                  Icon(Icons.person, size: iconSize,),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('My Profile')
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: FlatButton(
                            onPressed: () {
                              Navigator.pushNamed(context, 'data_screen');
                            },
                            child: Container(
                              width: 160,
                              child: Column(
                                children: <Widget>[
                                  Icon(Icons.data_usage, size: iconSize,),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('My Data'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
