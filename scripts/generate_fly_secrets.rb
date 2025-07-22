#!/usr/bin/env ruby

# Generate Fly.io secrets commands from Rails credentials
# Usage: ruby scripts/generate_fly_secrets.rb [app-name]

require_relative '../config/environment'

app_name = ARGV[0] || 'skin-secrets'

puts "🔐 Generating Fly.io secrets commands for app: #{app_name}"
puts "=" * 60

begin
  # Get all credentials
  credentials = Rails.application.credentials.config

  if credentials.empty?
    puts "❌ No credentials found in Rails application"
    exit 1
  end

  puts "✅ Found #{credentials.keys.length} credential(s)"
  puts

  # Generate Fly secrets commands
  puts "📋 Individual Fly.io secrets commands:"
  puts

  credentials.each do |key, value|
    if value.is_a?(Hash)
      # Handle nested credentials (like facebook_page_access_token)
      value.each do |nested_key, nested_value|
        secret_name = "#{key.upcase}_#{nested_key.upcase}"
        puts "fly secrets set #{secret_name}=\"#{nested_value}\" --app #{app_name}"
      end
    else
      # Handle simple credentials
      secret_name = key.upcase
      puts "fly secrets set #{secret_name}=\"#{value}\" --app #{app_name}"
    end
  end

  puts
  puts "📋 All secrets in one command:"
  puts

  # Generate a single command with all secrets
  secret_pairs = []

  credentials.each do |key, value|
    if value.is_a?(Hash)
      value.each do |nested_key, nested_value|
        secret_name = "#{key.upcase}_#{nested_key.upcase}"
        secret_pairs << "#{secret_name}=\"#{nested_value}\""
      end
    else
      secret_name = key.upcase
      secret_pairs << "#{secret_name}=\"#{value}\""
    end
  end

  puts "fly secrets set #{secret_pairs.join(' ')} --app #{app_name}"

  puts
  puts "💡 Additional secrets you might need:"
  puts "fly secrets set RAILS_MASTER_KEY=\"$(cat config/master.key)\" --app #{app_name}"

  puts
  puts "🚀 Quick deployment commands:"
  puts "fly apps create #{app_name}"
  puts "fly volumes create skin_secrets_data --size 10 --region iad --app #{app_name}"
  puts "fly deploy --app #{app_name}"
  puts "fly open --app #{app_name}"

rescue => e
  puts "❌ Error reading credentials: #{e.message}"
  puts
  puts "💡 Make sure you have:"
  puts "   - config/credentials.yml.enc file"
  puts "   - config/master.key file"
  puts "   - Proper Rails environment loaded"
  exit 1
end
