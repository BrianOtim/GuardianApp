import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:guardianapp/helpers/urls.dart';
import 'package:http/http.dart' as http;
import '../helpers/storage.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});
  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  List<dynamic> alertList = [];
  bool _loading = false;

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
            'My Alerts ${alertList.isNotEmpty ? "(${alertList.length})" : ""}',
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
                return Container(
                    height: 100.0,
                    margin: const EdgeInsets.only(bottom: 5.0),
                    child: ListTile(
                      tileColor: const Color.fromARGB(255, 250, 249, 249),
                      title: Text(
                        alert['message'],
                      ),
                      trailing: InkWell(
                        onTap: _loading
                            ? null
                            : () async {
                                deleteAlert(alertId: alert['id']);
                              },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("- Remove"),
                        ),
                      ),
                    ));
              }),
    );
  }

  Future<Map<String, dynamic>> loadAlert() async {
    var apiUrl =
        Uri.parse('$baseUrl/alerts/${await pickIntegerValue(name: "userId")}');
    final response = await http.get(
      apiUrl,
      headers: {'Content-Type': 'application/json'},
    );
    // print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      // print('Data fetched 🔥');
      if (responseData.containsKey('alerts')) {
        setState(() {
          alertList = responseData['alerts'];
        });
      }
      return responseData;
    } else if (response.statusCode == 400) {
      Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('error')) {
        // setState(() {
        //   _errorMessage = responseData['error'];
        // });
      } else {
        // setState(() {
        //   _errorMessage = 'Unknown error occurred';
        // });
      }
    } else {
      return {};
    }

    return {};
  }

  //
  Future<void> deleteAlert({required int alertId}) async {
    var apiUrl = Uri.parse('$baseUrl/alerts/$alertId');
    final response = await http.delete(
      apiUrl,
      headers: {'Content-Type': 'application/json'},
    );
    setState(() {
      _loading = false;
    });
    //  print(response.body);

    if (response.statusCode == 200) {
      loadAlert();
      setState(() {});
    } else if (response.statusCode == 400) {
    } else {}
  }

  //
}
