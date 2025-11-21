class AddFacebookPostIdToForumTopics < ActiveRecord::Migration[8.0]
  def change
    add_column :forum_topics, :facebook_post_id, :string
    add_column :forum_topics, :facebook_posted_at, :datetime
  end
end
