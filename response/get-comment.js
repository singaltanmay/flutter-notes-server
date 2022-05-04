function getComment({commentObj, creatorObj, requesterId}) {
    let requesterVoted = 0;
    if (requesterId && commentObj.upvoters.includes(requesterId)) {
        requesterVoted = 1;
    } else if (commentObj.downvoters.includes(requesterId)) {
        requesterVoted = -1;
    }
    return {
        "_id": commentObj._id.toString(),
        "body": commentObj.body,
        "created": commentObj.created,
        "creator": commentObj.creator.toString(),
        "creatorUsername": creatorObj.username,
        "numberOfUpvotes": commentObj.upvoters.length,
        "numberOfDownvotes": commentObj.downvoters.length,
        "requesterVoted": requesterVoted,
        "parentNote": commentObj.parentNote.toString(),
        "parentComment": commentObj.parentComment ? commentObj.parentComment.toString() : null,
        "numberOfNestedComments": commentObj.comments ? commentObj.comments.length : 0
    }
}

module.exports = getComment
