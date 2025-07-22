#!/usr/bin/env ruby
# Script to generate a long-lived Facebook token using local Rails credentials

require 'net/http'
require 'json'

puts "🔄 Generating long-lived Facebook token using local credentials..."

# Load Rails environment
require_relative '../config/environment'

# Get credentials from Rails
app_id = Rails.application.credentials.facebook_app_id
app_secret = Rails.application.credentials.facebook_app_secret
current_token = Rails.application.credentials.facebook_page_access_token

if app_id.blank? || app_secret.blank? || current_token.blank?
  puts "❌ Missing credentials in Rails credentials file"
  puts "   Please ensure you have:"
  puts "     facebook_app_id: your_app_id"
  puts "     facebook_app_secret: your_app_secret"
  puts "     facebook_page_access_token: your_current_token"
  exit 1
end

puts "📋 Using credentials:"
puts "   App ID: #{app_id}"
puts "   App Secret: #{app_secret[0..10]}..."
puts "   Current Token: #{current_token[0..10]}..."

# Exchange token for long-lived token
puts "\n🔄 Exchanging token for long-lived token..."

uri = URI("https://graph.facebook.com/v18.0/oauth/access_token")
params = {
  grant_type: 'fb_exchange_token',
  client_id: app_id,
  client_secret: app_secret,
  fb_exchange_token: current_token
}

uri.query = URI.encode_www_form(params)

begin
  response = Net::HTTP.get_response(uri)
  result = JSON.parse(response.body)

  if result['access_token']
    new_token = result['access_token']
    expires_in = result['expires_in']

    puts "✅ Successfully generated long-lived token!"
    puts "   New token: #{new_token[0..10]}..."

    if expires_in
      puts "   Expires in: #{expires_in} seconds (#{(expires_in / 86400.0).round(1)} days)"
    else
      puts "   Expires in: Never (truly long-lived token!)"
    end

    # Update Fly.io secrets
    puts "\n🔄 Updating Fly.io secrets..."
    system("fly secrets set FACEBOOK_PAGE_ACCESS_TOKEN='#{new_token}' --app skin-secrets")

    if $?.success?
      puts "✅ Successfully updated Fly.io secrets!"
      puts "   New long-lived token is now active on Fly.io"
    else
      puts "❌ Failed to update Fly.io secrets"
      puts "   Please manually update: fly secrets set FACEBOOK_PAGE_ACCESS_TOKEN='#{new_token}' --app skin-secrets"
    end

    # Also update Rails credentials if possible
    puts "\n🔄 Updating Rails credentials..."
    puts "   New token: #{new_token}"
    puts "   Please manually update your Rails credentials with:"
    puts "   rails credentials:edit"
    puts "   Add/update: facebook_page_access_token: #{new_token}"

  else
    puts "❌ Failed to generate long-lived token: #{result['error']}"
    puts "   Message: #{result['error_description']}"
    puts "   Code: #{result['code']}"
  end

rescue => e
  puts "❌ Error generating long-lived token: #{e.message}"
  puts "   Please check your credentials and try again"
end
