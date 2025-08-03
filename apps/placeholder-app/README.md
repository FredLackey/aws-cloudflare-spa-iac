# Placeholder App

A simple React 19 + Vite frontend application for validating AWS infrastructure deployment.

**Runtime**: React 19 with Vite build tool

## Overview

This is a minimal placeholder frontend that:
- Tests backend API connectivity via automated health checks
- Shows a simple dialogue-style interface
- Displays API response payload for validation

## Local Development

### Setup and Run
```bash
cd apps/placeholder-app
npm install
npm run dev
```

Frontend available at: http://localhost:5173

**Local API Target**: `http://localhost:3000` (make sure placeholder-api is running)

## Building for Deployment

### Production Build
```bash
npm run build
```

This creates a `dist/` folder with optimized assets.

### Build with Production API Configuration

The build automatically configures the correct API endpoint:
- **Local development**: `http://localhost:3000`
- **Production deployment**: Uses CloudFront routing to `/api`

### Build Verification

Check that your build is ready:

```bash
# Verify build output
ls -la dist/
# Expected: index.html, assets/, vite.svg

# Check file sizes
du -h dist/assets/*
# Expected: CSS ~2KB, JS ~180-200KB
```

### Handoff to iac-env-hosting

The `iac-env-hosting` package expects:
- **Build location**: `apps/placeholder-app/dist/`
- **Required files**: `index.html`, `assets/` folder, static assets
- **Build status**: Complete and current

## Dependencies

- **react**: UI framework (v19)
- **react-dom**: React DOM bindings
- **vite**: Build tool and dev server
- **@vitejs/plugin-react**: React plugin for Vite

## Environment Configuration

The app automatically detects API endpoints:
- **Development**: `http://localhost:3000`
- **Production**: CloudFront routing to `/api`

Optional override with `.env.local`:
```env
VITE_API_URL=http://localhost:3000
```