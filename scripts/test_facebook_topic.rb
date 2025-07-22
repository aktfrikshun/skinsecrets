# Test script for Facebook forum topic posting
puts "Testing Facebook forum topic posting..."

# Find admin user
admin_user = User.find_by(email: "admin@skinsecretsnc.com")
unless admin_user
  puts "❌ Admin user not found"
  exit 1
end

# Create test topic
topic = ForumTopic.new(
  title: "Test Facebook Integration - #{Time.current.strftime('%Y-%m-%d %H:%M')}",
  content: "This is a test topic to verify Facebook posting is working correctly. If you see this on the FrikFan Facebook page, the integration is successful! 🎉",
  user: admin_user
)

if topic.save
  puts "✅ Topic created successfully"
  puts "   ID: #{topic.id}"
  puts "   Title: #{topic.title}"
  puts "   User: #{topic.user.email}"
  puts "   Facebook posting should happen automatically via background job"

  # Check if this user should trigger Facebook posting
  should_post = topic.user.email == "ai@skinsecrets.com" || topic.user.email == "admin@skinsecretsnc.com"
  puts "   Should post to Facebook: #{should_post}"
else
  puts "❌ Failed to create topic: #{topic.errors.full_messages.join(', ')}"
end
