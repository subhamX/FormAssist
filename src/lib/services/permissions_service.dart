import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  static Future<bool> listenForPermissionStatus() async {
    PermissionStatus status = await Permission.microphone.status;
    if (status == PermissionStatus.granted) {
      return false;
    } else {
      return true;
    }
  }
}
