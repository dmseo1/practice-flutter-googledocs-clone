const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const http = require('http'); //socket 서버를 만들기 위해

const authRouter = require('./routes/auth');
const dotenv = require('dotenv');
const documentRouter = require('./routes/document');

dotenv.config();

const PORT = process.env.PORT | 3001;

const app = express();

let server = http.createServer(app);

let io = require('socket.io')(server);
// let socket = require('socket.io);
// let io = socket(server); 를 줄임

app.use(cors());
app.use(express.json()); //data manipulation to json format
app.use(authRouter);
app.use(documentRouter);

const DB = `mongodb+srv://${process.env.MONGODB_USERNAME}:${process.env.MONGODB_PASSWORD}@${process.env.MONGODB_CLUSTER}.1ooq9f5.mongodb.net/?retryWrites=true&w=majority`;


mongoose.connect(DB).then(() => {
    console.log('Connection successful!');
}).catch((err) => {
    console.log(err);
});

io.on('connection', (socket) => {
    socket.on('join', (documentId) => {
        socket.join(documentId);
        console.log('hello');
    });
    console.log('connected ' + socket.id);
});


server.listen(PORT, '0.0.0.0', (req, res) => {
    console.log(`Server is listening on port ${PORT}`);
});