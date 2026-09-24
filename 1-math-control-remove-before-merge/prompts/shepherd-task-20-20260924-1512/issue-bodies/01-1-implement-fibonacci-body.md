## Campaign context and required reading

On the `experiment/shepherd-control` branch, the directory `1-math-control-remove-before-merge` contains the plan (`math-tool-ignorance-reduction-plan.md`) and supporting resources (diagrams, decision records). Spike subdirectories are research artifacts — read the plan's Resolution sections for findings, not the spike source code.

Read the entire plan before working. Then carefully re-read these exact sections:

- `## Ignorance reduction`
- `### Repository-owned validation`
- `### Output and ordering contracts`
- `## Implementation`
- `### 1. Implement Fibonacci with unit and isolated CLI coverage`

Carry these resolved decisions into the implementation:

- The repository-owned acceptance command is exactly `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1`. The pull-request workflow installs Pester 5.7.1 and invokes that runner; do not replace or bypass either contract.
- Direct CLI execution writes exactly one result line to stdout in the form `Fibonacci(N) = value`.
- `Get-Fibonacci` returns only the numeric value, with no incidental output.
- Inputs are non-negative integers.
- The production and test files are repository-root `math-tool.ps1` and `math-tool.Tests.ps1`.

Research established that the repository-owned runner treats the implementation and test files as an inseparable pair and invokes the Pester suite only when both exist. Implement production code and production tests from scratch; do not copy or adapt throwaway spike code.

## Branch and execution order

Target `experiment/shepherd-control` as the PR base branch. This is task 1 of 2. Tasks are assigned, completed, and merged serially in the listed plan order. Do not start work until this issue is assigned to you. Task 2 must not begin until this task is merged into the base branch.

## Implement

Create repository-root `math-tool.ps1` with:

- A script parameter named `N` accepting non-negative integer input.
- A pure `Get-Fibonacci` function that returns the Fibonacci value for `N` without writing incidental output.
- Direct-execution behavior that writes exactly `Fibonacci(N) = value` followed only by the shell's normal line termination.

Create repository-root `math-tool.Tests.ps1` with:

- Dot-sourced unit tests for `Get-Fibonacci`.
- Isolated child-`pwsh` process tests for direct CLI behavior so CLI output is tested independently of the current test process.
- Coverage for `N=0`, `N=1`, and at least one small representative value greater than 1.

Keep the implementation objective and small. Preserve the exact file locations and observable output contract.

## Completion gates

- `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1` exits zero.
- Unit tests prove the exact numeric results for `N=0`, `N=1`, and a representative value.
- CLI tests prove each invocation exits zero and stdout contains exactly one result line with the required spelling, capitalization, spacing, input, and value.
- Tests discriminate function behavior from script behavior: dot-sourcing validates that the function returns only a number, while child-process execution validates the exact CLI contract.
- `math-tool.ps1` and `math-tool.Tests.ps1` are introduced together.
- The pinned pull-request CI passes with Pester 5.7.1.
- The PR targets `experiment/shepherd-control` and leaves the repository ready for task 2 to extend the same files without repairing task 1 behavior.

## Out of scope

- Do not implement factorial or an `Operation` dispatch parameter; those belong to task 2.
- Do not change the repository-owned test runner, workflow, Pester version, plan, or campaign metadata.
- Do not add unrelated files, dependencies, output, or features.
- Do not broaden the input domain beyond non-negative integers.
