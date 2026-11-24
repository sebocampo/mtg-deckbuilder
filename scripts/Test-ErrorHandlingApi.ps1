# Test-ErrorHandlingApi.ps1 — centralised error handling proof (Sprint 2)
# The other suites assert STATUS codes; this one asserts the error BODY —
# the whole point of CartasExceptionHandler (@RestControllerAdvice) is that
# every error leaves in the same ProblemDetail shape, and validation errors
# name the field that failed.
# Backend must be running on http://localhost:8081

$base = "http://localhost:8081/api"
$pass = 0; $fail = 0
function Check($name, $condition) {
    if ($condition) { $script:pass++; Write-Host "PASS  $name" -ForegroundColor Green }
    else { $script:fail++; Write-Host "FAIL  $name" -ForegroundColor Red }
}

# Calls the API and returns @{ Status; Body } — never throws on 4xx/5xx, and
# unlike the deck suite's helper it reads the ERROR body too (that body is
# what this suite exists to check). Works in PowerShell 5.1 and 7.
function Call($method, $url, $body) {
    try {
        $params = @{ Method = $method; Uri = $url; ContentType = "application/json" }
        if ($null -ne $body) { $params.Body = ($body | ConvertTo-Json) }
        $r = Invoke-WebRequest @params -UseBasicParsing
        $parsed = $null
        if ($r.Content) { $parsed = $r.Content | ConvertFrom-Json }
        return @{ Status = [int]$r.StatusCode; Body = $parsed }
    } catch {
        $status = [int]$_.Exception.Response.StatusCode
        $content = $_.ErrorDetails.Message
        if (-not $content -and $_.Exception.Response) {
            try {
                $stream = $_.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($stream)
                $content = $reader.ReadToEnd()
            } catch {}
        }
        $parsed = $null
        if ($content) { try { $parsed = $content | ConvertFrom-Json } catch {} }
        return @{ Status = $status; Body = $parsed }
    }
}

# Setup: a real deck for the commander checks
$deck = Call POST "$base/decks" @{ name = "Error Handling Test Deck" }
$deckId = $deck.Body.id
Check "setup deck created" ($null -ne $deckId)

# 1. Missing deck -> 404 in ProblemDetail shape
$missingId = [guid]::NewGuid()
$r = Call GET "$base/decks/$missingId"
Check "GET missing deck -> 404" ($r.Status -eq 404)
Check "404 body carries status 404" ($r.Body.status -eq 404)
Check "404 body has a detail message" (-not [string]::IsNullOrWhiteSpace($r.Body.detail))

# 2. Blank name -> 400, and the detail names the field
$r = Call POST "$base/decks" @{ name = "" }
Check "POST blank name -> 400" ($r.Status -eq 400)
Check "400 detail names the field (name)" ($r.Body.detail -like "*name*")

# 3. Commander with no id -> 400, detail names commanderScryfallId
$r = Call PUT "$base/decks/$deckId/commander" @{}
Check "PUT commander with empty body -> 400" ($r.Status -eq 400)
Check "400 detail names the field (commanderScryfallId)" ($r.Body.detail -like "*commanderScryfallId*")

# 4. The advice did not swallow ResponseStatusException: an unknown printing
#    still gets the service's own 400
$r = Call PUT "$base/decks/$deckId/commander" @{ commanderScryfallId = [guid]::NewGuid() }
Check "PUT unknown commander printing -> 400 (guard untouched)" ($r.Status -eq 400)

# Cleanup
Call DELETE "$base/decks/$deckId" | Out-Null
Write-Host "`n$pass passed, $fail failed"
