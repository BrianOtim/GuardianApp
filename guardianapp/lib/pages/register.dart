import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:guardianapp/helpers/routes.dart';
import 'package:guardianapp/style.dart';
import 'package:guardianapp/helpers/urls.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;
  bool _isObscure = true; // to manage password visibility

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      var apiUrl = Uri.parse('$baseUrl/register');
      final response = await http.post(
        apiUrl,
        body: json.encode({
          "username": _usernameController.text,
          "contact": _contactController.text,
          "email": _emailController.text,
          "password": _passwordController.text,
          "role": "user"
        }),
        headers: {'Content-Type': 'application/json'},
      );

      // print(response.body);
      // print(response.statusCode);

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('message')) {
          // register successful, navigate to next screen or perform action
          // print('Register Successful');

          Navigator.pushReplacementNamed(context, loginRoute);
        } else {
          setState(() {
            _errorMessage = 'Invalid response from server';
          });
        }
      } else if (response.statusCode == 400) {
        Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('error')) {
          setState(() {
            _errorMessage = responseData['error'];
          });
        } else {
          setState(() {
            _errorMessage = 'Unknown error occurred';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server error, please try again later';
        });
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 40, 182, 45),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  margin: const EdgeInsets.only(top: 0),
                  width: double.infinity,
                  height: height * 0.4,
                  child: Image.asset(
                    "assets/image1.jpg",
                    fit: BoxFit.fitWidth,
                  )),
              const SizedBox(
                height: 20.0,
              ),
              const Center(
                  child: Text(
                'Sign up for an account',
                style: TextStyle(fontSize: 26.0),
              )),
              const SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: TextFormField(
                  controller: _emailController,
                  decoration: customInputDecoration('Email'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    }
                    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                    RegExp regExp = RegExp(pattern);
                    if (!regExp.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: TextFormField(
                  controller: _usernameController,
                  decoration: customInputDecoration('Username'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your username';
                    }

                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: TextFormField(
                  controller: _contactController,
                  decoration: customInputDecoration('Contact'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your contact';
                    }

                    if (value.length != 10) {
                      return 'Contact must be 10 characters';
                    }

                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: const TextStyle(fontSize: 13.0),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _isObscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.only(
                        left: 14.0, bottom: 8.0, top: 8.0),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(25.7),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(25.7),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: width * 0.90,
                height: 50.0,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                height: 15.0,
                                width: 15.0,
                                child: CircularProgressIndicator()),
                            SizedBox(width: 10),
                            Text('Please wait...'),
                          ],
                        )
                      : const Text('Register'),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
              InkWell(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, loginRoute);
                  },
                  child: const Text(
                    "Already have an account? Login",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
