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

    It 'returns only 8 for N=6' {
        $result = @(Get-Fibonacci -N 6)

        $result.Count | Should -Be 1
        $result[0] | Should -Be 8
    }
}

Describe 'Get-Factorial' {
    BeforeAll {
        $mathToolPath = Join-Path $PSScriptRoot 'math-tool.ps1'
        . $mathToolPath
    }

    It 'returns only 1 for N=0' {
        $result = @(Get-Factorial -N 0)

        $result.Count | Should -Be 1
        $result[0] | Should -Be 1
    }

    It 'returns only 1 for N=1' {
        $result = @(Get-Factorial -N 1)

        $result.Count | Should -Be 1
        $result[0] | Should -Be 1
    }

    It 'returns only 120 for N=5' {
        $result = @(Get-Factorial -N 5)

        $result.Count | Should -Be 1
        $result[0] | Should -Be 120
    }
}

Describe 'math-tool.ps1 CLI' {
    BeforeAll {
        $mathToolPath = Join-Path $PSScriptRoot 'math-tool.ps1'
        $powerShellPath = (Get-Command pwsh -CommandType Application | Select-Object -First 1).Source
        $invokeMathTool = {
            param([string[]] $Arguments)

            $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
            $startInfo.FileName = $powerShellPath
            $startInfo.UseShellExecute = $false
            $startInfo.RedirectStandardOutput = $true
            $startInfo.RedirectStandardError = $true
            foreach ($argument in @('-NoLogo', '-NoProfile', '-File', $mathToolPath) + $Arguments) {
                [void] $startInfo.ArgumentList.Add($argument)
            }

            $process = $null
            try {
                $process = [System.Diagnostics.Process]::Start($startInfo)
                $stdoutTask = $process.StandardOutput.ReadToEndAsync()
                $stderrTask = $process.StandardError.ReadToEndAsync()
                $process.WaitForExit(10000) | Should -BeTrue -Because 'math-tool.ps1 should exit within 10 seconds'
                [PSCustomObject] @{
                    ExitCode = $process.ExitCode
                    Stderr = $stderrTask.GetAwaiter().GetResult()
                    Stdout = $stdoutTask.GetAwaiter().GetResult()
                }
            }
            finally {
                if ($null -ne $process) {
                    if (-not $process.HasExited) {
                        $process.Kill($true)
                        [void] $process.WaitForExit(5000)
                    }
                    $process.Dispose()
                }
            }
        }
    }

    It 'prints exactly one result line for N=<N>' -TestCases @(
        @{ N = 0; Operation = $null; Expected = 'Fibonacci(0) = 0' }
        @{ N = 1; Operation = $null; Expected = 'Fibonacci(1) = 1' }
        @{ N = 6; Operation = $null; Expected = 'Fibonacci(6) = 8' }
        @{ N = 0; Operation = 'fibonacci'; Expected = 'Fibonacci(0) = 0' }
        @{ N = 6; Operation = 'fibonacci'; Expected = 'Fibonacci(6) = 8' }
        @{ N = 0; Operation = 'factorial'; Expected = 'Factorial(0) = 1' }
        @{ N = 1; Operation = 'factorial'; Expected = 'Factorial(1) = 1' }
        @{ N = 5; Operation = 'factorial'; Expected = 'Factorial(5) = 120' }
    ) {
        $arguments = @('-N', $N.ToString())
        if ($Operation) {
            $arguments += @('-Operation', $Operation)
        }

        $result = & $invokeMathTool -Arguments $arguments
        $result.ExitCode | Should -Be 0
        $result.Stderr | Should -Be ''
        $stdoutLines = $result.Stdout -split '\r?\n'
        $stdoutLines.Count | Should -Be 2
        $stdoutLines[0] | Should -Be $Expected
        $stdoutLines[1] | Should -Be ''
    }

    It 'dispatches N=<N> to different results and labels per Operation' -TestCases @(
        @{ N = 6; FibonacciExpected = 'Fibonacci(6) = 8'; FactorialExpected = 'Factorial(6) = 720' }
    ) {
        $fibonacciResult = & $invokeMathTool -Arguments @('-N', $N.ToString(), '-Operation', 'fibonacci')
        $factorialResult = & $invokeMathTool -Arguments @('-N', $N.ToString(), '-Operation', 'factorial')

        $fibonacciResult.ExitCode | Should -Be 0
        $fibonacciResult.Stderr | Should -Be ''
        $factorialResult.ExitCode | Should -Be 0
        $factorialResult.Stderr | Should -Be ''
        $fibonacciLine = ($fibonacciResult.Stdout -split '\r?\n')[0]
        $factorialLine = ($factorialResult.Stdout -split '\r?\n')[0]

        $fibonacciLine | Should -Be $FibonacciExpected
        $factorialLine | Should -Be $FactorialExpected
        $fibonacciLine | Should -Not -Be $factorialLine
    }

    It 'preserves N as the first positional parameter' {
        $result = & $invokeMathTool -Arguments @('6')
        $result.ExitCode | Should -Be 0
        $result.Stderr | Should -Be ''
        $result.Stdout.TrimEnd("`r", "`n") | Should -Be 'Fibonacci(6) = 8'
    }
}
