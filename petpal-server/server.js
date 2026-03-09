import express from 'express';
import models from './models.js';

// pull specific model constructors for convenience
const { User, Request, Application } = models;

const app = express();
app.use(express.json()); 

// AUTH Endpoints
// We will pre-populate 2 users, during demo when one of the button is clicked, This endpoint
// will be hit with hard coded input of 1 of 2 existing users and their info will be returned 
app.post('/login', async (req, res) => {
    const { username, password } = req.body;
    try {
        let user = await User.findOne({ username });
        
        if (user) {
            // What happens during the demo: 
            // It finds the pre-populated user we made in Postman
            if (user.password === password) {
                return res.status(200).json(user);
            } else {
                return res.status(401).json({ error: "Invalid password" });
            }
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
        const { requestId, sitterId, sitterName } = req.body;

        // Prevent duplicate applications
        const existing = await Application.findOne({ requestId, sitterId });
        if (existing) {
            return res.status(400).json({ error: "Already applied for this job" });
        }
        
        // Find the OG request to grab owner details for the sitter's view and for the "Contact Reveal" if approved
        const parentRequest = await Request.findById(requestId);
        if (!parentRequest) {
            return res.status(404).json({ error: "Request not found" });
        }

        const newApp = new Application({
            requestId,
            sitterId,
            sitterName,
            requestTitle: parentRequest.title, // Saved so sitter sees job name in "Apps"
            ownerId: parentRequest.ownerId,    // Saved for the "Contact Reveal" -- Need this fetch Owner's info
            ownerName: parentRequest.ownerName // Saved for display
        });

        await newApp.save();
        res.status(201).json(newApp);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// 2. Owner views applicants for a specific request
// I.e., When an owner clicks their own post to see applications 
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
        
        // If approved, mark the job as 'closed' so it hard filters from the public feed
        if (req.body.status === 'approved') {
            await Request.findByIdAndUpdate(updatedApp.requestId, { status: 'closed' });
        }
        
        res.json(updatedApp);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// 4. "My Account > Apps"
// Allows a user to see the status of all jobs they've applied for
app.get('/applications/sitter/:sitterId', async (req, res) => {
    try {
        const myApps = await Application.find({ sitterId: req.params.sitterId }).sort({ _id: -1 });
        res.json(myApps);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.listen(3000, () => console.log('Pet Sitter backend running on port 3000!'));