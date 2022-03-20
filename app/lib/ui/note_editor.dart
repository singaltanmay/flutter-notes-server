import 'package:app/model/constants.dart';
import 'package:app/model/resource_uri.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/note.dart';
import '../model/url_builder.dart';

class NoteEditor extends StatefulWidget {
  final Note? note;

  const NoteEditor({Key? key, this.note}) : super(key: key);

  @override
  _NoteEditorState createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  TextEditingController titleController = TextEditingController();
  TextEditingController bodyController = TextEditingController();

  void postNewNote() async {
    String currentUser = await getCurrentUserToken();
    var note = Note(
        title: titleController.text,
        body: bodyController.text,
        creator: currentUser);

    var baseUri = await UrlBuilder().append("note").build();
    final response = await http.post(baseUri, body: note.toMap());
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Navigator.pop(context);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception(
          'Failed to POST Note $note. Response code = ${response.statusCode}\n');
    }
  }

  void updateNote() async {
    String currentUser = await getCurrentUserToken();
    var note = Note(
        id: widget.note?.id,
        title: titleController.text,
        body: bodyController.text,
        creator: currentUser);

    var baseUri = await UrlBuilder().append("note").build();
    final response = await http.put(baseUri, body: note.toMap());
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Navigator.pop(context);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception(
          'Failed to PUT Note $note. Response code = ${response.statusCode}\n');
    }
  }

  Future<String> getCurrentUserToken() async {
    var prefs = await SharedPreferences.getInstance();
    String? currentUser = prefs.getString(Constants.userTokenKey);
    if (currentUser == null) {
      throw Exception('User Token not found in Shared Preferences!');
    }
    return currentUser;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.note != null) {
      titleController.text = widget.note?.title ?? "";
      bodyController.text = widget.note?.body ?? "";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Note"),
        actions: [
          IconButton(
              icon: const Icon(Icons.done_rounded),
              onPressed: () => {
                    if (widget.note != null && widget.note?.id != null)
                      {updateNote()}
                    else
                      postNewNote()
                  }),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Title',
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Expanded(
              child: TextFormField(
                controller: bodyController,
                maxLines: 1000,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Body',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
