# PRD: Admin Dashboard & Agency Readiness Flow

## Introduction

CoverText currently lands admins on the Requests page after login, even when the system cannot function because critical setup steps (phone number provisioning) are incomplete. This creates confusion and a mismatch between user expectations and system readiness.

This feature introduces an Admin Dashboard as the primary post-login landing page. The dashboard communicates agency readiness, guides admins through required setup steps, and prevents access to non-functional areas until the system is operational.

## Goals

- Provide clear visibility into agency readiness state (Not Ready → Live)
- Guide admins through required setup steps in the correct order
- Block access to Requests page until phone number is provisioned
- Enable one-click Telnyx phone number provisioning from the dashboard
- Transition dashboard to monitoring/status mode once setup is complete
- Reduce support inquiries related to "nothing is happening"

## User Stories

### US-001: Create Dashboard Route and Controller
**Description:** As a developer, I need a dashboard controller and route so admins have a dedicated landing page.

**Acceptance Criteria:**
- [ ] Create `Admin::DashboardController` with `show` action
- [ ] Add route `get "dashboard", to: "dashboard#show"` in admin namespace
- [ ] Dashboard inherits from `Admin::BaseController` (gets `current_agency`, `current_account`)
- [ ] All tests pass (bin/rails test)
- [ ] Rubocop clean

### US-002: Redirect Login to Dashboard
**Description:** As an admin, I want to land on the Dashboard after login so I see system status immediately.

**Acceptance Criteria:**
- [ ] Update `SessionsController#create` to redirect to `admin_dashboard_path` instead of `admin_requests_path`
- [ ] Update any existing redirects that point to requests as the default landing page
- [ ] Existing tests updated to expect new redirect target
- [ ] All tests pass (bin/rails test)
- [ ] Rubocop clean

### US-003: Create Agency Readiness Concern
**Description:** As a developer, I need a concern that calculates agency readiness state so the dashboard can display status.

**Acceptance Criteria:**
- [ ] Create `Agency::Readiness` concern included in Agency model
- [ ] Expose methods: `subscription_ready?`, `phone_ready?`, `fully_ready?`
- [ ] `subscription_ready?` returns `account.subscription_active?`
- [ ] `phone_ready?` returns `phone_sms.present?`
- [ ] `fully_ready?` returns true only when subscription_ready? AND phone_ready?
- [ ] Note: Webhook configuration is handled at Telnyx Messaging Profile level (already configured)
- [ ] Unit tests for all readiness states
- [ ] All tests pass (bin/rails test)
- [ ] Rubocop clean

### US-004: Dashboard Setup State View
**Description:** As an admin whose agency is not ready, I want to see a clear setup checklist so I know what steps remain.

**Acceptance Criteria:**
- [ ] Dashboard shows "Get CoverText Ready" heading when `!@agency.fully_ready?`
- [ ] Displays checklist with status indicators for each step:
  - Subscription: ✓ Active / ✗ Inactive
  - Dedicated SMS Number: ✓ Provisioned / ✗ Not Provisioned
- [ ] Uses DaisyUI steps or cards component for visual presentation
- [ ] Primary CTA button: "Provision Phone Number" (disabled if subscription inactive)
- [ ] All tests pass (bin/rails test)
- [ ] Rubocop clean
- [ ] Verify in browser using dev server (bin/dev)

### US-005: Dashboard Live State View
**Description:** As an admin whose agency is ready, I want to see system status and basic metrics so I can monitor operations.

**Acceptance Criteria:**
- [ ] Dashboard shows agency phone number (E.164 formatted) when `@agency.phone_ready?`
- [ ] Shows subscription plan name (`@account.plan_name`) and status
- [ ] Shows basic usage summary: total requests count, last request timestamp (or "No requests yet")
- [ ] Shows link to Requests page
- [ ] All tests pass (bin/rails test)
- [ ] Rubocop clean
- [ ] Verify in browser using dev server (bin/dev)

### US-006: Gate Requests Page Access
**Description:** As the system, I need to prevent access to Requests when phone is not provisioned so admins don't see broken/empty states.

**Acceptance Criteria:**
- [ ] Add `before_action :require_phone_provisioned` to `Admin::RequestsController`
- [ ] `require_phone_provisioned` redirects to `admin_dashboard_path` with flash if `!current_agency.phone_ready?`
- [ ] Flash message: "Please provision a phone number before accessing Requests"
- [ ] Tests verify redirect behavior for both provisioned and non-provisioned agencies
- [ ] All tests pass (bin/rails test)
- [ ] Rubocop clean

### US-007: Update Navigation for Dashboard
**Description:** As an admin, I want the navigation to reflect Dashboard as primary and Requests as secondary.

