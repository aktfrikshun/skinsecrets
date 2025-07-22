namespace :facebook_basic_test do
  desc "Test basic Facebook integration with current permissions"
  task basic: :environment do
    puts "🧪 Testing basic Facebook integration..."

    token = Rails.application.credentials.facebook_page_access_token

    begin
      graph = Koala::Facebook::API.new(token)

      # Test 1: Get user info
      puts "\n1️⃣ Testing user info..."
      user_info = graph.get_object("me")
      puts "✅ User: #{user_info['name']} (ID: #{user_info['id']})"

      # Test 2: Get pages list
      puts "\n2️⃣ Testing pages access..."
      pages = graph.get_connections("me", "accounts")
      puts "✅ Found #{pages.length} page(s):"
      pages.each do |page|
        puts "   - #{page['name']} (ID: #{page['id']})"
      end

      # Test 3: Try to read page info (should work with pages_show_list)
      puts "\n3️⃣ Testing page info access..."
      if pages.any?
        page_id = pages.first["id"]
        begin
          page_info = graph.get_object(page_id)
          puts "✅ Page info: #{page_info['name']} (#{page_info['category']})"
        rescue => e
          puts "❌ Cannot read page info: #{e.message}"
        end
      end

      puts "\n🎉 Basic integration test completed!"
      puts "📝 Note: Posting requires additional permissions (pages_read_engagement, pages_manage_posts)"

    rescue => e
      puts "❌ Basic test failed: #{e.message}"
    end
  end
end
