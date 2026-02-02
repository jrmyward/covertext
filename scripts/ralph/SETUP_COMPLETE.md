# Ralph + CoverText Integration - Setup Complete

## What Changed

I've customized the Ralph autonomous agent workflow to fit CoverText's conventions and your development practices. Here's what's been updated:

### 1. **Ralph Prompt** (`scripts/ralph/prompt.md`)
   - Added CoverText-specific context (Rails 8, Minitest, multi-tenant patterns)
   - References AGENTS.md and copilot-instructions.md on every iteration
   - Requires `bin/rails test` to pass (not just "typecheck")
   - Uses `bin/dev` for browser testing (not generic dev-browser skill)
   - Knows about Account → Agency → User hierarchy
   - Knows about controller helpers (current_user, current_account, current_agency)

### 2. **PRD Skill** (`scripts/ralph/skill_prd.md`)
   - Saves PRDs to `docs/prd/` (your existing convention)
   - Acceptance criteria include "All tests pass (bin/rails test)" and "Rubocop clean"
   - UI stories include "Verify in browser using dev server (bin/dev)"
   - Examples use Rails/Minitest patterns

### 3. **Ralph Converter Skill** (`scripts/ralph/skill_ralph.md`)
   - Outputs to `scripts/ralph/prd.json` (not tasks/)
   - Uses CoverText test requirements
   - Knows about fixture usage (not factories)
   - Archives to `scripts/ralph/archive/`

### 4. **Documentation**
   - `scripts/ralph/README.md` - Comprehensive workflow guide
   - `scripts/ralph/QUICKREF.md` - Quick reference card

## Your Workflow Options

### Option 1: Pure Ralph (Autonomous)
1. Create PRD in `docs/prd/` (manually or with prd skill)
2. Convert to prd.json: `"convert docs/prd/prd-X.md to ralph"`
3. Run Ralph: `cd scripts/ralph && ./ralph.sh --tool amp 20`
4. Review commits, run `bin/ci`, merge

### Option 2: Hybrid (Recommended)
1. Create PRD in `docs/prd/` - plan the feature
2. Review/refine stories - ensure right-sized and ordered
3. Let Ralph implement foundation (migrations, models, tests)
4. Take over for polish (UI refinement, edge cases)
5. Update AGENTS.md with new patterns discovered

### Option 3: Manual with Ralph for Repetitive Work
1. Implement complex/exploratory parts yourself
2. Create mini-PRD for repetitive work (CRUD, tests, etc.)
3. Let Ralph finish the repetitive parts
4. Review and merge

## File Organization

```
CoverText/
├── docs/prd/                    # PRD markdown files
│   ├── prd-feature-name.md     # Active/in-progress PRDs
│   └── complete/               # Completed and merged PRDs
├── scripts/ralph/               # Ralph execution environment
│   ├── README.md               # Workflow guide
│   ├── QUICKREF.md             # Quick reference
│   ├── prompt.md               # Ralph instructions (CoverText-customized)
│   ├── ralph.sh                # Execution script
│   ├── prd.json                # Current PRD in execution format
│   ├── progress.txt            # Ralph's learning log
│   ├── skill_prd.md            # PRD generation skill
│   ├── skill_ralph.md          # PRD conversion skill
│   └── archive/                # Previous Ralph runs
├── AGENTS.md                    # Ralph reads this every iteration
└── .github/
    ├── copilot-instructions.md  # Ralph reads this too
    └── agent-checklist.md       # Standard workflow
```

## What Ralph Knows About CoverText

Ralph is pre-configured with:

✅ **Tech Stack:**
- Rails 8 + PostgreSQL (no Node)
- Hotwire (Turbo, Stimulus)
- Minitest (not RSpec)
- Tailwind + DaisyUI
- Solid Queue (runs in Puma)

✅ **Architecture:**
- Multi-tenant: Account → Agency → User
- User belongs to Account (NOT Agency)
- Agencies are operational tenants

✅ **Conventions:**
- Use controller helpers (current_user, current_account, current_agency)
- Test with fixtures (not factories)
- Run `bin/rails test` before committing
- Rubocop must be clean

✅ **Patterns:**
- Reads AGENTS.md on every iteration
- Updates AGENTS.md when discovering new patterns
- Maintains "Codebase Patterns" section in progress.txt

## Integration with Your Workflow

Ralph **complements** your existing practices:

- **Doesn't take over tasks/** - You moved PRDs to docs/prd, Ralph respects that
- **Doesn't replace manual work** - Use it when it helps, skip when it doesn't
- **Reads your conventions** - AGENTS.md is the source of truth
- **Learns as it goes** - Updates progress.txt with discoveries
- **Can be interrupted** - Review at any point, take over when needed

## Next Steps

1. **Try it out** with a small feature:
   ```bash
   # In Amp or Claude:
   "Create a PRD for adding a simple field to agencies"
   "Convert this PRD to Ralph format"

   # Then in terminal:
   cd scripts/ralph
   ./ralph.sh --tool amp 5  # Just 5 iterations to start
   ```

2. **Review the results:**
   - Check `progress.txt` for what Ralph learned
   - Run `bin/ci` to verify quality
   - Look at commits to see how Ralph implements stories

3. **Refine as needed:**
   - Update `scripts/ralph/prompt.md` with new patterns
   - Add discoveries to AGENTS.md
   - Adjust story sizing in PRDs

## Questions?

- **How do I create PRDs?** → Use `"create a prd for X"` in Amp/Claude or write manually in docs/prd/
- **How do I convert PRDs?** → `"convert docs/prd/prd-X.md to ralph"` in Amp/Claude
- **How do I run Ralph?** → `cd scripts/ralph && ./ralph.sh --tool amp [max_iterations]`
- **How do I check progress?** → `cat scripts/ralph/progress.txt` or `git log --oneline`
- **How do I stop Ralph?** → Ctrl+C, review commits, continue manually or resume later
- **What if Ralph gets stuck?** → Check progress.txt, story might be too big, update AGENTS.md

## Philosophy

Ralph is a tool, not a replacement. It's best for:
- Implementing features with clear requirements
- Repetitive work (migrations, CRUD, tests)
- Following established patterns

You're best for:
- Planning and architecture
- Exploratory work
- Complex judgment calls
- Final polish and integration

The hybrid approach (you plan, Ralph implements, you refine) tends to work best.

---

**Ralph is ready to use with your CoverText conventions.** Start with a small feature to get comfortable, then scale up to larger PRDs.
