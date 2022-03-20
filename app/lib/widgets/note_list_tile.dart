import 'dart:convert';
import 'dart:io';

import 'package:app/model/note.dart';
import 'package:app/model/resource_uri.dart';
import 'package:app/ui/note_editor.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NoteListTile extends StatefulWidget {
  final Note note;
  final Function onDelete;
  final Function onNoteEdited;
  String? noteCreatorUsername;

  NoteListTile(
      {Key? key,
      required this.note,
      required this.onDelete,
      required this.onNoteEdited})
      : super(key: key);

  @override
  _NoteListTileState createState() => _NoteListTileState();

  void printServerCommFailedError() {
    stderr.writeln('Failed to communicate with server');
  }

  Future<bool> delete() async {
    try {
      var appendedUri = await ResourceUri.getAppendedUri(note.id!);
      final response = await http.delete(appendedUri, headers: {
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*"
      });

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        return true;
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to delete the note');
      }
    } on Exception {
      printServerCommFailedError();
      return false;
    }
  }
}

class _NoteListTileState extends State<NoteListTile> {
  Future<String?> getNoteCreatorUsername(String creatorId) async {
    var appendedUri = await ResourceUri.getAppendedUri("user/" + creatorId);
    final response = await http.get(appendedUri);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      final Map responseBody = jsonDecode(response.body);
      return responseBody["username"];
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.note.title;
    String body = widget.note.body;

    if (widget.noteCreatorUsername == null) {
      getNoteCreatorUsername(widget.note.creator).then((value) => {
            setState(() {
              widget.noteCreatorUsername = value;
            })
          });
    }

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NoteEditor(note: widget.note)),
            ).then((value) => widget.onNoteEdited())
          },
          child: Column(
            children: [
              ListTile(
                leading: Container(
                    padding: const EdgeInsets.all(12.0),
                    child: const Icon(
                      Icons.ac_unit_rounded,
                      size: 32.0,
                    )),
                title: Text(title),
                subtitle: Text(
                  DateTime.parse(
                          widget.note.created ?? DateTime.now().toString())
                      .toLocal()
                      .toString(),
                  style: TextStyle(color: Colors.black.withOpacity(0.6)),
                ),
                trailing: PopupMenuButton<int>(
                    itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
                          const PopupMenuItem<int>(
                              value: 0, child: Text('Delete'))
                        ],
                    onSelected: (int value) {
                      if (value == 0) {
                        widget.delete().then((deleted) => {
                              if (!deleted)
                                {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Could not delete all notes'),
                                    ),
                                  ),
                                }
                              else
                                widget.onDelete()
                            });
                      }
                    }),
              ),
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        widget.noteCreatorUsername != null
                            ? body + " -- @" + widget.noteCreatorUsername!
                            : body,
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      ),
                    ),
                  ),
                ],
              ),
              ButtonBar(
                alignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      widget.delete();
                      widget.onDelete();
                    },
                    child: Text('Delete'.toUpperCase()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
