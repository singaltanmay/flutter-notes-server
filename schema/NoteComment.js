const mongoose = require('mongoose');

const commentSchema = new mongoose.Schema({
    body: {
        type: String, required: true
    },
    created: {
        type: Date, default: Date.now
    },
    creator: {
        type: mongoose.Schema.Types.ObjectId, ref: 'creator', required: true
    },
    upvoters: [mongoose.Schema.Types.ObjectId],
    downvoters: [mongoose.Schema.Types.ObjectId],
    nestedComments: [mongoose.Schema.Types.ObjectId],
    parentNote: {
        type: mongoose.Schema.Types.ObjectId, required: true
    },
    parentComment: {
        type: mongoose.Schema.Types.ObjectId
    }
});

module.exports = mongoose.model('Comment', commentSchema);
