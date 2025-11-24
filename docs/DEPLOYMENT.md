# Deployment Guide

## Overview

The Flutter Partner App is deployed to Cloudflare Pages with automatic deployments via GitHub Actions.

## Live URLs

### Production
- **URL:** https://partner.wifi-4u.net
- **Cloudflare Pages URL:** https://wifi-4u-partner.pages.dev
- **Branch:** `devin/1763121919-api-alignment-patch`
- **Auto-deploys:** On every push to the production branch

### Staging
- **URL:** https://partner-staging.wifi-4u.net
- **Auto-deploys:** On every pull request

### Preview Deployments
- Each PR gets a unique preview URL: `https://<branch-name>.wifi-4u-partner.pages.dev`
- Preview URLs are automatically posted as PR comments

## DNS Configuration

To complete the custom domain setup, add these CNAME records to your DNS:

```
partner.wifi-4u.net          CNAME    wifi-4u-partner.pages.dev
partner-staging.wifi-4u.net  CNAME    wifi-4u-partner.pages.dev
```

**Note:** If wifi-4u.net is already managed by Cloudflare, the DNS records will be automatically configured.

## GitHub Secrets

The following secrets are configured in the repository:

- `CLOUDFLARE_ACCOUNT_ID`: cdbd00e3efae5135a49ed13ac47e0f68
- `CLOUDFLARE_API_TOKEN`: (configured with Cloudflare Pages Edit permissions)

## Manual Deployment

To deploy manually using wrangler CLI:

```bash
# Install wrangler
npm install -g wrangler

# Set environment variables
export CLOUDFLARE_ACCOUNT_ID="cdbd00e3efae5135a49ed13ac47e0f68"
export CLOUDFLARE_API_TOKEN="your-api-token"

# Build the Flutter web app
flutter clean
flutter pub get
flutter build web --release

# Deploy to Cloudflare Pages
wrangler pages deploy build/web --project-name=wifi-4u-partner --branch=main
```

## CORS Configuration

**IMPORTANT:** The backend API must whitelist the following origins to prevent CORS errors:

```
https://partner.wifi-4u.net
https://partner-staging.wifi-4u.net
https://wifi-4u-partner.pages.dev
```

Add these to the CORS allowlist on `https://api.tiknetafrica.com/v1`

## SPA Routing

The deployment includes SPA routing configuration files:

- `web/_redirects`: Routes all requests to index.html (prevents 404s on deep links)
- `web/_headers`: Configures cache control
  - `index.html`: no-cache (ensures users get latest version)
  - Other assets: immutable with 1-year cache (performance optimization)

## Deployment Workflow

1. **Push to production branch** → Automatic deployment to production
2. **Create PR** → Automatic preview deployment with unique URL
3. **Merge PR** → Preview deployment is deleted, production is updated

## Troubleshooting

### Deployment fails with authentication error
- Verify the `CLOUDFLARE_API_TOKEN` secret has "Cloudflare Pages - Edit" permissions
- Check token at: https://dash.cloudflare.com/cdbd00e3efae5135a49ed13ac47e0f68/api-tokens

### App shows CORS errors in browser
- Verify backend has whitelisted the deployment URLs
- Check browser console for exact CORS error message

### Deep links return 404
- Verify `web/_redirects` file exists and contains: `/* /index.html 200`
- Check Cloudflare Pages dashboard for routing configuration

### App shows stale content after deployment
- Verify `web/_headers` file exists with proper cache control
- Clear browser cache or use incognito mode
- Check service worker is not caching aggressively

## Monitoring

- **Cloudflare Pages Dashboard:** https://dash.cloudflare.com/cdbd00e3efae5135a49ed13ac47e0f68/pages/view/wifi-4u-partner
- **GitHub Actions:** https://github.com/Josh84-Axe/Flutter_partnerapp/actions
- **Deployment Logs:** Available in Cloudflare Pages dashboard

## Security Notes

- API tokens should be rotated regularly
- Never commit API tokens to the repository
- Use GitHub Secrets for sensitive credentials
- Monitor Cloudflare Pages access logs for suspicious activity
