# PRD: Agency Registration

## 1. Introduction/Overview

Build a multi-step agency registration flow that collects agency information, admin user credentials, and payment details via Stripe. The registration must be atomic: if payment fails, the entire signup is blocked. Successful registration logs the admin in immediately and sends a welcome email.

## 2. Goals

- Enable new agencies to self-serve signup with minimal friction
- Collect essential agency and admin contact information
- Require valid payment method (credit card via Stripe) before activation
- Automatically create the first admin user for the agency
- Send welcome email and log admin in upon successful registration
- Keep the flow simple and focused for MVP launch

## 3. User Stories

### US-001: Add agency address fields to database
**Description:** As a developer, I need to store agency name and address information so agencies have complete profiles.

**Acceptance Criteria:**
- [ ] Add fields to agencies table: `name` (required), `address_1`, `address_2`, `city`, `state_code`, `postal_code`, `country_code` (`address_2` optional)
- [ ] Add validation: `name`, `address_1`, `city`, `state_code`, `postal_code`, `country_code` presence required
- [ ] Generate and run migration successfully
- [ ] Tests pass
- [ ] CI passes

### US-002: Add Stripe customer tracking to agency
**Description:** As a developer, I need to link each agency to a Stripe customer so we can manage billing.

**Acceptance Criteria:**
- [ ] Add `stripe_customer_id` field to agencies table (string, indexed)
- [ ] Generate and run migration successfully
- [ ] Tests pass
- [ ] CI passes

### US-003: Add plan selection to agency
**Description:** As a developer, I need to track which plan an agency has selected.

**Acceptance Criteria:**
- [ ] Add `plan_id` field to agencies table (string or integer, default to "$49/month" plan identifier)
- [ ] Generate and run migration successfully
- [ ] Tests pass
- [ ] CI passes

### US-004: Create agency registration form view
**Description:** As a new agency, I want to fill out a registration form so I can sign up for the service.

**Acceptance Criteria:**
- [ ] Registration form collects: agency name, admin first name, admin last name, admin email, admin password, admin password confirmation
- [ ] Agency name is required
- [ ] Plan selection field shows "$49/month" as default and only option
- [ ] Form uses DaisyUI styling consistent with existing auth pages
- [ ] Form is accessible via `/signup` or `/register` route
- [ ] Tests pass
- [ ] CI passes
- [ ] Verify in browser using dev-browser skill

### US-005: Integrate Stripe Elements for payment collection
**Description:** As a new agency, I want to securely enter my credit card details so I can activate my account.

**Acceptance Criteria:**
- [ ] Registration form includes Stripe Elements card input (single unified field or separate card number/expiry/CVC)
- [ ] Stripe publishable key loaded from Rails credentials/ENV
- [ ] Card validation displays inline errors (invalid card, incomplete fields, etc.)
- [ ] Form submission disabled until card input is complete and valid
- [ ] Tests pass (stub Stripe in tests)
- [ ] CI passes
- [ ] Verify in browser using dev-browser skill

### US-006: Create agency registration controller and flow
**Description:** As a developer, I need a controller action that orchestrates agency creation, user creation, and Stripe customer setup.

**Acceptance Criteria:**
- [ ] `RegistrationsController#create` (or similar) handles form submission
- [ ] All-or-nothing transaction: if Stripe fails, rollback agency and user creation
- [ ] On success: create agency, create admin user, create Stripe customer, attach payment method
- [ ] On failure: display clear error message and allow user to retry
- [ ] Tests pass (including Stripe failure scenarios)
- [ ] CI passes

### US-007: Create Stripe customer and attach payment method
**Description:** As the system, I need to create a Stripe customer and attach the payment method during signup so billing can occur.

**Acceptance Criteria:**
- [ ] Use Stripe API to create customer with agency name and admin email
- [ ] Attach payment method token to Stripe customer
- [ ] Store `stripe_customer_id` on agency record
- [ ] Handle Stripe API errors gracefully (card declined, invalid token, etc.)
- [ ] Tests pass (stub Stripe API calls)
- [ ] CI passes

### US-008: Log admin in after successful registration
**Description:** As a new agency admin, I want to be logged in immediately after signup so I don't have to log in separately.

**Acceptance Criteria:**
- [ ] After successful registration, create session for the new admin user
- [ ] Redirect to admin dashboard or appropriate landing page
- [ ] Session should persist like a normal login
- [ ] Tests pass
- [ ] CI passes

