import 'package:app/model/resource_uri.dart';
import 'package:flutter/material.dart';

import 'input_field.dart';

class NoConnectionModal extends StatelessWidget {
  Function? callback;

  NoConnectionModal({Key? key, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _dbBaseUrlController = TextEditingController();

    if (_dbBaseUrlController.text.isEmpty) {
      ResourceUri.getBaseUri()
          .then((value) => _dbBaseUrlController.text = value.toString());
    }
    _dbBaseUrlController.addListener(() {
      String value = _dbBaseUrlController.text;
      if (value.isNotEmpty) {
        ResourceUri.setBaseUri(value);
      }
    });

    return Wrap(
      children: [
        const RotatedBox(quarterTurns: 2, child: LinearProgressIndicator()),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 24, left: 8, right: 8),
                child: Text(
                  "Could not connect to the Flutter Notes database server",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
              InputField(
                  prefixIcon: const Icon(Icons.link,
                      size: 30, color: Color(0xffA6B0BD)),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.backspace_rounded,
                      color: Color(0xffA6B0BD),
                    ),
                    onPressed: () {
                      _dbBaseUrlController.clear();
                    },
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                  ),
                  hintText: "Database Server URL",
                  controller: _dbBaseUrlController),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(top: 4, bottom: 4),
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
                  child: FlatButton.icon(
                    hoverColor: Colors.transparent,
                    onPressed: () => callback?.call(),
                    textColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    label: const Text("Done"),
                    icon: const Icon(Icons.done),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
