import 'package:shared_preferences/shared_preferences.dart';

Future<String> pickValue({required String name}) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(name) ?? "";
}

Future<int> pickIntegerValue({required String name}) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(name) ?? 0;
}

Future<String> getUsername() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('username') ?? '';
}

Future<bool> clearData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return await prefs.clear();
}
