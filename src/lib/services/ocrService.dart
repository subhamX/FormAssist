import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
/*
  name = 0
  dob = 1
  gender = 2
  aadhaar_card_number = 3
  pan_card_number = 4
*/

class OCRService {
  static Map<int, List<String>> record = {
    0: ["personal_details", "name"],
    1: ["personal_details", "dob"],
    2: ["personal_details", "gender"],
    3: ["personal_details", "aadhaar"],
    4: ["personal_details", "pan_card"],
  };

  static Future<String> updateData(String payload, int id) async {
    Firestore _firestore = Firestore.instance;
    FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      var user = await _auth.currentUser();
      String uid = user.uid;
      if (id == 0) {
        await _firestore
            .collection('users')
            .document(uid)
            .updateData({"name": payload});
      }
      var masterDoc = await _firestore
          .collection('master_fields')
          .document(record[id][0])
          .collection('section')
          .document(record[id][1])
          .get();
      print("hehe ${masterDoc.exists}");
      if (masterDoc.exists) {
        await _firestore
            .collection('users')
            .document(uid)
            .collection('data')
            .document(record[id][0])
            .collection('fields')
            .document(record[id][1])
            .setData({...masterDoc.data, "value": payload});
      } else {
        return 'error';
      }

      return 'success';
    } catch (err) {
      print("Error $err");
      return 'error';
    }
  }
}
