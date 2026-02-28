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

// UserSchema
const userSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  password: { type: String, required: true }, 
  role: { type: String, enum: ['owner', 'sitter'], required: true },
  contactInfo: String,
  bio: String
});

// RequestSchema
const requestSchema = new mongoose.Schema({
  ownerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  ownerName: String, 
  title: String,
  petName: String,
  description: String,
  dates: String,
  status: { type: String, default: 'open' } // 'open' or 'closed'
});

// ApplicationSchema
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