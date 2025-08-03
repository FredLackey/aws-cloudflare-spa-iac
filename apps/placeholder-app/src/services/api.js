// Simple validation utilities
const isObject = (value) => value !== null && typeof value === 'object' && !Array.isArray(value)

// API URL configuration
const getApiBaseUrl = () => {
  // Use environment variable if set
  if (import.meta.env.VITE_API_URL) {
    return import.meta.env.VITE_API_URL
  }
  
  // Development: localhost
  if (import.meta.env.DEV || window.location.hostname === 'localhost') {
    return 'http://localhost:3000'
  }
  
  // Production: use CloudFront routing to /api
  return window.location.origin + '/api'
}

const API_BASE_URL = getApiBaseUrl()

/**
 * Makes an HTTP request to the API
 * @param {string} endpoint - API endpoint path
 * @param {Object} options - Fetch options
 * @returns {Promise<Object>} API response
 */
async function apiRequest(endpoint, options = {}) {
  const url = `${API_BASE_URL}${endpoint}`
  
  const defaultOptions = {
    headers: {
      'Content-Type': 'application/json',
      ...options.headers
    }
  }

  const requestOptions = { ...defaultOptions, ...options }

  try {
    const response = await fetch(url, requestOptions)
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }

    const data = await response.json()
    return { success: true, data }
  } catch (error) {
    return { 
      success: false, 
      error: error.message || 'Network error occurred'
    }
  }
}

/**
 * Checks API health status
 * @returns {Promise<Object>} Health check response
 */
export async function checkHealth() {
  return apiRequest('/status')
}

/**
 * Tests echo endpoint with payload
 * @param {Object} payload - Data to echo back
 * @returns {Promise<Object>} Echo response
 */
export async function testEcho(payload) {
  if (!isObject(payload)) {
    return { 
      success: false, 
      error: 'Payload must be a valid object' 
    }
  }

  return apiRequest('/echo', {
    method: 'POST',
    body: JSON.stringify(payload)
  })
}

/**
 * Tests the do-it function endpoint
 * @returns {Promise<Object>} Function response
 */
export async function testDoIt() {
  return apiRequest('/functions/do-it', { method: 'POST' })
}

/**
 * Tests the get-it function endpoint
 * @returns {Promise<Object>} Function response
 */
export async function testGetIt() {
  return apiRequest('/functions/get-it')
}

/**
 * Makes a custom API request
 * @param {string} method - HTTP method
 * @param {string} endpoint - API endpoint
 * @param {Object} body - Request body
 * @returns {Promise<Object>} API response
 */
export async function customRequest(method, endpoint, body = null) {
  const options = { method }
  
  if (body && (method === 'POST' || method === 'PUT' || method === 'PATCH')) {
    options.body = JSON.stringify(body)
  }

  return apiRequest(endpoint, options)
}