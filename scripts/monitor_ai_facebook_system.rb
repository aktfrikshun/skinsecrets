#!/usr/bin/env ruby

# Monitoring script for AI Forum + Facebook Integration System
# Run with: bundle exec rails runner scripts/monitor_ai_facebook_system.rb

puts "📊 AI Forum + Facebook Integration System Monitor"
puts "=" * 60
puts "🕐 Current time: #{Time.current.strftime('%Y-%m-%d %H:%M:%S %Z')}"

# 1. Recurring Jobs Status
puts "\n📅 Recurring Jobs Status:"
SolidQueue::RecurringTask.all.each do |task|
  puts "   • #{task.key}: #{task.class_name}"
  puts "     Schedule: #{task.schedule}"
  puts "     Queue: #{task.queue_name}"

  # Find recent executions
  recent_jobs = SolidQueue::Job.where(class_name: task.class_name)
                               .where("created_at > ?", 24.hours.ago)
                               .order(created_at: :desc)

  if recent_jobs.any?
    last_job = recent_jobs.first
    status = last_job.finished_at ? "✅ COMPLETED" : "⏳ RUNNING"
    puts "     Last run: #{last_job.created_at.strftime('%m/%d %H:%M')} (#{status})"
  else
    puts "     Last run: No executions in last 24h"
  end
  puts
end

# 2. Recent AI Topics
puts "\n🤖 Recent AI Topics:"
ai_user = User.find_by(email: "ai@skinsecrets.com")
if ai_user
  recent_topics = ForumTopic.where(user: ai_user)
                           .where("created_at > ?", 7.days.ago)
                           .order(created_at: :desc)

  if recent_topics.any?
    recent_topics.limit(5).each do |topic|
      age = Time.current - topic.created_at
      age_text = if age < 1.hour
        "#{age.to_i / 60}m ago"
      elsif age < 1.day
        "#{age.to_i / 3600}h ago"
      else
        "#{age.to_i / 86400}d ago"
      end

      puts "   • #{topic.title}"
      puts "     Created: #{topic.created_at.strftime('%m/%d %H:%M')} (#{age_text})"
      puts "     Posts: #{topic.post_count}"
      puts
    end
  else
    puts "   No AI topics found in last 7 days"
  end
else
  puts "   ❌ AI user not found"
end

# 3. Facebook Integration Status
puts "\n📱 Facebook Integration Status:"
begin
  facebook_service = FacebookService.new
  connection_result = facebook_service.test_connection

  if connection_result[:success]
    puts "   ✅ Facebook connection: #{connection_result[:message]}"
  else
    puts "   ❌ Facebook connection failed: #{connection_result[:error]}"
  end

  # Recent Facebook jobs
  facebook_jobs = SolidQueue::Job.where(class_name: "FacebookPostJob")
                                 .where("created_at > ?", 24.hours.ago)
                                 .order(created_at: :desc)

  puts "   📊 Facebook jobs (24h): #{facebook_jobs.count}"

  facebook_jobs.limit(3).each do |job|
    status = job.finished_at ? "✅ COMPLETED" : "⏳ PENDING"
    duration = job.finished_at ? " (#{((job.finished_at - job.created_at) * 1000).round(0)}ms)" : ""
    puts "     • #{job.created_at.strftime('%m/%d %H:%M')}: #{status}#{duration}"
  end

rescue => e
  puts "   ❌ Facebook service error: #{e.message}"
end

# 4. Job Queue Health
puts "\n⚙️  Job Queue Health:"
active_jobs = SolidQueue::Job.where(finished_at: nil).count
completed_jobs_24h = SolidQueue::Job.where('finished_at > ?', 24.hours.ago).count
failed_jobs = SolidQueue::FailedExecution.count

puts "   Active jobs: #{active_jobs}"
puts "   Completed (24h): #{completed_jobs_24h}"
puts "   Failed jobs: #{failed_jobs}"

if failed_jobs > 0
  puts "\n   ❌ Recent Failed Jobs:"
  SolidQueue::FailedExecution.order(created_at: :desc).limit(3).each do |failed_job|
    puts "     • #{failed_job.job_class}: #{failed_job.exception_class}"
    puts "       #{failed_job.created_at.strftime('%m/%d %H:%M')}: #{failed_job.exception_message}"
  end
end

# 5. Next Scheduled Run
puts "\n⏰ Next Scheduled Runs:"
daily_job = SolidQueue::RecurringTask.find_by(key: "daily_ai_forum_post")
if daily_job
  # Calculate next 9 AM Eastern
  eastern_tz = ActiveSupport::TimeZone.new("Eastern Time (US & Canada)")
  now_eastern = Time.current.in_time_zone(eastern_tz)

  next_9am = if now_eastern.hour < 9
    now_eastern.beginning_of_day + 9.hours
  else
    (now_eastern + 1.day).beginning_of_day + 9.hours
  end

  time_until = next_9am - now_eastern
  hours_until = (time_until / 3600).floor
  minutes_until = ((time_until % 3600) / 60).floor

  puts "   📅 Next AI post: #{next_9am.strftime('%Y-%m-%d at 9:00 AM %Z')}"
  puts "   ⏳ Time until: #{hours_until}h #{minutes_until}m"
end

puts "\n" + "=" * 60
puts "💡 Commands:"
puts "   Test system: bundle exec rails runner scripts/test_ai_facebook_system.rb"
puts "   Manual post: bundle exec rails ai_forum:post_topic"
puts "   View logs: fly logs --app skin-secrets | grep -E '(AI|Facebook)'"
