import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:guardianapp/helpers/urls.dart';
import 'package:guardianapp/pages/guardians.dart';
import 'package:http/http.dart' as http;

import '../helpers/storage.dart';
import '../style.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => UserSearchScreenState();
}

class UserSearchScreenState extends State<UserSearchScreen> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> userList = [];
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 117, 20, 14),
      appBar: AppBar(
        title: TextField(
            controller: searchController,
            decoration: customInputDecoration("Search users")),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: _loading
                ? null
                : () async {
                    setState(() {
                      _loading = true;
                    });
                    _loadUsers();
                  },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.search_rounded),
                  Text("Search"),
                ],
              ),
            ),
          )
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: userList.isEmpty
              ? const Center(
                  child: Text(
                    'No results to display!',
                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                )
              : ListView.builder(
                  itemCount: userList.length,
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, int index) {
                    var user = userList[index];
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
                                    await addGuardian(guardianId: user['id']);
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) => const UserSearchScreen()));
                                  },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("+ Make Guardian"),
                            ),
                          ),
                        ));
                  })),
    );
  }

  Future<Map<String, dynamic>> _loadUsers() async {
    var apiUrl = Uri.parse('$baseUrl/users?q=${searchController.text.trim()}');
    final response = await http.get(
      apiUrl,
      headers: {'Content-Type': 'application/json'},
    );

    //print(response.body);
    setState(() {
      _loading = false;
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      // print('Data fetched 🔥');
      if (responseData.containsKey('users')) {
        setState(() {
          userList = responseData['users'];
        });
      }
      return responseData;
    } else {
      return {};
    }
  }

  //
  //
  Future<void> addGuardian({required int guardianId}) async {
    var apiUrl = Uri.parse('$baseUrl/guardians');
    final response = await http.post(
      apiUrl,
      body: json.encode({
        "userId": await pickIntegerValue(name: "userId"),
        "guardianId": guardianId
      }),
      headers: {'Content-Type': 'application/json'},
    );
    setState(() {
      _loading = false;
    });
    print(response.body);

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('token')) {
        // Login successful, navigate to next screen or perform action
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GuardiansScreen()),
        );
      } else {}
    } else if (response.statusCode == 400) {
      Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('error')) {
      } else {}
    } else {}
  }

  //
  //
}
