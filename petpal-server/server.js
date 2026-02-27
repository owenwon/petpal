const express = require('express');
const fs = require('fs');
const app = express();

// parse incoming JSON payloads from the iOS app
app.use(express.json()); 

const DB_FILE = './database.json';

// helper functions to read and write to the JSON file
const readDB = () => JSON.parse(fs.readFileSync(DB_FILE, 'utf8'));
const writeDB = (data) => fs.writeFileSync(DB_FILE, JSON.stringify(data, null, 2));

// load data
app.get('/db', (req, res) => {
    res.json(readDB());
});

// create a new job
app.post('/jobs', (req, res) => {
    const db = readDB();
    const newJob = {
        id: 'job_' + Date.now(), // creates a unique ID based on the current timestamp
        owner_id: req.body.owner_id,
        pet_details: req.body.pet_details,
        status: 'open',
        applicants: [],
        approved_sitter_id: null
    };
    
    db.jobs.push(newJob);
    writeDB(db); 
    res.status(201).json(newJob); 
});

// apply for a job
app.put('/jobs/:id/apply', (req, res) => {
    const db = readDB();
    const job = db.jobs.find(j => j.id === req.params.id);
    
    if (!job) {
        return res.status(404).send('Job not found');
    }

    const sitterId = req.body.sitter_id;

    // don't let the owner apply for their own job
    if (job.owner_id === sitterId) {
        return res.status(400).send('You cannot apply for your own job.');
    }

    // prevent the same user from applying twice
    if (job.applicants.includes(sitterId)) {
        return res.status(400).send('You have already applied for this job.');
    }

    // if they pass the checks, add them to the applicants list
    job.applicants.push(sitterId);
    job.status = 'pending_approval'; 
    writeDB(db);
    res.json(job);
});

// approve a sitter
app.put('/jobs/:id/approve', (req, res) => {
    const db = readDB();
    const job = db.jobs.find(j => j.id === req.params.id);
    
    if (!job) {
        return res.status(404).send('Job not found');
    }

    // is the person tapping 'Approve' the actual owner of the job?
    if (job.owner_id !== req.body.current_user_id) {
        return res.status(403).send('Only the job owner can approve sitters.');
    }

    // update the job to lock in the match
    job.approved_sitter_id = req.body.sitter_id;
    job.status = 'matched';
    writeDB(db);
    res.json(job);
});

// start server
app.listen(3000, () => console.log('Pet Sitter backend running on port 3000!'));