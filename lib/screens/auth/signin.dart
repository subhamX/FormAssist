import 'package:flutter/material.dart';
import 'package:form_assist/services/auth_service.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  String _email, _password;

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
      dynamic data = {'email': _email, 'password': _password};
      await AuthService.signIn(data, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Form Assist',
                  style: TextStyle(
                    fontFamily: 'BBPU',
                    fontSize: 42.0,
                    fontWeight: FontWeight.w400,
                  ),
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
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                        ),
                        onSaved: (input) {
                          _password = input;
                        },
                        obscureText: true,
                        validator: (input) {
                          if (input.length >= 6) {
                            return null;
                          } else {
                            return 'Min. 6 char needed';
                          }
                        },
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: FlatButton(
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 11),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, 'forgot_password');
                          },
                        ),
                      ),
                      FlatButton(
                        child: Text('SIGN IN'),
                        onPressed: submitForm,
                      ),
                      FlatButton(
                        child: FittedBox(
                          child: Row(
                            children: <Widget>[
                              Image.asset(
                                'assets/google.png',
                                width: 35,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text('SIGN IN WITH GOOGLE')
                            ],
                          ),
                        ),
                        onPressed: () async{
                          await AuthService.googleSignIn(context);
                        },
                      ),
                      FlatButton(
                        child: Text('GO TO SIGN UP'),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, 'signup');
                        },
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
