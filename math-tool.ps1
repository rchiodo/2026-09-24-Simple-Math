[CmdletBinding()]
param(
    [ValidateRange(0, [int]::MaxValue)]
    [int] $N = 0
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

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

$isDotSourced = $MyInvocation.InvocationName -eq '.' -or $MyInvocation.Line -match '^\s*\.\s+'
if (-not $isDotSourced) {
    $value = Get-Fibonacci -N $N
    Write-Output "Fibonacci($N) = $value"
}
