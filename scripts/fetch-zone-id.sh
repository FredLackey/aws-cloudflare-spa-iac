#!/bin/bash

# Fetch Cloudflare Zone ID for domains
# This script uses the Cloudflare API to retrieve the zone ID

# Copyright 2025, Fred Lackey (https://fredlackey.com)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
API_TOKEN=""
DOMAIN=""

# Display help message
show_help() {
    cat << EOF
🔍 Cloudflare Zone ID Fetcher

USAGE:
    $0 --key <api-token> --domain <domain-name> [--help]

OPTIONS:
    -k, --key <token>      Cloudflare API token (required)
    -d, --domain <domain>  Domain name to lookup (required)
    -h, --help             Show this help message

EXAMPLES:
    $0 --key your-api-token --domain yourdomain.com
    $0 -k your-api-token -d example.com
    $0 -k your-api-token -d subdomain.example.com

NOTES:
    • Get your API token from: https://dash.cloudflare.com/profile/api-tokens
    • API token needs Zone:Read permissions
    • Domain must be added to your Cloudflare account

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -k|--key)
                API_TOKEN="$2"
                shift 2
                ;;
            -d|--domain)
                DOMAIN="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Unknown option: $1${NC}"
                echo -e "${YELLOW}💡 Use --help for usage information${NC}"
                exit 1
                ;;
        esac
    done
}

# Validate required arguments
validate_args() {
    local missing_args=()
    
    if [ -z "$API_TOKEN" ]; then
        missing_args+=("API token")
    fi
    
    if [ -z "$DOMAIN" ]; then
        missing_args+=("domain name")
    fi
    
    if [ ${#missing_args[@]} -gt 0 ]; then
        echo -e "${RED}❌ Missing required arguments: ${missing_args[*]}${NC}"
        echo ""
        echo -e "${YELLOW}Required parameters:${NC}"
        echo -e "${YELLOW}  --key/-k    : Cloudflare API token${NC}"
        echo -e "${YELLOW}  --domain/-d : Domain name to lookup${NC}"
        echo ""
        echo -e "${YELLOW}💡 Use --help for complete usage information${NC}"
        exit 1
    fi
}

# Fetch zone ID from Cloudflare API
fetch_zone_id() {
    echo -e "${BLUE}🔍 Fetching Cloudflare Zone ID for ${DOMAIN}${NC}"
    echo "=================================================="
    echo -e "${BLUE}📡 Querying Cloudflare API for domain: ${DOMAIN}${NC}"

    # Make API request to get zone information
    RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}" \
        -H "Authorization: Bearer ${API_TOKEN}" \
        -H "Content-Type: application/json")

    # Check if curl was successful
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to connect to Cloudflare API${NC}"
        exit 1
    fi

    # Parse the response using jq (if available) or basic text processing
    if command -v jq >/dev/null 2>&1; then
        parse_with_jq
    else
        parse_with_basic_tools
    fi
}

# Parse JSON response using jq
parse_with_jq() {
    SUCCESS=$(echo "$RESPONSE" | jq -r '.success')
    
    if [ "$SUCCESS" = "true" ]; then
        ZONE_ID=$(echo "$RESPONSE" | jq -r '.result[0].id // empty')
        ZONE_NAME=$(echo "$RESPONSE" | jq -r '.result[0].name // empty')
        
        if [ -n "$ZONE_ID" ] && [ "$ZONE_ID" != "null" ]; then
            echo -e "${GREEN}✅ Zone found successfully!${NC}"
            echo -e "${GREEN}Zone Name: ${ZONE_NAME}${NC}"
            echo -e "${GREEN}Zone ID: ${ZONE_ID}${NC}"
            echo ""
            echo -e "${YELLOW}📋 Copy this Zone ID to your terraform.tfvars:${NC}"
            echo -e "${BLUE}cloudflare_zone_id = \"${ZONE_ID}\"${NC}"
        else
            echo -e "${RED}❌ Zone '${DOMAIN}' not found in your account${NC}"
            echo -e "${YELLOW}💡 Make sure the domain is added to your Cloudflare account${NC}"
            exit 1
        fi
    else
        ERROR_MSG=$(echo "$RESPONSE" | jq -r '.errors[0].message // "Unknown error"')
        echo -e "${RED}❌ API Error: ${ERROR_MSG}${NC}"
        echo -e "${YELLOW}💡 Check your API token permissions${NC}"
        exit 1
    fi
}

# Parse JSON response using basic tools (fallback)
parse_with_basic_tools() {
    echo -e "${YELLOW}⚠️  jq not found, using basic text parsing${NC}"
    
    if echo "$RESPONSE" | grep -q '"success":true'; then
        # Extract zone ID using grep and sed
        ZONE_ID=$(echo "$RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | sed 's/"id":"\([^"]*\)"/\1/')
        
        if [ -n "$ZONE_ID" ]; then
            echo -e "${GREEN}✅ Zone found successfully!${NC}"
            echo -e "${GREEN}Zone ID: ${ZONE_ID}${NC}"
            echo ""
            echo -e "${YELLOW}📋 Copy this Zone ID to your terraform.tfvars:${NC}"
            echo -e "${BLUE}cloudflare_zone_id = \"${ZONE_ID}\"${NC}"
        else
            echo -e "${RED}❌ Zone '${DOMAIN}' not found in your account${NC}"
            exit 1
        fi
    else
        echo -e "${RED}❌ API request failed${NC}"
        echo -e "${YELLOW}Response: ${RESPONSE}${NC}"
        exit 1
    fi
}

# Main function
main() {
    parse_args "$@"
    validate_args
    fetch_zone_id
    
    echo ""
    echo -e "${GREEN}🎉 Done! You can now use this Zone ID in your Terraform configuration.${NC}"
}

# Call main function with all arguments
main "$@"
