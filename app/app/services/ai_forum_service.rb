class AiForumService
  include ActiveModel::Model

  def self.generate_daily_topic
    # Only generate topics if OpenAI is available
    if Rails.application.credentials.openai_api_key.present?
      begin
        OpenaiForumService.generate_topic
      rescue => e
        Rails.logger.error "AI Forum Service: OpenAI failed - #{e.message}"
        nil
      end
    else
      Rails.logger.info "AI Forum Service: OpenAI API key not configured, skipping topic generation"
      nil
    end
  end



  private

  def self.find_or_create_ai_user
    # Look for existing AI user
    ai_user = User.find_by(email: "ai@skinsecrets.com")

    unless ai_user
      # Create AI user if it doesn't exist
      password = SecureRandom.hex(16)
      ai_user = User.create!(
        first_name: "Skin",
        last_name: "Secrets AI",
        email: "ai@skinsecrets.com",
        phone: "000-000-0000",
        password: password,
        password_confirmation: password
      )
      Rails.logger.info "AI Forum Service: Created AI user account"
    end

    ai_user
  end
end
