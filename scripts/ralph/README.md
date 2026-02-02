# Ralph + CoverText Workflow

This directory contains the Ralph autonomous agent configuration for CoverText. Ralph helps implement features by working through user stories autonomously while following CoverText conventions.

## Directory Structure

```
docs/prd/
├── prd-feature-name.md    # Active PRDs (planning/in-progress)
└── complete/              # Completed and merged PRDs

scripts/ralph/
├── README.md              # This file
├── prompt.md              # Ralph agent instructions (customized for CoverText)
├── ralph.sh               # Execution script
├── prd.json               # Current PRD in JSON format (for Ralph execution)
├── progress.txt           # Ralph's progress log
├── skill_prd.md           # Skill for generating PRD markdown files
├── skill_ralph.md         # Skill for converting PRDs to prd.json
└── archive/               # Previous Ralph runs (with progress logs)
```

## Workflow Overview

### 1. PRD Creation (Manual or with `prd` skill)

Create PRD markdown files in `docs/prd/`:

```bash
# Option A: Manually create markdown file
# docs/prd/prd-feature-name.md

# Option B: Use prd skill in Amp/Claude
"Create a PRD for [feature description]"
```

PRDs should follow CoverText conventions:
- User stories sized for single iterations
- Dependencies ordered first (schema → backend → UI)
- Acceptance criteria include: "All tests pass (bin/rails test)", "Rubocop clean"
- UI stories include: "Verify in browser using dev server (bin/dev)"

### 2. Convert PRD to prd.json (with `ralph` skill)

Convert the PRD to Ralph's execution format:

```bash
# In Amp or Claude:
"Convert docs/prd/prd-feature-name.md to Ralph format"
```

This creates `scripts/ralph/prd.json` with:
- Structured user stories
- Priority ordering
- Branch name (ralph/feature-name)
- All stories marked `passes: false`
- **Story IDs as numbers** (e.g., "1", "2", "3") - Ralph adds "US-" prefix in commits

**Important:** Story IDs are scoped to the feature branch, not globally unique. IDs reset for each PRD conversion. The meaningful identifier is the branch name + story ID (e.g., `ralph/marketing-improvements` + `US-3`).

### 3. Run Ralph

Execute Ralph to autonomously implement stories:

```bash
cd scripts/ralph
./ralph.sh --tool amp 20  # Run up to 20 iterations with Amp
```

**Note:** Ralph works on ONE feature at a time. The `prd.json` and `progress.txt` files track the current feature only. When you start a new feature, the previous run auto-archives.

Ralph will:
1. Read AGENTS.md and copilot-instructions.md
2. Pick the highest priority story with `passes: false`
3. Implement the story following CoverText patterns
4. Run `bin/rails test` (must pass)
5. Commit changes: `feat: US-[id] - [title]` (e.g., "feat: US-1 - Add status field")
6. Update prd.json to mark story as `passes: true`
7. Append to progress.txt
8. Repeat until all stories complete or max iterations reached

### 4. Review and Merge

After Ralph completes (or you stop it):

```bash
# Review the changes
git log --oneline

# Review progress
cat scripts/ralph/progress.txt

# Run full CI
bin/ci

# If everything passes, merge the feature branch
git checkout main
git merge ralph/feature-name

# Archive the completed PRD
mkdir -p docs/prd/complete
mv docs/prd/prd-feature-name.md docs/prd/complete/
```

## Best Practices

### Story Sizing
- Each story should complete in one Ralph iteration (one LLM context window)
- If Ralph runs out of context before finishing, the story is too big
- Break large stories into: schema → backend logic → UI components → filters/dashboards

### Dependencies
- Stories execute in priority order
- Earlier stories MUST NOT depend on later ones
- Correct order: Database → Models → Controllers → Views
- Wrong order: Views that depend on schema that doesn't exist yet

### CoverText-Specific Patterns

Ralph is configured to know:
- Multi-tenant architecture (Account → Agency → User)
- Controller helpers (`current_user`, `current_account`, `current_agency`)
- Testing with fixtures (not factories)
- Minitest conventions
- Tailwind + DaisyUI for UI
- Hotwire (Turbo) for page updates

These patterns are in:
- `AGENTS.md` - Data model, controller patterns, gotchas
- `.github/copilot-instructions.md` - Project overview, tech stack
- `scripts/ralph/prompt.md` - Ralph-specific instructions

### Progress Tracking

Ralph maintains two logs:

1. **prd.json** - Execution state (which stories pass/fail)
2. **progress.txt** - Learning log with:
   - What was implemented per story
   - Files changed
   - Patterns discovered
   - Gotchas encountered

The **Codebase Patterns** section at the top of progress.txt consolidates the most important learnings.

