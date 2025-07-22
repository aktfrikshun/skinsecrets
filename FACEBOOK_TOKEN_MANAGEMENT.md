# Facebook Token Management Guide

This guide explains how to manage Facebook access tokens for the Skin Secrets application, including getting long-lived tokens and implementing automatic refresh.

## Token Types and Lifespans

### 1. **Short-Lived User Access Token**
- **Lifespan**: 1-2 hours
- **Use Case**: Initial authentication
- **How to get**: User login flow

### 2. **Long-Lived User Access Token**
- **Lifespan**: 60 days
- **Use Case**: Extended user sessions
- **How to get**: Exchange short-lived token

### 3. **Page Access Token**
- **Lifespan**: Varies (can be long-lived)
- **Use Case**: Posting to Facebook pages
- **How to get**: From user token with page permissions

### 4. **App Access Token**
- **Lifespan**: Never expires (but can be invalidated)
- **Use Case**: Server-to-server API calls
- **How to get**: Using app ID and app secret

## Getting a Long-Lived Token

### Method 1: Using the Rake Task (Recommended)

```bash
# First, add your Facebook App credentials
rails credentials:edit
# Add:
#   facebook_app_id: your_app_id
#   facebook_app_secret: your_app_secret

# Then convert your current token to long-lived
rails facebook_token:convert_to_long_lived
```

### Method 2: Manual Process

1. **Get your Facebook App ID and App Secret**
   - Go to [Facebook Developers](https://developers.facebook.com/)
   - Select your app
   - Go to Settings > Basic
   - Copy App ID and App Secret

2. **Exchange your current token**
   ```bash
   curl -X GET "https://graph.facebook.com/v18.0/oauth/access_token?grant_type=fb_exchange_token&client_id=YOUR_APP_ID&client_secret=YOUR_APP_SECRET&fb_exchange_token=YOUR_CURRENT_TOKEN"
   ```

3. **Update the token on Fly.io**
   ```bash
   fly secrets set FACEBOOK_PAGE_ACCESS_TOKEN="your_new_long_lived_token" --app skin-secrets
   ```

## Automatic Token Refresh

### Option 1: Built-in Retry Logic

The `FacebookService` now includes automatic retry logic that:
- Detects expired tokens (error code 190)
- Automatically refreshes using app credentials
- Retries the failed operation

**Requirements**: Set `FACEBOOK_APP_ID` and `FACEBOOK_APP_SECRET` environment variables.

### Option 2: Scheduled Refresh (Cron Job)

```bash
# Set up automatic refresh
rails facebook_token:setup_auto_refresh

# Add to crontab (runs daily at 2 AM)
crontab -e
# Add: 0 2 * * * /Users/allentaylor/src/skin_secrets/scripts/refresh_facebook_token.sh
```

### Option 3: Manual Refresh Commands

```bash
# Check token status
rails facebook_token:check_status

# Refresh token manually
rails facebook_token:refresh
```

## Setting Up App Credentials

### 1. Get App ID and App Secret

1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Select your app
3. Go to Settings > Basic
4. Copy App ID and App Secret

### 2. Add to Environment Variables

```bash
# Add to Fly.io secrets
fly secrets set FACEBOOK_APP_ID="your_app_id" --app skin-secrets
fly secrets set FACEBOOK_APP_SECRET="your_app_secret" --app skin-secrets

# Or add to Rails credentials
rails credentials:edit
# Add:
#   facebook_app_id: your_app_id
#   facebook_app_secret: your_app_secret
```

## Testing Token Management

### Check Current Token Status

```bash
# Test connection
fly ssh console --app skin-secrets --command "bundle exec rails runner 'service = FacebookService.new; result = service.test_connection; puts result.inspect'"

# Check detailed status
rails facebook_token:check_status
```

### Test Automatic Refresh

```bash
# Test posting (will trigger refresh if needed)
fly ssh console --app skin-secrets --command "bundle exec rails runner 'service = FacebookService.new; result = service.post_message(\"Test message - #{Time.current}\"); puts result.inspect'"
```

## Best Practices

### 1. **Use Long-Lived Tokens**
- Convert short-lived tokens to long-lived tokens
- Monitor token expiration dates
- Refresh before expiration

### 2. **Store App Credentials Securely**
- Never commit app secrets to version control
- Use environment variables or Rails credentials
- Rotate app secrets regularly

### 3. **Implement Monitoring**
- Log token refresh attempts
- Monitor for failed posts
- Set up alerts for token issues

### 4. **Handle Errors Gracefully**
- Implement retry logic
- Log detailed error messages
- Provide fallback behavior

## Troubleshooting

### Common Issues

1. **"App ID or App Secret not configured"**
   - Set `FACEBOOK_APP_ID` and `FACEBOOK_APP_SECRET` environment variables
   - Or add to Rails credentials

2. **"Token expired" errors**
   - Use `rails facebook_token:convert_to_long_lived` to get a long-lived token
   - Set up automatic refresh

3. **"Permission denied" errors**
   - Ensure your app has the required permissions
   - Check that the page access token has the right scopes

4. **Posts not appearing on Facebook**
   - Check token validity with `rails facebook_token:check_status`
   - Verify page permissions
   - Check Facebook app review status

### Debug Commands

```bash
# Check all Facebook-related environment variables
fly secrets list --app skin-secrets

# Test Facebook connection
rails facebook_token:check_status

# Test posting with detailed logs
fly ssh console --app skin-secrets --command "bundle exec rails runner 'service = FacebookService.new; result = service.post_message(\"Debug test - #{Time.current}\"); puts result.inspect'"

# Check Rails logs for Facebook errors
fly logs --app skin-secrets | grep -i facebook
```

## Security Considerations

1. **Token Storage**
   - Store tokens securely (environment variables, not in code)
   - Rotate tokens regularly
   - Monitor for unauthorized access

2. **App Permissions**
   - Use minimum required permissions
   - Review app permissions regularly
   - Remove unused permissions

3. **Error Handling**
   - Don't expose sensitive information in error messages
   - Log errors securely
   - Implement rate limiting

## Monitoring and Alerts

### Set up monitoring for:
- Token expiration dates
- Failed Facebook posts
- Token refresh attempts
- API rate limit errors

### Recommended monitoring tools:
- Rails logs with structured logging
- External monitoring services
- Facebook App Insights
- Custom health checks

## Next Steps

1. **Immediate**: Get your Facebook App ID and App Secret
2. **Short-term**: Convert your current token to long-lived
3. **Medium-term**: Set up automatic refresh
4. **Long-term**: Implement comprehensive monitoring

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review Facebook's API documentation
3. Check the Rails logs for detailed error messages
4. Test with the provided rake tasks 