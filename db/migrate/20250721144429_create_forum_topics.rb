class CreateForumTopics < ActiveRecord::Migration[8.0]
  def change
    create_table :forum_topics do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :content

      t.timestamps
    end
  end
end
