# PRD: MVP Authentication QoL

## 1. Introduction/Overview

Improve the authentication experience for agency admins by adding password reset, clearer login feedback, and a welcome email. The goal is to reduce login friction and support burden for early pilot agencies without expanding scope into a full auth rewrite.

## 2. Goals

- Enable agency admins to reset forgotten passwords without manual intervention.
- Provide clear, actionable login error messaging.
- Send a welcome email after signup to confirm account creation and next steps.
- Keep changes minimal and aligned with MVP polish scope.

## 3. User Stories

### US-001: Add password reset request flow
**Description:** As an agency admin, I want to request a password reset so that I can regain access if I forget my password.

**Acceptance Criteria:**
- [ ] Add a “Forgot password?” link on the login page.
- [ ] Admin can submit their email to request a reset.
- [ ] System creates a time-limited reset token tied to the user.
- [ ] System sends a reset email with a secure link.
- [ ] Typecheck/lint passes.
- [ ] Verify in browser using dev-browser skill.

### US-002: Add password reset completion flow
**Description:** As an agency admin, I want to set a new password after receiving a reset link so that I can log in again.

**Acceptance Criteria:**
- [ ] Reset link validates token and expiration.
- [ ] Admin can set a new password and confirmation.
- [ ] Successful reset invalidates the token and logs the admin in or redirects to login.
- [ ] Invalid/expired tokens show a clear error message.
- [ ] Tests pass.
- [ ] Typecheck/lint passes.
- [ ] Verify in browser using dev-browser skill.

### US-003: Improve login error messaging
**Description:** As an agency admin, I want clear login error messaging so that I can fix mistakes quickly.

**Acceptance Criteria:**
- [ ] Login errors distinguish between “email not found” and “incorrect password”.
- [ ] Errors are displayed consistently in the login UI.
- [ ] Tests pass.
- [ ] Typecheck/lint passes.
- [ ] Verify in browser using dev-browser skill.

### US-004: Send welcome email after signup
**Description:** As a new agency admin, I want a welcome email so that I can confirm my account and know next steps.

**Acceptance Criteria:**
- [ ] Welcome email is sent after successful signup.
- [ ] Email includes login link and brief “getting started” steps.
- [ ] Uses existing mailer layout templates.
- [ ] Tests pass.
- [ ] Typecheck/lint passes.

### US-005: Add login page entry points
**Description:** As an agency admin, I want clear links to the login page so I can access authentication quickly.

**Acceptance Criteria:**
- [ ] Add a visible “Log in” link on the marketing site header/nav.
- [ ] Add a “Log in” link in the footer.
- [ ] Login links route to the existing login page.
- [ ] Tests pass.
- [ ] Typecheck/lint passes.

## 4. Functional Requirements

- FR-1: The system must allow an admin to request a password reset by email.
- FR-2: The system must generate and store a secure, time-limited reset token.
- FR-3: The system must send a reset email with a secure link.
- FR-4: The system must allow an admin to set a new password using a valid token.
- FR-5: The system must provide explicit login error messaging for not-found vs incorrect password.
- FR-6: The system must send a welcome email after signup.

## 5. Non-Goals (Out of Scope)

- No multi-factor authentication.
- No SSO or OAuth.
- No account lockout or rate limiting.
- No UI redesign beyond minimal additions to support flows.

## 6. Design Considerations (Optional)

- Reuse existing DaisyUI components for forms and alerts.
- Keep login/signup layout consistent with current styling.
- Add a minimal reset request and reset form view.

## 7. Technical Considerations (Optional)

- Token storage can be added to the `users` table with expiration timestamp.
- Use Rails mailers and existing mailer layouts.
- Ensure reset links use `APP_HOST` and `APP_PROTOCOL` for URL generation.

## 8. Success Metrics

- Password reset flow works end-to-end without manual intervention.
- Login error messaging reduces confusion during pilot onboarding.
- Welcome email delivered for every new agency admin signup.

## 9. Open Questions

- Should the reset flow automatically log the user in after password change, or redirect to login?
- Do we need to notify the admin of password changes via email?
