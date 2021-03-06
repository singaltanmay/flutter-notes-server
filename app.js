const createError = require('http-errors');
const express = require('express');
const path = require('path');
const cors = require('cors');
const jwt = require('jsonwebtoken')
const crypto = require('crypto');

const mongoose = require('mongoose');

// TOOD migrate enivronments variables to a .env file
const server = '127.0.0.1:27017';
const database = 'flutter-notes-db';
const TOKEN_SECRET = 'QKKawsbKW1OgC5FIvcEtjjsnLTkVbFRi7ITxnjId'

let mongooseConnected = false;
let mongoUrl = `mongodb://${server}/${database}`;

const connectWithRetry = function () {
    return mongoose.connect(mongoUrl, {
        useNewUrlParser: true, useUnifiedTopology: true
    }, function (err) {
        if (err) {
            console.log('Failed to connect to Flutter Notes database on startup. Retrying in 5 sec', err);
            setTimeout(connectWithRetry, 5000);
        } else {
            mongooseConnected = true;
            console.log('Flutter Notes database connected!\n');
        }
    })
};
connectWithRetry();

const app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');

app.use(cors())
app.use(express.json());
app.use(express.urlencoded({extended: false}));
app.use(express.static(path.join(__dirname, 'public')));

// HTTP method declarations
app.get('/note', getNote)
app.get('/note/starred', getStarredNotes)
app.post('/note', saveNote)
app.delete('/note', deleteNote)
app.put('/note', updateNote)
app.post('/note/:noteId/vote', voteOnNote)
app.get('/note/:noteId/comments', getCommentsFromNoteId)
app.post('/note/:noteId/comment', saveCommentFromNoteId)
app.get('/comment', getComment)
app.post('/comment', saveComment)
app.put('/comment', updateComment)
app.delete('/comment', delComment)
app.get('/user', getUser)
app.post('/signup', signUpUser)
app.post('/signin', signInUser)
app.get('/health', (_, res) => res.send(mongooseConnected))

// catch 404 and forward to error handler
app.use(function (req, res, next) {
    next(createError(404));
});

// error handler
app.use(function (err, req, res, next) {
    // set locals, only providing error in development
    res.locals.message = err.message;
    res.locals.error = req.app.get('env') === 'development' ? err : {};

    // render the error page
    res.status(err.status || 500);
    res.send(JSON.stringify(err));
});

// Schema imports
const Note = require('./schema/Note')
const User = require('./schema/User')
const Comment = require('./schema/NoteComment')

// Response Helper imports
const getNoteResponse = require('./response/get-note')
const getCommentResponse = require('./response/get-comment')

async function getNote({query}, res, next) {
    let requesterId = await getUserIdByToken(query.token);
    // Return all notes if note id is not provided
    if (!query || !(query.noteid)) {
        let allNoteObjs = await Note.find();
        if (allNoteObjs == null) {
            res.sendStatus(404);
            return;
        }
        const responseJsonList = []
        for (i = 0; i < allNoteObjs.length; i++) {
            const noteObj = allNoteObjs[i];
            let creatorObj = await User.findById(noteObj.creator);
            let responseJson = getNoteResponse({
                'noteObj': noteObj, 'creatorObj': creatorObj, 'requesterId': requesterId
            });
            responseJsonList.push(responseJson)
        }
        res.status(200).send(responseJsonList);
    } else {
        let noteObj = await Note.findById(query.noteid);
        if (noteObj == null) {
            res.sendStatus(404);
            return;
        }
        let creatorObj = await User.findById(noteObj.creator);
        let responseJson = getNoteResponse({
            'noteObj': noteObj, 'creatorObj': creatorObj, 'requesterId': requesterId
        });
        res.status(200).send(responseJson);
    }
}

async function getStarredNotes(req, res, next) {
    // Return all notes if note id is not provided
    Note.find({"starred": true}).then(notes => {
        res.send(notes);
    }).catch(err => {
        console.log(err)
        res.sendStatus(404)
        next(err)
    })
}

