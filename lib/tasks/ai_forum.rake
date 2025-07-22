namespace :ai_forum do
  desc "Generate and post a new AI forum topic"
  task post_topic: :environment do
    puts "Generating new AI forum topic..."

    if Rails.application.credentials.openai_api_key.blank?
      puts "❌ OpenAI API key not configured. Please add it to credentials."
      puts "   Run: rails credentials:edit"
      puts "   Add: openai_api_key: sk-your-key-here"
      exit 1
    end

    forum_topic = AiForumService.generate_daily_topic

    if forum_topic
      puts "✅ Successfully posted OpenAI topic: '#{forum_topic.title}'"
      puts "   Topic ID: #{forum_topic.id}"
      puts "   Created at: #{forum_topic.created_at}"
      puts "   URL: /forum_topics/#{forum_topic.id}"
    else
      puts "❌ Failed to generate forum topic"
      puts "   Please check your OpenAI API key and try again"
      exit 1
    end
  end

  desc "Schedule the daily AI forum post job"
  task schedule_daily: :environment do
    puts "Scheduling daily AI forum post job..."

    # Schedule the job to run daily at 9:00 AM
    DailyAiForumPostJob.set(wait: 1.day).perform_later

    puts "✅ Daily AI forum post job scheduled"
  end

  desc "List all AI-generated forum topics"
  task list_topics: :environment do
    ai_user = User.find_by(email: "ai@skinsecrets.com")

    if ai_user
      topics = ForumTopic.where(user: ai_user).order(created_at: :desc)

      if topics.any?
        puts "AI-generated forum topics (#{topics.count} total):"
        puts "=" * 80

        topics.each do |topic|
          puts "ID: #{topic.id}"
          puts "Title: #{topic.title}"
          puts "Created: #{topic.created_at.strftime('%Y-%m-%d %H:%M:%S')}"
          puts "Posts: #{topic.post_count}"
          puts "-" * 40
        end
      else
        puts "No AI-generated topics found"
      end
    else
      puts "AI user account not found"
    end
  end



  desc "Reset AI user account (useful for testing)"
  task reset_ai_user: :environment do
    puts "Resetting AI user account..."

    ai_user = User.find_by(email: "ai@skinsecrets.com")

    if ai_user
      # Delete all AI-generated topics
      topic_count = ai_user.forum_topics.count
      ai_user.forum_topics.destroy_all

      # Delete AI user
      ai_user.destroy

      puts "✅ Deleted AI user and #{topic_count} associated topics"
    else
      puts "AI user account not found"
    end
  end
end
