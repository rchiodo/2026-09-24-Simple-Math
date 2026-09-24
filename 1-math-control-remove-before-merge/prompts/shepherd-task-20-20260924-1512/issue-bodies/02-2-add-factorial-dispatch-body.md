## Campaign context and required reading

On the `experiment/shepherd-control` branch, the directory `1-math-control-remove-before-merge` contains the plan (`math-tool-ignorance-reduction-plan.md`) and supporting resources (diagrams, decision records). Spike subdirectories are research artifacts — read the plan's Resolution sections for findings, not the spike source code.

Read the entire plan before working. Then carefully re-read these exact sections:

- `## Ignorance reduction`
- `### Repository-owned validation`
- `### Output and ordering contracts`
- `## Implementation`
- `### 1. Implement Fibonacci with unit and isolated CLI coverage`
- `### 2. Add factorial and operation dispatch`

Carry these resolved decisions into the implementation:

- The repository-owned acceptance command is exactly `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1`. The pull-request workflow installs Pester 5.7.1 and invokes that runner; do not replace or bypass either contract.
- Direct CLI execution writes exactly one result line to stdout: `Fibonacci(N) = value` or `Factorial(N) = value`, according to the selected operation.
- `Get-Fibonacci` and `Get-Factorial` return only numeric values, with no incidental output.
- Inputs are non-negative integers.
- The production and test files remain repository-root `math-tool.ps1` and `math-tool.Tests.ps1`.
- This task begins only after task 1 has merged, and it must preserve task 1's Fibonacci behavior.

Research established that the repository-owned runner requires the implementation and test files together, uses Pester 5.7.1, and runs the combined regression suite. Implement the production extension and tests from scratch; do not copy or adapt throwaway spike code.

## Branch and execution order

Target `experiment/shepherd-control` as the PR base branch. This is task 2 of 2 and depends on merged task 1. Tasks are assigned, completed, and merged serially in the listed plan order. Do not start work until task 1 is merged and this issue is assigned to you.

## Implement

Extend the existing repository-root `math-tool.ps1` from task 1:

- Add a pure `Get-Factorial` function that returns the factorial value for `N` without writing incidental output.
- Add an `Operation` script parameter that dispatches between `fibonacci` and `factorial` while retaining the existing `N` parameter.
- Preserve the existing Fibonacci calculation and exact direct-execution output.
- For factorial direct execution, write exactly `Factorial(N) = value` followed only by the shell's normal line termination.

Extend repository-root `math-tool.Tests.ps1` with focused factorial and dispatch coverage. Preserve all existing Fibonacci unit and isolated CLI tests. Cover factorial values for `N=0`, `N=1`, and at least one small representative value greater than 1.

Keep the interface and test changes objective and small. Follow established repository conventions in the task 1 implementation without changing its observable contract.

## Completion gates

- `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1` exits zero for the combined regression suite.
- Existing Fibonacci unit and isolated child-process CLI tests continue to pass unchanged in behavior.
- Unit tests prove `Get-Factorial` returns exactly `1` for both `N=0` and `N=1`, plus the correct number for a representative value, without incidental output.
- Isolated child-`pwsh` tests prove both operation values dispatch to the correct function, exit zero, and produce exactly one correctly formatted stdout line.
- A discriminating dispatch test uses the same `N` with both operations and proves their results and labels differ as expected, preventing accidental routing of both operations to one implementation.
- The pinned pull-request CI passes with Pester 5.7.1.
- The PR targets `experiment/shepherd-control`.

## Out of scope

- Do not change the Fibonacci contract or remove its existing coverage.
- Do not add operations other than `fibonacci` and `factorial`.
- Do not change the repository-owned test runner, workflow, Pester version, plan, or campaign metadata.
- Do not add unrelated files, dependencies, output, or features.
- Do not broaden the input domain beyond non-negative integers.
