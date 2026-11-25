# Test-DuplicateNamesApi.ps1 — duplicate deck-name guard proof (Sprint 2)
# Sebastian's decision (Nov 25): deck names must be unique — service-level
# check on create AND rename, trimmed and case-insensitive, no DB constraint yet.
# Expected behaviour (from the audit): duplicate create -> 400 with
# "already exists" in the ProblemDetail detail; case-variant duplicate -> 400;
# renaming deck B onto deck A's name -> 400; renaming a deck to its own name
# in different case -> succeeds. Run this BEFORE implementing the guard and it
# should fail (red test); implement the guard, re-run, and it goes green.
# Backend must be running on http://localhost:8081

$base = "http://localhost:8081/api"
$pass = 0; $fail = 0
function Check($name, $condition) {
    if ($condition) { $script:pass++; Write-Host "PASS  $name" -ForegroundColor Green }
    else { $script:fail++; Write-Host "FAIL  $name" -ForegroundColor Red }
}

# Calls the API and returns @{ Status; Body } — never throws on 4xx/5xx, and
# reads the ERROR body too (the detail sentence is what several checks assert).
# Works in PowerShell 5.1 and 7.
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

# Setup: deck A, the name everything else collides with
$deckA = Call POST "$base/decks" @{ name = "Duplicate Guard A"; format = "COMMANDER" }
$deckAId = $deckA.Body.id
Check "setup deck A created" ($null -ne $deckAId)

# 1. Exact duplicate create -> 400, and the detail says why
$r = Call POST "$base/decks" @{ name = "Duplicate Guard A"; format = "COMMANDER" }
Check "duplicate create -> 400" ($r.Status -eq 400)
Check "400 detail says already exists" ($r.Body.detail -like "*already exists*")

# 2. Case-variant duplicate create -> 400 (trimmed, case-insensitive comparison)
$r = Call POST "$base/decks" @{ name = "duplicate guard a"; format = "STANDARD" }
Check "case-variant duplicate create -> 400" ($r.Status -eq 400)

# 3. Whitespace-padded duplicate create -> 400 (trim happens before the check)
$r = Call POST "$base/decks" @{ name = "  Duplicate Guard A  "; format = "PAUPER" }
Check "whitespace-padded duplicate create -> 400" ($r.Status -eq 400)

# 4. No extra deck was created by the three rejected attempts
$all = Call GET "$base/decks"
$matching = @($all.Body | Where-Object { $_.name -eq "Duplicate Guard A" })
Check "still exactly one deck with that name" ($matching.Count -eq 1)

# Setup: deck B, for the rename checks
$deckB = Call POST "$base/decks" @{ name = "Duplicate Guard B"; format = "COMMANDER" }
$deckBId = $deckB.Body.id
Check "setup deck B created" ($null -ne $deckBId)

# 5. Renaming B onto A's name -> 400 (rename is the back door)
$r = Call PATCH "$base/decks/$deckBId" @{ name = "Duplicate Guard A" }
Check "rename B onto A's name -> 400" ($r.Status -eq 400)

# 6. Renaming B onto A's name in different case -> 400
$r = Call PATCH "$base/decks/$deckBId" @{ name = "DUPLICATE GUARD A" }
Check "rename B onto A's name, different case -> 400" ($r.Status -eq 400)

# 7. Renaming A to its own name in different case -> succeeds (the AndIdNot clause)
$r = Call PATCH "$base/decks/$deckAId" @{ name = "duplicate guard a" }
Check "rename A to its own name, re-cased -> 200" ($r.Status -eq 200)

# Cleanup
Call DELETE "$base/decks/$deckAId" | Out-Null
Call DELETE "$base/decks/$deckBId" | Out-Null
Write-Host "`n$pass passed, $fail failed"
