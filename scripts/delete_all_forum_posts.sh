#!/bin/bash

# Script to delete all forum posts from the Skin Secrets application
# This script should be run on the Fly.io server via SSH

set -e

echo "🗑️  Starting forum post deletion process..."
echo "⚠️  WARNING: This will permanently delete ALL forum posts!"
echo "   This action cannot be undone."
echo

# Check if we're running in a Rails environment
if ! command -v bundle &> /dev/null; then
    echo "❌ Bundle command not found. Please run this script in a Rails environment."
    exit 1
fi

# Confirm deletion
read -p "Are you sure you want to delete ALL forum posts? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Deletion cancelled."
    exit 0
fi

echo
echo "🔍 Counting current forum posts..."

# Count posts before deletion
POST_COUNT=$(bundle exec rails runner "puts ForumPost.count" 2>/dev/null || echo "0")
TOPIC_COUNT=$(bundle exec rails runner "puts ForumTopic.count" 2>/dev/null || echo "0")

echo "   Found $POST_COUNT forum posts"
echo "   Found $TOPIC_COUNT forum topics"
echo

# Final confirmation
read -p "Proceed with deletion of $POST_COUNT posts and $TOPIC_COUNT topics? (yes/no): " final_confirm

if [ "$final_confirm" != "yes" ]; then
    echo "❌ Deletion cancelled."
    exit 0
fi

echo
echo "🗑️  Deleting all forum posts..."

# Delete all forum posts
bundle exec rails runner "
begin
  post_count = ForumPost.count
  topic_count = ForumTopic.count
  
  puts \"Deleting #{post_count} forum posts...\"
  ForumPost.delete_all
  
  puts \"Deleting #{topic_count} forum topics...\"
  ForumTopic.delete_all
  
  puts \"✅ Successfully deleted #{post_count} posts and #{topic_count} topics\"
rescue => e
  puts \"❌ Error during deletion: #{e.message}\"
  exit 1
end
"

echo
echo "✅ Forum post deletion completed!"
echo "   The forum is now empty and ready for fresh content." 