import React, { useState, useEffect } from 'react'
import { checkHealth } from './services/api'

function App() {
  const [healthStatus, setHealthStatus] = useState('loading')
  const [healthData, setHealthData] = useState(null)
  const [error, setError] = useState(null)
  
  // Determine API endpoint for display
  const getApiEndpoint = () => {
    if (import.meta.env.VITE_API_URL) {
      return import.meta.env.VITE_API_URL
    }
    if (import.meta.env.DEV || window.location.hostname === 'localhost') {
      return 'http://localhost:3000'
    }
    return window.location.origin + '/api'
  }

  useEffect(() => {
    const performHealthCheck = async () => {
      // Wait 3 seconds before making the call
      setTimeout(async () => {
        const result = await checkHealth()
        
        if (result.success) {
          setHealthStatus('healthy')
          setHealthData(result.data)
        } else {
          setHealthStatus('unhealthy')
          setError(result.error)
        }
      }, 3000)
    }

    performHealthCheck()
  }, [])

  const getStatusDisplay = () => {
    switch (healthStatus) {
      case 'loading':
        return { text: 'Checking API connection...', color: '#fbbf24' }
      case 'healthy':
        return { text: 'API Connected', color: '#4ade80' }
      case 'unhealthy':
        return { text: 'API Disconnected', color: '#ef4444' }
      default:
        return { text: 'Unknown', color: '#6b7280' }
    }
  }

  const status = getStatusDisplay()

  return (
    <div className="app">
      <div className="dialogue">
        <h1>API Placeholder App</h1>
        <p>
          This is a simple frontend that validates the AWS infrastructure 
          by testing connectivity to the backend API.
        </p>

        <div className="health-section">
          <h2>API Health Check</h2>
          <p className="api-endpoint">
            Target: <code>{getApiEndpoint()}</code>
          </p>
          <div className="status-display">
            <div 
              className="status-indicator"
              style={{ backgroundColor: status.color }}
            ></div>
            <span>{status.text}</span>
          </div>

          {healthStatus === 'loading' && (
            <div className="loading-message">
              <p>Please wait while we check the API connection...</p>
            </div>
          )}

          {healthStatus === 'healthy' && healthData && (
            <div className="success-message">
              <p>✅ Successfully connected to the API</p>
              <pre className="api-response">
                {JSON.stringify(healthData, null, 2)}
              </pre>
            </div>
          )}

          {healthStatus === 'unhealthy' && (
            <div className="error-message">
              <p>❌ Failed to connect to the API</p>
              {error && <p className="error-text">{error}</p>}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

export default App