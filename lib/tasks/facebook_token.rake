namespace :facebook_token do
  desc "Convert short-lived token to long-lived token"
  task convert_to_long_lived: :environment do
    puts "🔄 Converting Facebook token to long-lived token..."

    # Get current token
    current_token = ENV["FACEBOOK_PAGE_ACCESS_TOKEN"] || Rails.application.credentials.facebook_page_access_token

    if current_token.blank?
      puts "❌ No Facebook token found. Please set FACEBOOK_PAGE_ACCESS_TOKEN first."
      exit 1
    end

    puts "📋 Current token: #{current_token[0..10]}..."

    # Facebook App credentials needed for token exchange
    app_id = ENV["FACEBOOK_APP_ID"] || Rails.application.credentials.facebook_app_id
    app_secret = ENV["FACEBOOK_APP_SECRET"] || Rails.application.credentials.facebook_app_secret

    if app_id.blank? || app_secret.blank?
      puts "❌ Facebook App ID and App Secret required for token conversion."
      puts "   Please set FACEBOOK_APP_ID and FACEBOOK_APP_SECRET environment variables"
      puts "   or add them to Rails credentials:"
      puts "   rails credentials:edit"
      puts "   Add:"
      puts "     facebook_app_id: your_app_id"
      puts "     facebook_app_secret: your_app_secret"
      exit 1
    end

    # Exchange token using Facebook Graph API
    require "net/http"
    require "json"

    uri = URI("https://graph.facebook.com/v18.0/oauth/access_token")
    params = {
      grant_type: "fb_exchange_token",
      client_id: app_id,
      client_secret: app_secret,
      fb_exchange_token: current_token
    }

    uri.query = URI.encode_www_form(params)

    begin
      response = Net::HTTP.get_response(uri)
      result = JSON.parse(response.body)

      if result["access_token"]
        new_token = result["access_token"]
        expires_in = result["expires_in"]

        puts "✅ Successfully converted to long-lived token!"
        puts "   New token: #{new_token[0..10]}..."
        puts "   Expires in: #{expires_in} seconds (#{(expires_in / 86400.0).round(1)} days)"

        # Update the token
        puts "🔄 Updating token on Fly.io..."
        system("fly secrets set FACEBOOK_PAGE_ACCESS_TOKEN='#{new_token}' --app skin-secrets")

        if $?.success?
          puts "✅ Token updated successfully!"
        else
          puts "❌ Failed to update token on Fly.io"
          puts "   Please manually update: fly secrets set FACEBOOK_PAGE_ACCESS_TOKEN='#{new_token}' --app skin-secrets"
        end
      else
        puts "❌ Failed to convert token: #{result['error']}"
        puts "   Message: #{result['error_description']}"
      end

    rescue => e
      puts "❌ Error converting token: #{e.message}"
    end
  end

  desc "Check token status and expiration"
  task check_status: :environment do
    puts "🔍 Checking Facebook token status..."

    token = ENV["FACEBOOK_PAGE_ACCESS_TOKEN"] || Rails.application.credentials.facebook_page_access_token

    if token.blank?
      puts "❌ No Facebook token found"
      exit 1
    end

    # Test the token by getting page info
    service = FacebookService.new
    result = service.get_page_info

    if result[:success]
      page_info = result[:page_info]
      puts "✅ Token is valid!"
      puts "   Page: #{page_info['name']}"
      puts "   Page ID: #{page_info['id']}"
      puts "   Category: #{page_info['category']}"

      # Try to get token info (if available)
      begin
        require "net/http"
        require "json"

        uri = URI("https://graph.facebook.com/debug_token")
        params = {
          input_token: token,
          access_token: token
        }

        uri.query = URI.encode_www_form(params)
        response = Net::HTTP.get_response(uri)
        debug_info = JSON.parse(response.body)

        if debug_info["data"]
          data = debug_info["data"]
          puts "   Token Type: #{data['type']}"
          puts "   App ID: #{data['app_id']}"
          puts "   Expires At: #{data['expires_at'] ? Time.at(data['expires_at']).strftime('%Y-%m-%d %H:%M:%S') : 'Never'}"
          puts "   Valid: #{data['is_valid']}"
          puts "   Permissions: #{data['scopes']&.join(', ')}"
        end
      rescue => e
        puts "   Could not get detailed token info: #{e.message}"
      end

    else
      puts "❌ Token is invalid or expired"
      puts "   Error: #{result[:error]}"
      puts "   Code: #{result[:code]}"
      puts "   Type: #{result[:type]}"
    end
  end

  desc "Refresh token using app credentials"
  task refresh: :environment do
    puts "🔄 Refreshing Facebook token..."

    app_id = ENV["FACEBOOK_APP_ID"] || Rails.application.credentials.facebook_app_id
    app_secret = ENV["FACEBOOK_APP_SECRET"] || Rails.application.credentials.facebook_app_secret

    if app_id.blank? || app_secret.blank?
      puts "❌ Facebook App ID and App Secret required for token refresh."
      puts "   Please set FACEBOOK_APP_ID and FACEBOOK_APP_SECRET"
      exit 1
    end

    # Get a new app access token
    require "net/http"
    require "json"

    uri = URI("https://graph.facebook.com/oauth/access_token")
    params = {
      client_id: app_id,
      client_secret: app_secret,
      grant_type: "client_credentials"
    }

    uri.query = URI.encode_www_form(params)

    begin
      response = Net::HTTP.get_response(uri)
      result = JSON.parse(response.body)

      if result["access_token"]
        new_token = result["access_token"]
        puts "✅ Generated new app access token!"
        puts "   New token: #{new_token[0..10]}..."

        # Update the token
        puts "🔄 Updating token on Fly.io..."
        system("fly secrets set FACEBOOK_PAGE_ACCESS_TOKEN='#{new_token}' --app skin-secrets")

        if $?.success?
          puts "✅ Token updated successfully!"
        else
          puts "❌ Failed to update token on Fly.io"
          puts "   Please manually update: fly secrets set FACEBOOK_APP_ACCESS_TOKEN='#{new_token}' --app skin-secrets"
        end
      else
        puts "❌ Failed to generate new token: #{result['error']}"
      end

    rescue => e
      puts "❌ Error refreshing token: #{e.message}"
    end
  end

  desc "Setup automatic token refresh (cron job)"
  task setup_auto_refresh: :environment do
    puts "🤖 Setting up automatic token refresh..."

    # Create a script for automatic refresh
    script_content = <<~SCRIPT
      #!/bin/bash
      # Facebook Token Auto-Refresh Script
      # Run this daily via cron: 0 2 * * * /path/to/refresh_facebook_token.sh

      cd /Users/allentaylor/src/skin_secrets

      # Check if token needs refresh
      echo "$(date): Checking Facebook token status..."

      # Run token check
      fly ssh console --app skin-secrets --command "bundle exec rails runner 'service = FacebookService.new; result = service.test_connection; puts result[:success]'" > /tmp/facebook_token_check.txt 2>&1

      if grep -q "false" /tmp/facebook_token_check.txt; then
        echo "$(date): Token appears to be expired, attempting refresh..."
      #{'  '}
        # Try to refresh token
        fly ssh console --app skin-secrets --command "bundle exec rails runner 'Rake::Task[\"facebook_token:refresh\"].invoke'" > /tmp/facebook_token_refresh.txt 2>&1
      #{'  '}
        if grep -q "Token updated successfully" /tmp/facebook_token_refresh.txt; then
          echo "$(date): Token refreshed successfully"
        else
          echo "$(date): Token refresh failed - manual intervention required"
          # You could add email notification here
        fi
      else
        echo "$(date): Token is still valid"
      fi

      # Clean up temp files
      rm -f /tmp/facebook_token_check.txt /tmp/facebook_token_refresh.txt
    SCRIPT

    File.write("scripts/refresh_facebook_token.sh", script_content)
    File.chmod(0755, "scripts/refresh_facebook_token.sh")

    puts "✅ Created auto-refresh script: scripts/refresh_facebook_token.sh"
    puts ""
    puts "📋 To set up automatic refresh, add this to your crontab:"
    puts "   crontab -e"
    puts "   Add: 0 2 * * * /Users/allentaylor/src/skin_secrets/scripts/refresh_facebook_token.sh"
    puts ""
    puts "📋 Or run manually:"
    puts "   ./scripts/refresh_facebook_token.sh"
  end
end
