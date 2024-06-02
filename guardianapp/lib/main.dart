import 'package:flutter/material.dart';
import 'package:guardianapp/helpers/routes.dart';
import 'package:guardianapp/pages/my_alerts.dart';
import 'package:guardianapp/pages/guardians.dart';
import 'package:guardianapp/pages/home.dart';
import 'package:guardianapp/pages/login.dart';
import 'package:guardianapp/pages/register.dart';
import 'package:guardianapp/pages/resource.dart';
import 'package:guardianapp/pages/users_under_my_guardianship.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/my_people_alerts.dart';
import 'pages/search_users.dart';

Future<bool> _checkTokenExists() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  return token != null; // Return true if token exists, otherwise false
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp(
    isAuthenticated: await _checkTokenExists(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isAuthenticated});
  final bool isAuthenticated;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardian App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: isAuthenticated ? homeRoute : loginRoute,
      routes: {
        loginRoute: (context) => const LoginScreen(),
        registerRoute: (context) => const RegisterScreen(),
        homeRoute: (context) => const HomeScreen(),
        guardiansRoute: (context) => const GuardiansScreen(),
        guardianshipRoute: (context) => const UsersUnderMyGuardianshipScreen(),
        userSearchRoute: (context) => const UserSearchScreen(),
        alertsRoute: (context) => const AlertScreen(),
        myPeopleAlertsRoute: (context) => const MyPeopleAlertScreen(),
        resourceRoute: (context) => const ResourceScreen(),
      },
    );
  }
}
