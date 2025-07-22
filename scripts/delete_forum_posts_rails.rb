# Rails script to delete all forum posts and topics
# Usage: rails runner scripts/delete_forum_posts_rails.rb

puts "🗑️  Forum Post Deletion Script"
puts "=" * 50

# Count current posts and topics
post_count = ForumPost.count
topic_count = ForumTopic.count

puts "Current forum state:"
puts "  - Forum Posts: #{post_count}"
puts "  - Forum Topics: #{topic_count}"
puts

if post_count == 0 && topic_count == 0
  puts "✅ Forum is already empty!"
  exit 0
end

puts "⚠️  WARNING: This will permanently delete ALL forum posts and topics!"
puts "   This action cannot be undone."
puts

# Get user confirmation
print "Type 'DELETE ALL' to confirm: "
confirmation = gets.chomp

if confirmation != "DELETE ALL"
  puts "❌ Deletion cancelled."
  exit 0
end

puts
puts "🗑️  Starting deletion process..."

begin
  # Delete all forum posts first (due to foreign key constraints)
  puts "Deleting #{post_count} forum posts..."
  ForumPost.delete_all

  # Then delete all forum topics
  puts "Deleting #{topic_count} forum topics..."
  ForumTopic.delete_all

  puts
  puts "✅ Successfully deleted:"
  puts "  - #{post_count} forum posts"
  puts "  - #{topic_count} forum topics"
  puts
  puts "🎉 Forum has been completely cleared!"
  puts "   The forum is now empty and ready for fresh content."

rescue => e
  puts "❌ Error during deletion: #{e.message}"
  puts e.backtrace.first(5).join("\n")
  exit 1
end
