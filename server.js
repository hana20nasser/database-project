const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const authRoutes = require('./routes/authRoutes');
const patientRoutes = require('./routes/patientRoutes');
const requestRoutes = require('./routes/requestRoutes');
const examRoutes = require('./routes/examRoutes');
const roomRoutes = require('./routes/roomRoutes');
const reportRoutes = require('./routes/reportRoutes');

const app = express();
const PORT = process.env.PORT || 5000;

// Enable CORS
app.use(cors({
  origin: '*', // Allows convenient cross-port requests for React Vite in development
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Body Parsers
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve Uploaded Images Statically
// This enables <img src="http://localhost:5000/uploads/filename.jpg" /> in the frontend
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Register API Routes
app.use('/api/auth', authRoutes);
app.use('/api/patients', patientRoutes);
app.use('/api/requests', requestRoutes);
app.use('/api/exams', examRoutes);
app.use('/api/rooms', roomRoutes);
app.use('/api/reports', reportRoutes);

// Root Endpoint (For quick server status checks)
app.get('/', (req, res) => {
  res.status(200).json({
    message: 'Welcome to the Radiology Management System (RMS) API Service',
    status: 'online',
    timestamp: new Date()
  });
});

// Centralized Error Handling Middleware
app.use((err, req, res, next) => {
  console.error('Centralized Error Handler caught an error:');
  console.error(err.stack || err.message || err);

  const statusCode = err.status || 500;
  const errorMessage = err.message || 'An unexpected internal server error occurred.';

  res.status(statusCode).json({
    status: 'error',
    statusCode,
    message: errorMessage,
    // Avoid leaking stack traces in production environment
    stack: process.env.NODE_ENV === 'production' ? null : err.stack
  });
});

// Start Server
app.listen(PORT, () => {
  console.log(`\n=========================================`);
  console.log(`RMS Server successfully initialized!`);
  console.log(`Running in environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`Listening on http://localhost:${PORT}`);
  console.log(`=========================================\n`);
});
