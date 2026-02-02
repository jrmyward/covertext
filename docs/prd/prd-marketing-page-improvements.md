# PRD: Marketing Page Improvements for Launch

## Introduction

Refine CoverText's public marketing pages to achieve launch clarity, trust, and simplicity. This work focuses exclusively on unauthenticated public pages—no application logic, billing integration, or admin UI changes are included.

The goal is to ensure first-time visitors (independent insurance agency owners) can quickly understand what CoverText does, who it's for, how much it costs, and how to get started.

## Goals

- Present a consistent, professional public-facing experience across all marketing pages
- Eliminate confusing "Pilot" language in favor of clear "Free Trial" messaging
- Communicate transparent, single-plan pricing ($49/month per agency)
- Build trust through honest, non-hyperbolic copy
- Reduce friction for first-time visitors exploring the product

## User Stories

### US-001: Add Global Public Header
**Description:** As a first-time visitor, I want a consistent navigation header so I can easily find login and signup on any public page.

**Acceptance Criteria:**
- [ ] Header appears on homepage and all public marketing pages
- [ ] Left side displays "CoverText" wordmark (text-based logo)
- [ ] Right side contains "Log in" text link routing to `/login`
- [ ] Right side contains primary CTA button ("Start Free Trial") routing to signup flow
- [ ] Header is visually lightweight, does not distract from hero content
- [ ] No visual overlap or broken layout on mobile viewports
- [ ] Typecheck/lint passes
- [ ] Verify in browser using dev-browser skill

---

### US-002: Replace "Start a Pilot" Language Site-Wide
**Description:** As a visitor, I want clear CTA language so I understand I can start a free trial without ambiguity.

**Acceptance Criteria:**
- [ ] All instances of "Start a Pilot" replaced with "Start Free Trial" (or "Get Started" where appropriate)
- [ ] CTA text is consistent across header, hero section, and pricing section
- [ ] No public page contains the word "Pilot"
- [ ] Typecheck/lint passes
- [ ] Verify in browser using dev-browser skill

---

### US-003: Simplify Pricing Section to Single Plan
**Description:** As a visitor, I want to see one simple price so I understand exactly what CoverText costs.

**Acceptance Criteria:**
- [ ] Only one pricing card is displayed
- [ ] Price shown as "$49 / month"
- [ ] "Per Agency" clarifier displayed below price
- [ ] "Cancel anytime" messaging is present
- [ ] No Growth plan, Enterprise plan, or "contact us" upsell language exists
- [ ] Typecheck/lint passes
- [ ] Verify in browser using dev-browser skill

---

### US-004: Refine Hero and Marketing Copy
**Description:** As a visitor, I want clear, professional copy so I quickly understand what CoverText does.

**Acceptance Criteria:**
- [ ] Hero subheadline is readable and confidence-building
- [ ] Tone is professional and insurance-appropriate (no hype, no jargon)
- [ ] No new features are implied beyond current product behavior
- [ ] Existing feature explanations preserved unless clearly improved
- [ ] Typecheck/lint passes
- [ ] Verify in browser using dev-browser skill

---

### US-005: Refine "What CoverText Does NOT Do" Section
**Description:** As a visitor, I want to understand product boundaries so I have realistic expectations.

**Acceptance Criteria:**
- [ ] Section remains visible on homepage
- [ ] Language is unambiguous and non-technical
- [ ] Clear distinction between CoverText billing (subscription) vs. agency client billing/payments
- [ ] No over-promising or confusion about capabilities
- [ ] Typecheck/lint passes
- [ ] Verify in browser using dev-browser skill

---

### US-006: Add Consistent Footer Navigation
**Description:** As a visitor, I want footer links so I can access login and legal pages without scrolling to top.

**Acceptance Criteria:**
- [ ] Footer includes "Log in" link routing to `/login`
- [ ] Footer includes "Privacy Policy" link
- [ ] Footer includes "Terms of Service" link
- [ ] All footer links function correctly
- [ ] Footer appears on all public pages
- [ ] Typecheck/lint passes
- [ ] Verify in browser using dev-browser skill

---

### US-007: Refine Compliance/Trust Language
**Description:** As a visitor, I want to trust that CoverText handles SMS responsibly without seeing overclaimed certifications.

**Acceptance Criteria:**
- [ ] Existing compliance section retained
- [ ] No claims of certification or legal guarantees
- [ ] Messaging conveys "built with SMS compliance in mind" without over-promising
- [ ] Tone remains professional and appropriately cautious
- [ ] Typecheck/lint passes
- [ ] Verify in browser using dev-browser skill

---

## Functional Requirements

- **FR-001:** Add a global header component to all public marketing pages with CoverText wordmark (left), "Log in" link (right), and "Start Free Trial" button (right)
- **FR-002:** Replace all instances of "Start a Pilot" with "Start Free Trial" across all public pages
- **FR-003:** Display a single pricing card showing "$49 / month" with "Per Agency" clarifier and "Cancel anytime" messaging; remove all multi-tier or enterprise pricing references
- **FR-004:** Refine hero subheadline and marketing copy for clarity, professionalism, and accuracy
- **FR-005:** Update "What CoverText Does NOT Do" section to clarify billing terminology and maintain explicit product boundaries
- **FR-006:** Add footer navigation with "Log in", "Privacy Policy", and "Terms of Service" links on all public pages
- **FR-007:** Adjust compliance/trust language to avoid legal overclaims while maintaining professional credibility

## Non-Goals (Out of Scope)

- No Growth or Enterprise pricing plans
- No demo scheduling flow or contact forms
- No testimonials or case studies
- No AI/LLM messaging or features
- No changes to logged-in admin UI
- No backend or billing logic changes
- No graphic logo design work (text wordmark only)
- No major visual redesign—reuse existing Tailwind/DaisyUI components

## Design Considerations

- Reuse existing Tailwind CSS and DaisyUI component system
- Text-based "CoverText" wordmark is sufficient (no graphic logo)
- Mobile responsiveness required for all changes
- Header should be visually lightweight; sticky behavior is optional
- Maintain existing page layout structure

## Technical Considerations

- All changes are frontend/view-only (ERB templates, partials)
- No database migrations required
- No controller or model changes
- Shared header/footer should be extracted to partials for reuse
- Routes for login and signup already exist

## Success Metrics

- First-time visitors understand what CoverText does, who it's for, how much it costs, and how to get started within 10 seconds
- Public pages feel trustworthy to insurance agency owners
- No confusion about pricing or plans
- Zero instances of "Pilot" language remain on public pages
- Consistent CTA language across all touchpoints

## Open Questions

- None—scope is well-defined and limited to public marketing pages
