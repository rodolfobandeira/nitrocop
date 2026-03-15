---
name: fix-continue
description: Tell a fix-department session to continue working on the next batch.
---

# Fix Continue — Resume a Fix Session

Continue with the fix workflow:

- If you were between batches, proceed to Phase 1 (plan the next batch)
- If you were collecting results, finish collecting and then plan the next batch
- If you were in Phase 0 assessment, continue from where you left off
- If you are resuming in a fresh cloud/worktree environment, rerun the
  `fix-department` bootstrap first (`git submodule update --init --recursive`,
  corpus bundle setup, and local `vendor/corpus` wiring if needed)

Resume the normal workflow as described in the skill instructions.

## Arguments

- `/fix-continue` — resume the fix loop
