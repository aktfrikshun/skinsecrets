# OpenAI Integration Setup for Skin Secrets

This guide explains how to set up OpenAI API integration for dynamic forum topic generation.

## Overview

The Skin Secrets forum now supports OpenAI-powered topic generation that creates engaging, contextual content specific to skincare and beauty in New Bern, North Carolina.

## Features

- **Dynamic Content Generation**: Creates unique topics using OpenAI's GPT-4
- **Contextual Relevance**: Focuses on New Bern, NC esthetician services
- **Duplicate Prevention**: Avoids topics posted in the last 30 days
- **OpenAI Required**: Only generates topics when OpenAI is available
- **Rich Content**: Includes tips, product recommendations, and tutorials

## Setup Instructions

### 1. Get OpenAI API Key

1. Visit [OpenAI Platform](https://platform.openai.com/)
2. Sign up or log in to your account
3. Navigate to "API Keys" section
4. Create a new API key
5. Copy the API key (starts with `sk-`)

### 2. Add API Key to Rails Credentials

```bash
# Edit Rails credentials
rails credentials:edit
```

Add the following to your credentials file:

```yaml
openai_api_key: sk-your-actual-api-key-here
```

### 3. Install Dependencies

```bash
# Install the ruby-openai gem
bundle install
```

## Usage

### Manual Topic Generation

```bash
# Generate topic using OpenAI (OpenAI API key required)
rails ai_forum:post_topic
```

### Web Interface

1. Log in as admin (`admin@skinsecretsnc.com`)
2. Navigate to the forum page
3. Click "Generate AI Topic" button
4. The system will use OpenAI to generate a new topic

### Scheduled Generation

The system automatically generates topics daily at 9:00 AM using the same logic.

## Prompt Configuration

The OpenAI service uses the following prompt:

```
You are a professional Esthetician located in New Bern, North Carolina
You are posting forum topics with useful tips and resources for your customers health and beauty needs
topics can include image and links and tutorials
Please avoid reposting content that has been posted in the past 30 days

[Recent topics list]

Please create a forum topic with:
1. An engaging title (5-10 words)
2. Detailed content that encourages discussion (200-400 words)
3. Include specific tips, product recommendations, or treatment advice
4. Ask engaging questions to encourage community participation
5. Reference New Bern, NC when relevant
6. Focus on skincare, beauty, and esthetician services

Format the response as JSON with "title" and "content" fields.
```

## Configuration Options

### Model Settings

The service uses GPT-4 with the following parameters:
- **Model**: `gpt-4`
- **Temperature**: `0.8` (creative but focused)
- **Max Tokens**: `800` (sufficient for topic content)

### Customization

To modify the prompt or settings, edit `app/services/openai_forum_service.rb`:

```ruby
# Change model
model: "gpt-3.5-turbo"  # Alternative model

# Adjust creativity
temperature: 0.5  # More conservative

# Increase content length
max_tokens: 1200  # Longer topics
```

## Error Handling

The system includes robust error handling:

1. **API Key Missing**: No topic generated, clear error message
2. **API Errors**: Logs errors and returns nil
3. **JSON Parsing Errors**: Extracts content from text response
4. **Network Issues**: Returns nil, no topic generated

## Monitoring

Check logs for OpenAI activity:

```bash
# View OpenAI service logs
tail -f log/development.log | grep "OpenAI Forum Service"

# View all AI topic generation
tail -f log/development.log | grep "AI Forum Service"
```

## Cost Management

OpenAI API usage is charged per token. To manage costs:

1. **Monitor Usage**: Check OpenAI dashboard regularly
2. **Set Limits**: Configure spending limits in OpenAI dashboard
3. **Optimize Prompts**: Keep prompts concise but effective
4. **Use Fallbacks**: System automatically uses predefined topics if needed

## Security

- API key is stored securely in Rails credentials
- No sensitive data is sent to OpenAI
- All generated content is reviewed before posting
- Fallback system ensures service availability

## Troubleshooting

### Common Issues

1. **"OpenAI API key not configured"**
   - Add API key to credentials: `rails credentials:edit`

2. **"Failed to generate OpenAI forum topic"**
   - Check API key validity
   - Verify internet connection
   - Check OpenAI account status

3. **"No content in response"**
   - API rate limits exceeded
   - Check OpenAI service status
   - Verify prompt format

### Debug Mode

Enable detailed logging:

```ruby
# In config/environments/development.rb
config.log_level = :debug
```

## Support

For issues with:
- **OpenAI API**: Contact OpenAI support
- **Skin Secrets Integration**: Check application logs
- **Configuration**: Review this setup guide

## Future Enhancements

Potential improvements:
- Multiple AI models for different content types
- Content moderation integration
- User feedback collection
- Performance analytics
- A/B testing for prompts 