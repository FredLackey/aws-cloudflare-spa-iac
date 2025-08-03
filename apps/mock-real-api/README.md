# Mock Real API

A simple Express.js API for proof of concept deployment that works both locally and on AWS Lambda.

**Runtime**: Node.js 20.x

## Overview

This is a minimal mock-real API designed to demonstrate:
- Local development with Express.js
- AWS Lambda deployment with serverless-express
- Basic API endpoints for testing

## API Endpoints

### GET / (Local) | GET /api (Deployed)
Health check endpoint returning package information and timestamp.

### POST /echo (Local) | POST /api/echo (Deployed)  
Echo service that returns the request payload with timestamp.

### POST /functions/do-it (Local) | POST /api/functions/do-it (Deployed)
Returns `{"status": "done"}`.

### GET /functions/get-it (Local) | GET /api/functions/get-it (Deployed)
Returns `{"status": "fiz buz"}`.

## Quick Start

### Local Development
```bash
cd apps/mock-real-api
npm install
npm run dev
```

API available at: http://localhost:3000

### Lambda Deployment
```bash
npm run package:lambda
```

This creates `lambda-deployment.zip` ready for AWS Lambda deployment.

## Dependencies

- **express**: Web framework
- **@vendia/serverless-express**: AWS Lambda adapter

## Project Structure

```
apps/mock-real-api/
├── src/
│   ├── app.js              # Express application
│   └── lambda.js           # Lambda handler
├── package.json            # Dependencies and scripts
├── package-lambda.json     # Lambda-only dependencies
└── .lambdaignore          # Lambda deployment exclusions
```

## Integration

This API is designed to work with:
- **iac-env-hosting**: Complete hosting environment (Lambda, S3, CloudFront)
- **iac-cert-dns**: SSL certificate management  
- **iac-app-lambda**: Individual Lambda function deployment
- **iac-app-cloudfront**: Individual CDN configuration

**Note**: The `iac-env-hosting` package provides a complete deployment solution that includes both Lambda and CloudFront configuration, making it the primary integration point for full environment deployments.