const mongoose = require('mongoose');

const noteSchema = new mongoose.Schema({
    title: {
        type: String,
        required: true
    },
    body: String,
    created: {
        type: Date,
        default: Date.now
    },
    creator: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'creator',
        required: true
    },
    starred: {
        type: Boolean,
        default: false
    }
})

module.exports = mongoose.model('Note', noteSchema);
