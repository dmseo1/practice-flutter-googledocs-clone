const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/user');
const { OAuth2Client } = require('google-auth-library');

const authRouter = express.Router();

const client = new OAuth2Client();

authRouter.post('/api/signup', async (req, res) => {
    try {
        const { idToken } = req.body;

        const ticket = await client.verifyIdToken({
            idToken
        });

        const payload = ticket.getPayload();
        const email = payload.email;
        const profilePic = payload.picture;
        const name = payload.name;

        //email already exists?
        let user = await User.findOne({ email, });
        

        if(!user) {
            user = new User({ name, email, profilePic, });
            user = await user.save();
        }

        const token = jwt.sign({id: user._id});

        res.status(200).json({ user, token });
    } catch (e) {
        console.log(e);
        res.status(500).json({ error: e.message });
    }
});

// authRouter.get('/', auth, async (req, res) => {

// });


module.exports = authRouter;