import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  static Future<bool> listenForPermissionStatus() async {
    final Future<PermissionStatus> statusFuture =
        PermissionHandler().checkPermissionStatus(PermissionGroup.microphone);

    PermissionStatus status = await statusFuture;
    if (status == PermissionStatus.denied) {
      return true;
    } else {
      return false;
    }
  }
}
