namespace :facebook_debug do
  desc "Debug Facebook token and permissions"
  task token_info: :environment do
    puts "🔍 Debugging Facebook token..."

    token = Rails.application.credentials.facebook_page_access_token
    page_id = Rails.application.credentials.facebook_page_id

    puts "Token (first 20 chars): #{token[0..19]}..."
    puts "Page ID: #{page_id}"

    begin
      # Create a user graph object to test the token
      user_graph = Koala::Facebook::API.new(token)

      # Try to get user info
      puts "\n📋 Testing token with user info..."
      user_info = user_graph.get_object("me")
      puts "✅ Token is valid!"
      puts "   User ID: #{user_info['id']}"
      puts "   Name: #{user_info['name']}"

      # Try to get user's pages
      puts "\n📄 Getting user's pages..."
      pages = user_graph.get_connections("me", "accounts")

      if pages.any?
        puts "✅ Found #{pages.length} page(s):"
        pages.each_with_index do |page, index|
          puts "   #{index + 1}. #{page['name']} (ID: #{page['id']})"
          puts "      Access Token: #{page['access_token'][0..19]}..."
          puts "      Category: #{page['category']}"
          puts "      Permissions: #{page['perms']&.join(', ')}"
        end

        # Check if our configured page ID is in the list
        configured_page = pages.find { |p| p["id"] == page_id }
        if configured_page
          puts "\n✅ Configured page ID (#{page_id}) found in user's pages!"
          puts "   Page name: #{configured_page['name']}"
        else
          puts "\n❌ Configured page ID (#{page_id}) NOT found in user's pages."
          puts "   Available page IDs: #{pages.map { |p| p['id'] }.join(', ')}"
        end
      else
        puts "❌ No pages found for this user."
      end

    rescue Koala::Facebook::AuthenticationError => e
      puts "❌ Authentication failed: #{e.message}"
      puts "   The token may be invalid or expired."
    rescue Koala::Facebook::ClientError => e
      puts "❌ Client error: #{e.fb_error_message}"
      puts "   Type: #{e.fb_error_type}"
      puts "   Code: #{e.fb_error_code}"
    rescue => e
      puts "❌ Unexpected error: #{e.message}"
    end
  end

  desc "Test posting to a specific page"
  task test_page_post: :environment do
    puts "📝 Testing post to specific page..."

    token = Rails.application.credentials.facebook_page_access_token
    page_id = Rails.application.credentials.facebook_page_id

    begin
      # Try to post directly using the page access token
      graph = Koala::Facebook::API.new(token)

      message = "🧪 Debug test post - #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}"

      puts "Attempting to post: #{message}"
      puts "To page ID: #{page_id}"

      response = graph.put_connections(page_id, "feed", message: message)

      puts "✅ Post successful!"
      puts "   Post ID: #{response['id']}"

    rescue Koala::Facebook::ClientError => e
      puts "❌ Post failed: #{e.fb_error_message}"
      puts "   Type: #{e.fb_error_type}"
      puts "   Code: #{e.fb_error_code}"
    rescue => e
      puts "❌ Unexpected error: #{e.message}"
    end
  end

  desc "Get all available permissions for the token"
  task permissions: :environment do
    puts "🔐 Checking token permissions..."

    token = Rails.application.credentials.facebook_page_access_token

    begin
      graph = Koala::Facebook::API.new(token)

      # Get permissions
      permissions = graph.get_connections("me", "permissions")

      puts "✅ Token permissions:"
      permissions.each do |permission|
        status = permission["status"] == "granted" ? "\u2705" : "\u274C"
        puts "   #{status} #{permission['permission']}: #{permission['status']}"
      end

    rescue Koala::Facebook::ClientError => e
      puts "❌ Failed to get permissions: #{e.fb_error_message}"
    rescue => e
      puts "❌ Unexpected error: #{e.message}"
    end
  end
end
