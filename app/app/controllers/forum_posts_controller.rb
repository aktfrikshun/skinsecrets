class ForumPostsController < ApplicationController
  before_action :require_login, except: [ :show ]
  before_action :set_forum_topic
  before_action :set_forum_post, only: [ :show, :edit, :update, :destroy ]
  before_action :ensure_owner, only: [ :edit, :update ]
  before_action :ensure_owner_or_admin, only: [ :destroy ]

  def show
    @replies = @forum_post.replies.includes(:user).order(:created_at)
    @new_reply = @forum_topic.forum_posts.build(parent_post: @forum_post)
  end

  def create
    @forum_post = @forum_topic.forum_posts.build(forum_post_params)
    @forum_post.user = current_user

    if @forum_post.save
      redirect_to @forum_topic, notice: "Post created successfully!"
    else
      redirect_to @forum_topic, alert: "Error creating post. Please try again."
    end
  end

  def edit
  end

  def update
    if @forum_post.update(forum_post_params)
      redirect_to @forum_topic, notice: "Post updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @forum_post.destroy
    redirect_to @forum_topic, notice: "Post deleted successfully!"
  end

  private

  def set_forum_topic
    @forum_topic = ForumTopic.find(params[:forum_topic_id])
  end

  def set_forum_post
    @forum_post = @forum_topic.forum_posts.find(params[:id])
  end

  def ensure_owner
    unless @forum_post.user == current_user
      redirect_to @forum_topic, alert: "You can only edit your own posts."
    end
  end

  def ensure_owner_or_admin
    unless @forum_post.user == current_user || current_user&.email == "admin@skinsecretsnc.com"
      redirect_to @forum_topic, alert: "You can only delete your own posts or must be an admin."
    end
  end

  def forum_post_params
    params.require(:forum_post).permit(:content, :parent_post_id)
  end
end
