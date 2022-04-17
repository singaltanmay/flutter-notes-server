// final String? id;
// final String title;
// final String body;
// final bool starred;
// String? created = DateTime.now().toString();
// final String creator;
// List<String>? upvoters;
// List<String>? downvoters;
// List<Comment>? comments;

function getNoteByToken({note, creatorUsername, numberOfUpvotes, numberOfDownvotes, numberOfComments}) {
    return {
        "_id": note._id,
        "title": note.title,
        "body": note.body,
        "created": note.created,
        "starred": note.starred,
        "creator": note.creator,
        "creatorUsername": creatorUsername,
        "numberOfUpvotes": numberOfUpvotes,
        "numberOfDownvotes": numberOfDownvotes,
        "numberOfComments": numberOfComments
    }
}

module.exports = getNoteByToken
