#!/bin/bash

# Generate Fly.io secrets commands from Rails credentials
# Usage: ./scripts/generate_fly_secrets.sh [app-name]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default app name
APP_NAME=${1:-"skin-secrets"}

echo -e "${BLUE}🔐 Generating Fly.io secrets commands for app: ${APP_NAME}${NC}"
echo "=" * 60

# Check if we're in a Rails app
if [ ! -f "config/environment.rb" ]; then
    echo -e "${RED}❌ Not in a Rails application directory${NC}"
    echo "Please run this script from your Rails app root directory"
    exit 1
fi

# Check if credentials exist
if [ ! -f "config/credentials.yml.enc" ]; then
    echo -e "${RED}❌ No credentials file found${NC}"
    echo "Please ensure you have config/credentials.yml.enc"
    exit 1
fi

if [ ! -f "config/master.key" ]; then
    echo -e "${RED}❌ No master key found${NC}"
    echo "Please ensure you have config/master.key"
    exit 1
fi

echo -e "${GREEN}✅ Rails app and credentials found${NC}"
echo

# Run the Ruby script
if ruby scripts/generate_fly_secrets.rb "$APP_NAME"; then
    echo
    echo -e "${GREEN}✅ Secrets commands generated successfully!${NC}"
    echo
    echo -e "${BLUE}💡 Next steps:${NC}"
    echo "1. Copy the commands above"
    echo "2. Run them in your terminal"
    echo "3. Deploy your app with: fly deploy --app $APP_NAME"
else
    echo -e "${RED}❌ Failed to generate secrets commands${NC}"
    exit 1
fi 