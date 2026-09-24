[CmdletBinding(PositionalBinding = $false)]
param(
    [Parameter(Position = 0)]
    [ValidateRange(0, [int]::MaxValue)]
    [int] $N = 0,

    [ValidateSet('fibonacci', 'factorial')]
    [string] $Operation = 'fibonacci'
)

function Get-Fibonacci {
    <#
    .SYNOPSIS
    Returns the nth Fibonacci number.

    .PARAMETER N
    A non-negative integer index into the Fibonacci sequence.

    .OUTPUTS
    System.Numerics.BigInteger
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(0, [int]::MaxValue)]
        [int] $N
    )

    if ($N -lt 2) {
        return [System.Numerics.BigInteger] $N
    }

    $previous = [System.Numerics.BigInteger] 0
    $current = [System.Numerics.BigInteger] 1
    for ($i = 2; $i -le $N; $i++) {
        $next = $previous + $current
        $previous = $current
        $current = $next
    }

    return $current
}

function Get-Factorial {
    <#
    .SYNOPSIS
    Returns the factorial of N.

    .PARAMETER N
    A non-negative integer. By definition, 0! and 1! both return 1.

    .OUTPUTS
    System.Numerics.BigInteger
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(0, [int]::MaxValue)]
        [int] $N
    )

    $result = [System.Numerics.BigInteger] 1
    for ($i = 2; $i -le $N; $i++) {
        $result *= $i
    }

    return $result
}

$isDotSourced = $MyInvocation.InvocationName -eq '.'
if (-not $isDotSourced) {
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    switch ($Operation) {
        'fibonacci' {
            $value = Get-Fibonacci -N $N
            Write-Output "Fibonacci($N) = $value"
        }
        'factorial' {
            $value = Get-Factorial -N $N
            Write-Output "Factorial($N) = $value"
        }
        default {
            throw "Unsupported Operation: $Operation"
        }
    }
}