async function saveNote({query, body}, res, next) {
    let creator = await getUserIdByToken(query.token);
    const note = new Note({
        title: body.title, body: body.body, created: body.created, starred: body.starred
    })
    if (creator == null) {
        let errorMsg = "Cannot save note without a valid creator";
        console.log(errorMsg + "\n" + note)
        res.status(400).send(errorMsg);
        next()
    } else {
        note.creator = creator
    }
    note.save()
        .then(_ => {
            res.sendStatus(200);
        }).catch(err => {
        next(err)
        return;
    });
}

async function updateNote({query, body}, res, next) {
    const noteId = body._id || query.noteid;
    if (!noteId) {
        res.sendStatus(404)
        return;
    }
    const oldNote = await Note.findById(noteId);
    if (oldNote == null) {
        res.sendStatus(404)
        return;
    }
    let userId = await getUserIdByToken(query.token);
    Note.updateOne({'_id': noteId}, {
        'title': body.title || oldNote['title'],
        'body': body.body || oldNote['body'],
        'created': body.created || oldNote['created'],
        'creator': userId || oldNote['creator'],
        'starred': body.starred || oldNote['starred']
    }).then(_ => {
        res.sendStatus(200);
    }).catch(err => {
        console.log(err)
        next(err)
    })
}

function deleteNote({query}, res, next) {
    // Delete all notes if note id is not provided
    if (!query || !(query.noteid)) {
        Note.deleteMany().then(res.sendStatus(200)).catch(err => {
            console.log(err)
            res.sendStatus(500)
            next(err)
        })
    } else {
        Note.deleteOne({'_id': query.noteid}).then(res.sendStatus(200)).catch(next)
    }
}

async function voteOnNote({params, query}, res, next) {
    // Request did not contain any vote value or did not specify the note ID
    if (!query || !(query.vote) || !params || !(params.noteId)) {
        res.status(400).send('Note ID and Vote value should be provided!');
        return;
    }
    let requesterId = await getUserIdByToken(query.token);
    let noteObj = await Note.findById(params.noteId);
    if (!noteObj) {
        res.status(404).send('Note with note ID ' + params.noteId + ' not found.');
        return;
    }
    if (query.vote == -1) {
        // Case: Downvote
        // Remove any upvote by this user
        noteObj.upvoters = noteObj.upvoters.filter((value) => value != requesterId);
        // Add the downvote
        noteObj.downvoters = noteObj.downvoters.push(requesterId);
        Note.updateOne({'_id': noteObj._id}, {
            'upvoters': noteObj.upvoters, 'downvoters': noteObj.downvoters
        }).then(_ => {
            res.sendStatus(200);
        }).catch(err => {
            console.log(err)
            next(err)
        })
    } else if (query.vote == 0) {
        // Case: No Vote
        // Remove any upvote by this user
        noteObj.upvoters = noteObj.upvoters.filter((value) => value != requesterId);
        // Remove any downvote by this user
        noteObj.downvoters = noteObj.downvoters.filter((value) => value != requesterId);
        Note.updateOne({'_id': noteObj._id}, {
            'upvoters': noteObj.upvoters, 'downvoters': noteObj.downvoters
        }).then(_ => {
            res.sendStatus(200);
        }).catch(err => {
            console.log(err)
            next(err)
        })
    } else if (query.vote == 1) {
        // Case: Upvote
        // Remove any downvote by this user
        noteObj.downvoters = noteObj.downvoters.filter((value) => value != requesterId);
        // Add the upvote
        noteObj.upvoters = noteObj.upvoters.push(requesterId);
        Note.updateOne({'_id': noteObj._id}, {
            'upvoters': noteObj.upvoters, 'downvoters': noteObj.downvoters
        }).then(_ => {
            res.sendStatus(200);
        }).catch(err => {
            console.log(err)
            next(err)
        })
    } else {
        res.status(400).send('The vote value ' + query.vote + ' is not valid');
    }
}

