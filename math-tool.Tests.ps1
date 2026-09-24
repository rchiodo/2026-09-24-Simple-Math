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
        $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
        $startInfo.FileName = $powerShellPath
        $startInfo.UseShellExecute = $false
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true
        $arguments = @('-NoLogo', '-NoProfile', '-File', $mathToolPath, '-N', $N.ToString())
        if ($Operation) {
            $arguments += @('-Operation', $Operation)
        }
        foreach ($argument in $arguments) {
            [void] $startInfo.ArgumentList.Add($argument)
        }

        $process = $null
        try {
            $process = [System.Diagnostics.Process]::Start($startInfo)
            $stdoutTask = $process.StandardOutput.ReadToEndAsync()
            $stderrTask = $process.StandardError.ReadToEndAsync()
            $process.WaitForExit()
            $stdout = $stdoutTask.GetAwaiter().GetResult()
            $stderr = $stderrTask.GetAwaiter().GetResult()

            $process.ExitCode | Should -Be 0
            $stderr | Should -Be ''
            $stdoutLines = $stdout -split '\r?\n'
            $stdoutLines.Count | Should -Be 2
            $stdoutLines[0] | Should -Be $Expected
            $stdoutLines[1] | Should -Be ''
        }
        finally {
            if ($null -ne $process) {
                $process.Dispose()
            }
        }
    }

    It 'dispatches N=<N> to different results and labels per Operation' -TestCases @(
        @{ N = 6; FibonacciExpected = 'Fibonacci(6) = 8'; FactorialExpected = 'Factorial(6) = 720' }
    ) {
        $runMathTool = {
            param($operation)

            $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
            $startInfo.FileName = $powerShellPath
            $startInfo.UseShellExecute = $false
            $startInfo.RedirectStandardOutput = $true
            $startInfo.RedirectStandardError = $true
            foreach ($argument in @('-NoLogo', '-NoProfile', '-File', $mathToolPath, '-N', $N.ToString(), '-Operation', $operation)) {
                [void] $startInfo.ArgumentList.Add($argument)
            }

            $process = $null
            try {
                $process = [System.Diagnostics.Process]::Start($startInfo)
                $stdoutTask = $process.StandardOutput.ReadToEndAsync()
                $process.WaitForExit()
                $stdout = $stdoutTask.GetAwaiter().GetResult()
                $process.ExitCode | Should -Be 0
                return ($stdout -split '\r?\n')[0]
            }
            finally {
                if ($null -ne $process) {
                    $process.Dispose()
                }
            }
        }

        $fibonacciLine = & $runMathTool 'fibonacci'
        $factorialLine = & $runMathTool 'factorial'

        $fibonacciLine | Should -Be $FibonacciExpected
        $factorialLine | Should -Be $FactorialExpected
        $fibonacciLine | Should -Not -Be $factorialLine
    }

    It 'preserves N as the first positional parameter' {
        $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
        $startInfo.FileName = $powerShellPath
        $startInfo.UseShellExecute = $false
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true
        foreach ($argument in @('-NoLogo', '-NoProfile', '-File', $mathToolPath, '6')) {
            [void] $startInfo.ArgumentList.Add($argument)
        }

        $process = $null
        try {
            $process = [System.Diagnostics.Process]::Start($startInfo)
            $stdoutTask = $process.StandardOutput.ReadToEndAsync()
            $stderrTask = $process.StandardError.ReadToEndAsync()
            $process.WaitForExit()
            $stdout = $stdoutTask.GetAwaiter().GetResult()
            $stderr = $stderrTask.GetAwaiter().GetResult()

            $process.ExitCode | Should -Be 0
            $stderr | Should -Be ''
            $stdout.TrimEnd("`r", "`n") | Should -Be 'Fibonacci(6) = 8'
        }
        finally {
            if ($null -ne $process) {
                $process.Dispose()
            }
        }
    }
}