### US-009: Send welcome email after registration
**Description:** As a new agency admin, I want to receive a welcome email so I have confirmation and next steps.

**Acceptance Criteria:**
- [ ] Welcome email sent after successful registration (use existing mailer layout)
- [ ] Email includes: welcome message, login link, brief getting started steps
- [ ] Email sent asynchronously via background job
- [ ] Tests pass (verify email queued/sent)
- [ ] CI passes

### US-010: Add validation for unique email addresses
**Description:** As the system, I need to ensure no duplicate admin emails exist so users can log in reliably.

**Acceptance Criteria:**
- [ ] Validate email uniqueness on User model (case-insensitive)
- [ ] Display error on email field if email already exists (client-side or on blur if possible, otherwise on submit)
- [ ] Tests pass (including duplicate email scenarios)
- [ ] CI passes
- [ ] Verify in browser using dev-browser skill

### US-011: Add "Sign up" link to marketing site
**Description:** As a prospective agency, I want a clear call-to-action to sign up so I can start using the service.

**Acceptance Criteria:**
- [ ] Add "Sign up" or "Get Started" link to marketing site header/nav
- [ ] Link routes to registration page
- [ ] Tests pass
- [ ] CI passes
- [ ] Verify in browser using dev-browser skill

## 4. Functional Requirements

- FR-1: The system must collect agency name (required) and optional address fields (address_1, address_2, city, state_code, postal_code, country_code).
- FR-2: The system must collect admin first name, last name, email, and password during registration.
- FR-3: The system must validate email uniqueness across all users.
- FR-4: The system must display a plan selector with "$49/month" as the default and only option for MVP.
- FR-5: The system must integrate Stripe Elements to securely collect credit card details.
- FR-6: The system must create a Stripe customer and attach the payment method before completing registration.
- FR-7: The system must store the Stripe customer ID on the agency record.
- FR-8: The system must use an atomic transaction: if Stripe payment setup fails, rollback agency and user creation entirely.
- FR-9: The system must log the admin user in immediately after successful registration.
- FR-10: The system must send a welcome email asynchronously after successful registration.
- FR-11: The system must redirect the logged-in admin to the dashboard or appropriate landing page.
- FR-12: The system must display clear error messages for Stripe failures (card declined, invalid card, etc.).

## 5. Non-Goals (Out of Scope)

- No email verification/confirmation flow (welcome email is informational only)
- No multi-step wizard UI (single-page form acceptable for MVP)
- No trial period or delayed billing (payment required upfront)
- No multiple plan tiers (only $49/month for MVP)
- No agency name uniqueness validation (can add later)
- No support for users belonging to multiple agencies (future enhancement)
- No promo codes or discounts
- No tax calculation or collection

## 6. Design Considerations

- Reuse existing DaisyUI components and auth page styling
- Keep form layout clean: agency info → admin info → payment → submit
- Use Stripe Elements for PCI compliance (no raw card data touches our server)
- Display Stripe errors inline near the card input
- Consider adding a "Terms of Service" checkbox (optional for MVP)

## 7. Technical Considerations

- Use `stripe` gem for Stripe API integration
- Store Stripe publishable key in Rails credentials or ENV (`STRIPE_PUBLISHABLE_KEY`)
- Store Stripe secret key in Rails credentials or ENV (`STRIPE_SECRET_KEY`)
- Use `ActiveRecord::Base.transaction` to ensure atomicity
- Stripe customer creation and payment method attachment should happen in a service object or controller logic
- Use existing `User` model; ensure it supports `password_digest` (bcrypt)
- Plan ID can be a string like "monthly_49" or reference a future plans table
- Welcome email should reuse existing mailer layout templates

## 8. Success Metrics

- Agency registration completes successfully end-to-end with valid payment
- Invalid or declined cards prevent registration and show clear errors
- Admin is logged in immediately after signup
- Welcome email is delivered within 1 minute of registration
- Zero duplicate email addresses in production

## 9. Open Questions

- Should we add a uniqueness constraint on agency name in a future iteration?
- Do we need to support users belonging to multiple agencies (many-to-many relationship)?
- Should the welcome email include any specific onboarding steps or tutorial links?
- Should we display a loading spinner during Stripe processing?
- Do we need a "Terms of Service" or "Privacy Policy" acceptance checkbox?
- Should we send a notification to internal team when a new agency signs up?