async function getUser({query}, res, next) {
    let userId = await getUserIdByToken(query.token);
    User.findById(userId).then(user => {
        res.status(200).send(user.redactedJson());
    }).catch(err => {
        console.log(err)
        res.status(404).send()
        next(err)
    })
}

async function signInUser(req, res, next) {
    await User.findOne({
        'username': req.body.username
    }).then(user => {
        // Verify password
        if (generateSaltedPassword(req.body.password, user.salt) === user.password) {
            // Create JWT
            let userId = user._id.toString();
            const jwToken = jwt.sign({"username": userId}, TOKEN_SECRET, {expiresIn: '1800s'})
            res.status(200).send(jwToken);
        } else {
            console.log("User " + req.body.username + " failed password authentication.")
            res.sendStatus(403);
            next(err)
        }
    }).catch(err => {
        console.log(err)
        next(err)
    });
}

async function getCommentsFromNoteId({params, query}, res, next) {
    // Request did not specify the note ID
    if (!params || !(params.noteId)) {
        res.status(400).send('Note ID should be provided!');
        return;
    }
    let requesterId = await getUserIdByToken(query.token);
    let noteObj = await Note.findById(params.noteId);
    if (!noteObj) {
        res.status(404).send('Note with note ID ' + params.noteId + ' not found.');
        return;
    }
    const commentQueryJson = query && query.parentComment ? {
        'parentNote': params.noteId, 'parentComment': query.parentComment
    } : {'parentNote': params.noteId};
    var allCommentObjs = await Comment.find(commentQueryJson);
    const responseJsonList = [];
    for (i = 0; i < allCommentObjs.length; i++) {
        const commentObj = allCommentObjs[i];
        let creatorObj = await User.findById(commentObj.creator);
        let responseJson = getCommentResponse({
            'commentObj': commentObj, 'creatorObj': creatorObj, 'requesterId': requesterId
        });
        responseJsonList.push(responseJson)
    }
    res.status(200).send(responseJsonList);
}

async function saveCommentFromNoteId({query, params, body}, res, next) {
    // Request did not specify the note ID
    if (!params || !(params.noteId)) {
        res.status(400).send('Note ID should be provided!');
        return;
    }
    let requesterId = await getUserIdByToken(query.token);
    let noteObj = await Note.findById(params.noteId);
    if (!noteObj) {
        res.status(404).send('Note with note ID ' + params.noteId + ' not found.');
        return;
    }
    const comment = new Comment({
        body: body.body, created: body.created, parentNote: params.noteId
    })
    let parentCommentId = body.parentComment;
    let parentCommentObj = await Comment.findById(body.parentComment);
    if (parentCommentId && !parentCommentObj) {
        res.status(404).send('Comment with comment ID ' + parentCommentId + ' not found.');
        return;
    } else comment.parentComment = parentCommentId;
    if (requesterId == null) {
        let errorMsg = "Cannot save comment without a valid creator";
        console.log(errorMsg + "\n" + comment)
        res.status(400).send(errorMsg);
        next()
    } else {
        comment.creator = requesterId
    }
    comment.save()
        .then(newCommentObj => {
            if (parentCommentObj) {
                parentCommentObj.nestedComments.push(newCommentObj._id)
                Comment.findOneAndUpdate({'_id': parentCommentId}, parentCommentObj)
            }
            res.sendStatus(200);
        }).catch(err => {
        next(err)
        return;
    });
}

async function getComment({query, body}, res, next) {
    if (!query || !(query.id)) {
        Comment.find().then(comments => {
            res.send(comments)
        }).catch(err => {
            logAndSendError(res, err)
            return;
        });
    } else {
        Comment.findById(query.id).then(comment => {
            res.send(comment);
        }).catch(err => {
            logAndSendError(res, err)
            next(err)
        })
    }
}

