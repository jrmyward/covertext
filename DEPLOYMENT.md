# Deployment Guide

## CoverText Staging Deployment

This guide covers deploying CoverText to the staging environment using Kamal.

### Architecture

**Staging Environment:**
- **Web Role**: Puma serving HTTP requests via kamal-proxy (with SSL)
- **Worker Role**: Solid Queue processing background jobs
- **Database**: PostgreSQL 16 (Kamal accessory)
- **Cache**: Solid Cache (SQLite, persisted in `/var/lib/covertext/staging/data`)
- **Queue**: Solid Queue (SQLite, persisted in `/var/lib/covertext/staging/data`)
- **Cable**: Solid Cable (SQLite, persisted in `/var/lib/covertext/staging/data`)

### Prerequisites

1. **1Password CLI** installed and authenticated
2. **GHCR access** configured with personal access token in 1Password
3. **SSH access** to staging server (159.65.70.168)
4. **DNS configured**: staging.covertext.app → 159.65.70.168

### Initial Setup (One Time)

```bash
# 1. Login to GitHub Container Registry
kamal registry login -d staging

# 2. Setup Kamal infrastructure (volumes, networks)
kamal setup -d staging

# 3. Boot Postgres accessory
kamal accessory boot postgres -d staging

# 4. Verify Postgres is running
kamal accessory logs postgres -d staging

# 5. Deploy application
kamal deploy -d staging

# 6. Prepare databases (run migrations, load schemas)
kamal db-prepare -d staging
```

### Deploying Updates

```bash
# Standard deployment (after code changes)
git push origin main  # Wait for GitHub Actions to build image
kamal deploy -d staging

# If database changes
kamal db-prepare -d staging
```

### Verification

**Check Web Container:**
```bash
kamal app logs -d staging --roles web
curl https://staging.covertext.app/up
```

**Check Worker Container:**
```bash
kamal worker-logs -d staging
```

**Verify Database Connectivity:**
```bash
kamal app exec -d staging "bin/rails runner 'puts ActiveRecord::Base.connection.select_value(\"select 1\")'"
```

**Verify Solid Queue:**
```bash
kamal app exec -d staging "bin/rails runner 'puts SolidQueue::Job.count'"
```

**Test Job Processing:**
```bash
# Queue a test job
kamal app exec -d staging "bin/rails runner 'TestJob.perform_later'"

# Check worker logs
kamal worker-logs -d staging
```

### Troubleshooting

**Web container won't start:**
```bash
# Check logs
kamal app logs -d staging --roles web

# Check health endpoint
kamal app exec -d staging "curl localhost:3000/up"

# Verify environment variables
kamal app exec -d staging "env | grep RAILS"
```

**Worker not processing jobs:**
```bash
# Check worker logs
kamal worker-logs -d staging

# Verify Solid Queue tables exist
kamal app exec -d staging "bin/rails runner 'puts SolidQueue::Job.table_exists?'"

# Check database connection
kamal app exec -d staging "bin/rails runner 'puts ActiveRecord::Base.connection.active?'"
```

**Database connection issues:**
```bash
# Check DATABASE_URL is set
kamal app exec -d staging "env | grep DATABASE_URL"

# Verify Postgres accessory is running
kamal accessory details postgres -d staging

# Test connection from container
kamal app exec -d staging "bin/rails dbconsole" -p
```

**Schema files missing:**
```bash
# Verify schema files in image
kamal app exec -d staging "ls -la /rails/db/*schema.rb"

# Re-run schema load if needed
kamal app exec -d staging "bin/rails db:schema:load:cache db:schema:load:queue db:schema:load:cable"
```

### Rollback

```bash
# Rollback to previous version
kamal rollback -d staging

# If needed, rollback database (manual)
kamal app exec -d staging "bin/rails db:rollback STEP=1"
```

### Common Aliases

```bash
kamal console -d staging    # Rails console
kamal shell -d staging      # Bash shell
kamal logs -d staging       # Web logs
kamal worker-logs -d staging  # Worker logs
kamal dbc -d staging        # Database console
kamal db-prepare -d staging  # Run migrations
```

### Secrets Management

Secrets are stored in **1Password** in the `CoverText/Staging` vault:
- `KAMAL_REGISTRY_PASSWORD`: GitHub Container Registry token
- `RAILS_MASTER_KEY`: Rails credentials master key
- `POSTGRES_PASSWORD`: PostgreSQL password

DATABASE_URL is constructed automatically in `.kamal/secrets.staging`.

### File Structure

```
config/
  deploy.staging.yml    # Kamal staging configuration
  environments/
    staging.rb          # Rails staging environment
  database.yml          # Multi-database configuration
.kamal/
  secrets.staging       # Staging secrets (fetches from 1Password)
  hooks/
    pre-deploy          # Creates volume directories before deployment
    docker-setup        # Legacy hook (now using pre-deploy)
```

### Important Notes

1. **Solid Queue runs in a separate worker container**, not in Puma
2. **DATABASE_URL** must point to `covertext-postgres-staging` (Docker network service name), not `localhost`
3. **SQLite databases** for Cache/Queue/Cable are in `/rails/data`, persisted via volume mount
4. **Schema files** for Solid gems are in `/rails/db` (from Docker image, not volume)
5. **Let's Encrypt SSL** is automatic via kamal-proxy (may take 2-5 minutes on first deployment)

### Production Deployment

Production follows the same pattern but uses:
- `config/deploy.production.yml`
- `.kamal/secrets.production`
- Managed PostgreSQL (Digital Ocean)
- Different host/domain

See production-specific documentation when ready to deploy.
