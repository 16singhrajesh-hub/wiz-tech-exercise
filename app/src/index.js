const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const { MongoClient } = require('mongodb');

const app = express();
const PORT = process.env.PORT || 3000;

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/tododb';
let db;
let todosCollection;

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));


MongoClient.connect(MONGODB_URI, { useNewUrlParser: true, useUnifiedTopology: true })
    .then(client => {
        console.log('Connected to MongoDB');
        db = client.db('tododb');
        todosCollection = db.collection('todos');
    })
    .catch(error => {
        console.error('Error connecting to MongoDB:', error);
        process.exit(1);
    });

    app.get('/', (req, res) => {
        res.json({ message: 'Hello, World!', endpoints: { health: '/health', todos: '/todos' , wizexercise: '/wizexercise'} });
    });


    app.get('/wizexercise', (req, res) => {
        const fs = require('fs');
        try {
            const content = fs.readFileSync('wizexercise.txt', 'utf-8');
            res.send(`<pre>${content}</pre>`);
        } catch (error) {
            console.error('Error reading wizexercise file:', error);
            res.status(500).json({ error: 'Internal Server Error' });
        }
    });

    app.get('/api/todos', async (req, res) => {
        try {
            const todos = await todosCollection.find().toArray();
            res.json(todos);
        } catch (error) {
            console.error('Error fetching todos:', error);
            res.status(500).json({ error: 'Internal Server Error' });
        }
    });

    app.get('/api/todos/:id', async (req, res) => {
        const id = req.params.id;
        try {
            const todo = await todosCollection.findOne({ _id: require('mongodb').ObjectId(id) });  
            if (!todo) {
                res.status(404).json({ error: 'Todo not found' });
            } 
            res.json(todo);
        } catch (error) {
            console.error('Error fetching todo:', error);
            res.status(500).json({ error: 'Internal Server Error' });
        }
    });

    app.post('/api/todos', async (req, res) => {
       
        try {
             const { title, description } = req.body;
             if (!title) {
                return res.status(400).json({ error: 'Title is required' });
            }
            const todo = { title,
                completed: completed ||false,
                createdAt: new Date(),
                updatedAt: new Date()
             };
            const result = await todosCollection.insertOne({ todo });
            todo._id = result.insertedId;
            res.status(201).json({ todo });
        } catch (error) {
            console.error('Error creating todo:', error);
            res.status(500).json({ error: 'Internal Server Error' });
        }
    });

    app.put('/api/todos/:id', async (req, res) => {
       
        
        try {
            const { title, completed } = req.body;
            const update = {
                updatedAt: new Date()
            }

            if(title !== undefined) update.title = title;
            if(completed !== undefined) update.completed = completed;

             const result = await todosCollection.findOneAndUpdate(
                { _id: require('mongodb').ObjectId(id) },
                { $set: update },
                { returnDocument: 'after' }
            );
            if (!result.value) {
                return res.status(404).json({ error: 'Todo not found' });
            }
            res.json(result.value);
        } catch (error) {
            console.error('Error updating todo:', error);
            res.status(500).json({ error: 'Internal Server Error' });
        }


           
    });

    app.delete('api/todos/:id', async (req, res) => {
        const id = req.params.id;
        try {
            const result = await todosCollection.deleteOne({ _id: require('mongodb').ObjectId(id) });
            if (result.deletedCount === 0) {
                return res.status(404).json({ error: 'Todo not found' });
            }
            res.json({ message: 'Todo deleted successfully' });
        } catch (error) {
            console.error('Error deleting todo:', error);
            res.status(500).json({ error: 'Internal Server Error' });
        }
    });

    app.listen(PORT, () => {
        console.log(`Server is running on port ${PORT}`);
        console.log(`MongoDB URI: $MONGODB_URI.replace(/:[^:]*@/, '****@')}`);
    });