async function saveComment({query, body}, res, next) {
    let creator = await getUserIdByToken(query.token);
    if (creator == null) {
        console.log("Cannot save note without a valid creator" + "\n" + commentObj)
        logAndSendError(res, err)
        return;
    }
    let parentNoteId = body.parentNote;
    var noteObj = await Note.findById(parentNoteId);
    if (!noteObj) {
        console.log("Parent Note ID is invalid. Cannot save comment. Please provide a valid parent note ID.")
        logAndSendError(res, err)
        return;
    }
    let parentCommentId = body.parentComment;
    var parentCommentObj = null;
    if (parentCommentId && !parentCommentId.isEmpty()) {
        parentCommentObj = await Comment.findById(parentCommentId);
        if (!parentCommentObj) {
            console.log("Parent Comment ID is invalid. Cannot save comment.")
            logAndSendError(res, err)
            return;
        }
    }
    const commentObj = new Comment({
        body: body.body, creator: creator, parentNote: parentNoteId, parentComment: parentCommentId
    })
    commentObj.save().then(_ => {
        res.sendStatus(200);
        return;
    }).catch(err => {
        logAndSendError(res, err);
        return;
    });

}

async function updateComment({query, body}, res, next) {
    let creator = await getUserIdByToken(query.token);
    if (creator == null) {
        console.log("Valid user token not provided")
        logAndSendError(res, err)
        return;
    }
    const commentId = body.id || query.id;
    if (!commentId) {
        logAndSendError(res, "No Comment ID provided")
        return;
    }
    const oldComment = await Comment.findById(commentId);
    if (oldComment == null) {
        logAndSendError(res, "Invalid Comment ID")
        return;
    }
    Comment.updateOne({'_id': commentId}, {body: body.body || oldComment.body}).then(_ => {
        res.sendStatus(200);
    }).catch(err => {
        logAndSendError(res, err);
        return;
    })
}

async function delComment({query, body}, res, next) {
    // Delete all notes if note id is not provided
    if (query && query.cmtId || body && body.cmtId) {
        Comment.deleteOne({'_id': query.cmtId || body.cmtId}).then(res.status(200).send(query.cmtId || body.cmtId)).catch(err => {
            logAndSendError(res, "Comment Id does not exist \n" + err)
        })
    } else {
        logAndSendError(res, "Invaild Comment Id")
    }
}

function signUpUser(req, res, next) {
    const salt = saltmine();
    const saltedPassword = generateSaltedPassword(req.body.password, salt);
    const user = new User({
        username: req.body.username,
        password: saltedPassword,
        salt: salt,
        securityQuestion: req.body.securityQuestion,
        securityQuestionAnswer: req.body.securityQuestionAnswer
    });
    user.save()
        .then(_ => {
            return (signInUser(req, res, next))
        }).catch(err => {
        console.log(err)
        next(err)
    });
}

async function getUserIdByToken(token) {
    if (!token) return null;
    const tokenObj = jwt.decode(token);
    if (tokenObj && tokenObj['username']) {
        // Check if the user who the token was issued to still exists
        let tokenUserId = tokenObj['username'].toString();
        const userFromDb = await User.findById(tokenUserId)
        if (userFromDb && userFromDb._id.toString() === tokenUserId) {
            return tokenUserId
        } else return null;
    } else return null;
}

// Returns a random 16 digit string to be used as salt
function saltmine() {
    return crypto.randomBytes(8).toString('hex').slice(0, 16);
}

// Create a salted password
function generateSaltedPassword(password, salt) {
    let hmac = crypto.createHmac('sha512', salt);
    let update = hmac.update(password);
    return update.digest('hex');
}

function logAndSendError(res, err) {
    console.log(err)
    res.status(404).send(err)
}

module.exports = app;
