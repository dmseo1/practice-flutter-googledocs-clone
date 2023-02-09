// Document
// - user id
// - created at
// - title
// content

const mongoose = require('mongoose');
const dayjs = require('dayjs');

const documentSchema = mongoose.Schema({
    uid: {
        required: true,
        type: String,
    },
    createdAt: {
        require: true,
        type: Number, //epoch millisecond in dart
        default: dayjs().valueOf()
    },
    title: {
        required: true,
        type: String,
        trim: true,
    },
    content: {
        type: Array,
        default: [],
    },
});

const Document = mongoose.model('Document', documentSchema);

module.exports = Document;