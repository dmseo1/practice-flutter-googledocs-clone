const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const authRouter = require('./routes/auth');
const dotenv = require('dotenv');

dotenv.config();

const PORT = process.env.PORT | 3001;

const app = express();

app.use(cors());
app.use(express.json()); //data manipulation to json format
app.use(authRouter);

const DB = `mongodb+srv://${process.env.MONGODB_USERNAME}:${process.env.MONGODB_PASSWORD}@${process.env.MONGODB_CLUSTER}.1ooq9f5.mongodb.net/?retryWrites=true&w=majority`;


mongoose.connect(DB).then(() => {
    console.log('Connection successful!');
}).catch((err) => {
    console.log(err);
});


app.listen(PORT, '0.0.0.0', (req, res) => {
    console.log(`Server is listening on port ${PORT}`);
});