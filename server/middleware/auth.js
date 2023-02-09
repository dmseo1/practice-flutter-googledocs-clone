const jwt = require('jsonwebtoken');

const auth = async (req, res, next) => {
    try {
        const token = req.header('x-auth-token');

        if(!token) 
            return res.status(401).json({error: 'Access denied.'});

        const verified = jwt.verify(token, process.env.JWT_PASSWORD_KEY);

        if(!verified)
            return res.status(401).json({error: 'The authentication is not valid or expired.'});

        req.user = verified.id;
        req.token = token;

        next();

    } catch (e) {
        res.status(500).json({ error: e.message });
    }
};

module.exports = auth;