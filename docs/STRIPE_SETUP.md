# Stripe Configuration

This application uses Stripe for subscription billing. To configure Stripe:

## 1. Create Stripe Products

In your Stripe Dashboard, create the following products:

- **Pilot Plan**: $49/month recurring subscription
- **Growth Plan**: $99/month recurring subscription

Note the Price IDs for each plan (e.g., `price_1ABC123...`).

## 2. Configure Credentials

Add the following to your Rails credentials:

```yaml
stripe:
  secret_key: sk_test_... # Your Stripe secret key
  publishable_key: pk_test_... # Your Stripe publishable key (not currently used but good to have)
  pilot_price_id: price_1ABC123... # Pilot plan price ID
  growth_price_id: price_1DEF456... # Growth plan price ID
  webhook_secret: whsec_... # Webhook signing secret from Stripe Dashboard
```

### Development/Test

```bash
EDITOR="code --wait" bin/rails credentials:edit
```

### Production

```bash
EDITOR="code --wait" bin/rails credentials:edit --environment production
```

## 3. Set Up Webhooks

In Stripe Dashboard → Developers → Webhooks, add an endpoint:

**URL**: `https://yourdomain.com/webhooks/stripe`

**Events to listen for**:
- `customer.subscription.updated`
- `customer.subscription.deleted`
- `invoice.payment_succeeded`
- `invoice.payment_failed`

Copy the webhook signing secret to your credentials as `stripe.webhook_secret`.

## 4. Test Locally

To test webhooks locally, use the Stripe CLI:

```bash
stripe listen --forward-to localhost:3000/webhooks/stripe
```

This will give you a webhook secret for local testing (starts with `whsec_`).

## Features Implemented

### Public Marketing Site
- Homepage at `/` with product positioning
- Clear value proposition and pricing
- No authentication required

### Self-Serve Signup
- Agency registration at `/signup`
- Creates agency + admin user
- Redirects to Stripe Checkout for payment
- Handles subscription confirmation

### Subscription Management
- Billing page at `/admin/billing`
- Shows current plan and status
- Links to Stripe Customer Portal for:
  - Plan changes
  - Cancellation
  - Payment method updates

### Plan Gating
- `Agency.subscription_active?` - checks if subscription is active
- `Agency.can_go_live?` - checks both subscription AND `live_enabled` flag
- UI banners in admin showing:
  - Subscription issues (if not active)
  - "Not Live" status (if active but not enabled)

### Database Fields

Added to `agencies` table:
- `stripe_customer_id` - Stripe Customer ID (unique)
- `stripe_subscription_id` - Stripe Subscription ID (unique)
- `subscription_status` - Status from Stripe (active, past_due, canceled, etc.)
- `plan_name` - Plan name (pilot, growth)
- `live_enabled` - Boolean flag to control "live" status (default: false)

## Compliance & A2P Readiness

Even with an active subscription, agencies start with `live_enabled: false`. This supports:
- Manual compliance review before activation
- A2P registration verification
- Gradual rollout control

To enable an agency:

```ruby
agency = Agency.find(...)
agency.update!(live_enabled: true)
```

## Next Steps (Not Implemented)

Future enhancements could include:
- Email notifications for failed payments
- Usage-based billing tiers
- Annual billing options
- Team member seats
- Grace periods for past_due subscriptions
