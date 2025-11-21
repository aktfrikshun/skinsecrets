class ForumTopicsController < ApplicationController
  before_action :require_login, except: [ :index, :show ]
  before_action :set_forum_topic, only: [ :show, :edit, :update, :destroy, :post_to_facebook ]
  before_action :ensure_owner, only: [ :edit, :update ]
  before_action :ensure_owner_or_admin, only: [ :destroy ]
  before_action :require_admin, only: [ :generate_ai_topic, :post_to_facebook ]

  def index
    @forum_topics = ForumTopic.includes(:user, :forum_posts)
                             .recent
                             .limit(20)
  end

  def show
    @forum_posts = @forum_topic.forum_posts.includes(:user, :replies)
                               .top_level
                               .order(:created_at)
    @new_post = @forum_topic.forum_posts.build
  end

  def new
    @forum_topic = current_user.forum_topics.build
  end

  def create
    @forum_topic = current_user.forum_topics.build(forum_topic_params)

    if @forum_topic.save
      redirect_to @forum_topic, notice: "Topic created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @forum_topic.update(forum_topic_params)
      redirect_to @forum_topic, notice: "Topic updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @forum_topic.destroy
    redirect_to forum_topics_path, notice: "Topic deleted successfully!"
  end

  def generate_ai_topic
    forum_topic = AiForumService.generate_daily_topic

    if forum_topic
      redirect_to forum_topics_path, notice: "OpenAI topic '#{forum_topic.title}' generated successfully!"
    else
      if Rails.application.credentials.openai_api_key.blank?
        redirect_to forum_topics_path, alert: "OpenAI API key not configured. Please add it to credentials."
      else
        redirect_to forum_topics_path, alert: "Failed to generate AI topic. Please check your OpenAI API key and try again."
      end
    end
  end

  def post_to_facebook
    begin
      # Post to Facebook immediately
      result = FacebookService.post_forum_topic(@forum_topic)

      if result[:success]
        redirect_to forum_topics_path, notice: "Topic '#{@forum_topic.title}' posted to Facebook successfully! Post ID: #{result[:post_id]}"
      else
        redirect_to forum_topics_path, alert: "Failed to post to Facebook: #{result[:error]}"
      end
    rescue => e
      Rails.logger.error "Manual Facebook post error: #{e.message}"
      redirect_to forum_topics_path, alert: "Error posting to Facebook: #{e.message}"
    end
  end

  private

  def set_forum_topic
    @forum_topic = ForumTopic.find(params[:id])
  end

  def ensure_owner
    unless @forum_topic.user == current_user
      redirect_to @forum_topic, alert: "You can only edit your own topics."
    end
  end

  def ensure_owner_or_admin
    unless @forum_topic.user == current_user || current_user&.email == "admin@skinsecretsnc.com"
      redirect_to @forum_topic, alert: "You can only delete your own topics or must be an admin."
    end
  end

  def forum_topic_params
    params.require(:forum_topic).permit(:title, :content)
  end
end
