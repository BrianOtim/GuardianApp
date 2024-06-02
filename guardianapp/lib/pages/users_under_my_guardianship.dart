import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:guardianapp/helpers/urls.dart';
import 'package:http/http.dart' as http;
import '../helpers/storage.dart';

class UsersUnderMyGuardianshipScreen extends StatefulWidget {
  const UsersUnderMyGuardianshipScreen({super.key});

  @override
  State<UsersUnderMyGuardianshipScreen> createState() =>
      UsersUnderMyGuardianshipScreenState();
}

class UsersUnderMyGuardianshipScreenState
    extends State<UsersUnderMyGuardianshipScreen> {
  List<dynamic> usersUnderMyGuardianshipList = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    loadUsersUnderMyGuardianship();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 117, 20, 14),
      appBar: AppBar(
        // leading: InkWell(
        //     onTap: () {
        //       loadUsersUnderMyGuardianship();
        //     },
        //     child: const Icon(Icons.refresh)),
        title: const Text('People I Watchover',
            style: TextStyle(fontSize: 16.0, color: Colors.black)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
                onTap: () {
                  loadUsersUnderMyGuardianship();
                },
                child: const Icon(Icons.refresh)),
          )
        ],
      ),
      body: usersUnderMyGuardianshipList.isEmpty
          ? const Center(
              child: Text(
                'You do not watch over anyone!',
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
              itemCount: usersUnderMyGuardianshipList.length,
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, int index) {
                var user = usersUnderMyGuardianshipList[index];
                return Container(
                    height: 100.0,
                    margin: const EdgeInsets.only(bottom: 5.0),
                    child: ListTile(
                      tileColor: const Color.fromARGB(255, 250, 249, 249),
                      title: Text(
                        user['username'],
                      ),
                      subtitle: Text(
                        user['email'],
                      ),
                      trailing: InkWell(
                        onTap: _loading
                            ? null
                            : () async {
                                dissolveGuardianship(personId: user['id']);
                              },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("+ Remove Person"),
                        ),
                      ),
                    ));
              }),
    );
  }

  Future<Map<String, dynamic>> loadUsersUnderMyGuardianship() async {
    var apiUrl = Uri.parse(
        '$baseUrl/guardians/${await pickIntegerValue(name: "userId")}/people');
    final response = await http.get(
      apiUrl,
      headers: {'Content-Type': 'application/json'},
    );
    //  print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      // print('Data fetched 🔥');
      if (responseData.containsKey('people')) {
        setState(() {
          usersUnderMyGuardianshipList = responseData['people'];
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
  Future<void> dissolveGuardianship({required int personId}) async {
    var apiUrl = Uri.parse(
        '$baseUrl/guardians/${await pickIntegerValue(name: "userId")}/$personId');
    final response = await http.delete(
      apiUrl,
      headers: {'Content-Type': 'application/json'},
    );
    setState(() {
      _loading = false;
    });
    // print(response.body);

    if (response.statusCode == 200) {
      loadUsersUnderMyGuardianship();
      setState(() {});
    } else if (response.statusCode == 400) {
    } else {}
  }

  //
}
