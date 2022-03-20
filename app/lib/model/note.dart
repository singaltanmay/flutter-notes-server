class Note {
  final String? id;
  final String title;
  final String body;
  String? created = DateTime.now().toString();
  final String creator;

  Note({this.id, required this.title, required this.body, this.created, required this.creator});

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['_id'],
      title: json['title'],
      body: json['body'],
      created: json['created'],
      creator: json['creator']
    );
  }

  @override
  String toString() {
    return 'Note{id: $id, title: $title, body: $body, created: $created, creator: $creator}';
  }

  Map toMap() {
    var map = {};
    if (id != null) {
      map["_id"] = id;
    }
    map["title"] = title;
    map["body"] = body;
    map["created"] = created ?? DateTime.now().toString();
    map["creator"] = creator;
    return map;
  }
}
