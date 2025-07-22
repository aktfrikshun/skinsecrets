namespace :facebook_token_fetch do
  desc "Display page access token from user access token"
  task page_token: :environment do
    puts "🔑 Fetching page access token from user token..."
    puts "=" * 60

    begin
      # Get the current token from credentials
      current_token = Rails.application.credentials.facebook_page_access_token
      puts "Current token (first 20 chars): #{current_token[0..19]}..."
      puts

      # Try to determine if this is a user token or page token
      graph = Koala::Facebook::API.new(current_token)

      begin
        # Try to get user info first
        user_info = graph.get_object("me")
        puts "✅ This appears to be a USER token"
        puts "   User: #{user_info['name']} (ID: #{user_info['id']})"
        puts

        # Now get pages with their access tokens
        pages = graph.get_connections("me", "accounts")

        if pages.any?
          puts "✅ Found #{pages.length} page(s):"
          puts

          pages.each_with_index do |page, index|
            puts "#{index + 1}. #{page['name']} (ID: #{page['id']})"
            puts "   Category: #{page['category']}"
            puts "   Page Access Token: #{page['access_token']}"
            puts
          end

          # Show the configured page specifically
          configured_page_id = Rails.application.credentials.facebook_page_id
          configured_page = pages.find { |p| p["id"] == configured_page_id }

          if configured_page
            puts "🎯 CONFIGURED PAGE:"
            puts "   Name: #{configured_page['name']}"
            puts "   ID: #{configured_page['id']}"
            puts "   Page Access Token: #{configured_page['access_token']}"
            puts
            puts "📋 COPY THIS TOKEN:"
            puts "   #{configured_page['access_token']}"
          else
            puts "⚠️ Configured page ID (#{configured_page_id}) not found."
            puts "   Available page IDs: #{pages.map { |p| p['id'] }.join(', ')}"
          end

        else
          puts "❌ No pages found for this user."
        end

      rescue Koala::Facebook::ClientError => e
        if e.fb_error_code == 100 && e.fb_error_message.include?("accounts")
          puts "✅ This appears to be a PAGE token"
          puts "   You already have a page access token configured!"
          puts "   Current token: #{current_token}"
          puts
          puts "💡 If you want to test posting, run:"
          puts "   rbenv exec bundle exec rails facebook_token_fetch:test_page_posting"
        else
          raise e
        end
      end

    rescue Koala::Facebook::AuthenticationError => e
      puts "❌ Authentication failed: #{e.message}"
    rescue Koala::Facebook::ClientError => e
      puts "❌ Client error: #{e.fb_error_message}"
      puts "   Type: #{e.fb_error_type}"
      puts "   Code: #{e.fb_error_code}"
    rescue => e
      puts "❌ Unexpected error: #{e.message}"
    end

    puts "=" * 60
    puts "💡 Next steps:"
    puts "   1. Copy the page access token above"
    puts "   2. Run: rbenv exec bundle exec rails credentials:edit"
    puts "   3. Replace facebook_page_access_token with the copied token"
    puts "   4. Save and exit the editor"
  end

  desc "Test posting with current page access token"
  task test_page_posting: :environment do
    puts "🧪 Testing posting with current page access token..."

    begin
      # Get the current token (should be a page token)
      page_token = Rails.application.credentials.facebook_page_access_token
      page_id = Rails.application.credentials.facebook_page_id

      puts "Using page ID: #{page_id}"
      puts "Token (first 20 chars): #{page_token[0..19]}..."
      puts

      # Create graph object with page token
      page_graph = Koala::Facebook::API.new(page_token)

      # Test posting
      message = "🧪 Test post with page token - #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}"
      response = page_graph.put_connections(page_id, "feed", message: message)

      puts "✅ Post successful!"
      puts "   Post ID: #{response['id']}"
      puts "   Message: #{message}"
      puts "   URL: https://facebook.com/#{response['id']}"

    rescue Koala::Facebook::ClientError => e
      puts "❌ Post failed: #{e.fb_error_message}"
      puts "   Type: #{e.fb_error_type}"
      puts "   Code: #{e.fb_error_code}"
    rescue => e
      puts "❌ Test failed: #{e.message}"
    end
  end
end
