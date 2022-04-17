const mongoose = require('mongoose');

const noteSchema = new mongoose.Schema({
    title: {
        type: String, required: true
    }, body: String,
    created: {
        type: Date, default: Date.now
    }, creator: {
        type: mongoose.Schema.Types.ObjectId, ref: 'creator', required: true
    }, starred: {
        type: Boolean, default: false
    }, upvoters: [mongoose.Schema.Types.ObjectId],
    downvoters: [mongoose.Schema.Types.ObjectId],
    comments: [mongoose.Schema.Types.ObjectId]
})

module.exports = mongoose.model('Note', noteSchema);
