#!/usr/bin/env ruby

# Debug Facebook permissions and account access
# Run with: bundle exec rails runner scripts/debug_facebook_permissions.rb

require 'net/http'
require 'json'
require 'uri'

puts "🔍 Facebook Permissions Debug"
puts "=" * 40

user_token = Rails.application.credentials.facebook_user_access_token

if user_token.blank?
  puts "❌ No user token found in credentials"
  exit 1
end

puts "✅ User token found: #{user_token[0..20]}..."

# Check token info
puts "\n1️⃣ Checking token info..."
begin
  uri = URI("https://graph.facebook.com/v18.0/me?access_token=#{user_token}")
  response = Net::HTTP.get_response(uri)

  if response.code == '200'
    data = JSON.parse(response.body)
    puts "✅ Token valid for user: #{data['name']} (ID: #{data['id']})"
  else
    puts "❌ Token invalid: #{response.code} - #{response.body}"
    exit 1
  end
rescue => e
  puts "❌ Error checking token: #{e.message}"
  exit 1
end

# Check permissions
puts "\n2️⃣ Checking permissions..."
begin
  uri = URI("https://graph.facebook.com/v18.0/me/permissions?access_token=#{user_token}")
  response = Net::HTTP.get_response(uri)

  if response.code == '200'
    data = JSON.parse(response.body)
    permissions = data['data']

    puts "✅ Found #{permissions.length} permissions:"
    permissions.each do |perm|
      status = perm['status'] == 'granted' ? '✅' : '❌'
      puts "   #{status} #{perm['permission']}"
    end

    # Check for required permissions
    required = [ 'pages_manage_posts', 'pages_show_list', 'manage_pages' ]
    missing = required.select do |req|
      !permissions.any? { |p| p['permission'] == req && p['status'] == 'granted' }
    end

    if missing.any?
      puts "\n⚠️  Missing required permissions:"
      missing.each { |perm| puts "   - #{perm}" }
    else
      puts "\n✅ All required permissions granted!"
    end

  else
    puts "❌ Cannot check permissions: #{response.code} - #{response.body}"
  end
rescue => e
  puts "❌ Error checking permissions: #{e.message}"
end

# Check pages access
puts "\n3️⃣ Checking pages access..."
begin
  uri = URI("https://graph.facebook.com/v18.0/me/accounts?access_token=#{user_token}")
  response = Net::HTTP.get_response(uri)

  if response.code == '200'
    data = JSON.parse(response.body)
    pages = data['data']

    puts "✅ Found #{pages.length} accessible page(s):"

    if pages.any?
      pages.each_with_index do |page, index|
        puts "   #{index + 1}. #{page['name']}"
        puts "      ID: #{page['id']}"
        puts "      Category: #{page['category']}"
        puts "      Tasks: #{page['tasks']&.join(', ')}"
        puts
      end
    else
      puts "   No pages found. Possible reasons:"
      puts "   - You're not an admin of any Facebook pages"
      puts "   - Missing 'manage_pages' permission"
      puts "   - Wrong Facebook account logged in"
    end

  else
    puts "❌ Cannot access pages: #{response.code} - #{response.body}"
  end
rescue => e
  puts "❌ Error checking pages: #{e.message}"
end

puts "\n💡 Next steps:"
puts "   1. Make sure you're admin of the Skin Secrets Facebook page"
puts "   2. Get a new token with 'manage_pages' permission"
puts "   3. Update your credentials and try again"
