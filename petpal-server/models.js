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
  role: { type: String, enum: ['owner', 'sitter'], required: true },
  headline: String,   // E.g., Owner "Needs a patient walker for energetic huskry", Sitter "Experienced dog lover available for weekend sitting"
  location: String,      // E.g., "San Francisco, CA"
  bio: String,
  contactInfo: String,
  experience: String  // null for owners, 5 years for sitters for example
});

// RequestSchema (the job post)
const requestSchema = new mongoose.Schema({
  ownerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  ownerName: String, 
  title: String,    // e.g. "Need a sitter for my dog"... "weekend sitting for Luna"
  petName: String,
  breed: String,      
  age: Number,      
  weight: Number,    
  description: String,
  imageUrl: { type: String, default: "" },  // optional user story; field for pet image URL; 
  price: Number,      
  dates: String,
  status: { type: String, default: 'open' } // 'open' or 'closed'
});

// ApplicationSchema (the sitter's application to a request)
const applicationSchema = new mongoose.Schema({
  requestId: { type: mongoose.Schema.Types.ObjectId, ref: 'Request', required: true },
  sitterId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  sitterName: String,
  status: { type: String, default: 'pending' } // 'pending', 'approved', 'rejected'
});

models.User = mongoose.model('User', userSchema);
models.Request = mongoose.model('Request', requestSchema);
models.Application = mongoose.model('Application', applicationSchema);

export default models;