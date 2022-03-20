import 'package:app/model/constants.dart';
import 'package:app/model/db_connected_state.dart';
import 'package:app/model/resource_uri.dart';
import 'package:app/ui/all_notes.dart';
import 'package:app/ui/signup.dart';
import 'package:app/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/url_builder.dart';
import '../widgets/logo.dart';
import '../widgets/no_connection_modal.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends DbConnectedState<SignIn> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool checkedValue = true;

  Future<void> onSignInPressed(Function callback) async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username cannot be blank'),
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password cannot be blank'),
        ),
      );
      return;
    }

    var appendedUri = await UrlBuilder().append("signin").build(withToken: false);
    final response = await http
        .post(appendedUri, body: {"username": username, "password": password});
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      var prefs = await SharedPreferences.getInstance();
      prefs.setString(Constants.userTokenKey, response.body);
      if (checkedValue) {
        prefs.setString(Constants.userName, username);
        prefs.setString(Constants.password, password);
      }
      callback();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      ResourceUri.isServerHealthy().then((value) => {
        if (!value)
          {
            showBottomSheet(
              builder: (context) {
                return NoConnectionModal(
                  callback: () {
                    // Close this modal sheet
                    Navigator.of(context).pop();
                  },
                );
              },
              context: context,
            )
          }
      });
      /*throw Exception(
          'Failed to Sign In. Response code = ${response.statusCode}\n');*/
    }
  }

  @override
  Widget build(BuildContext context) {
    getPrefilledUserName();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Sign In",
      home: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            color: const Color(0xFFfafafa),
            width: double.infinity,
            child: Column(
              children: [
                const Logo(),
                _logoText(),
                InputField(
                    prefixIcon: const Icon(Icons.person_outline,
                        size: 30, color: Color(0xffA6B0BD)),
                    hintText: "Username",
                    isPassword: false,
                    controller: _usernameController),
                InputField(
                    prefixIcon: const Icon(Icons.lock_outline,
                        size: 30, color: Color(0xffA6B0BD)),
                    hintText: "Password",
                    isPassword: true,
                    controller: _passwordController),
                CheckboxListTile(
                    title: const Text("Remember Me",
                        style: TextStyle(
                          fontSize: 14.0
                        )),
                  value: checkedValue,
                  onChanged: (newValue) {
                    setState(() {
                      checkedValue = newValue ?? true;
                      });
                  },
                  controlAffinity: ListTileControlAffinity.leading),
                _signinBtn(context),
                const Text("Don't have an account?"),
                _signUp(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _signinBtn(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20, bottom: 50),
      decoration: const BoxDecoration(
          color: Color(0xff008FFF),
          borderRadius: BorderRadius.all(Radius.circular(50)),
          boxShadow: [
            BoxShadow(
              color: Color(0x60008FFF),
              blurRadius: 10,
              offset: Offset(0, 5),
              spreadRadius: 0,
            ),
          ]),
      child: FlatButton(
        onPressed: () => onSignInPressed(() => {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AllNotes()),
              )
            }),
        textColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 25),
        child: const Text("SIGN IN"),
      ),
    );
  }

  getPrefilledUserName() async {
    var prefs = await SharedPreferences.getInstance();
    _usernameController.text = prefs.getString(Constants.userName) ?? "";
    _passwordController.text = prefs.getString(Constants.password) ?? "";
  }
}

Widget _signUp(BuildContext context) {
  return TextButton(
    onPressed: () => {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignUp()),
      )
    },
    child: const Text("SIGN UP NOW"),
  );
}

Widget _logoText() {
  return Container(
      margin: const EdgeInsets.all(50), child: const Text("Flutter Notes"));
}
