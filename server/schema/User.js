const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    username: {
        type: String,
        required: true
    },
    password: {
        type: String,
        required: true
    },
    securityQuestion: String,
    securityQuestionAnswer: String
})

userSchema.methods.redactedJson = function () {
    return {
        "_id": this._id,
        "username": this.username
    }
}

module.exports = mongoose.model('User', userSchema);
