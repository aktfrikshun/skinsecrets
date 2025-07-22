class FacebookPostJob < ApplicationJob
  queue_as :default

  def perform(forum_topic)
    Rails.logger.info "Facebook Post Job: Starting to post topic '#{forum_topic.title}' to Facebook"

    result = FacebookService.post_forum_topic(forum_topic)

    if result
      Rails.logger.info "Facebook Post Job: Successfully posted topic to Facebook"
    else
      Rails.logger.error "Facebook Post Job: Failed to post topic to Facebook"
    end
  end
end
