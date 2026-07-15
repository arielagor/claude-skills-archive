---
name: fix-with-tests
description: Fix a bug using test-driven approach — write a failing test first, then iterate autonomously until all tests pass. Use when fixing bugs, debugging issues, or when the user says "fix" or "debug".
user_invocable: true
---

# Test-First Bug Fix

Fix bugs by writing a failing test BEFORE attempting any fix, then iterating autonomously until green.

## Steps

1. **Understand the bug.** Read the user's description. If they reference a file or error, read it.

2. **Find the test infrastructure.** Look for:
   - `jest.config.*`, `vitest.config.*`, `*.test.*`, `*.spec.*`
   - `package.json` scripts containing "test"
   - Determine test runner and conventions

3. **Write a minimal failing test** that reproduces the exact bug:
   - Place it alongside existing tests following project conventions
   - Name it clearly: `it('should not crash when X is null')` etc.
   - Run the test to confirm it FAILS as expected
   - If it passes, the bug description is wrong or already fixed — report this

4. **Analyze the failure** to identify root cause:
   - Read the failing test output carefully
   - Trace the code path that causes the failure
   - Identify the smallest possible fix

5. **Implement the fix.** Make the minimum change needed.

6. **Run the full test suite** (not just the new test):
   - ALL existing tests must still pass
   - The new test must now pass
   - If any test fails, analyze why and iterate — do NOT ask the user, keep trying

7. **Iterate autonomously** if tests fail:
   - Try up to 5 different approaches
   - After each attempt, run the full suite
   - If stuck after 5 attempts, present what you've learned and ask for guidance

8. **Present the solution** only when ALL tests pass:
   - Show the failing test you wrote
   - Show your root cause analysis (1-2 sentences)
   - Show the fix diff
   - Report test results: X passing, 0 failing

## Constraints
- NEVER present a fix without running tests first
- NEVER skip writing the failing test
- NEVER modify existing tests to make them pass (unless they're genuinely wrong)
- Keep fixes minimal — don't refactor surrounding code
- If no test infrastructure exists, set it up first (Jest for JS/TS, pytest for Python)
