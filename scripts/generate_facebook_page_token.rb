#!/usr/bin/env ruby

# Script to generate long-lived Facebook Page Access Token
# Run with: bundle exec rails runner scripts/generate_facebook_page_token.rb

require 'net/http'
require 'json'
require 'uri'

puts "🔑 Facebook Page Access Token Generator"
puts "=" * 50

# Get credentials from Rails credentials
app_id = Rails.application.credentials.facebook_app_id
app_secret = Rails.application.credentials.facebook_app_secret
user_token = Rails.application.credentials.facebook_user_access_token

if app_id.blank? || app_secret.blank?
  puts "❌ Missing Facebook App credentials in Rails credentials!"
  puts "   facebook_app_id: #{app_id.present? ? 'SET' : 'MISSING'}"
  puts "   facebook_app_secret: #{app_secret.present? ? 'SET' : 'MISSING'}"
  puts ""
  puts "💡 Add them by running: rails credentials:edit"
  puts "   Then add:"
  puts "   facebook_app_id: your_app_id_here"
  puts "   facebook_app_secret: your_app_secret_here"
  exit 1
end

if user_token.blank?
  puts "❌ Missing facebook_user_access_token in Rails credentials!"
  puts "   Please add it by running: rails credentials:edit"
  puts "   Then add: facebook_user_access_token: your_token_here"
  puts ""
  puts "   You can get this from Facebook Graph API Explorer:"
  puts "   https://developers.facebook.com/tools/explorer/"
  puts "   1. Select your app"
  puts "   2. Select 'User Token'"
  puts "   3. Add permissions: pages_manage_posts, pages_read_engagement, pages_show_list"
  puts "   4. Generate Access Token"
  exit 1
end

puts "✅ All credentials found in Rails credentials"
puts "   App ID: #{app_id}"
puts "   App Secret: #{app_secret[0..10]}..."
puts "   User Token: #{user_token[0..20]}..."

# Step 1: Convert short-lived user token to long-lived user token
puts "\n🔄 Step 1: Converting to long-lived user token..."

begin
  uri = URI('https://graph.facebook.com/v18.0/oauth/access_token')
  uri.query = URI.encode_www_form({
    grant_type: 'fb_exchange_token',
    client_id: app_id,
    client_secret: app_secret,
    fb_exchange_token: user_token
  })

  response = Net::HTTP.get_response(uri)

  if response.code == '200'
    data = JSON.parse(response.body)
    long_lived_user_token = data['access_token']
    expires_in = data['expires_in']

    puts "✅ Long-lived user token generated"
    puts "   Expires in: #{expires_in} seconds (#{expires_in / 86400} days)"
    puts "   Token: #{long_lived_user_token[0..20]}..."
  else
    puts "❌ Failed to get long-lived user token"
    puts "   Response: #{response.code} - #{response.body}"
    exit 1
  end
rescue => e
  puts "❌ Error getting long-lived user token: #{e.message}"
  exit 1
end

# Step 2: Get user's pages
puts "\n📄 Step 2: Getting user's pages..."

begin
  uri = URI("https://graph.facebook.com/v18.0/me/accounts")
  uri.query = URI.encode_www_form({
    access_token: long_lived_user_token
  })

  response = Net::HTTP.get_response(uri)

  if response.code == '200'
    data = JSON.parse(response.body)
    pages = data['data']

    puts "✅ Found #{pages.length} page(s):"
    pages.each_with_index do |page, index|
      puts "   #{index + 1}. #{page['name']} (ID: #{page['id']})"
    end

    # Find the Skin Secrets page or use the first one
    target_page = pages.find { |p| p['name'].downcase.include?('skin secrets') } || pages.first

    if target_page
      page_id = target_page['id']
      page_name = target_page['name']
      page_token = target_page['access_token']

      puts "\n🎯 Selected page: #{page_name} (ID: #{page_id})"
      puts "   Page token: #{page_token[0..20]}..."

      # Step 3: Convert page token to long-lived
      puts "\n🔄 Step 3: Converting to long-lived page token..."

      uri = URI('https://graph.facebook.com/v18.0/oauth/access_token')
      uri.query = URI.encode_www_form({
        grant_type: 'fb_exchange_token',
        client_id: app_id,
        client_secret: app_secret,
        fb_exchange_token: page_token
      })

      response = Net::HTTP.get_response(uri)

      if response.code == '200'
        data = JSON.parse(response.body)
        long_lived_page_token = data['access_token']

        puts "✅ Long-lived page token generated!"
        puts "   Token: #{long_lived_page_token[0..30]}..."

        # Step 4: Test the token
        puts "\n🧪 Step 4: Testing the page token..."

        uri = URI("https://graph.facebook.com/v18.0/#{page_id}")
        uri.query = URI.encode_www_form({
          access_token: long_lived_page_token
        })

        response = Net::HTTP.get_response(uri)

        if response.code == '200'
          page_info = JSON.parse(response.body)
          puts "✅ Token test successful!"
          puts "   Page: #{page_info['name']}"
          puts "   ID: #{page_info['id']}"

          # Step 5: Update Fly.io secrets
          puts "\n🚀 Step 5: Updating Fly.io secrets..."
          puts "   FACEBOOK_PAGE_ID: #{page_id}"
          puts "   FACEBOOK_PAGE_ACCESS_TOKEN: #{long_lived_page_token[0..30]}..."

          puts "\n📝 Run these commands to update your secrets:"
          puts "   fly secrets set FACEBOOK_PAGE_ID=#{page_id}"
          puts "   fly secrets set FACEBOOK_PAGE_ACCESS_TOKEN=#{long_lived_page_token}"

          # Test posting capability
          puts "\n🧪 Step 6: Testing posting capability..."

          uri = URI("https://graph.facebook.com/v18.0/#{page_id}/feed")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true

          request = Net::HTTP::Post.new(uri)
          request.set_form_data({
            message: "Test post from Skin Secrets Rails app - #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}",
            access_token: long_lived_page_token
          })

          response = http.request(request)

          if response.code == '200'
            post_data = JSON.parse(response.body)
            puts "✅ Test post successful!"
            puts "   Post ID: #{post_data['id']}"
            puts "   Check your Facebook page to see if the post is visible to others"
          else
            puts "⚠️  Test post failed: #{response.code} - #{response.body}"
          end

        else
          puts "❌ Token test failed: #{response.code} - #{response.body}"
        end

      else
        puts "❌ Failed to get long-lived page token: #{response.code} - #{response.body}"
      end

    else
      puts "❌ No suitable page found"
    end

  else
    puts "❌ Failed to get pages: #{response.code} - #{response.body}"
  end

rescue => e
  puts "❌ Error: #{e.message}"
  exit 1
end

puts "\n🎉 Facebook Page Token Generation Complete!"
puts "=" * 50
puts "💡 Next steps:"
puts "   1. Update your Fly.io secrets with the commands above"
puts "   2. Test the Facebook posting button on your forum topics"
puts "   3. Check if posts are now visible to other users"
