#!/bin/bash

# Setup Fly.io deployment with all secrets and commands
# Usage: ./scripts/setup_fly_deployment.sh [app-name]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default app name
APP_NAME=${1:-"skin-secrets"}

echo -e "${BLUE}🚀 Setting up Fly.io deployment for: ${APP_NAME}${NC}"
echo "=" * 60

# Check if we're in a Rails app
if [ ! -f "config/environment.rb" ]; then
    echo -e "${RED}❌ Not in a Rails application directory${NC}"
    exit 1
fi

# Generate secrets commands
echo -e "${BLUE}📋 Generating secrets commands...${NC}"
SECRETS_OUTPUT=$(rbenv exec bundle exec ruby scripts/generate_fly_secrets.rb "$APP_NAME")

# Extract the single command with all secrets
ALL_SECRETS_CMD=$(echo "$SECRETS_OUTPUT" | grep "fly secrets set.*--app $APP_NAME" | tail -1)

# Get Rails master key
RAILS_MASTER_KEY=$(cat config/master.key)

# Create deployment script
DEPLOY_SCRIPT="deploy_${APP_NAME}.sh"

cat > "$DEPLOY_SCRIPT" << EOF
#!/bin/bash

# Auto-generated Fly.io deployment script for ${APP_NAME}
# Generated on $(date)

set -e

echo "🚀 Deploying ${APP_NAME} to Fly.io..."

# Check if fly CLI is installed
if ! command -v fly &> /dev/null; then
    echo "❌ Fly CLI is not installed. Please install it first:"
    echo "https://fly.io/docs/hands-on/install-flyctl/"
    exit 1
fi

# Check if user is logged in
if ! fly auth whoami &> /dev/null; then
    echo "⚠️  You are not logged in to Fly.io"
    echo "Please run: fly auth login"
    exit 1
fi

echo "✅ Fly CLI is installed and you are logged in"

# Create app if it doesn't exist
if ! fly apps list | grep -q "$APP_NAME"; then
    echo "⚠️  App '$APP_NAME' does not exist. Creating it..."
    fly apps create "$APP_NAME"
    echo "✅ App '$APP_NAME' created"
else
    echo "✅ App '$APP_NAME' exists"
fi

# Create volume if it doesn't exist
if ! fly volumes list --app "$APP_NAME" | grep -q "skin_secrets_data"; then
    echo "⚠️  Volume 'skin_secrets_data' does not exist. Creating it..."
    fly volumes create skin_secrets_data --size 10 --region iad --app "$APP_NAME"
    echo "✅ Volume 'skin_secrets_data' created"
else
    echo "✅ Volume 'skin_secrets_data' exists"
fi

# Set all secrets
echo "🔐 Setting secrets..."
${ALL_SECRETS_CMD}
fly secrets set RAILS_MASTER_KEY="${RAILS_MASTER_KEY}" --app "$APP_NAME"

echo "✅ All secrets set"

# Deploy the application
echo "🚀 Deploying application..."
fly deploy --app "$APP_NAME"

echo "✅ Deployment successful!"
echo
echo "🌐 Your app should be available at:"
echo "https://${APP_NAME}.fly.dev"
echo
echo "📝 Useful commands:"
echo "  fly logs --app $APP_NAME          # View logs"
echo "  fly open --app $APP_NAME          # Open in browser"
echo "  fly ssh console --app $APP_NAME   # SSH into app"
echo "  fly status --app $APP_NAME        # Check status"
EOF

chmod +x "$DEPLOY_SCRIPT"

echo -e "${GREEN}✅ Generated deployment script: ${DEPLOY_SCRIPT}${NC}"
echo
echo -e "${BLUE}📋 Secrets that will be set:${NC}"
echo "$SECRETS_OUTPUT" | grep "fly secrets set" | head -4
echo "... and RAILS_MASTER_KEY"
echo
echo -e "${BLUE}🚀 To deploy, run:${NC}"
echo "./$DEPLOY_SCRIPT"
echo
echo -e "${BLUE}💡 Or run commands manually:${NC}"
echo "1. Create app: fly apps create $APP_NAME"
echo "2. Create volume: fly volumes create skin_secrets_data --size 10 --region iad --app $APP_NAME"
echo "3. Set secrets: (see commands above)"
echo "4. Deploy: fly deploy --app $APP_NAME"
echo "5. Open: fly open --app $APP_NAME" 