import 'package:flutter/material.dart';
import 'package:form_assist/services/auth_service.dart';
import 'package:form_assist/config.dart';

class Common {
  static String sbiFormId = 'sbi_home_loan';
  static String unionBankFormId = 'union_bank_home_loan';
  static String hdfcBankFormId = 'hdfc_professional_loan';
  static String indianBankFormId = 'indian_bank_home_loan';
  static String appRootUrl = Config.serverBaseUrl;
  static String appUrl = Config.formViewBaseUrl;

  static List<Map<dynamic, dynamic>> forms = [
    {"name": "SBI HOME LOAN", "id": 0},
    {"name": "HDFC PROFESSIONAL LOAN", "id": 1},
    {"name": "UNION BANK HOME LOAN", "id": 2},
    {"name": "INDIAN BANK HOME LOAN", "id": 3},
  ];
  static List<Color> colors = [
    Colors.amber[600],
    Colors.blue[500],
    Colors.green[800],
    Colors.purple[700],
    Colors.blue[100],
  ];
  static AppBar getAppBar(context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        'Form Assist',
        style: TextStyle(
          fontFamily: 'BBPU',
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
      iconTheme: IconThemeData(
        color: Colors.black, //change your color here
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('SIGN OUT'),
          onPressed: () {
            AuthService.signOut(context);
          },
        ),
      ],
    );
  }
}
