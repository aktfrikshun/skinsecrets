class ForumTopic < ApplicationRecord
  belongs_to :user
  has_many :forum_posts, dependent: :destroy

  validates :title, presence: true, length: { minimum: 5, maximum: 200 }
  validates :content, presence: true, length: { minimum: 10 }

  after_create :post_to_facebook, if: :should_post_to_facebook?

  scope :recent, -> { order(created_at: :desc) }
  scope :popular, -> { joins(:forum_posts).group(:id).order("COUNT(forum_posts.id) DESC") }

  def last_post
    forum_posts.order(created_at: :desc).first
  end

  def post_count
    forum_posts.count
  end

  def last_activity
    last_post&.created_at || created_at
  end

  def excerpt
    # Clean content and create excerpt
    cleaned_content = content.gsub(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/, "")
    cleaned_content.length > 150 ? "#{cleaned_content[0..147]}..." : cleaned_content
  end

  def formatted_content
    # Clean any potential JSON artifacts and format content properly
    cleaned_content = content.gsub(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/, "")
    cleaned_content.gsub(/\n/, "<br>").html_safe
  end

  private

  def post_to_facebook
    # Post to Facebook asynchronously to avoid blocking the response
    FacebookPostJob.perform_later(self)
  end

  def should_post_to_facebook?
    # Only post AI-generated topics or topics from admin users to Facebook
    user.email == "ai@skinsecrets.com" || user.email == "admin@skinsecretsnc.com"
  end
end
