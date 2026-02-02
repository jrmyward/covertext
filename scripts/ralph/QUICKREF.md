# Ralph Quick Reference

## Commands

```bash
# Generate PRD (in Amp/Claude)
"Create a PRD for [feature]"
# → Saves to docs/prd/prd-feature-name.md

# Convert to Ralph format (in Amp/Claude)
"Convert docs/prd/prd-feature-name.md to Ralph format"
# → Creates scripts/ralph/prd.json

# Run Ralph
cd scripts/ralph
./ralph.sh --tool amp 20

# Check progress
cat scripts/ralph/progress.txt
git log --oneline
bin/rails test

# Full CI check
bin/ci

# After merge, archive the PRD
mkdir -p docs/prd/complete
mv docs/prd/prd-feature-name.md docs/prd/complete/
```

## Story Acceptance Criteria Template

```markdown
### US-XXX: [Title]
**Description:** As a [user], I want [feature] so that [benefit].

**Acceptance Criteria:**
- [ ] Specific verifiable criterion
- [ ] Another criterion
- [ ] All tests pass (bin/rails test)
- [ ] Rubocop clean
- [ ] [UI only] Verify in browser using dev server (bin/dev)
```

## Story Sizing Guide

✅ **Right-sized stories** (completable in one Ralph iteration):
- Add a database column and migration
- Add a UI component to an existing page
- Update a controller action with new logic
- Add a filter dropdown to a list

❌ **Too big** (split these):
- "Build the entire dashboard"
- "Add authentication"
- "Refactor the API"

## Story Dependency Order

1. Schema/database changes (migrations)
2. Model methods and validations
3. Controller actions
4. Views and UI components
5. Filters and dashboards

## CoverText Patterns Ralph Knows

```ruby
# Controller helpers (ALWAYS use these)
current_user      # Returns authenticated User
current_account   # Returns current_user.account
current_agency    # Returns first active agency

# Multi-tenant hierarchy
Account → has_many :agencies, :users
Agency → belongs_to :account, has_many :clients
User → belongs_to :account (NOT agency)

# Test fixtures (not factories)
accounts(:reliable_group)
agencies(:reliable)
users(:john_owner)  # owner role
users(:bob_admin)   # admin role
clients(:alice)
```

## When Ralph Gets Stuck

1. Check `scripts/ralph/progress.txt` for error details
2. Story might be too big - split it
3. Dependencies might be out of order
4. Missing pattern in AGENTS.md - add it

## File Locations

| File | Location | Purpose |
|------|----------|---------|
| PRD markdown (active) | `docs/prd/` | Human-readable feature specs |
| PRD markdown (done) | `docs/prd/complete/` | Completed PRDs |
| PRD JSON | `scripts/ralph/prd.json` | Ralph execution format |
| Progress log | `scripts/ralph/progress.txt` | What Ralph learned |
| Ralph archives | `scripts/ralph/archive/` | Previous runs |
| Ralph config | `scripts/ralph/prompt.md` | Agent instructions |
| Patterns | `AGENTS.md` | Codebase conventions |
| Checklist | `.github/agent-checklist.md` | Standard workflow |

## Amp Skills

In an Amp or Claude session:

```
"create a prd for [feature]"    → Generates PRD markdown
"convert this prd to ralph"     → Creates prd.json
```

Skills are in `scripts/ralph/skill_*.md`
