#!/bin/bash

# Skin Secrets Fly.io Deployment Script
# Usage: ./deploy.sh [app-name]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default app name
APP_NAME=${1:-"skin-secrets"}

echo -e "${BLUE}🚀 Deploying Skin Secrets to Fly.io${NC}"
echo -e "${BLUE}App name: ${APP_NAME}${NC}"
echo

# Check if fly CLI is installed
if ! command -v fly &> /dev/null; then
    echo -e "${RED}❌ Fly CLI is not installed. Please install it first:${NC}"
    echo "https://fly.io/docs/hands-on/install-flyctl/"
    exit 1
fi

# Check if user is logged in
if ! fly auth whoami &> /dev/null; then
    echo -e "${YELLOW}⚠️  You are not logged in to Fly.io${NC}"
    echo "Please run: fly auth login"
    exit 1
fi

echo -e "${GREEN}✅ Fly CLI is installed and you are logged in${NC}"

# Check if app exists
if ! fly apps list | grep -q "$APP_NAME"; then
    echo -e "${YELLOW}⚠️  App '$APP_NAME' does not exist. Creating it...${NC}"
    fly apps create "$APP_NAME"
    echo -e "${GREEN}✅ App '$APP_NAME' created${NC}"
else
    echo -e "${GREEN}✅ App '$APP_NAME' exists${NC}"
fi

# Check if volume exists
if ! fly volumes list --app "$APP_NAME" | grep -q "skin_secrets_data"; then
    echo -e "${YELLOW}⚠️  Volume 'skin_secrets_data' does not exist. Creating it...${NC}"
    fly volumes create skin_secrets_data --size 10 --region iad --app "$APP_NAME"
    echo -e "${GREEN}✅ Volume 'skin_secrets_data' created${NC}"
else
    echo -e "${GREEN}✅ Volume 'skin_secrets_data' exists${NC}"
fi

echo
echo -e "${BLUE}📋 Required secrets:${NC}"
echo "You may need to set the following secrets:"
echo "  - RAILS_MASTER_KEY (from config/master.key)"
echo "  - FACEBOOK_PAGE_ACCESS_TOKEN (if using Facebook integration)"
echo "  - FACEBOOK_PAGE_ID (if using Facebook integration)"
echo
echo "To set secrets, run:"
echo "  fly secrets set RAILS_MASTER_KEY=your_key_here --app $APP_NAME"
echo "  fly secrets set FACEBOOK_PAGE_ACCESS_TOKEN=your_token_here --app $APP_NAME"
echo "  fly secrets set FACEBOOK_PAGE_ID=your_page_id_here --app $APP_NAME"
echo

read -p "Do you want to continue with deployment? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Deployment cancelled${NC}"
    exit 0
fi

echo
echo -e "${BLUE}🚀 Deploying to Fly.io...${NC}"

# Deploy the application
if fly deploy --app "$APP_NAME"; then
    echo -e "${GREEN}✅ Deployment successful!${NC}"
    echo
    echo -e "${BLUE}📊 Checking app status...${NC}"
    fly status --app "$APP_NAME"
    echo
    echo -e "${GREEN}🌐 Your app should be available at:${NC}"
    echo "https://$APP_NAME.fly.dev"
    echo
    echo -e "${BLUE}📝 Useful commands:${NC}"
    echo "  fly logs --app $APP_NAME          # View logs"
    echo "  fly open --app $APP_NAME          # Open in browser"
    echo "  fly ssh console --app $APP_NAME   # SSH into app"
    echo "  fly status --app $APP_NAME        # Check status"
else
    echo -e "${RED}❌ Deployment failed${NC}"
    echo "Check the logs above for more information."
    exit 1
fi 