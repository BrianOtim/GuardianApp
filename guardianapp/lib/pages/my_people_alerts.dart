import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guardianapp/helpers/urls.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../helpers/storage.dart';

class MyPeopleAlertScreen extends StatefulWidget {
  const MyPeopleAlertScreen({super.key});
  @override
  State<MyPeopleAlertScreen> createState() => _MyPeopleAlertScreenState();
}

class _MyPeopleAlertScreenState extends State<MyPeopleAlertScreen> {
  List<dynamic> alertList = [];
  //bool _loading = false;

  @override
  void initState() {
    super.initState();
    loadAlert();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 117, 20, 14),
      appBar: AppBar(
        title: Text(
            'My People Alerts ${alertList.isNotEmpty ? "(${alertList.length})" : ""}',
            style: const TextStyle(fontSize: 16.0, color: Colors.black)),
        centerTitle: true,
      ),
      body: alertList.isEmpty
          ? const Center(
              child: Text(
                'No Alert yet!',
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
              itemCount: alertList.length,
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, int index) {
                var alert = alertList[index];
                var message = alert['message'];
                var lat = alert['latitude'];
                var long = alert['longitude'];
                return Container(
                    height: 110.0,
                    margin: const EdgeInsets.only(bottom: 5.0),
                    child: ListTile(
                      tileColor: const Color.fromARGB(255, 250, 249, 249),
                      leading: IconButton(
                        onPressed: () async {
                          final uri = Uri.parse(
                              "https://www.google.com/maps/search/?api=1&query=$lat,$long");
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          } else {
                            throw 'Could not launch $uri';
                          }
                        },
                        icon: const Icon(
                          CupertinoIcons.location_solid,
                          color: Colors.blue,
                          size: 35.0,
                        ),
                      ),
                      title: Text(
                        message,
                      ),
                    ));
              }),
    );
  }

  Future<Map<String, dynamic>> loadAlert() async {
    var apiUrl = Uri.parse(
        '$baseUrl/guardians/${await pickIntegerValue(name: "userId")}/alerts');
    final response = await http.get(
      apiUrl,
      headers: {'Content-Type': 'application/json'},
    );
    // print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('alerts')) {
        setState(() {
          alertList = responseData['alerts'];
        });
      }
      return responseData;
    } else if (response.statusCode == 400) {
      Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('error')) {
      } else {}
    } else {
      return {};
    }

    return {};
  }

  //
}
