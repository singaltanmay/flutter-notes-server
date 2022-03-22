const mongoose = require('mongoose');

const commentSchema = new mongoose.Schema({
body: {type: String, required: true},
 creator: {
        type: mongoose.Schema.Types.ObjectId, ref: 'creator', required: true
    },
    children: [Schema.Types.Comment]
});

module.exports = mongoose.model('Comment', commentSchema);
