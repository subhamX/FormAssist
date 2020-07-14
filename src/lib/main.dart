import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:form_assist/error/errorpage.dart';
import 'package:form_assist/screens/auth/forgot_pass.dart';
import 'package:form_assist/screens/auth/signin.dart';
import 'package:form_assist/screens/auth/signup.dart';
import 'package:form_assist/screens/explore.dart';
import 'package:form_assist/screens/forms/custom_field_list.dart';
import 'package:form_assist/screens/forms/data_screen.dart';
import 'package:form_assist/screens/forms/export_screen.dart';
import 'package:form_assist/screens/forms/form_fields.dart';
import 'package:form_assist/screens/forms/form_sections.dart';
import 'package:form_assist/screens/forms/forms_list.dart';
import 'package:form_assist/screens/forms/listening.dart';
import 'package:form_assist/screens/forms/listening_fetch.dart';
import 'package:form_assist/screens/forms/make_form/show_fields.dart';
import 'package:form_assist/screens/forms/make_form/show_sections.dart';
import 'package:form_assist/screens/forms/new_form.dart';
import 'package:form_assist/screens/forms/profile.dart';
import 'package:form_assist/screens/forms/show_form/show_selected_fields.dart';
import 'package:form_assist/screens/forms/show_form/show_selected_sections.dart';
import 'package:form_assist/screens/home.dart';
import 'package:form_assist/screens/links.dart';
import 'package:form_assist/screens/ocr/aadhar.dart';
import 'package:form_assist/screens/ocr/ocr_home.dart';
import 'package:form_assist/screens/ocr/pan_card.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // @override
  void initState() {
    super.initState();
  }

  Widget _getInitialRoute() {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Home();
        } else {
          return SignIn();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Lato',
        bottomAppBarColor: Theme.of(context).scaffoldBackgroundColor
      ),
      title: 'Form Assist',
      home: _getInitialRoute(),
      routes: {
        'home': (context) => Home(),
        // Auth Screens
        'signin': (context) => SignIn(),
        'signup': (context) => SignUp(),
        'forgot_password': (context) => ForgotPassword(),
        'explore': (context) => Explore(),


        // OCR Screens
        'ocr_home': (context) => OCRHome(),
        'aadhar_ocr': (context) => AadhaarOCR(),
        'pan_ocr': (context) => PanOCR(),
        // User Info Screen
        'profile': (context) => Profile(),
        'data_screen': (context) => DataScreen(),
        "export_screen": (context) => ExportScreen(),
        'links': (context) => Links(),

        // Form Screens
        'new_form': (context) => NewForm(),
        'show_selected_sections': (context) => ShowSelectedSections(),
        'show_selected_fields': (context) => ShowSelectedFields(),
        'form_list': (context) => FormsList(),
        "form_sections": (context) => FormSections(),
        "form_fields": (context) => FormFields(),
        'custom_field_list': (context) => CustomFieldList(),
        'show_sections': (context) => ShowSections(),
        'show_fields': (context) => ShowFields(),

        'error_page': (context) => ErrorPage(),
        // Voice Assistant Screen
        'listening': (context) => Listening(),
        'listening_fetch': (context) => ListeningFetch(),
      },
    );
  }
}
