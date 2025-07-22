class CreateForumPosts < ActiveRecord::Migration[8.0]
  def change
    create_table :forum_posts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :forum_topic, null: false, foreign_key: true
      t.references :parent_post, null: true, foreign_key: { to_table: :forum_posts }
      t.text :content

      t.timestamps
    end
  end
end
