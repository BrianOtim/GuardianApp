import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:guardianapp/helpers/notification.dart';
import 'package:guardianapp/helpers/attention.dart';
import 'package:guardianapp/helpers/sms.dart';
import 'package:guardianapp/helpers/storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record_mp3/record_mp3.dart';

void sendData(List<Object> data) async {
  String user = await getUsername();
  // Define the server's IP address and port
  //const String serverIp = '192.168.43.1';
  final String serverIp = await getIP();
  const int serverPort = 6000;

  String lat = data[0].toString();
  String long = data[1].toString();
  String place = data[2].toString();

  String location = "$lat/$long/$place";

  List<String> contactList = ["0759244764"];
  String smessage = "$user needs help!!! check alerts";
  log("IPv4: $serverIp");

  try {
    final server = await ServerSocket.bind(serverIp, serverPort);
    {
      server.listen((socket) {
        socket.listen((eventBytes) {
          final result = utf8.decode(eventBytes);
          if (result == "L") {
            socket.add(utf8.encode(location));
            sendSms(contactList, smessage);
          } else if (result == "T") {
            LocalNotificationService().showNotificationAndroid(
                "ALERT RECEIVED", "Help needed!!! check alerts.");
            ring();
            vibrate();
          } else if (result.startsWith("2024")) {
            backgroundRecord(result);
          }
        });
      });
    }
  } catch (e) {
    throw Exception("Sending location error!");
  }
}

Future<bool> checkPermission() async {
  if (!await Permission.microphone.isGranted) {
    PermissionStatus status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      return false;
    }
  }
  return true;
}

Future<String> getFilePath(String name) async {
  bool hasPermission = await checkPermission();
  String filePath = "";

  if (hasPermission) {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    var dir = p.join(appDocDir.path, "MyRecordings");
    // ignore: unused_local_variable
    var recordingDir = Directory(dir).create(recursive: true);
    if (name.isEmpty) {
      filePath = p.join(dir, "test.mp3");
    } else {
      filePath = p.join(dir, "$name.mp3");
    }
  }
  return filePath;
}

String convertName(String name) {
  String newName =
      name.replaceAll("-", "_").replaceAll(" ", "_").replaceAll(":", "_");
  return newName;
}

void backgroundRecord(String rawName) async {
  String fileName = convertName(rawName);
  String audioPath = await getFilePath(fileName);

  RecordMp3.instance.start(audioPath, (type) {});
  log("Started background recording: $audioPath");

  Future.delayed(const Duration(seconds: 10), () async {
    RecordMp3.instance.stop();
    log("Stopped recording.");
  });
}

getIP() async {
  for (var interface in await NetworkInterface.list()) {
    log('== Interface: ${interface.name} ==');
    for (var addr in interface.addresses) {
      var ip = addr.address;
      if (ip.startsWith("192.")) {
        return ip;
      }
    }
  }
}
