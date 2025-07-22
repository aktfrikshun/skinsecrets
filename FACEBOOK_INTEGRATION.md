# Facebook Integration for Skin Secrets

This document explains how to set up and use the Facebook integration feature that automatically posts forum topics to the Skin Secrets Facebook page.

## Overview

The Facebook integration automatically posts new forum topics to the Skin Secrets Facebook page when:
- AI-generated topics are created (from `ai@skinsecrets.com`)
- Admin-created topics are created (from `admin@skinsecretsnc.com`)

## Features

- **Automatic Posting**: Forum topics are automatically posted to Facebook via background jobs
- **Smart Filtering**: Only posts from AI or admin users to avoid spam
- **Rich Content**: Includes topic title, excerpt, and link back to the forum
- **Hashtags**: Automatically adds relevant hashtags for better discoverability
- **Error Handling**: Graceful error handling with detailed logging

## Setup Instructions

### 1. Create a Facebook App

1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Click "Create App" and select "Business" type
3. Fill in your app details
4. Add the "Pages" product to your app

### 2. Get Page Access Token

1. In your Facebook app, go to "Tools" > "Graph API Explorer"
2. Select your app from the dropdown
3. Click "Generate Access Token"
4. Select the following permissions:
   - `pages_manage_posts`
   - `pages_read_engagement`
5. Copy the generated token

### 3. Get Your Page ID

1. Go to your Facebook page
2. Look at the URL: `https://www.facebook.com/YourPageName`
3. Or go to "About" section and find the Page ID

### 4. Configure Rails Credentials

Run the following command to edit your credentials:

```bash
rails credentials:edit
```

Add the following lines:

```yaml
facebook_page_access_token: your_page_access_token_here
facebook_page_id: your_page_id_here
```

### 5. Install Dependencies

```bash
bundle install
```

## Usage

### Automatic Posting

Once configured, forum topics will be automatically posted to Facebook when:
- AI generates a new topic
- Admin creates a new topic

### Manual Testing

Test the Facebook integration:

```bash
# Check configuration
rails facebook:check_config

# Test with a sample post
rails facebook:test_post

# Post existing topic to Facebook
rails facebook:post_topic[123]

# List recent topics that would be posted
rails facebook:list_facebook_topics
```

### Background Jobs

Facebook posting happens asynchronously via background jobs. Make sure your job queue is running:

```bash
# Start the job queue
rails solid_queue:start
```

## Facebook Post Format

Each Facebook post includes:

- **Title**: "🌟 New Community Topic: [Topic Title]"
- **Excerpt**: First 200 characters of the topic content
- **Call to Action**: Encourages community participation
- **Link**: Direct link to the forum topic
- **Hashtags**: #SkinSecrets #NewBern #Esthetician #Skincare #Beauty #Community

## Troubleshooting

### Common Issues

1. **"Facebook not configured" error**
   - Check that credentials are properly set
   - Run `rails facebook:check_config`

2. **"Permission denied" error**
   - Ensure your Page Access Token has the correct permissions
   - Regenerate the token with proper permissions

3. **Posts not appearing on Facebook**
   - Check the Rails logs for error messages
   - Verify the Page ID is correct
   - Ensure the page access token is valid

### Logs

Check the Rails logs for Facebook-related messages:

```bash
tail -f log/development.log | grep -i facebook
```

### Testing

Use the rake tasks to test the integration:

```bash
# Test configuration
rails facebook:check_config

# Test posting
rails facebook:test_post
```

## Security Considerations

- **Access Tokens**: Never commit access tokens to version control
- **Permissions**: Use the minimum required permissions
- **Rate Limits**: Facebook has rate limits; the system handles this gracefully
- **Error Handling**: Failed posts are logged but don't break the application

## Maintenance

### Regular Tasks

1. **Monitor Logs**: Check for Facebook posting errors
2. **Token Refresh**: Facebook tokens may expire; monitor for 401 errors
3. **Rate Limits**: Monitor for rate limit errors

### Token Management

Facebook Page Access Tokens can expire. To refresh:

1. Go to Facebook Developers
2. Generate a new Page Access Token
3. Update your Rails credentials
4. Test the integration

## Support

If you encounter issues:

1. Check the Rails logs for error messages
2. Verify Facebook app configuration
3. Test with the provided rake tasks
4. Check Facebook's API documentation for any changes

## Files Modified

- `app/services/facebook_service.rb` - Main Facebook integration service
- `app/jobs/facebook_post_job.rb` - Background job for posting
- `app/models/forum_topic.rb` - Added Facebook posting callback
- `lib/tasks/facebook.rake` - Management and testing tasks
- `Gemfile` - Added Koala gem for Facebook API 