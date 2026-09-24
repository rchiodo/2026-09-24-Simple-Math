Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'Get-Fibonacci' {
    BeforeAll {
        $mathToolPath = Join-Path $PSScriptRoot 'math-tool.ps1'
        . $mathToolPath
    }

    It 'returns only 0 for N=0' {
        $result = @(Get-Fibonacci -N 0)

        $result.Count | Should -Be 1
        $result[0] | Should -Be 0
    }

    It 'returns only 1 for N=1' {
        $result = @(Get-Fibonacci -N 1)

        $result.Count | Should -Be 1
        $result[0] | Should -Be 1
    }

    It 'returns only 5 for N=5' {
        $result = @(Get-Fibonacci -N 5)

        $result.Count | Should -Be 1
        $result[0] | Should -Be 5
    }
}

Describe 'math-tool.ps1 CLI' {
    BeforeAll {
        $mathToolPath = Join-Path $PSScriptRoot 'math-tool.ps1'
        $powerShellPath = (Get-Process -Id $PID).Path
    }

    It 'prints exactly one result line for N=<N>' -TestCases @(
        @{ N = 0; Expected = 'Fibonacci(0) = 0' }
        @{ N = 1; Expected = 'Fibonacci(1) = 1' }
        @{ N = 5; Expected = 'Fibonacci(5) = 5' }
    ) {
        $output = @(& $powerShellPath -NoLogo -NoProfile -File $mathToolPath -N $N 2>&1)

        $LASTEXITCODE | Should -Be 0
        $output.Count | Should -Be 1
        $output[0] | Should -Be $Expected
    }
}
