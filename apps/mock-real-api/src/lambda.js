const serverlessExpress = require('@codegenie/serverless-express');
const app = require('./app');

// Cache the serverless wrapper
let cachedHandler;

exports.handler = async (event, context) => {
  try {
    if (!cachedHandler) {
      cachedHandler = serverlessExpress({ 
        app,
        logLevel: 'error'
      });
    }
    
    // Strip /api prefix from CloudFront requests - CRITICAL: Must modify rawPath for serverless-express
    if (event.rawPath && event.rawPath.startsWith('/api')) {
      event.rawPath = event.rawPath.replace('/api', '') || '/';
    }
    
    // Strip /api prefix from event.path if it exists
    if (event.path && event.path.startsWith('/api')) {
      event.path = event.path.replace('/api', '') || '/';
    }
    
    // Also handle requestContext.http.path for API Gateway v2 format
    if (event.requestContext?.http?.path && event.requestContext.http.path.startsWith('/api')) {
      event.requestContext.http.path = event.requestContext.http.path.replace('/api', '') || '/';
    }
    
    return cachedHandler(event, context);
  } catch (error) {
    console.error('Lambda handler error:', error);
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({ 
        error: 'Internal Server Error',
        message: error.message 
      })
    };
  }
};