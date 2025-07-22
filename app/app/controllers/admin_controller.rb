class AdminController < ApplicationController
  before_action :require_admin

  def dashboard
    @total_users = User.count
    @total_topics = ForumTopic.count
    @total_posts = ForumPost.count
    @ai_topics = ForumTopic.joins(:user).where(users: { email: "ai@skinsecrets.com" }).count
    @facebook_configured = FacebookService.facebook_configured?
  end

  def facebook_settings
    @facebook_configured = FacebookService.facebook_configured?
    @recent_facebook_topics = ForumTopic.joins(:user)
                                       .where(users: { email: [ "ai@skinsecrets.com", "admin@skinsecretsnc.com" ] })
                                       .order(created_at: :desc)
                                       .limit(10)
  end

  def test_facebook
    if FacebookService.facebook_configured?
      # Create a test topic
      test_topic = ForumTopic.new(
        title: "Test Facebook Integration",
        content: "This is a test post to verify Facebook integration is working correctly. If you see this on our Facebook page, the integration is successful!",
        user: current_user
      )

      if test_topic.save
        redirect_to admin_facebook_settings_path, notice: "Test topic created! Facebook posting should happen automatically."
      else
        redirect_to admin_facebook_settings_path, alert: "Failed to create test topic: #{test_topic.errors.full_messages.join(', ')}"
      end
    else
      redirect_to admin_facebook_settings_path, alert: "Facebook is not configured. Please add credentials first."
    end
  end

  private

  def require_admin
    unless logged_in? && current_user.email == "admin@skinsecretsnc.com"
      redirect_to root_path, alert: "Access denied. Admin privileges required."
    end
  end
end
