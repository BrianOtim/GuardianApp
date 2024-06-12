import 'dart:developer';

import 'package:permission_handler/permission_handler.dart';
import 'package:background_sms/background_sms.dart';

Future<void> sendSms(List<String> contacts, String smsMessage) async {
  bool? customSim = await BackgroundSms.isSupportCustomSim;
  await Permission.sms.onDeniedCallback(() {
    // Your code
  }).onGrantedCallback(() async {
    if (customSim!) {
      log("Support Custom Sim Slot");
    }
    for (int i = 0; i < contacts.length; i++) {
      SmsStatus result = await BackgroundSms.sendMessage(
          phoneNumber: contacts[i], message: smsMessage);
      if (result == SmsStatus.sent) {
        log("Sent: $smsMessage");
      } else {
        var val = SmsStatus.values.toString();
        log("Failed: $val");
      }
    }
  }).request();
}
