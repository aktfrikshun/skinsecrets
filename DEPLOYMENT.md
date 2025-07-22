# Fly.io Deployment Guide for Skin Secrets

## Prerequisites

1. Install Fly CLI: https://fly.io/docs/hands-on/install-flyctl/
2. Sign up for Fly.io: https://fly.io/docs/hands-on/sign-up/
3. Login to Fly: `fly auth login`

## Initial Setup

### 1. Create the Fly App

```bash
# Create the app (this will use the fly.toml configuration)
fly apps create skin-secrets

# Or if you want to use a different name:
fly apps create your-app-name
```

### 2. Set Up Secrets

You'll need to set your Rails master key and other sensitive data:

```bash
# Set Rails master key
fly secrets set RAILS_MASTER_KEY=your_master_key_here

# Set Facebook credentials (if using Facebook integration)
fly secrets set FACEBOOK_PAGE_ACCESS_TOKEN=your_facebook_token
fly secrets set FACEBOOK_PAGE_ID=your_facebook_page_id

# Set any other environment variables
fly secrets set DATABASE_URL=your_database_url
```

### 3. Create Volume for Data Storage

```bash
# Create a volume for persistent data
fly volumes create skin_secrets_data --size 10 --region iad
```

## Deployment

### Deploy the Application

```bash
# Deploy to Fly.io
fly deploy

# Or deploy with specific configuration
fly deploy --config fly.toml
```

### Check Deployment Status

```bash
# Check app status
fly status

# View logs
fly logs

# Open the app in browser
fly open
```

## Configuration Details

### App Configuration (`fly.toml`)

- **App Name**: `skin-secrets`
- **Primary Region**: `iad` (Washington DC)
- **Memory**: 1024MB
- **CPU**: 1 shared CPU
- **Port**: 8080 (internal), 80 (external)

### Environment Variables

The following environment variables are configured:

- `RAILS_ENV=production`
- `RAILS_LOG_TO_STDOUT=true`
- `RAILS_MAX_THREADS=5`
- `RAILS_SERVE_STATIC_FILES=true`
- `WEB_CONCURRENCY=2`
- `SOLID_QUEUE_IN_PUMA=true`
- `PORT=8080`

### Health Checks

- **Endpoint**: `/up`
- **Interval**: 30 seconds
- **Timeout**: 5 seconds
- **Grace Period**: 10 seconds

## Database Setup

### For SQLite (Current Setup)

The app is configured to use SQLite with a persistent volume. The database file will be stored in `/data`.

### For PostgreSQL (Recommended for Production)

If you want to use PostgreSQL instead:

1. Create a Postgres database:
```bash
fly postgres create skin-secrets-db
```

2. Attach it to your app:
```bash
fly postgres attach skin-secrets-db --app skin-secrets
```

3. Update your `config/database.yml` for production.

## Monitoring

### Metrics

Metrics are available at `/metrics` on port 9091.

### Logs

```bash
# View real-time logs
fly logs

# View logs for specific time
fly logs --since 1h
```

## Scaling

### Scale Up

```bash
# Scale to more machines
fly scale count 2

# Scale to larger machines
fly scale vm shared-cpu-2x --memory 2048
```

### Scale Down

```bash
# Scale down to 1 machine
fly scale count 1
```

## Troubleshooting

### Common Issues

1. **Health Check Failing**: Check if `/up` endpoint is working
2. **Database Issues**: Ensure migrations run successfully
3. **Memory Issues**: Consider scaling up memory
4. **Build Failures**: Check Dockerfile and dependencies

### Debug Commands

```bash
# SSH into the running app
fly ssh console

# Check app status
fly status

# View recent deployments
fly releases

# Rollback to previous version
fly deploy --image-label v1
```

## Maintenance

### Update Secrets

```bash
# Update a secret
fly secrets set NEW_SECRET=value

# Remove a secret
fly secrets unset OLD_SECRET
```

### Database Migrations

Migrations run automatically on deployment, but you can run them manually:

```bash
fly ssh console -C "bin/rails db:migrate"
```

## Cost Optimization

- **Auto-stop**: Machines stop when not in use (configured)
- **Min machines**: 1 machine always running
- **Shared CPU**: Most cost-effective option

## Security

- **HTTPS**: Forced for all connections
- **Non-root user**: App runs as user 1000
- **Secrets**: Sensitive data stored as Fly secrets
- **Health checks**: Regular monitoring of app health

## Support

- [Fly.io Documentation](https://fly.io/docs/)
- [Rails on Fly.io](https://fly.io/docs/rails/)
- [Fly.io Community](https://community.fly.io/) 