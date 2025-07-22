namespace :facebook_test do
  desc "Test Facebook connection and get page info"
  task connection: :environment do
    puts "🔍 Testing Facebook connection..."

    service = FacebookService.new
    result = service.test_connection

    if result[:success]
      puts "✅ #{result[:message]}"
    else
      puts "❌ Connection failed: #{result[:error]}"
      puts "   Type: #{result[:type]}"
      puts "   Code: #{result[:code]}" if result[:code]
    end
  end

  desc "Test posting a simple message to Facebook"
  task post_message: :environment do
    puts "📝 Testing Facebook post..."

    service = FacebookService.new
    message = "🧪 Test post from Skin Secrets app - #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}"

    result = service.post_message(message)

    if result[:success]
      puts "✅ Post successful!"
      puts "   Post ID: #{result[:post_id]}"
      puts "   Message: #{message}"
    else
      puts "❌ Post failed: #{result[:error]}"
      puts "   Type: #{result[:type]}"
      puts "   Code: #{result[:code]}" if result[:code]
    end
  end

  desc "Test posting a message with image to Facebook"
  task post_with_image: :environment do
    puts "🖼️ Testing Facebook post with image..."

    service = FacebookService.new
    message = "🖼️ Test post with image from Skin Secrets app - #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}"
    image_url = "https://via.placeholder.com/600x400/FF6B6B/FFFFFF?text=Skin+Secrets+Test"

    result = service.post_with_image(message, image_url)

    if result[:success]
      puts "✅ Post with image successful!"
      puts "   Post ID: #{result[:post_id]}"
      puts "   Message: #{message}"
      puts "   Image URL: #{image_url}"
    else
      puts "❌ Post with image failed: #{result[:error]}"
      puts "   Type: #{result[:type]}"
      puts "   Code: #{result[:code]}" if result[:code]
    end
  end

  desc "Get detailed page information"
  task page_info: :environment do
    puts "📋 Getting Facebook page information..."

    service = FacebookService.new
    result = service.get_page_info

    if result[:success]
      page_info = result[:page_info]
      puts "✅ Page information retrieved:"
      puts "   Name: #{page_info['name']}"
      puts "   ID: #{page_info['id']}"
      puts "   Category: #{page_info['category']}"
      puts "   Followers: #{page_info['followers_count']}" if page_info["followers_count"]
      puts "   Likes: #{page_info['fan_count']}" if page_info["fan_count"]
      puts "   Username: #{page_info['username']}" if page_info["username"]
    else
      puts "❌ Failed to get page info: #{result[:error]}"
      puts "   Type: #{result[:type]}"
      puts "   Code: #{result[:code]}" if result[:code]
    end
  end

  desc "Run all Facebook tests"
  task all: :environment do
    puts "🚀 Running all Facebook integration tests..."
    puts "=" * 50

    Rake::Task["facebook_test:connection"].invoke
    puts
    Rake::Task["facebook_test:page_info"].invoke
    puts
    Rake::Task["facebook_test:post_message"].invoke
    puts
    Rake::Task["facebook_test:post_with_image"].invoke

    puts "=" * 50
    puts "🎉 All tests completed!"
  end
end
