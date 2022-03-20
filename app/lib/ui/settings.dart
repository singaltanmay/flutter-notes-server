import 'package:app/model/constants.dart';
import 'package:app/model/resource_uri.dart';
import 'package:app/ui/signin.dart';
import 'package:app/widgets/app_bottom_navigation_bar.dart';
import 'package:app/widgets/input_field.dart';
import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  Settings({Key? key}) : super(key: key);

  final TextEditingController _dbBaseUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (_dbBaseUrlController.text.isEmpty) {
      ResourceUri.getBaseUri()
          .then((value) => _dbBaseUrlController.text = value.toString());
    }
    _dbBaseUrlController.addListener(() {
      String value = _dbBaseUrlController.text;
      if(value.isNotEmpty){
        ResourceUri.setBaseUri(value);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        actions: [
          RotatedBox(
            quarterTurns: 1,
            child: PopupMenuButton<int>(
                itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
                      const PopupMenuItem<int>(
                          value: 1, child: Text('Sign Out'))
                    ],
                onSelected: (int value) {
                  if (value == 1) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const SignIn()),
                    );
                  }
                }),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InputField(
                prefixIcon:
                    const Icon(Icons.link, size: 30, color: Color(0xffA6B0BD)),
                hintText: "Database Server URL",
                controller: _dbBaseUrlController)
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(
        initialPosition: Constants.appBarSettingsPosition,
      ),
    );
  }
}
