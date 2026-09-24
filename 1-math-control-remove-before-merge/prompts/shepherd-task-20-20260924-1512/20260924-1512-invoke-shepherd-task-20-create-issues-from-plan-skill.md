Invoke skill `shepherd-task-20-create-issues-from-plan` with these inputs:

- CAMPAIGN_ID: ebe53a6b-9586-41df-8a88-da27f70edf26
- LESSON_PROPAGATION: off
- REPO: rchiodo/2026-09-24-Simple-Math
- BASE_BRANCH: experiment/shepherd-control
- PARENT_ISSUE: 1
- PLAN_DIRECTORY: 1-math-control-remove-before-merge
- PLAN_FILE_NAME: math-tool-ignorance-reduction-plan.md
- QUESTIONS_SECTION: ## Ignorance reduction
- IMPLEMENTATION_SECTION: ## Implementation
- EXPECTED_TASK_COUNT: 2
- BASE_REMOTE: origin
- LOG_DIRECTORY: C:\Users\rchiodo\workareas\2026-09-24-Simple-Math-shepherd-control\1-math-control-remove-before-merge\prompts\shepherd-task-20-20260924-1512
- DRAFT_VALIDATOR: C:\Users\rchiodo\.copilot\plugins\shepherd-task\scripts\validate-stage20-drafts.ps1
- ISSUE_BODY_VERIFIER: C:\Users\rchiodo\.copilot\plugins\shepherd-task\scripts\verify-github-issue-body.ps1

Fixture pagination response contract (mandatory):

- `gh api ... --paginate --slurp` returns a JSON array of page payloads, so a
  one-page response has the shape `[[{...}]]`, not `[{...}]`.
- Before indexing child issue fields such as `.id`, normalize the response to
  one flat issue array exactly once.
- In Bash, use:
  `jq 'if length == 0 then [] elif all(.[]; type == "array") then add else . end'`.
- In PowerShell, capture the `gh` output and `$LASTEXITCODE` first, then pass
  the complete JSON through the same `jq` normalization before
  `ConvertFrom-Json`.
- Use the normalized flat array for the pre-creation baseline, final child
  count/order checks, and failure reconciliation. Do not apply `add` a second
  time to an already-flat array.