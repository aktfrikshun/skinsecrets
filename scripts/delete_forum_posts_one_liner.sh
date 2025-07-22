#!/bin/bash

# One-liner script to delete all forum posts via Fly SSH
# Usage: fly ssh console --app skin-secrets --command "bash -c '$(cat scripts/delete_forum_posts_one_liner.sh)'"

echo "🗑️  Deleting all forum posts and topics..."

# Count and display current state
echo "Current forum state:"
bundle exec rails runner "puts \"  - Forum Posts: #{ForumPost.count}\"; puts \"  - Forum Topics: #{ForumTopic.count}\""

# Delete all posts and topics
bundle exec rails runner "
begin
  post_count = ForumPost.count
  topic_count = ForumTopic.count
  
  puts \"\\n🗑️  Deleting #{post_count} forum posts...\"
  ForumPost.delete_all
  
  puts \"🗑️  Deleting #{topic_count} forum topics...\"
  ForumTopic.delete_all
  
  puts \"\\n✅ Successfully deleted #{post_count} posts and #{topic_count} topics\"
  puts \"🎉 Forum has been completely cleared!\"
rescue => e
  puts \"\\n❌ Error: #{e.message}\"
  exit 1
end
"

echo "✅ Forum post deletion completed!" 