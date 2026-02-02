# Completed PRDs

This directory contains Product Requirements Documents for features that have been:
- Fully implemented
- Passed all tests (bin/ci)
- Merged to main branch

## Organization

Move PRDs here after successful completion to keep the parent `docs/prd/` directory focused on active/in-progress work.

```bash
# After merging a completed feature:
mv docs/prd/prd-feature-name.md docs/prd/complete/
```

## Archive Reference

For Ralph-implemented features, the execution details (progress logs, thread URLs) are archived in:
```
scripts/ralph/archive/YYYY-MM-DD-feature-name/
├── prd.json          # Final state with all stories marked passes: true
└── progress.txt      # Implementation log with learnings
```

The PRD markdown in this directory is the original specification; check the Ralph archive for implementation details.
