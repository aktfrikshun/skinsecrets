class ForumPost < ApplicationRecord
  belongs_to :user
  belongs_to :forum_topic
  belongs_to :parent_post, class_name: "ForumPost", optional: true
  has_many :replies, class_name: "ForumPost", foreign_key: "parent_post_id", dependent: :destroy

  validates :content, presence: true, length: { minimum: 5 }

  scope :recent, -> { order(created_at: :desc) }
  scope :top_level, -> { where(parent_post_id: nil) }

  def is_reply?
    parent_post_id.present?
  end

  def reply_count
    replies.count
  end

  def excerpt
    content.length > 100 ? "#{content[0..97]}..." : content
  end

  def formatted_content
    # Simple formatting for line breaks
    content.gsub(/\n/, "<br>").html_safe
  end
end
