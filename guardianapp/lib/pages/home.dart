import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guardianapp/helpers/colors.dart';
import 'package:guardianapp/helpers/routes.dart';
import '../helpers/storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeColor,
      appBar: AppBar(
        leading: Icon(
          CupertinoIcons.home,
          color: themeColor,
        ),
        title:
            Text('Home', style: TextStyle(fontSize: 16.0, color: themeColor)),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () async {
              await clearData().then((value) {
                if (value) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, loginRoute, (route) => false);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Sign out",
                  style: TextStyle(fontSize: 16.0, color: themeColor)),
            ),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Guardian Application',
            style: TextStyle(fontSize: 36.0, color: Colors.white),
          ),
          Center(
            child: FutureBuilder<String>(
              future: getUsername(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else {
                  if (snapshot.hasData) {
                    return Text(
                      'Welcome, ${snapshot.data}',
                      style:
                          const TextStyle(fontSize: 16.0, color: Colors.white),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const Text('Loading...');
                  }
                }
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MenuButton(
                  title: "Guardians",
                  routeName: guardiansRoute,
                ),
                MenuButton(
                  title: "My\nGuardianship",
                  routeName: guardianshipRoute,
                )
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MenuButton(
                  title: "Resources",
                  routeName: resourceRoute,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MenuButton(
                  title: "My Alerts",
                  routeName: alertsRoute,
                ),
                MenuButton(
                  title: "Guardianship Alerts",
                  routeName: myPeopleAlertsRoute,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  const MenuButton({super.key, required this.title, required this.routeName});
  final String routeName;
  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
            border: Border.all(color: greenColor, width: 2.0),
            color: whiteColor,
            borderRadius: BorderRadius.circular(100.0)),
        child: Center(
            child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 13.0, color: themeColor, fontWeight: FontWeight.bold),
        )),
      ),
    );
  }
}
