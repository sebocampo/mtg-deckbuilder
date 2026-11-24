# Run-AllTests.ps1 - runs every Test-*.ps1 suite in this folder and rolls up the results.
# Each suite runs in its own PowerShell process, so no state leaks between suites.
# Drop this file in the same folder as the suites (scripts/). Any future
# Test-*.ps1 file is picked up automatically. This file is not named Test-*,
# so it never tries to run itself.

$folder = $PSScriptRoot
if (-not $folder) { $folder = Split-Path -Parent $MyInvocation.MyCommand.Path }

# Fail fast with a clear message if the backend is not up.
try {
    Invoke-RestMethod -Uri "http://localhost:8081/actuator/health" -TimeoutSec 3 | Out-Null
} catch {
    Write-Host "Backend is not responding on http://localhost:8081 - start it first (docker compose up -d, then .\mvnw.cmd spring-boot:run)." -ForegroundColor Red
    exit 1
}

$suites = Get-ChildItem -Path $folder -Filter "Test-*.ps1" | Sort-Object Name
if ($suites.Count -eq 0) {
    Write-Host "No Test-*.ps1 suites found in $folder" -ForegroundColor Red
    exit 1
}

$totalPass = 0
$totalFail = 0
$results = @()

foreach ($suite in $suites) {
    Write-Host ""
    Write-Host "===== $($suite.Name) =====" -ForegroundColor Cyan
    $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $suite.FullName 2>&1
    $output | ForEach-Object { Write-Host $_ }

    $summary = $output | Select-String -Pattern "(\d+) passed, (\d+) failed" | Select-Object -Last 1
    if ($summary) {
        $p = [int]$summary.Matches[0].Groups[1].Value
        $f = [int]$summary.Matches[0].Groups[2].Value
        $totalPass += $p
        $totalFail += $f
        $status = if ($f -eq 0) { "PASS" } else { "FAIL" }
    } else {
        $status = "ERROR (no summary - did it crash?)"
        $totalFail += 1
    }
    $results += [PSCustomObject]@{ Suite = $suite.Name; Result = $status }
}

Write-Host ""
Write-Host "===== SUMMARY =====" -ForegroundColor Cyan
$results | ForEach-Object {
    $color = if ($_.Result -eq "PASS") { "Green" } else { "Red" }
    Write-Host ("{0,-35} {1}" -f $_.Suite, $_.Result) -ForegroundColor $color
}
Write-Host ""
Write-Host "Total checks: $totalPass passed, $totalFail failed"
if ($totalFail -gt 0) { exit 1 } else { exit 0 }
