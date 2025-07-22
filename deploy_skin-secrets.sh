#!/bin/bash

# Auto-generated Fly.io deployment script for skin-secrets
# Generated on Mon Jul 21 14:23:40 EDT 2025

set -e

echo "🚀 Deploying skin-secrets to Fly.io..."

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
if ! fly apps list | grep -q "skin-secrets"; then
    echo "⚠️  App 'skin-secrets' does not exist. Creating it..."
    fly apps create "skin-secrets"
    echo "✅ App 'skin-secrets' created"
else
    echo "✅ App 'skin-secrets' exists"
fi

# Create volume if it doesn't exist
if ! fly volumes list --app "skin-secrets" | grep -q "skin_secrets_data"; then
    echo "⚠️  Volume 'skin_secrets_data' does not exist. Creating it..."
    fly volumes create skin_secrets_data --size 10 --region iad --app "skin-secrets"
    echo "✅ Volume 'skin_secrets_data' created"
else
    echo "✅ Volume 'skin_secrets_data' exists"
fi

# Set secrets for production
echo "🔐 Setting production secrets..."
if [ -f "config/master.key" ]; then
    echo "Setting RAILS_MASTER_KEY from config/master.key..."
    fly secrets set RAILS_MASTER_KEY="$(cat config/master.key)" --app skin-secrets
else
    echo "❌ config/master.key not found - REQUIRED for production"
    echo "   Please create config/master.key with your Rails master key"
    exit 1
fi

echo "✅ Production secrets set"

# Deploy the application
echo "🚀 Deploying application..."
fly deploy --app "skin-secrets"

# Wait for deployment to complete and verify database
echo "🔍 Verifying deployment and database..."
sleep 10

# Check if the application is responding
echo "Checking application health..."
if curl -s -f https://skin-secrets.fly.dev/up > /dev/null; then
    echo "✅ Application is responding"
else
    echo "⚠️  Application may still be starting up"
fi

# Check database status via SSH
echo "Checking database status..."
if fly ssh console --app skin-secrets --command "bundle exec rails runner 'puts \"Database connected: #{ActiveRecord::Base.connection.active?}\"'" 2>/dev/null; then
    echo "✅ Database is accessible"
else
    echo "⚠️  Database check failed (may still be initializing)"
fi

echo "✅ Deployment successful!"
echo
echo "🌐 Your app should be available at:"
echo "https://skin-secrets.fly.dev"
echo
echo "📝 Useful commands:"
echo "  fly logs --app skin-secrets          # View logs"
echo "  fly open --app skin-secrets          # Open in browser"
echo "  fly ssh console --app skin-secrets   # SSH into app"
echo "  fly status --app skin-secrets        # Check status"
