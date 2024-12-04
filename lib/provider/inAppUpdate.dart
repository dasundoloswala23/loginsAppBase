import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_version_plus/new_version_plus.dart';

void inAppUpdate(BuildContext context) async {
  // Instantiate NewVersion manager object
  final newVersion = NewVersionPlus(
    iOSId: 'com.base.base',
    androidId: 'com.base.base',
    androidPlayStoreCountry: "es_ES",
  );

  // You can let the plugin handle fetching the status and showing a dialog,
  // or you can fetch the status and display your own dialog, or no dialog.

  const simpleBehavior = true;

  if (simpleBehavior) {
    await basicStatusCheck(newVersion, context); // Pass the 'context' variable here
  } else {
    // Handle custom behavior if needed
  }
}
Future<void> basicStatusCheck(NewVersionPlus newVersion, BuildContext context) async {
  final version = await newVersion.getVersionStatus();
  if (version != null) {
    String release = version.releaseNotes ?? "";
    debugPrint("Release Notes: $release");

    // Check if a new version alert is necessary
    bool showAlert = false;
    try {
      showAlert = await newVersion.showAlertIfNecessary(
        context: context,
        launchModeVersion: LaunchModeVersion.external,
      );
    } catch (e) {
      // Handle any potential exceptions here
      print('Error while checking for new version: $e');
    }

    if (showAlert) {
      showDialog(
        context: context,
        barrierDismissible: false, // Allows dismissing the dialog when tapping the background

        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () {
              // Close the dialog when tapped outside of it
              Navigator.pop(context);
            },
            child: Center(
              child: AlertDialog(
                title: const Text("New Version Available"),
                actions: [
                  newVersion.showAlertIfNecessary(
                    context: context,
                    launchModeVersion: LaunchModeVersion.external,
                  ),
                ],
                content: Text("Release Notes: $release"),
              ),
            ),
          );
        },
      );

    }
  }
}

