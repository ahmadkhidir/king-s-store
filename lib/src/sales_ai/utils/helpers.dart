import 'package:permission_handler/permission_handler.dart';

requestAllNeededPermissions() async {
  await [
    Permission.microphone,
    Permission.bluetooth,
    Permission.bluetoothConnect,
  ].request();
  if (await Permission.speech.isPermanentlyDenied) {
    // The user opted to never again see the permission request dialog for this
    // app. The only way to change the permission's status now is to let the
    // user manually enables it in the system settings.
    openAppSettings();
  }
}
