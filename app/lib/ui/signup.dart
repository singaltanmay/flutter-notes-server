import 'package:app/model/constants.dart';
import 'package:app/model/resource_uri.dart';
import 'package:app/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/url_builder.dart';
import '../widgets/logo.dart';
import 'all_notes.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController securityQuestionController = TextEditingController();
  TextEditingController securityQuestionAnswerController =
      TextEditingController();
  bool checkedValue = true;

  Future<void> onSignUpPressed(Function callback) async {
    String username = usernameController.text;
    String password = passwordController.text;
    String securityQuestion = securityQuestionController.text;
    String securityQuestionAnswer = securityQuestionAnswerController.text;

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

    if (securityQuestion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Security Question needs to be set'),
        ),
      );
      return;
    }

    if (securityQuestionAnswer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Security Question needs to be answered'),
        ),
      );
      return;
    }

    var appendedUri = await UrlBuilder().append("signup").build(withToken: false);
    final response = await http.post(appendedUri, body: {
      "username": username,
      "password": password,
      "securityQuestion": securityQuestion,
      "securityQuestionAnswer": securityQuestionAnswer
    });
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
      throw Exception(
          'Failed to Sign Up. Response code = ${response.statusCode}\n');
    }
  }

  Widget _signupBtn() {
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
        onPressed: () => onSignUpPressed(() => {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AllNotes()),
              )
            }),
        textColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 25),
        child: const Text("SIGN UP"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Sign Up",
      home: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            color: const Color(0xFFfafafa),
            width: double.infinity,
            child: Column(
              children: [
                const Logo(),
                Container(
                    margin: const EdgeInsets.all(50),
                    child: const Text("Flutter Notes")),
                InputField(
                    prefixIcon: const Icon(Icons.person_outline,
                        size: 30, color: Color(0xffA6B0BD)),
                    hintText: "Username",
                    isPassword: false,
                    controller: usernameController),
                InputField(
                    prefixIcon: const Icon(Icons.lock_outline,
                        size: 30, color: Color(0xffA6B0BD)),
                    hintText: "Password",
                    isPassword: true,
                    controller: passwordController),
                InputField(
                    prefixIcon: const Icon(Icons.article_outlined,
                        size: 30, color: Color(0xffA6B0BD)),
                    hintText: "Security Question",
                    isPassword: false,
                    controller: securityQuestionController),
                InputField(
                    prefixIcon: const Icon(Icons.question_answer_outlined,
                        size: 30, color: Color(0xffA6B0BD)),
                    hintText: "Security Question Answer",
                    isPassword: false,
                    controller: securityQuestionAnswerController),
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
                _signupBtn(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
