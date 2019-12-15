import 'package:flutter/material.dart';
// import 'package:form_assist/screens/home.dart';

// --> uncomment Add the below code to call ErrorPage window <--
// _error (BuildContext context){
//   showDialog(
//     context: context,
//     builder: (BuildContext context){
//       return ErrorPage();
//     }
//     );
// }

class ErrorPage extends StatelessWidget {
  final errorMsg;
  ErrorPage({this.errorMsg = 'Something Went Wrong'});
  @override
  Widget build(BuildContext context) {
    // Map args = Map.from(ModalRoute.of(context).settings.arguments);
    // errorMsg = args["msg"];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.9,
              child: Dialog(
                elevation: 0,
                //backgroundColor: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.only(top: 0.0, right: 8.0, left: 8.0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 10.0),
                      Row(
                        children: <Widget>[
                          //Image.asset('assets/images/404_cat.jpg'),
                          Container(
                            child: new Image.asset(
                              'assets/images/404_cat.jpg',
                              height: 250.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "404",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.blueGrey[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 70.0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            errorMsg ?? 'Something went wrong! ☹',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.blueGrey[600],
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "FormAssist is unable to assist",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.blueGrey[600],
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 35.0),
                      RaisedButton(
                        color: Colors.blue,
                        colorBrightness: Brightness.dark,
                        child: Text("Go Back"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
