import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:permission_handler/permission_handler.dart';

enum PermissionStatus {
  granted,
  denied,
  permanentlyDenied,
}

class Helpers {
  static void showToast(String msg) {
    if (msg.isEmpty) {
      return;
    }

    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static String convert(int seconds) {
    int hours = (seconds / 3600).truncate();
    seconds = (seconds % 3600).truncate();
    int minutes = (seconds / 60).truncate();

    String hoursStr = (hours).toString().padLeft(2, '0');
    String minutesStr = (minutes).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return "$hoursStr:$minutesStr:$secondsStr";
  }

  static Future<Map<String, PermissionStatus>> requestPermissions(
      BuildContext context) async {
    Map<String, PermissionStatus> statuses = {
      'microphone': PermissionStatus.denied,
      'camera': PermissionStatus.denied,
    };

    var microphoneResult = await Permission.microphone.request();
    var cameraResult = await Permission.camera.request();

    if (microphoneResult.isGranted) {
      statuses['microphone'] = PermissionStatus.granted;
    } else if (microphoneResult.isPermanentlyDenied) {
      statuses['microphone'] = PermissionStatus.permanentlyDenied;

    }

    if (cameraResult.isGranted) {
      statuses['camera'] = PermissionStatus.granted;
    } else if (cameraResult.isPermanentlyDenied) {
      statuses['camera'] = PermissionStatus.permanentlyDenied;

    }

    return statuses;
  }

  static void showPermissionDialog(BuildContext context, String permission) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return PopScope(
     canPop:  false,
          child: AlertDialog(
            title: Text("$permission Permission Required"),
            content: Text(
                "$permission permission is required for audio and video calls. Please enable it in the settings."),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Settings"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await openAppSettings();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
