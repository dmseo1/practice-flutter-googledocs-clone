const express = require('express');
const Document = require('../models/document');
const auth = require('../middleware/auth');

const documentRouter = express.Router();

documentRouter.post('/doc/create', auth, async (req, res) => {
    try {

        let document = new Document({
            uid: req.user,
            title: 'Untitled Document',
        });

        document = await document.save();
        res.json(document);
    } catch (e) {
        res.status(500).json({ error : e.message });
    }
});

documentRouter.get('/doc/me', auth, async (req, res) => {
    try {
        let documents = await Document.find({ uid: req.user });
        res.json(documents);
    } catch (e) {
        res.status(500).json({ error : e.message });
    }
});

module.exports = documentRouter;