### Archiving

When starting a new feature, the previous run auto-archives to:
```
scripts/ralph/archive/YYYY-MM-DD-feature-name/
```

This keeps history without cluttering the working directory.

## Switching Between Ralph and Manual Work

### When to Use Ralph
- Multi-story features with clear requirements
- Repetitive implementation work (migrations, CRUD, tests)
- Features that follow established patterns
- When you want to focus on planning, not typing

### When to Work Manually
- Exploratory work where requirements are unclear
- Complex refactoring requiring judgment calls
- Debugging production issues
- When you want tight control over implementation

### Working on Multiple Features

**Ralph handles ONE feature at a time** via the active `prd.json` and `progress.txt`. To work on multiple features:

1. **Sequential (one feature completes before next starts):**
   - Complete Feature A with Ralph
   - Merge `ralph/feature-a` branch
   - Convert Feature B PRD to prd.json (archives Feature A automatically)
   - Run Ralph for Feature B

2. **Parallel (multiple features in progress):**
   - Work manually on Feature B while Ralph works on Feature A
   - Or use separate branches and manually implement stories from PRD markdown
   - Ralph is best for sequential automation, manual for parallel work

3. **Collaborative (multiple people on one feature):**
   - Commit PRD markdown to `docs/prd/` (version controlled)
   - Person A converts to prd.json and runs Ralph on stories 1-5
   - Person B manually implements stories 6-10 from the markdown PRD
   - Both work on same feature branch, different stories
   - Ralph's prd.json is **ephemeral** (gitignored), markdown is **canonical**

### Hybrid Approach (Recommended)

1. **Plan with PRD skill** - Define user stories, acceptance criteria
2. **Review and refine PRD** - Ensure stories are right-sized and ordered
3. **Let Ralph implement infrastructure** - Database, models, tests
4. **Review Ralph's work** - Check progress.txt, run tests, review commits
5. **Take over for polish** - UI refinements, edge cases, integration
6. **Update AGENTS.md** - Add any new patterns discovered

## Troubleshooting

### Ralph gets stuck on a story
- Check progress.txt to see what's failing
- Story might be too big - split it into smaller pieces
- Missing prerequisite - check if dependencies are out of order

### Tests fail mid-run
- Ralph should not commit failing tests
- If it does, check progress.txt for context
- May need to fix manually and update prd.json

### Ralph duplicates helper logic
- Update AGENTS.md with the helper pattern
- Add to "Codebase Patterns" in progress.txt
- Ralph reads these on every iteration

### Quality checks fail
- Ralph should run `bin/rails test` before committing
- If rubocop fails, check progress.txt for details
- May need to update .rubocop.yml configuration

## Integration with Existing Workflow

Ralph is designed to complement (not replace) your existing workflow:

- **PRDs stay in docs/prd/** - Your existing convention (move to docs/prd/complete/ when done)
- **Execution state in scripts/ralph/** - Ralph's working files
- **AGENTS.md stays authoritative** - Ralph reads it every iteration
- **Agent checklist still applies** - Ralph follows same standards
- **Manual commits mixed with Ralph** - No conflicts

The goal is to let Ralph handle repetitive implementation while you focus on planning, review, and polish.

## Version Control & File Organization

### What Gets Committed

**✅ Commit these:**
- `docs/prd/*.md` - PRD markdown files (source of truth)
- `docs/prd/complete/*.md` - Completed PRD markdown
- Feature implementation (code, tests, migrations)

**❌ Don't commit (gitignored):**
- `scripts/ralph/prd.json` - Generated execution state
- `scripts/ralph/progress.txt` - Ephemeral learning log
- `scripts/ralph/.last-branch` - Tracking file

**📦 Archive separately:**
- `scripts/ralph/archive/` - Previous runs with progress logs
- These provide historical context but don't need to be in git

### Why This Split?

- **PRD markdown** = human-readable, reviewable, collaborative, version controlled
- **prd.json** = machine-readable, ephemeral, regenerated per feature
- **progress.txt** = execution log, useful during the run, archived after

This means you can:
- Review PRD changes in pull requests
- Work on PRD markdown collaboratively
- Regenerate prd.json anytime from markdown
- Keep Ralph's execution state separate from your codebase

## Configuration Files

- **prompt.md** - Main Ralph instructions (customized for CoverText)
- **skill_prd.md** - PRD generation guidance
- **skill_ralph.md** - PRD-to-JSON conversion rules

All three are customized with CoverText patterns and should be updated as you discover new conventions.

## Questions?

Check:
1. progress.txt for recent learnings
2. AGENTS.md for data model patterns
3. .github/agent-checklist.md for standard workflow

If Ralph does something unexpected, it's learning from these files - update them to improve future runs.
