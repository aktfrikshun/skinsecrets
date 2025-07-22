#!/usr/bin/env ruby
# Simple script to generate a long-lived Facebook token

require 'net/http'
require 'json'

puts "🔄 Generating long-lived Facebook token..."

# Get credentials from environment
app_id = ENV['FACEBOOK_APP_ID']
app_secret = ENV['FACEBOOK_APP_SECRET']
current_token = ENV['FACEBOOK_PAGE_ACCESS_TOKEN']

if app_id.blank? || app_secret.blank? || current_token.blank?
  puts "❌ Missing environment variables"
  puts "   Please ensure FACEBOOK_APP_ID, FACEBOOK_APP_SECRET, and FACEBOOK_PAGE_ACCESS_TOKEN are set"
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
    puts "   New token: #{new_token}"
    puts "   Expires in: #{expires_in} seconds (#{(expires_in / 86400.0).round(1)} days)"

    # Update Fly.io secrets
    puts "\n🔄 Updating Fly.io secrets..."
    system("fly secrets set FACEBOOK_PAGE_ACCESS_TOKEN='#{new_token}' --app skin-secrets")

    if $?.success?
      puts "✅ Successfully updated Fly.io secrets!"
      puts "   New long-lived token is now active"
    else
      puts "❌ Failed to update Fly.io secrets"
      puts "   Please manually update: fly secrets set FACEBOOK_PAGE_ACCESS_TOKEN='#{new_token}' --app skin-secrets"
    end

  else
    puts "❌ Failed to generate long-lived token: #{result['error']}"
    puts "   Message: #{result['error_description']}"
    puts "   Code: #{result['code']}"
  end

rescue => e
  puts "❌ Error generating long-lived token: #{e.message}"
  puts "   Please check your credentials and try again"
end
