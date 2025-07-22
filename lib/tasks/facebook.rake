namespace :facebook do
  desc "Test Facebook integration by posting a test message"
  task test_post: :environment do
    puts "Testing Facebook integration..."

    unless FacebookService.facebook_configured?
      puts "❌ Facebook not configured. Please add credentials:"
      puts "   Run: rails credentials:edit"
      puts "   Add:"
      puts "     facebook_page_access_token: your_page_access_token"
      puts "     facebook_page_id: your_page_id"
      exit 1
    end

    # Create a test forum topic
    test_topic = ForumTopic.new(
      title: "Test Facebook Integration",
      content: "This is a test post to verify Facebook integration is working correctly. If you see this on our Facebook page, the integration is successful!",
      user: User.find_by(email: "admin@skinsecretsnc.com") || User.first
    )

    if test_topic.save
      puts "✅ Test topic created successfully"
      puts "   Topic ID: #{test_topic.id}"
      puts "   Facebook posting should happen automatically via background job"
    else
      puts "❌ Failed to create test topic: #{test_topic.errors.full_messages.join(', ')}"
    end
  end

  desc "Post existing forum topic to Facebook"
  task :post_topic, [ :topic_id ] => :environment do |task, args|
    topic_id = args[:topic_id]

    unless topic_id
      puts "❌ Please provide a topic ID: rails facebook:post_topic[123]"
      exit 1
    end

    forum_topic = ForumTopic.find_by(id: topic_id)

    unless forum_topic
      puts "❌ Forum topic with ID #{topic_id} not found"
      exit 1
    end

    puts "Posting topic '#{forum_topic.title}' to Facebook..."

    unless FacebookService.facebook_configured?
      puts "❌ Facebook not configured. Please add credentials."
      exit 1
    end

    result = FacebookService.post_forum_topic(forum_topic)

    if result
      puts "✅ Successfully posted to Facebook"
      puts "   Post ID: #{result['id']}"
    else
      puts "❌ Failed to post to Facebook"
    end
  end

  desc "Check Facebook configuration"
  task check_config: :environment do
    puts "Checking Facebook configuration..."

    if Rails.application.credentials.facebook_page_access_token.present?
      puts "✅ Facebook Page Access Token: Configured"
    else
      puts "❌ Facebook Page Access Token: Missing"
    end

    if Rails.application.credentials.facebook_page_id.present?
      puts "✅ Facebook Page ID: #{Rails.application.credentials.facebook_page_id}"
    else
      puts "❌ Facebook Page ID: Missing"
    end

    if FacebookService.facebook_configured?
      puts "✅ Facebook integration is fully configured"
    else
      puts "❌ Facebook integration is not configured"
      puts ""
      puts "To configure Facebook integration:"
      puts "1. Go to https://developers.facebook.com/"
      puts "2. Create a new app or use existing app"
      puts "3. Get a Page Access Token for your Facebook page"
      puts "4. Get your Facebook Page ID"
      puts "5. Run: rails credentials:edit"
      puts "6. Add:"
      puts "   facebook_page_access_token: your_token_here"
      puts "   facebook_page_id: your_page_id_here"
    end
  end

  desc "List recent forum topics that would be posted to Facebook"
  task list_facebook_topics: :environment do
    puts "Recent forum topics that would be posted to Facebook:"
    puts "=" * 60

    # Get AI-generated topics and admin topics
    facebook_topics = ForumTopic.joins(:user)
                               .where(users: { email: [ "ai@skinsecrets.com", "admin@skinsecretsnc.com" ] })
                               .order(created_at: :desc)
                               .limit(10)

    if facebook_topics.any?
      facebook_topics.each do |topic|
        puts "ID: #{topic.id}"
        puts "Title: #{topic.title}"
        puts "Author: #{topic.user.email}"
        puts "Created: #{topic.created_at.strftime('%Y-%m-%d %H:%M:%S')}"
        puts "Posted to Facebook: #{topic.created_at > 1.hour.ago ? 'Recently (check logs)' : 'No'}"
        puts "-" * 40
      end
    else
      puts "No topics found that would be posted to Facebook"
    end
  end
end
