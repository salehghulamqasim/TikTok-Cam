import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> requestCameraAndMicPermissions() async {
    final statuses = await [Permission.camera, Permission.microphone].request();

    final cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
    final micGranted = statuses[Permission.microphone]?.isGranted ?? false;

    return cameraGranted && micGranted;
  }
}

// permissions of Camera and Microphone . chceks if granted or not
