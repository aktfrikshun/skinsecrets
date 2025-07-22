require "koala"

class FacebookService
  def initialize
    @page_access_token = ENV["FACEBOOK_PAGE_ACCESS_TOKEN"] || Rails.application.credentials.facebook_page_access_token
    @page_id = ENV["FACEBOOK_PAGE_ID"] || Rails.application.credentials.facebook_page_id
    @graph = Koala::Facebook::API.new(@page_access_token)
  end

  def post_message(message)
    begin
      response = @graph.put_connections(@page_id, "feed", message: message)
      {
        success: true,
        post_id: response["id"],
        response: response
      }
    rescue Koala::Facebook::ClientError => e
      {
        success: false,
        error: e.fb_error_message,
        code: e.fb_error_code,
        type: e.fb_error_type
      }
    rescue => e
      {
        success: false,
        error: e.message,
        type: "UnknownError"
      }
    end
  end

  def post_with_image(message, image_url)
    begin
      response = @graph.put_connections(@page_id, "photos", {
        message: message,
        url: image_url
      })
      {
        success: true,
        post_id: response["id"],
        response: response
      }
    rescue Koala::Facebook::ClientError => e
      {
        success: false,
        error: e.fb_error_message,
        code: e.fb_error_code,
        type: e.fb_error_type
      }
    rescue => e
      {
        success: false,
        error: e.message,
        type: "UnknownError"
      }
    end
  end

  def get_page_info
    begin
      response = @graph.get_object(@page_id)
      {
        success: true,
        page_info: response
      }
    rescue Koala::Facebook::ClientError => e
      {
        success: false,
        error: e.fb_error_message,
        code: e.fb_error_code,
        type: e.fb_error_type
      }
    rescue => e
      {
        success: false,
        error: e.message,
        type: "UnknownError"
      }
    end
  end

  def test_connection
    begin
      # Try to get page info as a simple test
      response = get_page_info
      if response[:success]
        {
          success: true,
          message: "Successfully connected to Facebook page: #{response[:page_info]['name']}"
        }
      else
        response
      end
    rescue => e
      {
        success: false,
        error: e.message,
        type: "ConnectionError"
      }
    end
  end

  def self.post_forum_topic(forum_topic)
    begin
      service = new
      # Create a formatted message for Facebook
      message = service.format_forum_topic_for_facebook(forum_topic)

      # Post to Facebook with automatic retry on token expiration
      result = service.post_message_with_retry(message)

      if result[:success]
        Rails.logger.info "FacebookService: Successfully posted topic '#{forum_topic.title}' to Facebook"
        Rails.logger.info "FacebookService: Post ID: #{result[:post_id]}"
      else
        Rails.logger.error "FacebookService: Failed to post topic to Facebook: #{result[:error]}"
      end

      result
    rescue => e
      Rails.logger.error "FacebookService: Error posting topic to Facebook: #{e.message}"
      {
        success: false,
        error: e.message,
        type: "PostError"
      }
    end
  end

  def post_message_with_retry(message, max_retries = 1)
    attempt = 0

    while attempt <= max_retries
      result = post_message(message)

      # If successful, return immediately
      return result if result[:success]

      # If token expired, try to refresh and retry
      if result[:code] == 190 && result[:error].include?("expired")
        Rails.logger.warn "FacebookService: Token expired, attempting refresh..."

        if attempt < max_retries && refresh_token
          Rails.logger.info "FacebookService: Token refreshed, retrying post..."
          attempt += 1
          next
        else
          Rails.logger.error "FacebookService: Failed to refresh token or max retries reached"
          return result
        end
      else
        # Other errors, don't retry
        return result
      end
    end

    result
  end

  def refresh_token
    begin
      app_id = ENV["FACEBOOK_APP_ID"] || Rails.application.credentials.facebook_app_id
      app_secret = ENV["FACEBOOK_APP_SECRET"] || Rails.application.credentials.facebook_app_secret

      if app_id.blank? || app_secret.blank?
        Rails.logger.error "FacebookService: App ID or App Secret not configured for token refresh"
        return false
      end

      require "net/http"
      require "json"

      uri = URI("https://graph.facebook.com/oauth/access_token")
      params = {
        client_id: app_id,
        client_secret: app_secret,
        grant_type: "client_credentials"
      }

      uri.query = URI.encode_www_form(params)
      response = Net::HTTP.get_response(uri)
      result = JSON.parse(response.body)

      if result["access_token"]
        @page_access_token = result["access_token"]
        @graph = Koala::Facebook::API.new(@page_access_token)

        Rails.logger.info "FacebookService: Token refreshed successfully"
        true
      else
        Rails.logger.error "FacebookService: Failed to refresh token: #{result['error']}"
        false
      end

    rescue => e
      Rails.logger.error "FacebookService: Error refreshing token: #{e.message}"
      false
    end
  end

  def format_forum_topic_for_facebook(forum_topic)
    # Create a formatted message for Facebook
    title = forum_topic.title
    excerpt = forum_topic.excerpt
    url = "https://skin-secrets.fly.dev/forum_topics/#{forum_topic.id}"

    message = <<~MESSAGE
      🌟 New Community Topic: #{title}

      #{excerpt}

      Join the discussion and share your thoughts! 💬

      Read more: #{url}

      #SkinSecrets #NewBern #Esthetician #Skincare #Beauty #Community
    MESSAGE

    message.strip
  end

  def self.facebook_configured?
    token = ENV["FACEBOOK_PAGE_ACCESS_TOKEN"] || Rails.application.credentials.facebook_page_access_token
    page_id = ENV["FACEBOOK_PAGE_ID"] || Rails.application.credentials.facebook_page_id

    token.present? && page_id.present?
  end
end
