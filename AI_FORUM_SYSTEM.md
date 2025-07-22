# AI Forum Posting System for Skin Secrets

This system automatically generates and posts forum topics daily to keep the Skin Secrets community engaged with relevant skincare discussions.

## Features

- **Daily Automated Posting**: Posts one new topic every day at 9:00 AM (OpenAI only)
- **OpenAI Integration**: Dynamic topic generation using GPT-4 for unique, contextual content
- **AI User Account**: Dedicated "Skin Secrets AI" user account for generated content
- **Visual Indicators**: AI-generated topics are clearly marked with a purple "AI" badge
- **Duplicate Prevention**: Avoids posting the same topic within 30 days
- **Manual Trigger**: Admin can manually generate topics for testing
- **New Bern Context**: Content specifically tailored for New Bern, NC esthetician services
- **No Fallback**: Only generates topics when OpenAI is available

## How It Works

### 1. AI Service (`app/services/ai_forum_service.rb`)
- Orchestrates OpenAI topic generation
- Manages the AI user account creation
- Handles topic generation and posting logic
- Prevents duplicate topics within 30 days
- Only generates topics when OpenAI is available

### 2. OpenAI Service (`app/services/openai_forum_service.rb`)
- Integrates with OpenAI GPT-4 API
- Generates dynamic, contextual content
- Focuses on New Bern, NC esthetician services
- Includes robust error handling

### 2. Scheduled Job (`app/jobs/daily_ai_forum_post_job.rb`)
- Runs daily at 9:00 AM (configured in `config/recurring.yml`)
- Uses Rails Active Job with Solid Queue
- Logs success/failure for monitoring

### 3. Admin Controls
- Manual topic generation via rake tasks
- Admin-only web interface for testing
- Topic management and monitoring tools
- OpenAI-only generation (no fallback)

## Usage

### Manual Topic Generation

```bash
# Generate a single AI topic (OpenAI only)
rails ai_forum:post_topic

# List all AI-generated topics
rails ai_forum:list_topics

# Reset AI user account (for testing)
rails ai_forum:reset_ai_user

# Schedule daily job manually
rails ai_forum:schedule_daily
```

### Admin Web Interface

1. Log in as admin (email: `admin@skinsecrets.com`)
2. Navigate to any forum topic
3. Use the "Generate AI Topic" button (if implemented)

### Monitoring

Check the Rails logs for AI posting activity:
```bash
tail -f log/development.log | grep "AI Forum Service"
tail -f log/development.log | grep "OpenAI Forum Service"
tail -f log/development.log | grep "DailyAiForumPostJob"
```

## Configuration

### Scheduling
The daily job is configured in `config/recurring.yml`:
```yaml
daily_ai_forum_post:
  class: DailyAiForumPostJob
  queue: default
  schedule: at 9am every day
```

### AI User Account
- Email: `ai@skinsecrets.com`
- Name: "Skin Secrets AI"
- Automatically created when first topic is generated

### Topic Generation
**OpenAI Integration** (Required):
- Dynamic content generation using GPT-4
- Contextual to New Bern, NC esthetician services
- Includes tips, product recommendations, and tutorials
- Avoids duplicates from last 30 days
- No fallback system - only generates when OpenAI is available

## Customization

### Adding New Topics
**For OpenAI Integration**:
Edit `app/services/openai_forum_service.rb` to modify the prompt or model settings.

### Changing Schedule
Modify `config/recurring.yml`:
```yaml
daily_ai_forum_post:
  class: DailyAiForumPostJob
  queue: default
  schedule: at 2pm every day  # Change time
  # or
  schedule: every 2 days      # Change frequency
```

### Modifying AI User
Edit the `find_or_create_ai_user` method in `AiForumService` to change the AI user details.

## Troubleshooting

### Job Not Running
1. Check if Solid Queue is running: `rails solid_queue:start`
2. Verify recurring jobs are enabled
3. Check logs for errors

### Topics Not Generating
1. Ensure OpenAI API key is configured
2. Check OpenAI API key validity
3. Verify internet connectivity
4. Check OpenAI service status

### OpenAI API Issues
1. Verify API key in credentials: `rails credentials:edit`
2. Check OpenAI account status and billing
3. Monitor API rate limits
4. Check logs for specific error messages

### Duplicate Topics
The system prevents duplicates within 30 days. If you need to reset:
```bash
rails ai_forum:reset_ai_user
```

## OpenAI Setup

For OpenAI integration, see `OPENAI_SETUP.md` for detailed setup instructions.

### Quick Setup:
1. Get OpenAI API key from [OpenAI Platform](https://platform.openai.com/)
2. Add to Rails credentials: `rails credentials:edit`
3. Add: `openai_api_key: sk-your-key-here`
4. Install gem: `bundle install`

## Security

- AI user account has a secure random password
- Admin access is restricted to specific email
- All AI-generated content is clearly marked
- No sensitive data is exposed in AI topics
- OpenAI API key stored securely in Rails credentials

## Future Enhancements

Potential improvements:
- Multiple AI models for different content types
- Content moderation integration
- User feedback collection
- Performance analytics
- A/B testing for prompts
- Seasonal topic variations
- Multi-language support
- Social media integration 