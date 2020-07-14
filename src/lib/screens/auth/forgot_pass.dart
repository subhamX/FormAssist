import 'package:flutter/material.dart';
import 'package:form_assist/services/auth_service.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  String _email;

  // Validation Logic For Email
  bool validateEmail(email) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    if (regex.hasMatch(email)) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> submitForm() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      dynamic data = {'email': _email};
      await AuthService.forgotPassword(data, context);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            padding: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Form Assist',
                  style: TextStyle(
                    fontFamily: 'BBPU',
                    fontSize: 42.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                        ),
                        onSaved: (input) {
                          _email = input;
                        },
                        validator: (email) {
                          if (validateEmail(email)) {
                            return null;
                          } else {
                            return 'Enter a valid Email';
                          }
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * 0.30,
                            child: FlatButton(
                              child: Text('GO BACK'),
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, 'signin');
                              },
                            ),
                          ),
                          Expanded(
                            child: FlatButton(
                              color: Colors.black,
                              child: Text(
                                'RESET PASSWORD',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: submitForm,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
