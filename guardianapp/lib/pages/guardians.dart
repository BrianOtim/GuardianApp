import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:guardianapp/helpers/routes.dart';
import 'package:guardianapp/helpers/urls.dart';
import 'package:http/http.dart' as http;
import '../helpers/storage.dart';

class GuardiansScreen extends StatefulWidget {
  const GuardiansScreen({super.key});
  @override
  State<GuardiansScreen> createState() => _GuardiansScreenState();
}

class _GuardiansScreenState extends State<GuardiansScreen> {
  List<dynamic> guardianList = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    loadGuardians();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 117, 20, 14),
      appBar: AppBar(
        // leading: InkWell(
        //     onTap: () {
        //       loadGuardians();
        //     },
        //     child: const Icon(Icons.refresh)),
        title: const Text('Guardians',
            style: TextStyle(fontSize: 16.0, color: Colors.black)),
        centerTitle: true,
        actions: [
          InkWell(
              onTap: () {
                loadGuardians();
              },
              child: const Icon(Icons.refresh)),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, userSearchRoute);
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("+ Add"),
            ),
          )
        ],
      ),
      body: guardianList.isEmpty
          ? const Center(
              child: Text(
                'No guardians yet!',
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
              itemCount: guardianList.length,
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, int index) {
                var user = guardianList[index];
                return Container(
                    height: 100.0,
                    margin: const EdgeInsets.only(bottom: 5.0),
                    child: ListTile(
                      tileColor: const Color.fromARGB(255, 250, 249, 249),
                      title: Text(
                        user['guardian_username'],
                      ),
                      subtitle: Text(
                        user['guardian_email'],
                      ),
                      trailing: InkWell(
                        onTap: _loading
                            ? null
                            : () async {
                                await removeGuardian(
                                    guardianId: user['guardianId']);
                              },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("+ Remove Guardian"),
                        ),
                      ),
                    ));
              }),
    );
  }

  Future<Map<String, dynamic>> loadGuardians() async {
    var apiUrl = Uri.parse(
        '$baseUrl/guardians/${await pickIntegerValue(name: "userId")}');
    final response = await http.get(
      apiUrl,
      headers: {'Content-Type': 'application/json'},
    );
    // print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      // print('Data fetched 🔥');
      if (responseData.containsKey('guardians')) {
        setState(() {
          guardianList = responseData['guardians'];
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
  Future<void> removeGuardian({required int guardianId}) async {
    var apiUrl = Uri.parse(
        '$baseUrl/guardians/${await pickIntegerValue(name: "userId")}/$guardianId');
    final response = await http.delete(
      apiUrl,
      headers: {'Content-Type': 'application/json'},
    );
    setState(() {
      _loading = false;
    });
    //  print(response.body);

    if (response.statusCode == 200) {
      loadGuardians();
      setState(() {});
    } else if (response.statusCode == 400) {
    } else {}
  }

  //
}
