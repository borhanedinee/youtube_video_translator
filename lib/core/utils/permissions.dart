import 'package:permission_handler/permission_handler.dart';

Future<bool> requestStoragePermission() async {
  final status = await Permission.manageExternalStorage.request();
  if (status.isGranted) {
    print("Storage permission is granted");
    return true;
  } else {
    print("Storage permission is not granted");
    return false;
  }
}
