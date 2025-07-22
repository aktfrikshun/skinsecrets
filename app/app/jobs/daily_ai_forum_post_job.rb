class DailyAiForumPostJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "DailyAiForumPostJob: Starting daily AI forum post generation"

    begin
      # Generate and post a new forum topic
      forum_topic = AiForumService.generate_daily_topic

      if forum_topic
        Rails.logger.info "DailyAiForumPostJob: Successfully posted topic '#{forum_topic.title}'"

        # You could add additional logic here, such as:
        # - Sending notifications to users
        # - Posting to social media
        # - Analytics tracking
        # - Email notifications to community members
      else
        Rails.logger.error "DailyAiForumPostJob: Failed to generate forum topic"
      end

    rescue => e
      Rails.logger.error "DailyAiForumPostJob: Error occurred - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      # Re-raise the error to trigger job retry mechanism
      raise e
    end
  end
end
