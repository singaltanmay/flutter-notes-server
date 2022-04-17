function getNoteByToken({noteObj, creatorObj, requesterId}) {
    let requesterVoted = 0;
    if (requesterId && noteObj.upvoters.includes(requesterId)) {
        requesterVoted = 1;
    } else if (noteObj.downvoters.includes(requesterId)) {
        requesterVoted = -1;
    }
    return {
        "_id": noteObj._id.toString(),
        "title": noteObj.title,
        "body": noteObj.body,
        "created": noteObj.created,
        "starred": noteObj.starred,
        "creator": noteObj.creator.toString(),
        "creatorUsername": creatorObj.username,
        "numberOfUpvotes": noteObj.upvoters.length,
        "numberOfDownvotes": noteObj.downvoters.length,
        "numberOfComments": noteObj.comments.length,
        "requesterVoted": requesterVoted
    }
}

module.exports = getNoteByToken