**Acceptance Criteria:**
- [ ] Update [app/views/layouts/admin.html.erb](app/views/layouts/admin.html.erb) sidebar navigation
- [ ] Dashboard link appears first in admin navigation (before Requests)
- [ ] Requests link appears after Dashboard
- [ ] Requests link is visually disabled/grayed when phone not provisioned (use DaisyUI disabled state)
- [ ] Active state correctly highlights current page
- [ ] Update CoverText brand link to point to `admin_dashboard_path` instead of `admin_requests_path`
- [ ] All tests pass (bin/rails test)
- [ ] Rubocop clean
- [ ] Verify in browser using dev server (bin/dev)

### US-008: Telnyx Phone Number Provisioning Service
**Description:** As a developer, I need a service to purchase and configure Telnyx phone numbers so agencies can receive SMS.

**Acceptance Criteria:**
- [ ] Create `Telnyx::PhoneProvisioningService` in `app/services/telnyx/`
- [ ] Service accepts an `Agency` and provisions a number:
  - **Idempotency:** Check performed in service - return success immediately if agency already has `phone_sms` present
  - Searches for available toll-free numbers in US (following existing Telnyx patterns)
  - Purchases the first available number
  - Adds purchased number to existing Telnyx Messaging Profile (webhooks configured at profile level)
- [ ] On success: updates `agency.phone_sms` with E.164 number, sets `agency.live_enabled = true`
- [ ] On failure: returns error result with descriptive message
- [ ] Raises clear error if Telnyx credentials are missing
- [ ] Unit tests with Telnyx API mocked using WebMock (following test_helper.rb patterns)
- [ ] All tests pass (bin/rails test)
- [ ] Rubocop clean

### US-009: Phone Provisioning Controller Action
**Description:** As an admin, I want to click "Provision Phone Number" and have the system automatically set up my SMS number.

**Acceptance Criteria:**
- [ ] Add `Admin::PhoneProvisioningController` with `create` action
- [ ] Route: `post "phone_provisioning", to: "phone_provisioning#create"` in admin namespace
- [ ] Action calls `Telnyx::PhoneProvisioningService.new(current_agency).call`
- [ ] On success: redirect to dashboard with flash success "Phone number provisioned successfully!"
- [ ] On failure: redirect to dashboard with flash error containing failure reason
- [ ] Action requires active subscription (rejects if `!current_account.subscription_active?`)
- [ ] Action requires owner role (rejects if `current_user.role != 'owner'`)
- [ ] Tests with mocked Telnyx service
- [ ] All tests pass (bin/rails test)
- [ ] Rubocop clean
elnyx Provisioning Error Recovery
**Description:** As a developer, I need the system to handle partial provisioning failures gracefully so agencies don't end up in broken states.

**Acceptance Criteria:**
- [ ] If phone purchase succeeds but messaging profile addition fails:
  - Log error with purchased phone number details
  - Return failure result (do not update agency)
  - Error message: "Phone number purchased but configuration failed. Please contact support with error code: [error_details]"
- [ ] If any Telnyxtions in error message for manual cleanup
- [ ] If any Twilio API call fails, do not update `agency.phone_sms` or `agency.live_enabled`
- [ ] All database updates happen in a transaction (wrap in `ActiveRecord::Base.transaction`)
- [ ] Service returns structured result object with success/failure status and message
- [ ] Unit tests cover partial failure scenarios
- [ ] All tests pass (bin/rails test)
- [ ] Rubocop clean

### US-011: Provision Button Integration
**Description:** As an admin, I want the "Provision Phone Number" button to trigger provisioning and show me the result.

**Acceptance Criteria:**
- [ ] Setup state view includes form with button posting to `admin_phone_provisioning_path`
- [ ] Button is disabled with tooltip when subscription is inactive
- [ ] Button shows loading state during submission (use Turbo data-turbo-submits-with)
- [ ] After success, dashboard automatically shows Live state
- [ ] After failure, error message displayed via flash
- [ ] All tests pass (bin/rails test)
- [ ] Rubocop clean
- [ ] Verify in browser using dev server (bin/dev)

### US-012: Add Telnyx Credentials Documentation
**Description:** As a developer, I need Telnyx credentials documented so the provisioning service can be configured.

**Acceptance Criteria:**
- [ ] Update [docs/CREDENTIALS_SETUP.md](docs/CREDENTIALS_SETUP.md) with required Telnyx credentials for provisioning:
  - `telnyx.api_key` (already documented for messaging)
  - `telnyx.messaging_profile_id` (for adding numbers to profile)
- [ ] Document ENV var fallbacks: `TELNYX_API_KEY`, `TELNYX_MESSAGING_PROFILE_ID`
- [ ] Note: Inbound SMS webhooks configured at messaging profile level (point to `/webhooks/telnyx/inbound`)
- [ ] Service checks credentials and raises descriptive error if missing
- [ ] All tests pass (bin/rails test)
- [ ] Rubocop clean

### US-013: Update Seed Data for Testing
**Description:** As a developer, I need seed data that includes an agency without phone_sms so I can test the provisioning flow.

