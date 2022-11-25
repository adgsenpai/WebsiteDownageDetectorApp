import 'package:flutter_background/flutter_background.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_kit_flutter/networking/network.dart';
import 'package:material_kit_flutter/database/db.dart';
import 'package:material_kit_flutter/pushnotification/pushnotification.dart';
import 'dart:async';

class BGM {
  Future<bool> sendWebsiteAlerts() async {
    List<String> urls = await DBServices().getUrls();
    List<String> status = [];
    for (var i = 0; i < urls.length; i++) {
      if (!(await WebsiteChecking().isValidLink(Uri.parse(urls[i])) ==
          'Website is up')) {
        status.add(urls[i]);
      }
    }
    // if status length > 0 the send notification
    if (status.length > 0) {
      AppNotification().sendNotification(
          "Website Downage Detector", "One or more of your websites is down");
      return true;
    }
    print("Completed Sending Notification Job");
    return false;
  }

  bool background_running = true;
  bool success = false;
  bool isSent = false;
  Future<void> runAppbackground() async {
    try {
      //BACKGROUND RUNNER
      const androidConfig = FlutterBackgroundAndroidConfig(
        notificationTitle: "Alerts",
        notificationText:
            "Website Downage Detector is running in the background",
        notificationImportance: AndroidNotificationImportance.Default,
        notificationIcon: AndroidResource(
            name: 'background_icon',
            defType: 'drawable'), // Default is ic_launcher from folder mipmap
      );
      background_running =
          await FlutterBackground.initialize(androidConfig: androidConfig);
      if (background_running) {
        if (!FlutterBackground.isBackgroundExecutionEnabled) {
          success = await FlutterBackground.enableBackgroundExecution();
          print("Running");
          //
          while (background_running) {
            isSent = await sendWebsiteAlerts();
            if (isSent) {
              print("Delayed for 1 hour");
              await Future.delayed(Duration(hours: 1));
            }
          }
        }
      }
    } catch (e) {
      print("Background Process Error:" + e.toString());
    }
    //END BACKGROUND RUNNER
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BGM().runAppbackground();
}
