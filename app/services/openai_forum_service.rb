class OpenaiForumService
  include ActiveModel::Model

  def self.generate_topic
    client = OpenAI::Client.new(access_token: Rails.application.credentials.openai_api_key)

    # Get recent topics to avoid duplicates
    recent_topics = ForumTopic.where("created_at > ?", 30.days.ago).pluck(:title)
    recent_topics_text = recent_topics.any? ? "Recent topics to avoid: #{recent_topics.join(', ')}" : "No recent topics to avoid."

    prompt = <<~PROMPT
      You are a professional Esthetician located in New Bern, North Carolina
      You are posting forum topics with useful tips and resources for your customers health and beauty needs
      topics can include image and links and tutorials
      Please avoid reposting content that has been posted in the past 30 days

      #{recent_topics_text}

      Please create a forum topic with:
      1. An engaging title (5-10 words)
      2. Detailed content that encourages discussion (200-400 words)
      3. Include specific tips, product recommendations, or treatment advice
      4. Ask engaging questions to encourage community participation
      5. Reference New Bern, NC when relevant
      6. Focus on skincare, beauty, and esthetician services

      Format the response as JSON with "title" and "content" fields.
    PROMPT

    begin
      response = client.chat(
        parameters: {
          model: "gpt-4",
          messages: [
            {
              role: "system",
              content: "You are a helpful assistant that creates engaging forum topics for a skincare and beauty community in New Bern, North Carolina."
            },
            {
              role: "user",
              content: prompt
            }
          ],
          temperature: 0.8,
          max_tokens: 800
        }
      )

      if response.dig("choices", 0, "message", "content")
        content = response.dig("choices", 0, "message", "content")

        # Try to parse JSON response
        begin
          # Clean the content to remove any invalid characters and normalize newlines
          cleaned_content = content.gsub(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/, "")
                                  .gsub(/\r\n/, "\n")
                                  .gsub(/\r/, "\n")
                                  .strip

          # Try to find JSON content within the response
          json_match = cleaned_content.match(/\{.*\}/m)
          if json_match
            parsed = JSON.parse(json_match[0])
            title = parsed["title"]
            topic_content = parsed["content"]

            # Validate that we have both title and content
            if title.blank? || topic_content.blank?
              raise "Missing title or content in JSON response"
            end
          else
            raise "No JSON content found in response"
          end

        rescue JSON::ParserError, StandardError => e
          Rails.logger.error "OpenAI Forum Service: JSON parsing failed - #{e.message}"
          Rails.logger.error "Raw content: #{content}"

          # If JSON parsing fails, try to extract title and content from text
          lines = content.split("\n").map(&:strip).reject(&:blank?)

          # Look for title in the first few lines
          title = nil
          content_start = 0

          # First, try to find a line that contains "title"
          lines.each_with_index do |line, index|
            if line.downcase.include?("title") && line.length < 100
              title = line.gsub(/.*title.*:?\s*/i, "").strip.gsub(/["']/, "")
              content_start = index + 1
              break
            end
          end

          # If no title found, try to create a title from the first meaningful line
          if title.blank? && lines.any?
            first_line = lines.first

            # If first line is too short, try to create a title from the content
            if first_line.length < 10
              # Look for a longer line that could be a title
              potential_title = lines.find { |line| line.length >= 10 && line.length <= 100 }
              if potential_title
                title = potential_title
                content_start = lines.index(potential_title) + 1
              else
                # Create a generic title
                title = "Organic Skincare Tips and Recommendations"
                content_start = 0
              end
            else
              title = first_line
              content_start = 1
            end
          end

          # Clean up any JSON artifacts from title
          title = title.gsub(/^"title":\s*/, "")
                      .gsub(/^"content":\s*/, "")
                      .gsub(/^\{/, "")
                      .gsub(/\}$/, "")
                      .gsub(/^\[/, "")
                      .gsub(/\]$/, "")
                      .gsub(/^"/, "")
                      .gsub(/"$/, "")
                      .gsub(/^'/, "")
                      .gsub(/'$/, "")
                      .gsub(/,$/, "")
                      .gsub(/,$/, "")
                      .gsub(/^"title":\s*/, "")
                      .gsub(/^"content":\s*/, "")
                      .gsub(/^"/, "")
                      .gsub(/"$/, "")
                      .gsub(/^'/, "")
                      .gsub(/'$/, "")
                      .gsub(/,$/, "")
                      .strip

          # Get content from remaining lines and clean it
          topic_content = lines[content_start..-1].join("\n\n").strip

          # Clean up any remaining JSON artifacts
          topic_content = topic_content.gsub(/^"content":\s*/, "")
                                     .gsub(/^"title":\s*/, "")
                                     .gsub(/^\{/, "")
                                     .gsub(/\}$/, "")
                                     .gsub(/^\[/, "")
                                     .gsub(/\]$/, "")
                                     .gsub(/^"/, "")
                                     .gsub(/"$/, "")
                                     .gsub(/^'/, "")
                                     .gsub(/'$/, "")
                                     .strip

          # Fallback if extraction fails
          if title.blank? || topic_content.blank?
            Rails.logger.error "OpenAI Forum Service: Could not extract title or content from response"
            return nil
          end
        end

        # Final cleanup of title and content
        title = clean_title(title)
        topic_content = clean_content(topic_content)

        # Create the forum topic
        create_forum_topic(title, topic_content)
      else
        Rails.logger.error "OpenAI Forum Service: No content in response"
        nil
      end

    rescue => e
      Rails.logger.error "OpenAI Forum Service: Error occurred - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      nil
    end
  end

  private

  def self.create_forum_topic(title, content)
    # Find or create an AI user account
    ai_user = find_or_create_ai_user

    # Create the forum topic
    forum_topic = ForumTopic.new(
      title: title,
      content: content,
      user: ai_user
    )

    if forum_topic.save
      Rails.logger.info "OpenAI Forum Service: Successfully created topic '#{forum_topic.title}'"
      forum_topic
    else
      Rails.logger.error "OpenAI Forum Service: Failed to create topic - #{forum_topic.errors.full_messages.join(', ')}"
      nil
    end
  end

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
      Rails.logger.info "OpenAI Forum Service: Created AI user account"
    end

    ai_user
  end

  def self.clean_title(title)
    return title if title.blank?

    cleaned = title.to_s
      .gsub(/^"title":\s*/i, "")
      .gsub(/^"content":\s*/i, "")
      .gsub(/^\{/, "")
      .gsub(/\}$/, "")
      .gsub(/^\[/, "")
      .gsub(/\]$/, "")
      .gsub(/^"/, "")
      .gsub(/"$/, "")
      .gsub(/^'/, "")
      .gsub(/'$/, "")
      .gsub(/,$/, "")
      .gsub(/,$/, "")
      .gsub(/^"title":\s*/i, "")
      .gsub(/^"content":\s*/i, "")
      .gsub(/^"/, "")
      .gsub(/"$/, "")
      .gsub(/^'/, "")
      .gsub(/'$/, "")
      .gsub(/,$/, "")
      .strip

    Rails.logger.info "OpenAI Forum Service: Cleaned title from '#{title}' to '#{cleaned}'"
    cleaned
  end

  def self.clean_content(content)
    return content if content.blank?

    cleaned = content.to_s
      .gsub(/^"content":\s*/i, "")
      .gsub(/^"title":\s*/i, "")
      .gsub(/^\{/, "")
      .gsub(/\}$/, "")
      .gsub(/^\[/, "")
      .gsub(/\]$/, "")
      .gsub(/^"/, "")
      .gsub(/"$/, "")
      .gsub(/^'/, "")
      .gsub(/'$/, "")
      .strip

    Rails.logger.info "OpenAI Forum Service: Cleaned content length from #{content.length} to #{cleaned.length}"
    cleaned
  end
end
