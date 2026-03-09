import mongoose from 'mongoose';
import dotenv from 'dotenv';
dotenv.config();

const connectionString = process.env.MONGODB_URI;
if (!connectionString) {
  throw new Error('MONGODB_URI is not defined in environment variables');
}

const models = {};

mongoose.connect(connectionString)
  .then(() => console.log('Connected to MongoDB!'))
  .catch(err => console.error('Connection error', err));

// UserSchema (the profile)
const userSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  password: { type: String, required: true }, 
  headline: String,   // E.g., Owner "Needs a patient walker for energetic huskry", Sitter "Experienced dog lover available for weekend sitting"
  location: String,      
  bio: String,
  contactInfo: String,
}, { timestamps: true });

// RequestSchema (the job post)
const requestSchema = new mongoose.Schema({
  ownerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  ownerName: String, 
  title: String,    // e.g. "Need a sitter for my dog"... "weekend sitting for Luna"
  petName: String,
  description: String,
  price: Number,      
  dates: String,  
  status: { type: String, default: 'open' } // 'open' or 'closed'
}, { timestamps: true });

// ApplicationSchema (the sitter's application to a request)
const applicationSchema = new mongoose.Schema({
  requestId: { type: mongoose.Schema.Types.ObjectId, ref: 'Request', required: true },

  // newly added fields for the contact info user story; provided for sitter 
  requestTitle: String, // "Weekend sitting for Luna"
  ownerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }, // Need this to reveal contact info later for sitter 
  ownerName: String,    // for easy display in the "Apps" list

  sitterId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  sitterName: String,
  status: { type: String, default: 'pending' } // 'pending', 'approved', 'rejected'
}, { timestamps: true });

models.User = mongoose.model('User', userSchema);
models.Request = mongoose.model('Request', requestSchema);
models.Application = mongoose.model('Application', applicationSchema);

export default models;