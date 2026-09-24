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

Describe 'math-tool.ps1 CLI' {
    BeforeAll {
        $mathToolPath = Join-Path $PSScriptRoot 'math-tool.ps1'
        $powerShellPath = (Get-Command pwsh -CommandType Application | Select-Object -First 1).Source
    }

    It 'prints exactly one result line for N=<N>' -TestCases @(
        @{ N = 0; Expected = 'Fibonacci(0) = 0' }
        @{ N = 1; Expected = 'Fibonacci(1) = 1' }
        @{ N = 6; Expected = 'Fibonacci(6) = 8' }
    ) {
        $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
        $startInfo.FileName = $powerShellPath
        $startInfo.UseShellExecute = $false
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true
        foreach ($argument in @('-NoLogo', '-NoProfile', '-File', $mathToolPath, '-N', $N)) {
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
}
