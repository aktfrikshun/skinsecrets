#!/usr/bin/env ruby

# Test script for AI Forum Posting + Facebook Integration System
# Run with: bundle exec rails runner scripts/test_ai_facebook_system.rb

puts "🔍 AI Forum + Facebook Integration System Test"
puts "=" * 60

# Test 1: Check OpenAI Configuration
puts "\n1️⃣ Testing OpenAI Configuration..."
if Rails.application.credentials.openai_api_key.present?
  puts "   ✅ OpenAI API key is configured"
else
  puts "   ❌ OpenAI API key is missing"
  exit 1
end

# Test 2: Check Facebook Configuration
puts "\n2️⃣ Testing Facebook Configuration..."
facebook_service = FacebookService.new
connection_result = facebook_service.test_connection

if connection_result[:success]
  puts "   ✅ Facebook connection successful: #{connection_result[:message]}"
else
  puts "   ❌ Facebook connection failed: #{connection_result[:error]}"
  exit 1
end

# Test 3: Check Recurring Jobs Setup
puts "\n3️⃣ Testing Recurring Jobs Setup..."
daily_job = SolidQueue::RecurringTask.find_by(key: "daily_ai_forum_post")
if daily_job
  puts "   ✅ Daily AI job is scheduled: #{daily_job.schedule}"
  puts "   📋 Job details: #{daily_job.class_name} on queue '#{daily_job.queue_name}'"
else
  puts "   ❌ Daily AI job is not scheduled"
  puts "   💡 Run: bundle exec rails recurring_jobs:setup"
  exit 1
end

# Test 4: Test AI Topic Generation
puts "\n4️⃣ Testing AI Topic Generation..."
begin
  forum_topic = AiForumService.generate_daily_topic
  if forum_topic
    puts "   ✅ AI topic generated successfully: '#{forum_topic.title}'"
    puts "   📝 Topic ID: #{forum_topic.id}"
    puts "   👤 Created by: #{forum_topic.user.email}"

    # Test 5: Test Facebook Posting
    puts "\n5️⃣ Testing Facebook Posting..."

    # Wait a moment for the automatic Facebook job to process
    sleep(5)

    # Check if Facebook job was enqueued
    facebook_jobs = SolidQueue::Job.where(class_name: "FacebookPostJob")
                                   .where("created_at > ?", 1.minute.ago)

    if facebook_jobs.any?
      puts "   ✅ Facebook posting job was enqueued"
      facebook_jobs.each do |job|
        status = job.finished_at ? "COMPLETED" : "PENDING"
        puts "   📊 Job #{job.id}: #{status}"
        if job.finished_at
          puts "   ⏱️  Completed in: #{((job.finished_at - job.created_at) * 1000).round(2)}ms"
        end
      end
    else
      puts "   ⚠️  No Facebook jobs found - manually testing..."

      # Manual Facebook test
      result = FacebookService.post_forum_topic(forum_topic)
      if result[:success]
        puts "   ✅ Manual Facebook post successful"
        puts "   📱 Facebook Post ID: #{result[:post_id]}"
      else
        puts "   ❌ Manual Facebook post failed: #{result[:error]}"
      end
    end

  else
    puts "   ❌ AI topic generation failed"
    exit 1
  end
rescue => e
  puts "   ❌ Error during AI topic generation: #{e.message}"
  exit 1
end

# Test 6: System Health Check
puts "\n6️⃣ System Health Check..."
puts "   📊 Active jobs: #{SolidQueue::Job.where(finished_at: nil).count}"
puts "   ✅ Completed jobs (24h): #{SolidQueue::Job.where('finished_at > ?', 24.hours.ago).count}"
puts "   ❌ Failed jobs: #{SolidQueue::FailedExecution.count}"

# Test 7: Recent AI Topics
puts "\n7️⃣ Recent AI Topics (last 7 days)..."
ai_user = User.find_by(email: "ai@skinsecrets.com")
if ai_user
  recent_topics = ForumTopic.where(user: ai_user)
                           .where("created_at > ?", 7.days.ago)
                           .order(created_at: :desc)

  puts "   📈 AI topics in last 7 days: #{recent_topics.count}"
  recent_topics.limit(3).each do |topic|
    puts "   • #{topic.title} (#{topic.created_at.strftime('%m/%d %H:%M')})"
  end
else
  puts "   ⚠️  AI user not found"
end

puts "\n🎉 System Test Complete!"
puts "=" * 60
puts "📅 Next scheduled run: Tomorrow at 9:00 AM Eastern"
puts "🔗 Facebook Page: https://facebook.com/#{ENV['FACEBOOK_PAGE_ID'] || 'your-page-id'}"
puts "📱 Monitor logs with: fly logs --app skin-secrets | grep -E '(DailyAiForumPostJob|FacebookPostJob)'"