**Acceptance Criteria:**
- [ ] Update [db/seeds.rb](db/seeds.rb) to create third agency without `phone_sms` and with `live_enabled: false`
- [ ] Update [test/models/seed_test.rb](test/models/seed_test.rb) expectations to match (3 agencies total)
- [ ] Test seed data: `env RAILS_ENV=test bin/rails db:seed:replant`
- [ ] All tests pass (bin/rails test)
- [ ] Rubocop clean

### US-014: Integration Test for Full Provisioning Flow
**Description:** As a developer, I need an integration test covering the complete provisioning flow to ensure reliability.

**Acceptance Criteria:**
- [ ] Test: Admin logs in → sees setup state → clicks provision → sees live state
- [ ] Test: Admin with inactive subscription sees disabled provision button
- [ ] Test: Provisioning failure displays error, dashboard stays in setup state
- [ ] Test: After provisioning, Requests page is accessible (no redirect)
- [ ] Test: Attempting to provision when phone already exists returns success without API calls
- [ ] All tests pass (bin/rails test)
- [ ] Rubocop clean

## Functional Requirements

- FR-1: Dashboard shall be the default landing page after admin login
- FR-2: Dashboard shall display a readiness checklist when agency is not fully ready
- FR-3: Dashboard shall display agency status and metrics when agency is fully ready
- FR-4: Readiness checklist shall show: Subscription status, Phone provisioning status
- FR-5: "Provision Phone Number" button shall be disabled when subscription is inactive
- FR-6: Phone provisioning shall purchase a Twilio number, add it to messaging service, and update agency record atomically
- FR-7: Phone provisioning success shall set elnyx toll-free number, add it to messaging profilled = true`
- FR-8: Phone provisioning shall be idempotent (return success if phone already provisioned)
- FR-9: Requests page shall redirect to Dashboard with message when phone not provisioned
- FR-10: Navigation shall show Dashboard as primary, Requests as secondary
- FR-11: Dashboard shall use Turbo for form submissions to avoid full page reloads
- FR-12: Dashboard shall skip `require_active_subscription` to allow access for billing issue resolution

## Non-Goals (Out of Scope)

- Analytics-heavy dashboards or customizable widgets
- Multi-number support (one number per agency for MVP)
- Manual phone number entry or BYO number flows
- A2P status display (internal compliance concern, not customer-facing)
- Phone number porting or transfer functionality
- Usage billing or metering display
- Area code selection for phone numbers
- Internationalization (US phone numbers only for MVP)
- Phone number release/cancellation (agencies keep their number once provisioned)

## Design Considerations

- Use DaisyUI `steps` component for the setup checklist (vertical stepper style)
- Use `badge` components for status indicators (badge-success, badge-warning, badge-error)
- Use `card` component for the live state metrics display
- Keep layout consistent with existing admin pages (use [app/views/layouts/admin.html.erb](app/views/layouts/admin.html.erb))
- Mobile-responsive design required
- **Prefer ViewComponents over partials** for reusable UI elements

## Technical Considerations

- **Telnyx Gem:** Already installed and configured (see [docs/prd/complete/prd-telnyx-sms-integration.md](docs/prd/complete/prd-telnyx-sms-integration.md))
- **Credentials:** Telnyx credentials stored in `development.yml.enc` and `production.yml.enc` with ENV fallback (see test/test_helper.rb for test patterns)
- **Messaging Profile:** Webhooks configured at Telnyx Messaging Profile level, pointing to `/webhooks/telnyx/inbound` (route already exists)
- **Error Handling:** Telnyx API errors should be caught and displayed as user-friendly flash messages
- **Idempotency:** Provisioning should check if agency already has a phone number and return success immediately without API calls
- **Existing Patterns:** Use `current_agency` and `current_account` helpers from `Admin::BaseController`
- **Data Model:** Agency already has `live_enabled` boolean field (default: false) - no migration needed
- **Test Mocking:** Use WebMock for Telnyx API stubs (see test/test_helper.rb for existing Telnyx patterns)
- **Dashboard Access:** Dashboard controller should skip `require_active_subscription` (similar to BillingController) so users can diagnose issues
- **Role Restriction:** Phone provisioning action restricted to owner role only
- **Subscription Causes:** When subscription is inactive, redirect to the appropriate remedy (billing page) with descriptive flash message explaining the specific issue

## Success Metrics

- 100% of new admins see Dashboard before Requests page
- No admin can access empty/broken Requests page
- Phone provisioning success rate > 95%
- Reduction in "nothing is happening" support tickets
- Time from signup to live agency < 5 minutes

## Open Questionselnyx phone number ID (`phone_sid` field) for future management? (Can add if needed)
- Should we add a "test SMS" feature to verify the number works before going live?
- Should Dashboard show guidance for testing the number after provisioning?
- **Testing Strategy:** Should we use seed data with an agency without phone_sms for testing, or create proper fixtures? (Fixtures recommended for isolated, repeatable tests; seeds are for dev database only)nagement? (Can add if needed)
- Should we add a "test SMS" feature to verify the number works before going live?
- Should Dashboard show guidance for testing the number after provisioning?
