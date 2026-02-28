import express from 'express';
import models from './models.js';

// pull specific model constructors for convenience
const { User, Request, Application } = models;

const app = express();
app.use(express.json()); 

// AUTH Endpoints
// iOS will POST: { "username": "...", "password": "...", "role": "owner" }
app.post('/login', async (req, res) => {
    const { username, password, role } = req.body;
    try {
        let user = await models.User.findOne({ username });
        
        if (user) {
            if (user.password === password) {
                return res.status(200).json(user);
            } else {
                return res.status(401).json({ error: "Invalid password" });
            }
        } else {
            // Auto-register if user doesn't exist
            const newUser = new User({ username, password, role, contactInfo: "Not set", bio: "" });
            await newUser.save();
            return res.status(201).json(newUser);
        }
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Fetch a specific user profile (to see contact info/bio)
app.get('/users/:id', async (req, res) => {
    try {
        const user = await models.User.findById(req.params.id);
        res.json(user);
    } catch (err) {
        res.status(404).json({ error: "User not found" });
    }
});


// REQUEST Endpoints
// 1. Post a new Sitting Request (Owner Side)
// iOS will POST: { "ownerId": "...", "ownerName": "...", "title": "...", "petName": "...", "description": "...", "dates": "..." }
app.post('/requests', async (req, res) => {
    try {
        const newRequest = new Request(req.body);
        await newRequest.save();
        res.status(201).json(newRequest);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// 2. Fetch all OPEN requests (Sitter Side Feed)
// This populates the "Sitter Feed" TableView in iOS
app.get('/requests', async (req, res) => {
    try {
        // We only want requests that haven't been finalized yet
        const openRequests = await Request.find({ status: 'open' }).sort({ _id: -1 });
        res.json(openRequests);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 3. Fetch requests created by a specific owner (Owner Dashboard)
app.get('/requests/owner/:ownerId', async (req, res) => {
    try {
        const myRequests = await Request.find({ ownerId: req.params.ownerId }).sort({ _id: -1 });
        res.json(myRequests);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});


// APPLICATION Endpoints
// 1. Sitter applies for a job
// iOS will POST: { "requestId": "...", "sitterId": "...", "sitterName": "..." }
app.post('/applications', async (req, res) => {
    try {
        // Prevent duplicate applications
        const existing = await Application.findOne({ 
            requestId: req.body.requestId, 
            sitterId: req.body.sitterId 
        });
        
        if (existing) {
            return res.status(400).json({ error: "Already applied for this job" });
        }

        const newApp = new Application(req.body);
        await newApp.save();
        res.status(201).json(newApp);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// 2. Owner views applicants for a specific request
// Used for the "Applicant List" screen
app.get('/requests/:requestId/applicants', async (req, res) => {
    try {
        const applicants = await Application.find({ requestId: req.params.requestId });
        res.json(applicants);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 3. Owner approves a specific application
// iOS will PATCH: { "status": "approved" }
app.patch('/applications/:id', async (req, res) => {
    try {
        const updatedApp = await Application.findByIdAndUpdate(
            req.params.id, 
            { status: req.body.status }, 
            { new: true }
        );
        
        // If approved, automatically close the Request
        if (req.body.status === 'approved') {
            await Request.findByIdAndUpdate(updatedApp.requestId, { status: 'closed' });
        }
        
        res.json(updatedApp);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

app.listen(3000, () => console.log('Pet Sitter backend running on port 3000!'));