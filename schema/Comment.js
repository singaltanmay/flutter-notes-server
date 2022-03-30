const mongoose = require('mongoose');

const commentSchema = new mongoose.Schema({
    cmt: { type: String, required: true },
    liked: { type: Boolean, default: false },
    creator: {
        type: mongoose.Schema.Types.ObjectId, required: -1
    },
    parent_id: {
        type: mongoose.Schema.Types.ObjectId, required: -1
    }
});

module.exports = mongoose.model('Comment', commentSchema);
