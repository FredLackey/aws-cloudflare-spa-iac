const express = require('express');
const packageInfo = require('./package.json');

const app = express();

// CORS middleware for development - allows all origins
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  
  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    res.sendStatus(200);
  } else {
    next();
  }
});

// Basic JSON parsing
app.use(express.json());

// Health check endpoint
app.get('/', (req, res) => {
  res.json({
    name: packageInfo.name,
    version: packageInfo.version,
    description: packageInfo.description,
    timestamp: new Date().toISOString()
  });
});

// Status endpoint (alias for health check)
app.get('/status', (req, res) => {
  res.json({
    name: packageInfo.name,
    version: packageInfo.version,
    description: packageInfo.description,
    status: 'healthy',
    timestamp: new Date().toISOString()
  });
});

// Echo endpoint
app.post('/echo', (req, res) => {
  res.json({
    date: new Date().toISOString(),
    payload: req.body || {}
  });
});

// Function endpoints
app.post('/functions/do-it', (req, res) => {
  res.json({ status: 'done' });
});

app.get('/functions/get-it', (req, res) => {
  res.json({ status: 'fiz buz' });
});

// Start server only if this file is run directly
if (require.main === module) {
  const PORT = process.env.PORT || 3000;
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`API endpoints available at: http://localhost:${PORT}`);
  });
}

module.exports = app;